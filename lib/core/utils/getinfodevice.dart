import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:rijig_mobile/core/storage/secure_storage.dart';

class DeviceIdHelper {
  static final DeviceIdHelper _instance = DeviceIdHelper._internal();
  factory DeviceIdHelper() => _instance;
  DeviceIdHelper._internal();

  final SecureStorage _secureStorage = SecureStorage();
  static const String _deviceIdKey = 'device_id';
  static const String _deviceIdRoleKey = 'device_id_role';

  Future<String> getDeviceId(String role) async {
    final String? existingRole = await _secureStorage.readSecureData(
      _deviceIdRoleKey,
    );
    String? existingDeviceId = await _secureStorage.readSecureData(
      _deviceIdKey,
    );

    if (existingRole == role &&
        existingDeviceId != null &&
        existingDeviceId.isNotEmpty) {
      if (kDebugMode) {
        debugPrint('Using existing device ID for role: $role');
      }
      return existingDeviceId;
    }

    final String newDeviceId = _generateDeviceId(role);

    await Future.wait([
      _secureStorage.writeSecureData(_deviceIdKey, newDeviceId),
      _secureStorage.writeSecureData(_deviceIdRoleKey, role),
    ]);

    if (kDebugMode) {
      debugPrint('Generated new device ID for role: $role');
    }

    return newDeviceId;
  }

  String _generateDeviceId(String role) {
    if (role != 'masyarakat' && role != 'pengepul') {
      throw ArgumentError(
        'Invalid role: $role. Must be "masyarakat" or "pengepul"',
      );
    }

    final String prefix =
        role == 'masyarakat' ? 'devicemasyarakat' : 'devicepengepul';
    final String randomString = _generateRandomString(20);
    return '$prefix$randomString';
  }

  String _generateRandomString(int length) {
    const String chars =
        '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final Random random = Random();
    return List.generate(
      length,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  Future<String?> getCurrentDeviceId() async {
    return await _secureStorage.readSecureData(_deviceIdKey);
  }

  Future<String?> getCurrentRole() async {
    return await _secureStorage.readSecureData(_deviceIdRoleKey);
  }

  Future<bool> hasDeviceId() async {
    final String? deviceId = await getCurrentDeviceId();
    return deviceId != null && deviceId.isNotEmpty;
  }

  Future<void> clearDeviceId() async {
    await Future.wait([
      _secureStorage.deleteSecureData(_deviceIdKey),
      _secureStorage.deleteSecureData(_deviceIdRoleKey),
    ]);
    if (kDebugMode) {
      debugPrint('Device ID cleared');
    }
  }

  Future<String> regenerateDeviceId(String role) async {
    await clearDeviceId();
    return await getDeviceId(role);
  }

  bool isValidDeviceId(String deviceId) {
    if (deviceId.isEmpty) return false;

    return deviceId.startsWith('devicemasyarakat') ||
        deviceId.startsWith('devicepengepul');
  }

  String? getRoleFromDeviceId(String deviceId) {
    if (deviceId.startsWith('devicemasyarakat')) {
      return 'masyarakat';
    } else if (deviceId.startsWith('devicepengepul')) {
      return 'pengepul';
    }
    return null;
  }
}
