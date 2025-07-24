import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

enum NetworkStatus { connected, disconnected, checking, poor }

enum NetworkQuality { excellent, good, fair, poor, none }

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<NetworkStatus> _statusController =
      StreamController<NetworkStatus>.broadcast();
  final StreamController<NetworkQuality> _qualityController =
      StreamController<NetworkQuality>.broadcast();

  NetworkStatus _currentStatus = NetworkStatus.checking;
  NetworkQuality _currentQuality = NetworkQuality.none;

  Timer? _qualityTimer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isInitialized = false;

  static const int _timeoutSeconds = 10;
  static const Duration _qualityCheckInterval = Duration(minutes: 2);
  static const List<String> _testHosts = [
    'google.com',
    'cloudflare.com',
    '8.8.8.8',
  ];

  Stream<NetworkStatus> get networkStatusStream => _statusController.stream;
  Stream<NetworkQuality> get networkQualityStream => _qualityController.stream;
  NetworkStatus get currentStatus => _currentStatus;
  NetworkQuality get currentQuality => _currentQuality;
  bool get isConnected => _currentStatus == NetworkStatus.connected;

  Future<void> initialize() async {
    if (_isInitialized) return;

    _isInitialized = true;
    await _performInitialCheck();
    _startConnectivityListener();
    _startQualityMonitoring();
  }

  Future<void> _performInitialCheck() async {
    await checkConnection();
  }

  void _startConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _handleConnectivityChange,
      onError: (error) {
        debugPrint('Connectivity listener error: $error');
      },
    );
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none) || results.isEmpty) {
      _updateStatus(NetworkStatus.disconnected);
      _updateQuality(NetworkQuality.none);
    } else {
      Timer(const Duration(milliseconds: 500), () async {
        await checkConnection();
      });
    }
  }

  Future<bool> checkConnection({int timeoutSeconds = _timeoutSeconds}) async {
    _updateStatus(NetworkStatus.checking);

    try {
      final connectivityResults = await _connectivity.checkConnectivity();

      if (connectivityResults.contains(ConnectivityResult.none) ||
          connectivityResults.isEmpty) {
        _updateStatus(NetworkStatus.disconnected);
        _updateQuality(NetworkQuality.none);
        return false;
      }

      final bool canReachInternet = await _canReachInternet(timeoutSeconds);

      if (canReachInternet) {
        _updateStatus(NetworkStatus.connected);
        await _checkNetworkQuality();
        return true;
      } else {
        _updateStatus(NetworkStatus.disconnected);
        _updateQuality(NetworkQuality.none);
        return false;
      }
    } catch (e) {
      debugPrint('Network check error: $e');
      _updateStatus(NetworkStatus.disconnected);
      _updateQuality(NetworkQuality.none);
      return false;
    }
  }

  Future<bool> _canReachInternet(int timeoutSeconds) async {
    for (final host in _testHosts) {
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
    if (_currentStatus != NetworkStatus.connected) return;

    try {
      final stopwatch = Stopwatch()..start();

      await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 5));

      stopwatch.stop();
      final responseTime = stopwatch.elapsedMilliseconds;

      final quality = _calculateQuality(responseTime);
      _updateQuality(quality);

      if (quality == NetworkQuality.poor) {
        _updateStatus(NetworkStatus.poor);
      }
    } catch (e) {
      debugPrint('Network quality check error: $e');
      _updateQuality(NetworkQuality.none);
    }
  }

  NetworkQuality _calculateQuality(int responseTime) {
    if (responseTime < 200) {
      return NetworkQuality.excellent;
    } else if (responseTime < 500) {
      return NetworkQuality.good;
    } else if (responseTime < 1000) {
      return NetworkQuality.fair;
    } else {
      return NetworkQuality.poor;
    }
  }

  void _startQualityMonitoring() {
    _qualityTimer = Timer.periodic(_qualityCheckInterval, (_) async {
      if (_currentStatus == NetworkStatus.connected) {
        await _checkNetworkQuality();
      }
    });
  }

  void _updateStatus(NetworkStatus status) {
    if (_currentStatus != status) {
      _currentStatus = status;
      _statusController.add(status);
      debugPrint('Network status changed to: $status');
    }
  }

  void _updateQuality(NetworkQuality quality) {
    if (_currentQuality != quality) {
      _currentQuality = quality;
      _qualityController.add(quality);
      debugPrint('Network quality changed to: $quality');
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
    _qualityTimer?.cancel();
    _connectivitySubscription?.cancel();
    _statusController.close();
    _qualityController.close();
  }
}
