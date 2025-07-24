import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:rijig_mobile/core/storage/secure_storage.dart';

final SecureStorage _secureStorage = SecureStorage();

Future<bool> isTokenExpired() async {
  String? token = await _secureStorage.readSecureData('token');

  if (token == null || token.isEmpty) {
    return true;
  }

  try {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    int expirationTime = decodedToken['exp'];
    int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    return expirationTime < currentTime;
  } catch (e) {
    debugPrint("Error decoding token: $e");
    return true;
  }
}

Future<void> storeSessionData(
  String token,
  String userId,
  String userRole,
) async {
  await _secureStorage.writeSecureData('token', token);
  await _secureStorage.writeSecureData('user_id', userId);
  await _secureStorage.writeSecureData('user_role', userRole);
}

Future<void> deleteToken() async {
  await _secureStorage.deleteSecureData('token');
  await _secureStorage.deleteSecureData('user_id');
  await _secureStorage.deleteSecureData('user_role');
}
