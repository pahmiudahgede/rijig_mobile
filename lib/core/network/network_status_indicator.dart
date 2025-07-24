import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rijig_mobile/core/network/network_service.dart';

class NetworkStatusIndicator extends StatefulWidget {
  final Widget child;
  final bool showIndicator;
  final bool showOnlyWhenDisconnected;

  const NetworkStatusIndicator({
    super.key,
    required this.child,
    this.showIndicator = true,
    this.showOnlyWhenDisconnected = true,
  });

  @override
  State<NetworkStatusIndicator> createState() => _NetworkStatusIndicatorState();
}

class _NetworkStatusIndicatorState extends State<NetworkStatusIndicator> {
  final NetworkService _networkService = NetworkService();
  StreamSubscription<NetworkStatus>? _statusSubscription;
  StreamSubscription<NetworkQuality>? _qualitySubscription;
  
  NetworkStatus _currentStatus = NetworkStatus.connected;

  @override
  void initState() {
    super.initState();
    _initializeStatusListener();
  }

  void _initializeStatusListener() {
    _currentStatus = _networkService.currentStatus;
    
    _statusSubscription = _networkService.networkStatusStream.listen(
      (status) {
        if (mounted) {
          setState(() {
            _currentStatus = status;
          });
        }
      },
    );

    _qualitySubscription = _networkService.networkQualityStream.listen(
      (quality) {
        if (mounted) {
          setState(() {
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _qualitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shouldShowIndicator = widget.showIndicator && 
        (!widget.showOnlyWhenDisconnected || 
         _currentStatus != NetworkStatus.connected);

    return Stack(
      children: [
        widget.child,
        if (shouldShowIndicator)
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              color: _getStatusColor(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getStatusIcon(),
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getStatusText(),
                    style: const TextStyle(
                      color: Colors.white,
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