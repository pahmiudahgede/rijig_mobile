import 'package:rijig_mobile/core/api/api_response.dart';
import 'package:rijig_mobile/core/storage/token_manager.dart';
import 'package:rijig_mobile/features/auth/model/auth_model.dart';
import 'package:rijig_mobile/features/auth/repositories/auth_repository.dart';

class AuthService {
  final AuthRepository _repository;
  final TokenManager _tokenManager;

  AuthService(this._repository, {TokenManager? tokenManager})
    : _tokenManager = tokenManager ?? TokenManager();

  Future<AuthResult> requestOtpRegister(String phone) async {
    try {
      final request = OtpRequest(phone: phone, roleId: 'masyarakat');
      final response = await _repository.requestOtpRegister(request);

      if (response.isSuccess) {
        return AuthResult.success(message: _extractMessage(response));
      } else {
        return AuthResult.failure(message: _extractMessage(response));
      }
    } catch (e) {
      return AuthResult.failure(message: e.toString());
    }
  }

  Future<AuthResult> verifyOtpRegister(String phone, String otp) async {
    try {
      final deviceId = await _repository.getDeviceId('masyarakat');
      final verification = OtpVerification(
        phone: phone,
        otp: otp,
        deviceId: deviceId,
        roleId: 'masyarakat',
      );

      final response = await _repository.verifyOtpRegister(verification);

      if (response.isSuccess) {
        await _handleAuthResponse(response);
        return AuthResult.success(
          message: _extractMessage(response),
          nextStep: await _tokenManager.getNextStep(),
          registrationStatus: await _tokenManager.getRegistrationStatus(),
          tokenType: await _tokenManager.getTokenType(),
        );
      } else {
        return AuthResult.failure(message: _extractMessage(response));
      }
    } catch (e) {
      return AuthResult.failure(message: e.toString());
    }
  }

  Future<AuthResult> updateProfile({
    required String name,
    required String phone,
    required String gender,
    required String dateOfBirth,
    required String placeOfBirth,
  }) async {
    try {
      final profile = UserProfile(
        name: name,
        phone: phone,
        gender: gender,
        dateOfBirth: dateOfBirth,
        placeOfBirth: placeOfBirth,
      );

      final response = await _repository.updateProfile(profile);

      if (response.isSuccess) {
        await _handleAuthResponse(response);
        return AuthResult.success(
          message: _extractMessage(response),
          nextStep: await _tokenManager.getNextStep(),
          registrationStatus: await _tokenManager.getRegistrationStatus(),
          tokenType: await _tokenManager.getTokenType(),
        );
      } else {
        return AuthResult.failure(message: _extractMessage(response));
      }
    } catch (e) {
      return AuthResult.failure(message: e.toString());
    }
  }

  Future<AuthResult> createPin(String pin) async {
    try {
      final pinRequest = PinRequest(userPin: pin);
      final response = await _repository.createPin(pinRequest);

      if (response.isSuccess) {
        await _handleAuthResponse(response);
        return AuthResult.success(
          message: _extractMessage(response),
          nextStep: await _tokenManager.getNextStep(),
          registrationStatus: await _tokenManager.getRegistrationStatus(),
          tokenType: await _tokenManager.getTokenType(),
        );
      } else {
        return AuthResult.failure(message: _extractMessage(response));
      }
    } catch (e) {
      return AuthResult.failure(message: e.toString());
    }
  }

  Future<AuthResult> requestOtpLogin(String phone) async {
    try {
      final request = OtpRequest(phone: phone, roleId: 'masyarakat');
      final response = await _repository.requestOtpLogin(request);

      if (response.isSuccess) {
        return AuthResult.success(message: _extractMessage(response));
      } else {
        return AuthResult.failure(message: _extractMessage(response));
      }
    } catch (e) {
      return AuthResult.failure(message: e.toString());
    }
  }

  Future<AuthResult> verifyOtpLogin(String phone, String otp) async {
    try {
      final deviceId = await _repository.getDeviceId('masyarakat');
      final verification = OtpVerification(
        phone: phone,
        otp: otp,
        deviceId: deviceId,
        roleId: 'masyarakat',
      );

      final response = await _repository.verifyOtpLogin(verification);

      if (response.isSuccess) {
        await _handleAuthResponse(response);
        return AuthResult.success(
          message: _extractMessage(response),
          nextStep: await _tokenManager.getNextStep(),
          registrationStatus: await _tokenManager.getRegistrationStatus(),
          tokenType: await _tokenManager.getTokenType(),
        );
      } else {
        return AuthResult.failure(message: _extractMessage(response));
      }
    } catch (e) {
      return AuthResult.failure(message: e.toString());
    }
  }

  Future<AuthResult> verifyPin(String pin) async {
    try {
      final pinRequest = PinRequest(userPin: pin);
      final response = await _repository.verifyPin(pinRequest);

      if (response.isSuccess) {
        await _handleAuthResponse(response);
        return AuthResult.success(
          message: _extractMessage(response),
          nextStep: await _tokenManager.getNextStep(),
          registrationStatus: await _tokenManager.getRegistrationStatus(),
          tokenType: await _tokenManager.getTokenType(),
        );
      } else {
        return AuthResult.failure(message: _extractMessage(response));
      }
    } catch (e) {
      return AuthResult.failure(message: e.toString());
    }
  }

  Future<AuthResult> refreshToken() async {
    try {
      final refreshToken = await _repository.getRefreshToken();
      if (refreshToken == null) {
        return AuthResult.failure(message: 'No refresh token available');
      }

      final request = RefreshTokenRequest(refreshToken: refreshToken);
      final response = await _repository.refreshToken(request);

      if (response.isSuccess) {
        await _handleRefreshResponse(response);
        return AuthResult.success(
          message: _extractMessage(response),
          nextStep: await _tokenManager.getNextStep(),
          registrationStatus: await _tokenManager.getRegistrationStatus(),
          tokenType: await _tokenManager.getTokenType(),
        );
      } else {
        return AuthResult.failure(message: _extractMessage(response));
      }
    } catch (e) {
      return AuthResult.failure(message: e.toString());
    }
  }

  Future<AuthResult> logout() async {
    try {
      final response = await _repository.logout();
      await _repository.clearSession();

      if (response.isSuccess) {
        return AuthResult.success(message: _extractMessage(response));
      } else {
        return AuthResult.success(message: 'Logged out successfully');
      }
    } catch (e) {
      await _repository.clearSession();
      return AuthResult.success(message: 'Logged out successfully');
    }
  }

  Future<bool> isLoggedIn() async {
    return await _repository.isLoggedIn();
  }

  Future<String?> getNextStep() async {
    return await _repository.getNextStep();
  }

  Future<String?> getRegistrationStatus() async {
    return await _repository.getRegistrationStatus();
  }

  Future<bool> isRegistrationComplete() async {
    final status = await getRegistrationStatus();
    return status == 'complete';
  }

  Future<bool> hasFullAccess() async {
    return await _tokenManager.hasFullAccess();
  }

  Future<void> _handleAuthResponse(ApiResponse<dynamic> response) async {
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
          userRole: 'masyarakat',
        );
      }
    }
  }

  Future<void> _handleRefreshResponse(ApiResponse<dynamic> response) async {
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
