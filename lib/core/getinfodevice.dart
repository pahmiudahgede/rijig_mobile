import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

Future<String> getDeviceId() async {
  final deviceInfo = DeviceInfoPlugin();
  String deviceID;

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

  return deviceID;
}
