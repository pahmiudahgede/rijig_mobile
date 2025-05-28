// ignore_for_file: avoid_shadowing_type_parameters
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rijig_mobile/core/api/api_services.dart';
import 'package:rijig_mobile/core/router.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/widget/showmodal.dart';

import 'network_service.dart';

abstract class NetworkAwareWidget extends StatefulWidget {
  const NetworkAwareWidget({super.key});
}

abstract class NetworkAwareState<T extends NetworkAwareWidget>
    extends State<T> {
  final NetworkService _networkService = NetworkService();
  StreamSubscription<NetworkStatus>? _networkSubscription;
  bool _hasShownNetworkDialog = false;

  @override
  void initState() {
    super.initState();
    _initNetworkListener();
  }

  void _initNetworkListener() {
    _networkSubscription = _networkService.networkStatusStream.listen((status) {
      if (mounted) {
        _handleNetworkStatusChange(status);
      }
    });
  }

  void _handleNetworkStatusChange(NetworkStatus status) {
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

  Future<T> performNetworkOperation<T>(
    Future<T> Function() operation, {
    bool showLoadingDialog = true,
    String? loadingMessage,
  }) async {
    if (showLoadingDialog) {
      _showLoadingDialog(loadingMessage ?? 'Loading...');
    }

    try {
      final result = await operation();
      if (showLoadingDialog && mounted) {
        router.pop(context);
      }
      return result;
    } catch (e) {
      if (showLoadingDialog && mounted) {
        router.pop(context);
      }
      _handleNetworkException(e);
      rethrow;
    } finally {
      if (showLoadingDialog && mounted) {
        router.pop(context);
      }
    }
  }

  void _handleNetworkException(e) {
    switch (e.type) {
      case NetworkErrorType.noConnection:
        _showNetworkErrorDialog();
        break;
      case NetworkErrorType.timeout:
        _showTimeoutDialog();
        break;
      case NetworkErrorType.connectionFailed:
        _showConnectionFailedDialog();
        break;
      case NetworkErrorType.poor:
        _showPoorConnectionDialog();
        break;
    }
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoadingDialog(message: message),
    );
  }

  void _showNetworkErrorDialog() {
    _hasShownNetworkDialog = true;
    NetworkDialogManager.showNoInternetDialog(
      context: context,
      onRetry: () async {
        router.pop(context);
        _hasShownNetworkDialog = false;
        await _networkService.checkConnection();
      },
      onExit: () {
        SystemNavigator.pop();
      },
    );
  }

  void _showTimeoutDialog() {
    NetworkDialogManager.showTimeoutDialog(
      context: context,
      onRetry: () {
        router.pop(context);
      },
    );
  }

  void _showConnectionFailedDialog() {
    NetworkDialogManager.showConnectionFailedDialog(
      context: context,
      onRetry: () {
        router.pop(context);
      },
    );
  }

  void _showPoorConnectionDialog() {
    NetworkDialogManager.showPoorConnectionDialog(
      context: context,
      onContinue: () {
        router.pop(context);
      },
    );
  }

  void _dismissNetworkDialog() {
    if (_hasShownNetworkDialog && mounted) {
      router.pop(context);
      _hasShownNetworkDialog = false;
    }
  }

  @override
  void dispose() {
    _networkSubscription?.cancel();
    super.dispose();
  }
}

class NetworkDialogManager {
  static void showNoInternetDialog({
    required BuildContext context,
    required VoidCallback onRetry,
    required VoidCallback onExit,
  }) {
    CustomModalDialog.show(
      context: context,
      showCloseIcon: false,
      variant: ModalVariant.imageVersion,
      title: 'Tidak Ada Koneksi Internet',
      content:
          'Sepertinya koneksi internet Anda bermasalah. Periksa koneksi WiFi atau data seluler Anda, lalu coba lagi.',
      imageAsset: 'assets/image/bad_connection.png',
      buttonCount: 2,
      button1: ElevatedButton(
        onPressed: onRetry,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('Coba Lagi'),
      ),
      button2: OutlinedButton(
        onPressed: onExit,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('Keluar'),
      ),
    );
  }

  static void showTimeoutDialog({
    required BuildContext context,
    required VoidCallback onRetry,
  }) {
    CustomModalDialog.show(
      context: context,
      showCloseIcon: false,
      variant: ModalVariant.imageVersion,
      title: 'Koneksi Timeout',
      content:
          'Permintaan memakan waktu terlalu lama. Periksa koneksi internet Anda dan coba lagi.',
      imageAsset: 'assets/images/timeout.png', // Ganti dengan path gambar Anda
      buttonCount: 2,
      button1: ElevatedButton(
        onPressed: onRetry,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('Coba Lagi'),
      ),
      button2: OutlinedButton(
        onPressed: () => Navigator.of(context).pop(),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('Tutup'),
      ),
    );
  }

  static void showConnectionFailedDialog({
    required BuildContext context,
    required VoidCallback onRetry,
  }) {
    CustomModalDialog.show(
      context: context,
      showCloseIcon: false,
      variant: ModalVariant.imageVersion,
      title: 'Koneksi Gagal',
      content:
          'Tidak dapat terhubung ke server. Pastikan koneksi internet Anda stabil.',
      imageAsset:
          'assets/images/connection_failed.png', // Ganti dengan path gambar Anda
      buttonCount: 2,
      button1: ElevatedButton(
        onPressed: onRetry,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('Coba Lagi'),
      ),
      button2: OutlinedButton(
        onPressed: () => Navigator.of(context).pop(),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('Tutup'),
      ),
    );
  }

  static void showPoorConnectionDialog({
    required BuildContext context,
    required VoidCallback onContinue,
  }) {
    CustomModalDialog.show(
      context: context,
      showCloseIcon: false,
      variant: ModalVariant.imageVersion,
      title: 'Koneksi Lambat',
      content:
          'Koneksi internet Anda lambat. Beberapa fitur mungkin tidak berfungsi optimal.',
      imageAsset:
          'assets/images/poor_connection.png',
      buttonCount: 2,
      button1: ElevatedButton(
        onPressed: onContinue,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('Lanjutkan'),
      ),
      button2: OutlinedButton(
        onPressed: () => Navigator.of(context).pop(),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('Tutup'),
      ),
    );
  }
}

// void _showLoadingDialog(String message) {
//   CustomModalDialog.show(
//     context: context,
//     variant: ModalVariant.imageVersion,
//     title: 'Memuat',
//     content: message,
//     imageAsset: 'assets/images/loading.png', // Ganti dengan path gambar loading Anda
//     buttonCount: 0, // Tidak ada button untuk loading dialog
//   );
// }

class NetworkErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData iconData;
  final String primaryButtonText;
  final VoidCallback onPrimaryPressed;
  final String secondaryButtonText;
  final VoidCallback onSecondaryPressed;

  const NetworkErrorDialog({
    super.key,
    required this.title,
    required this.message,
    required this.iconData,
    required this.primaryButtonText,
    required this.onPrimaryPressed,
    required this.secondaryButtonText,
    required this.onSecondaryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, size: 48, color: Colors.red.shade400),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onSecondaryPressed,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(secondaryButtonText),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onPrimaryPressed,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(primaryButtonText),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LoadingDialog extends StatelessWidget {
  final String message;

  const LoadingDialog({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class NetworkStatusIndicator extends StatefulWidget {
  final Widget child;
  final bool showIndicator;

  const NetworkStatusIndicator({
    super.key,
    required this.child,
    this.showIndicator = true,
  });

  @override
  State<NetworkStatusIndicator> createState() => _NetworkStatusIndicatorState();
}

class _NetworkStatusIndicatorState extends State<NetworkStatusIndicator> {
  final NetworkService _networkService = NetworkService();
  StreamSubscription<NetworkStatus>? _subscription;
  NetworkStatus _currentStatus = NetworkStatus.connected;

  @override
  void initState() {
    super.initState();
    _currentStatus = _networkService.currentStatus;
    _subscription = _networkService.networkStatusStream.listen((status) {
      if (mounted) {
        setState(() {
          _currentStatus = status;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.showIndicator && _currentStatus != NetworkStatus.connected)
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: _getStatusColor(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_getStatusIcon(), size: 16, color: whiteColor),
                  const SizedBox(width: 8),
                  Text(
                    _getStatusText(),
                    style: TextStyle(
                      color: whiteColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (_currentStatus) {
      case NetworkStatus.disconnected:
        return Colors.red;
      case NetworkStatus.checking:
        return Colors.orange;
      case NetworkStatus.poor:
        return Colors.amber;
      case NetworkStatus.connected:
        return Colors.green;
    }
  }

  IconData _getStatusIcon() {
    switch (_currentStatus) {
      case NetworkStatus.disconnected:
        return Icons.wifi_off;
      case NetworkStatus.checking:
        return Icons.wifi_find;
      case NetworkStatus.poor:
        return Icons.signal_wifi_bad;
      case NetworkStatus.connected:
        return Icons.wifi;
    }
  }

  String _getStatusText() {
    switch (_currentStatus) {
      case NetworkStatus.disconnected:
        return 'Tidak ada koneksi internet';
      case NetworkStatus.checking:
        return 'Memeriksa koneksi...';
      case NetworkStatus.poor:
        return 'Koneksi lambat';
      case NetworkStatus.connected:
        return 'Terhubung';
    }
  }
}
