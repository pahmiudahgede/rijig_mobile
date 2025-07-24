import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rijig_mobile/core/api/api_exception.dart';
import 'package:rijig_mobile/core/network/network_service.dart';
import 'package:rijig_mobile/core/network/network_dialog_manager.dart';

mixin NetworkAwareMixin<T extends StatefulWidget> on State<T> {
  final NetworkService _networkService = NetworkService();
  StreamSubscription<NetworkStatus>? _networkSubscription;
  bool _hasShownNetworkDialog = false;

  @override
  void initState() {
    super.initState();
    _initializeNetworkListener();
  }

  void _initializeNetworkListener() {
    _networkSubscription = _networkService.networkStatusStream.listen(
      _handleNetworkStatusChange,
      onError: (error) {
        debugPrint('Network listener error: $error');
      },
    );
  }

  void _handleNetworkStatusChange(NetworkStatus status) {
    if (!mounted) return;

    switch (status) {
      case NetworkStatus.disconnected:
        if (!_hasShownNetworkDialog) {
          _showNetworkErrorDialog();
        }
        onNetworkDisconnected();
        break;
      case NetworkStatus.connected:
        if (_hasShownNetworkDialog) {
          _dismissNetworkDialog();
        }
        onNetworkConnected();
        break;
      case NetworkStatus.checking:
        onNetworkChecking();
        break;
      case NetworkStatus.poor:
        onNetworkPoor();
        break;
    }
  }

  void onNetworkConnected() {}
  void onNetworkDisconnected() {}
  void onNetworkChecking() {}
  void onNetworkPoor() {}

  Future<R> performNetworkOperation<R>(
    Future<R> Function() operation, {
    bool showLoadingDialog = true,
    String? loadingMessage,
    bool handleErrors = true,
  }) async {
    if (showLoadingDialog) {
      NetworkDialogManager.showLoadingDialog(
        context,
        loadingMessage ?? 'Loading...',
      );
    }

    try {
      final result = await operation();

      if (showLoadingDialog && mounted) {
        Navigator.of(context).pop();
      }

      return result;
    } catch (e) {
      if (showLoadingDialog && mounted) {
        Navigator.of(context).pop();
      }

      if (handleErrors) {
        await _handleNetworkError(e);
      }

      rethrow;
    }
  }

  Future<void> _handleNetworkError(dynamic error) async {
    if (error is NetworkException) {
      switch (error.type) {
        case NetworkErrorType.noConnection:
          _showNetworkErrorDialog();
          break;
        case NetworkErrorType.timeout:
          NetworkDialogManager.showTimeoutDialog(context);
          break;
        case NetworkErrorType.connectionFailed:
          NetworkDialogManager.showConnectionFailedDialog(context);
          break;
        case NetworkErrorType.poor:
          NetworkDialogManager.showPoorConnectionDialog(context);
          break;
      }
    } else if (error is ApiException) {
      NetworkDialogManager.showApiErrorDialog(context, error.message);
    }
  }

  void _showNetworkErrorDialog() {
    if (_hasShownNetworkDialog) return;

    _hasShownNetworkDialog = true;
    NetworkDialogManager.showNoInternetDialog(
      context: context,
      onRetry: () async {
        Navigator.of(context).pop();
        _hasShownNetworkDialog = false;
        await _networkService.checkConnection();
      },
      onExit: () {
        SystemNavigator.pop();
      },
    );
  }

  void _dismissNetworkDialog() {
    if (_hasShownNetworkDialog && mounted) {
      Navigator.of(context).pop();
      _hasShownNetworkDialog = false;
    }
  }

  @override
  void dispose() {
    _networkSubscription?.cancel();
    super.dispose();
  }
}
