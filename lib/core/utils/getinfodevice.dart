import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

Future<String> getDeviceId() async {
  final deviceInfo = DeviceInfoPlugin();
  String deviceID = '';

  try {
    if (Platform.isAndroid) {
      var androidInfo = await deviceInfo.androidInfo;
      deviceID = androidInfo.id;
    } else if (Platform.isIOS) {
      var iosInfo = await deviceInfo.iosInfo;
      deviceID = iosInfo.identifierForVendor ?? '';
    } else {
      var uuid = Uuid();
      deviceID = uuid.v4();
    }
  } catch (e) {
    debugPrint("Error fetching device ID: $e");

    var uuid = Uuid();
    deviceID = uuid.v4();
  }

  return deviceID;
}
