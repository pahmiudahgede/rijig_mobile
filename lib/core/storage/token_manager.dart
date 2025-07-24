import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:rijig_mobile/core/storage/secure_storage.dart';

class TokenManager {
  static final TokenManager _instance = TokenManager._internal();
  factory TokenManager() => _instance;
  TokenManager._internal();

  final SecureStorage _secureStorage = SecureStorage();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _sessionIdKey = 'session_id';
  static const String _tokenTypeKey = 'token_type';
  static const String _registrationStatusKey = 'registration_status';
  static const String _nextStepKey = 'next_step';
  static const String _userIdKey = 'user_id';
  static const String _userRoleKey = 'user_role';
  static const String _userPhoneKey = 'user_phone';
  static const String _expiresInKey = 'expires_in';

  Future<String?> getToken() async {
    return await _secureStorage.readSecureData(_accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.readSecureData(_refreshTokenKey);
  }

  Future<String?> getSessionId() async {
    return await _secureStorage.readSecureData(_sessionIdKey);
  }

  Future<String?> getTokenType() async {
    return await _secureStorage.readSecureData(_tokenTypeKey);
  }

  Future<String?> getRegistrationStatus() async {
    return await _secureStorage.readSecureData(_registrationStatusKey);
  }

  Future<String?> getNextStep() async {
    return await _secureStorage.readSecureData(_nextStepKey);
  }

  Future<String?> getUserId() async {
    return await _secureStorage.readSecureData(_userIdKey);
  }

  Future<String?> getUserRole() async {
    return await _secureStorage.readSecureData(_userRoleKey);
  }

  Future<String?> getUserPhone() async {
    return await _secureStorage.readSecureData(_userPhoneKey);
  }

  Future<int?> getExpiresIn() async {
    final String? expiresIn = await _secureStorage.readSecureData(
      _expiresInKey,
    );
    return expiresIn != null ? int.tryParse(expiresIn) : null;
  }

  Future<bool> isTokenExpired() async {
    final String? token = await getToken();

    if (token == null || token.isEmpty) {
      return true;
    }

    try {
      return JwtDecoder.isExpired(token);
    } catch (e) {
      debugPrint('Error checking token expiration: $e');
      return true;
    }
  }

  Future<DateTime?> getTokenExpirationTime() async {
    final String? token = await getToken();

    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      return JwtDecoder.getExpirationDate(token);
    } catch (e) {
      debugPrint('Error getting token expiration time: $e');
      return null;
    }
  }

  Future<void> storeSession({
    required String accessToken,
    required String refreshToken,
    required String sessionId,
    String? tokenType,
    String? registrationStatus,
    String? nextStep,
    String? userId,
    String? userRole,
    String? userPhone,
    int? expiresIn,
  }) async {
    final List<Future<void>> futures = [
      _secureStorage.writeSecureData(_accessTokenKey, accessToken),
      _secureStorage.writeSecureData(_refreshTokenKey, refreshToken),
      _secureStorage.writeSecureData(_sessionIdKey, sessionId),
    ];

    if (tokenType != null) {
      futures.add(_secureStorage.writeSecureData(_tokenTypeKey, tokenType));
    }
    if (registrationStatus != null) {
      futures.add(
        _secureStorage.writeSecureData(
          _registrationStatusKey,
          registrationStatus,
        ),
      );
    }
    if (nextStep != null) {
      futures.add(_secureStorage.writeSecureData(_nextStepKey, nextStep));
    }
    if (userId != null) {
      futures.add(_secureStorage.writeSecureData(_userIdKey, userId));
    }
    if (userRole != null) {
      futures.add(_secureStorage.writeSecureData(_userRoleKey, userRole));
    }
    if (userPhone != null) {
      futures.add(_secureStorage.writeSecureData(_userPhoneKey, userPhone));
    }
    if (expiresIn != null) {
      futures.add(
        _secureStorage.writeSecureData(_expiresInKey, expiresIn.toString()),
      );
    }

    await Future.wait(futures);
  }

  Future<void> updateSession({
    String? accessToken,
    String? refreshToken,
    String? sessionId,
    String? tokenType,
    String? registrationStatus,
    String? nextStep,
    int? expiresIn,
  }) async {
    final List<Future<void>> futures = [];

    if (accessToken != null) {
      futures.add(_secureStorage.writeSecureData(_accessTokenKey, accessToken));
    }
    if (refreshToken != null) {
      futures.add(
        _secureStorage.writeSecureData(_refreshTokenKey, refreshToken),
      );
    }
    if (sessionId != null) {
      futures.add(_secureStorage.writeSecureData(_sessionIdKey, sessionId));
    }
    if (tokenType != null) {
      futures.add(_secureStorage.writeSecureData(_tokenTypeKey, tokenType));
    }
    if (registrationStatus != null) {
      futures.add(
        _secureStorage.writeSecureData(
          _registrationStatusKey,
          registrationStatus,
        ),
      );
    }
    if (nextStep != null) {
      futures.add(_secureStorage.writeSecureData(_nextStepKey, nextStep));
    }
    if (expiresIn != null) {
      futures.add(
        _secureStorage.writeSecureData(_expiresInKey, expiresIn.toString()),
      );
    }

    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
  }

  Future<void> clearSession() async {
    await Future.wait([
      _secureStorage.deleteSecureData(_accessTokenKey),
      _secureStorage.deleteSecureData(_refreshTokenKey),
      _secureStorage.deleteSecureData(_sessionIdKey),
      _secureStorage.deleteSecureData(_tokenTypeKey),
      _secureStorage.deleteSecureData(_registrationStatusKey),
      _secureStorage.deleteSecureData(_nextStepKey),
      _secureStorage.deleteSecureData(_userIdKey),
      _secureStorage.deleteSecureData(_userRoleKey),
      _secureStorage.deleteSecureData(_userPhoneKey),
      _secureStorage.deleteSecureData(_expiresInKey),
    ]);
  }

  Future<bool> isLoggedIn() async {
    final String? token = await getToken();
    return token != null && token.isNotEmpty && !await isTokenExpired();
  }

  Future<bool> isRegistrationComplete() async {
    final String? registrationStatus = await getRegistrationStatus();
    return registrationStatus == 'complete';
  }

  Future<bool> hasFullAccess() async {
    final String? tokenType = await getTokenType();
    return tokenType == 'full';
  }

  Future<bool> hasPartialAccess() async {
    final String? tokenType = await getTokenType();
    return tokenType == 'partial';
  }

  Future<bool> isAwaitingApproval() async {
    final String? registrationStatus = await getRegistrationStatus();
    return registrationStatus == 'awaiting_approval';
  }

  Future<bool> willExpireSoon([
    Duration threshold = const Duration(minutes: 5),
  ]) async {
    final DateTime? expirationTime = await getTokenExpirationTime();
    if (expirationTime == null) return true;

    final DateTime now = DateTime.now();
    return expirationTime.difference(now) < threshold;
  }

  Future<Map<String, dynamic>> getSessionInfo() async {
    return {
      'access_token': await getToken(),
      'refresh_token': await getRefreshToken(),
      'session_id': await getSessionId(),
      'token_type': await getTokenType(),
      'registration_status': await getRegistrationStatus(),
      'next_step': await getNextStep(),
      'user_id': await getUserId(),
      'user_role': await getUserRole(),
      'user_phone': await getUserPhone(),
      'expires_in': await getExpiresIn(),
      'is_logged_in': await isLoggedIn(),
      'is_registration_complete': await isRegistrationComplete(),
      'has_full_access': await hasFullAccess(),
      'has_partial_access': await hasPartialAccess(),
      'is_awaiting_approval': await isAwaitingApproval(),
    };
  }
}
