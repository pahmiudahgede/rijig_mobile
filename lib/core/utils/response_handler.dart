import 'package:rijig_mobile/core/api/api_response.dart';
import 'package:rijig_mobile/core/storage/token_manager.dart';

class ResponseHandler {
  static final ResponseHandler _instance = ResponseHandler._internal();
  factory ResponseHandler() => _instance;
  ResponseHandler._internal();

  final TokenManager _tokenManager = TokenManager();

  Future<void> handleAuthResponse(ApiResponse<dynamic> response) async {
    if (response.isSuccess && response.data != null) {
      final data = response.data['data'];

      if (data != null && data is Map<String, dynamic>) {
        await _tokenManager.storeSession(
          accessToken: data['access_token'] ?? '',
          refreshToken: data['refresh_token'] ?? '',
          sessionId: data['session_id'] ?? '',
          tokenType: data['token_type'],
          registrationStatus: data['registration_status'],
          nextStep: data['next_step'],
          expiresIn: data['expires_in'],
        );
      }
    }
  }

  Future<void> handleUpdateResponse(ApiResponse<dynamic> response) async {
    if (response.isSuccess && response.data != null) {
      final data = response.data['data'];

      if (data != null && data is Map<String, dynamic>) {
        await _tokenManager.updateSession(
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'],
          sessionId: data['session_id'],
          tokenType: data['token_type'],
          registrationStatus: data['registration_status'],
          nextStep: data['next_step'],
          expiresIn: data['expires_in'],
        );
      }
    }
  }

  Future<void> handleRefreshTokenResponse(ApiResponse<dynamic> response) async {
    if (response.isSuccess && response.data != null) {
      final data = response.data['data'];

      if (data != null && data is Map<String, dynamic>) {
        await _tokenManager.updateSession(
          accessToken: data['access_token'],
          sessionId: data['session_id'],
          tokenType: data['token_type'],
          registrationStatus: data['registration_status'],
          nextStep: data['next_step'],
          expiresIn: data['expires_in'],
        );
      }
    }
  }

  String extractMessage(ApiResponse<dynamic> response) {
    if (response.data != null) {
      final meta = response.data['meta'];
      if (meta != null && meta is Map<String, dynamic>) {
        return meta['message'] ?? response.message;
      }
    }
    return response.message;
  }

  int extractStatus(ApiResponse<dynamic> response) {
    if (response.data != null) {
      final meta = response.data['meta'];
      if (meta != null && meta is Map<String, dynamic>) {
        return meta['status'] ?? response.statusCode;
      }
    }
    return response.statusCode;
  }

  Map<String, dynamic>? extractData(ApiResponse<dynamic> response) {
    if (response.data != null) {
      final data = response.data['data'];
      if (data != null && data is Map<String, dynamic>) {
        return data;
      }
    }
    return null;
  }

  bool isResponseSuccess(ApiResponse<dynamic> response) {
    if (!response.isSuccess) return false;

    final status = extractStatus(response);
    return status >= 200 && status < 300;
  }

  String? getNextStep(ApiResponse<dynamic> response) {
    final data = extractData(response);
    return data?['next_step'];
  }

  String? getRegistrationStatus(ApiResponse<dynamic> response) {
    final data = extractData(response);
    return data?['registration_status'];
  }

  String? getTokenType(ApiResponse<dynamic> response) {
    final data = extractData(response);
    return data?['token_type'];
  }

  bool isRegistrationComplete(ApiResponse<dynamic> response) {
    final registrationStatus = getRegistrationStatus(response);
    return registrationStatus == 'complete';
  }

  bool hasFullAccess(ApiResponse<dynamic> response) {
    final tokenType = getTokenType(response);
    return tokenType == 'full';
  }

  bool isAwaitingApproval(ApiResponse<dynamic> response) {
    final registrationStatus = getRegistrationStatus(response);
    return registrationStatus == 'awaiting_approval';
  }
}
