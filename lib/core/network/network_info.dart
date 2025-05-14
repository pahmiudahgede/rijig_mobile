// ignore_for_file: unrelated_type_equality_checks

import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkInfo {
  final Connectivity _connectivity = Connectivity();

  Future<bool> checkConnection() async {
    var connectivityResult = await _connectivity.checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }

    try {
      final lookupResult = await InternetAddress.lookup('google.com');
      return lookupResult.isNotEmpty && lookupResult[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
