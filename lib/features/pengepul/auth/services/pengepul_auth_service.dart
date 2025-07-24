// lib/features/pengepul/auth/service/pengepul_auth_service.dart
import 'package:rijig_mobile/core/api/api_response.dart';
import 'package:rijig_mobile/core/storage/token_manager.dart';
import 'package:rijig_mobile/features/pengepul/auth/model/pengepul_auth_model.dart';
import 'package:rijig_mobile/features/pengepul/auth/repository/pengepul_auth_repository.dart';

class PengepulAuthService {
  final PengepulAuthRepository _repository;
  final TokenManager _tokenManager;

  PengepulAuthService(this._repository, {TokenManager? tokenManager})
    : _tokenManager = tokenManager ?? TokenManager();

  // Registration Flow
  Future<PengepulAuthResult> requestOtpRegister(String phone) async {
    try {
      final request = PengepulOtpRequest(phone: phone, roleId: 'pengepul');
      final response = await _repository.requestOtpRegister(request);

      if (response.isSuccess) {
        return PengepulAuthResult.success(message: _extractMessage(response));
      } else {
        return PengepulAuthResult.failure(message: _extractMessage(response));
      }
    } catch (e) {
      return PengepulAuthResult.failure(message: e.toString());
    }
  }

  Future<PengepulAuthResult> verifyOtpRegister(String phone, String otp) async {
    try {
      final deviceId = await _repository.getDeviceId('pengepul');
      final verification = PengepulOtpVerification(
        phone: phone,
        otp: otp,
        deviceId: deviceId,
        roleId: 'pengepul',
      );

      final response = await _repository.verifyOtpRegister(verification);

      if (response.isSuccess) {
        await _handleAuthResponse(response);
        return PengepulAuthResult.success(
          message: _extractMessage(response),
          nextStep: await _tokenManager.getNextStep(),
          registrationStatus: await _tokenManager.getRegistrationStatus(),
          tokenType: await _tokenManager.getTokenType(),
        );
      } else {
        return PengepulAuthResult.failure(message: _extractMessage(response));
      }
    } catch (e) {
      return PengepulAuthResult.failure(message: e.toString());
    }
  }

  Future<PengepulAuthResult> uploadKtp(KtpIdentity ktpData) async {
    try {
      final response = await _repository.uploadKtp(ktpData);

      if (response.isSuccess) {
        await _handleAuthResponse(response);
        return PengepulAuthResult.success(
          message: _extractMessage(response),
          nextStep: await _tokenManager.getNextStep(),
          registrationStatus: await _tokenManager.getRegistrationStatus(),
          tokenType: await _tokenManager.getTokenType(),
        );
      } else {
        return PengepulAuthResult.failure(message: _extractMessage(response));
      }
    } catch (e) {
      return PengepulAuthResult.failure(message: e.toString());
    }
  }

  Future<PengepulAuthResult> checkApprovalStatus() async {
    try {
      final response = await _repository.checkApprovalStatus();

      if (response.isSuccess) {
        await _handleApprovalResponse(response);
        
        final registrationStatus = await _tokenManager.getRegistrationStatus();
        
        return PengepulAuthResult.success(
          message: _extractMessage(response),
          nextStep: await _tokenManager.getNextStep(),
          registrationStatus: registrationStatus,
          tokenType: await _tokenManager.getTokenType(),
        );
      } else {
        return PengepulAuthResult.failure(message: _extractMessage(response));
      }
    } catch (e) {
      return PengepulAuthResult.failure(message: e.toString());
    }
  }

  Future<PengepulAuthResult> createPin(String pin) async {
    try {
      final pinRequest = PengepulPinRequest(userPin: pin);
      final response = await _repository.createPin(pinRequest);

      if (response.isSuccess) {
        await _handleAuthResponse(response);
        return PengepulAuthResult.success(
          message: _extractMessage(response),
          nextStep: await _tokenManager.getNextStep(),
          registrationStatus: await _tokenManager.getRegistrationStatus(),
          tokenType: await _tokenManager.getTokenType(),
        );
      } else {
        return PengepulAuthResult.failure(message: _extractMessage(response));
      }
    } catch (e) {
      return PengepulAuthResult.failure(message: e.toString());
    }
  }

  // Login Flow
  Future<PengepulAuthResult> requestOtpLogin(String phone) async {
    try {
      final request = PengepulOtpRequest(phone: phone, roleId: 'pengepul');
      final response = await _repository.requestOtpLogin(request);

      if (response.isSuccess) {
        return PengepulAuthResult.success(message: _extractMessage(response));
      } else {
        return PengepulAuthResult.failure(message: _extractMessage(response));
      }
    } catch (e) {
      return PengepulAuthResult.failure(message: e.toString());
    }
  }

  Future<PengepulAuthResult> verifyOtpLogin(String phone, String otp) async {
    try {
      final deviceId = await _repository.getDeviceId('pengepul');
      final verification = PengepulOtpVerification(
        phone: phone,
        otp: otp,
        deviceId: deviceId,
        roleId: 'pengepul',
      );

      final response = await _repository.verifyOtpLogin(verification);

      if (response.isSuccess) {
        await _handleAuthResponse(response);
        return PengepulAuthResult.success(
          message: _extractMessage(response),
          nextStep: await _tokenManager.getNextStep(),
          registrationStatus: await _tokenManager.getRegistrationStatus(),
          tokenType: await _tokenManager.getTokenType(),
        );
      } else {
        return PengepulAuthResult.failure(message: _extractMessage(response));
      }
    } catch (e) {
      return PengepulAuthResult.failure(message: e.toString());
    }
  }

  Future<PengepulAuthResult> verifyPin(String pin) async {
    try {
      final pinRequest = PengepulPinRequest(userPin: pin);
      final response = await _repository.verifyPin(pinRequest);

      if (response.isSuccess) {
        await _handleAuthResponse(response);
        return PengepulAuthResult.success(
          message: _extractMessage(response),
          nextStep: await _tokenManager.getNextStep(),
          registrationStatus: await _tokenManager.getRegistrationStatus(),
          tokenType: await _tokenManager.getTokenType(),
        );
      } else {
        return PengepulAuthResult.failure(message: _extractMessage(response));
      }
    } catch (e) {
      return PengepulAuthResult.failure(message: e.toString());
    }
  }

  Future<PengepulAuthResult> refreshToken() async {
    try {
      final response = await _repository.refreshToken();

      if (response.isSuccess) {
        await _handleRefreshResponse(response);
        return PengepulAuthResult.success(
          message: _extractMessage(response),
          nextStep: await _tokenManager.getNextStep(),
          registrationStatus: await _tokenManager.getRegistrationStatus(),
          tokenType: await _tokenManager.getTokenType(),
        );
      } else {
        return PengepulAuthResult.failure(message: _extractMessage(response));
      }
    } catch (e) {
      return PengepulAuthResult.failure(message: e.toString());
    }
  }

  Future<PengepulAuthResult> logout() async {
    try {
      final response = await _repository.logout();
      await _repository.clearSession();

      if (response.isSuccess) {
        return PengepulAuthResult.success(message: _extractMessage(response));
      } else {
        return PengepulAuthResult.success(message: 'Logged out successfully');
      }
    } catch (e) {
      await _repository.clearSession();
      return PengepulAuthResult.success(message: 'Logged out successfully');
    }
  }

  // Status Check Methods
  Future<bool> isLoggedIn() async {
    return await _repository.isLoggedIn();
  }

  Future<String?> getNextStep() async {
    return await _repository.getNextStep();
  }

  Future<String?> getRegistrationStatus() async {
    return await _repository.getRegistrationStatus();
  }

  Future<String?> getUserRole() async {
    return await _repository.getUserRole();
  }

  Future<bool> isRegistrationComplete() async {
    final status = await getRegistrationStatus();
    return status == 'complete';
  }

  Future<bool> isAwaitingApproval() async {
    final status = await getRegistrationStatus();
    return status == 'awaiting_approval';
  }

  Future<bool> isApproved() async {
    final status = await getRegistrationStatus();
    return status == 'approved';
  }

  Future<bool> hasFullAccess() async {
    return await _tokenManager.hasFullAccess();
  }

  // Private Methods
  Future<void> _handleAuthResponse(ApiResponse<dynamic> response) async {
    if (response.isSuccess && response.data != null) {
      final data = response.data['data'];
      if (data != null && data is Map<String, dynamic>) {
        await _repository.storeSession(
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

  Future<void> _handleApprovalResponse(ApiResponse<dynamic> response) async {
    if (response.isSuccess && response.data != null) {
      final data = response.data['data'];
      if (data != null && data is Map<String, dynamic>) {
        // Update session with approval data
        await _repository.updateSession(
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

  Future<void> _handleRefreshResponse(ApiResponse<dynamic> response) async {
    if (response.isSuccess && response.data != null) {
      final data = response.data['data'];
      if (data != null && data is Map<String, dynamic>) {
        await _repository.updateSession(
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

  String _extractMessage(ApiResponse<dynamic> response) {
    if (response.data != null) {
      final meta = response.data['meta'];
      if (meta != null && meta is Map<String, dynamic>) {
        return meta['message'] ?? response.message;
      }
    }
    return response.message;
  }
}