import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

enum NetworkStatus { connected, disconnected, checking, poor }

enum NetworkQuality { excellent, good, fair, poor, none }

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  NetworkService._internal();
  factory NetworkService() => _instance;

  final Connectivity _connectivity = Connectivity();
  final StreamController<NetworkStatus> _networkStatusController =
      StreamController<NetworkStatus>.broadcast();

  NetworkStatus _currentStatus = NetworkStatus.checking;
  NetworkQuality _currentQuality = NetworkQuality.none;
  Timer? _connectionTimer;
  Timer? _qualityTimer;
  bool _isInitialized = false;

  Stream<NetworkStatus> get networkStatusStream =>
      _networkStatusController.stream;
  NetworkStatus get currentStatus => _currentStatus;
  NetworkQuality get currentQuality => _currentQuality;
  bool get isConnected => _currentStatus == NetworkStatus.connected;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    await _checkConnection();
    _connectivity.onConnectivityChanged.listen(_handleConnectivityChange);
    _startQualityMonitoring();
  }

  Future<bool> checkConnection({int timeoutSeconds = 10}) async {
    _updateStatus(NetworkStatus.checking);

    try {
      final connectivityResult = await _connectivity.checkConnectivity();

      if (connectivityResult.contains(ConnectivityResult.none) ||
          connectivityResult.isEmpty) {
        _updateStatus(NetworkStatus.disconnected);
        return false;
      }

      final bool canReachInternet = await _canReachInternet(timeoutSeconds);

      if (canReachInternet) {
        _updateStatus(NetworkStatus.connected);
        await _checkNetworkQuality();
        return true;
      } else {
        _updateStatus(NetworkStatus.disconnected);
        return false;
      }
    } catch (e) {
      debugPrint('Network check error: $e');
      _updateStatus(NetworkStatus.disconnected);
      return false;
    }
  }

  Future<void> _checkConnection() async {
    await checkConnection();
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none) || results.isEmpty) {
      _updateStatus(NetworkStatus.disconnected);
      _currentQuality = NetworkQuality.none;
    } else {
      Timer(const Duration(seconds: 1), () async {
        await _checkConnection();
      });
    }
  }

  Future<bool> _canReachInternet(int timeoutSeconds) async {
    final List<String> testHosts = ['google.com', 'cloudflare.com', '8.8.8.8'];

    for (String host in testHosts) {
      try {
        final result = await InternetAddress.lookup(
          host,
        ).timeout(Duration(seconds: timeoutSeconds));
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          return true;
        }
      } catch (e) {
        debugPrint('Failed to reach $host: $e');
        continue;
      }
    }
    return false;
  }

  Future<void> _checkNetworkQuality() async {
    try {
      final stopwatch = Stopwatch()..start();

      await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 5));

      stopwatch.stop();
      final responseTime = stopwatch.elapsedMilliseconds;

      if (responseTime < 200) {
        _currentQuality = NetworkQuality.excellent;
      } else if (responseTime < 500) {
        _currentQuality = NetworkQuality.good;
      } else if (responseTime < 1000) {
        _currentQuality = NetworkQuality.fair;
      } else {
        _currentQuality = NetworkQuality.poor;
      }
    } catch (e) {
      _currentQuality = NetworkQuality.none;
    }
  }

  void _startQualityMonitoring() {
    _qualityTimer = Timer.periodic(const Duration(minutes: 2), (_) async {
      if (_currentStatus == NetworkStatus.connected) {
        await _checkNetworkQuality();
      }
    });
  }

  void _updateStatus(NetworkStatus status) {
    if (_currentStatus != status) {
      _currentStatus = status;
      _networkStatusController.add(status);
      debugPrint('Network status changed to: $status');
    }
  }

  Duration getTimeoutDuration() {
    switch (_currentQuality) {
      case NetworkQuality.excellent:
        return const Duration(seconds: 10);
      case NetworkQuality.good:
        return const Duration(seconds: 15);
      case NetworkQuality.fair:
        return const Duration(seconds: 20);
      case NetworkQuality.poor:
        return const Duration(seconds: 30);
      case NetworkQuality.none:
        return const Duration(seconds: 10);
    }
  }

  void dispose() {
    _connectionTimer?.cancel();
    _qualityTimer?.cancel();
    _networkStatusController.close();
  }
}
