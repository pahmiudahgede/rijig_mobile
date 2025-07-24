import 'package:rijig_mobile/core/api/api_client.dart';
import 'package:rijig_mobile/core/api/api_response.dart';
import 'package:rijig_mobile/core/storage/token_manager.dart';
import 'package:rijig_mobile/core/utils/getinfodevice.dart';
import 'package:rijig_mobile/features/auth/model/auth_model.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final TokenManager _tokenManager;
  final DeviceIdHelper _deviceIdHelper;

  AuthRepository({
    ApiClient? apiClient,
    TokenManager? tokenManager,
    DeviceIdHelper? deviceIdHelper,
  }) : _apiClient = apiClient ?? ApiClient(),
       _tokenManager = tokenManager ?? TokenManager(),
       _deviceIdHelper = deviceIdHelper ?? DeviceIdHelper();

  Future<ApiResponse<dynamic>> requestOtpRegister(OtpRequest request) async {
    try {
      return await _apiClient.post(
        '/auth/request-otp/register',
        body: request.toJson(),
      );
    } catch (e) {
      throw Exception('Failed to request OTP: $e');
    }
  }

  Future<ApiResponse<dynamic>> verifyOtpRegister(
    OtpVerification verification,
  ) async {
    try {
      return await _apiClient.post(
        '/auth/verif-otp/register',
        body: verification.toJson(),
      );
    } catch (e) {
      throw Exception('Failed to verify OTP: $e');
    }
  }

  Future<ApiResponse<dynamic>> updateProfile(UserProfile profile) async {
    try {
      return await _apiClient.put(
        '/userprofile/update',
        body: profile.toJson(),
      );
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<ApiResponse<dynamic>> createPin(PinRequest pinRequest) async {
    try {
      return await _apiClient.post('/pin/create', body: pinRequest.toJson());
    } catch (e) {
      throw Exception('Failed to create PIN: $e');
    }
  }

  Future<ApiResponse<dynamic>> requestOtpLogin(OtpRequest request) async {
    try {
      return await _apiClient.post('/auth/request-otp', body: request.toJson());
    } catch (e) {
      throw Exception('Failed to request OTP for login: $e');
    }
  }

  Future<ApiResponse<dynamic>> verifyOtpLogin(
    OtpVerification verification,
  ) async {
    try {
      return await _apiClient.post(
        '/auth/verif-otp',
        body: verification.toJson(),
      );
    } catch (e) {
      throw Exception('Failed to verify OTP for login: $e');
    }
  }

  Future<ApiResponse<dynamic>> verifyPin(PinRequest pinRequest) async {
    try {
      return await _apiClient.post('/pin/verif', body: pinRequest.toJson());
    } catch (e) {
      throw Exception('Failed to verify PIN: $e');
    }
  }

  Future<ApiResponse<dynamic>> refreshToken(RefreshTokenRequest request) async {
    try {
      return await _apiClient.post(
        '/auth/refresh-token',
        body: request.toJson(),
      );
    } catch (e) {
      throw Exception('Failed to refresh token: $e');
    }
  }

  Future<ApiResponse<dynamic>> logout() async {
    try {
      return await _apiClient.post('/auth/logout');
    } catch (e) {
      throw Exception('Failed to logout: $e');
    }
  }

  Future<String> getDeviceId(String role) async {
    return await _deviceIdHelper.getDeviceId(role);
  }

  Future<String?> getRefreshToken() async {
    return await _tokenManager.getRefreshToken();
  }

  Future<bool> isLoggedIn() async {
    return await _tokenManager.isLoggedIn();
  }

  Future<String?> getNextStep() async {
    return await _tokenManager.getNextStep();
  }

  Future<String?> getRegistrationStatus() async {
    return await _tokenManager.getRegistrationStatus();
  }

  Future<String?> getUserRole() async {
    return await _tokenManager.getUserRole();
  }

  Future<void> clearSession() async {
    await _tokenManager.clearSession();
    await _deviceIdHelper.clearDeviceId();
  }
}
