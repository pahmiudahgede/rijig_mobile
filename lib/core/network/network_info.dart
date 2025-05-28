// ignore_for_file: unrelated_type_equality_checks

import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:rijig_mobile/core/network/network_service.dart';
import 'package:rijig_mobile/core/utils/exportimportview.dart';

class NetworkInfo {
  Future<bool> checkConnection() async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }

      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 5));

      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (e) {
      debugPrint('Network check - Socket exception: $e');
      return false;
    } on TimeoutException catch (e) {
      debugPrint('Network check - Timeout: $e');
      return false;
    } catch (e) {
      debugPrint('Network check - General error: $e');
      return false;
    }
  }

  Future<NetworkQuality> checkNetworkQuality() async {
    final stopwatch = Stopwatch()..start();

    try {
      await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 3));
      stopwatch.stop();

      final responseTime = stopwatch.elapsedMilliseconds;

      if (responseTime < 1000) {
        return NetworkQuality.excellent;
      } else if (responseTime < 2000) {
        return NetworkQuality.good;
      } else if (responseTime < 3000) {
        return NetworkQuality.fair;
      } else {
        return NetworkQuality.poor;
      }
    } catch (e) {
      return NetworkQuality.none;
    }
  }
}
