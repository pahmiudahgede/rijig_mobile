import 'package:rijig_mobile/core/api/api_client.dart';
import 'package:rijig_mobile/core/api/api_response.dart';
import 'package:rijig_mobile/core/storage/token_manager.dart';
import 'package:rijig_mobile/core/utils/getinfodevice.dart';
import 'package:rijig_mobile/features/pengepul/auth/model/pengepul_auth_model.dart';

class PengepulAuthRepository {
  final ApiClient _apiClient;
  final TokenManager _tokenManager;
  final DeviceIdHelper _deviceIdHelper;

  PengepulAuthRepository({
    ApiClient? apiClient,
    TokenManager? tokenManager,
    DeviceIdHelper? deviceIdHelper,
  }) : _apiClient = apiClient ?? ApiClient(),
       _tokenManager = tokenManager ?? TokenManager(),
       _deviceIdHelper = deviceIdHelper ?? DeviceIdHelper();

  Future<ApiResponse<dynamic>> requestOtpRegister(
    PengepulOtpRequest request,
  ) async {
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
    PengepulOtpVerification verification,
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

  Future<ApiResponse<dynamic>> uploadKtp(KtpIdentity ktpData) async {
    try {
      return await _apiClient.uploadFile(
        '/identity/create',
        fields: ktpData.toFormData(),
      );
    } catch (e) {
      throw Exception('Failed to upload KTP: $e');
    }
  }

  Future<ApiResponse<dynamic>> checkApprovalStatus() async {
    try {
      return await _apiClient.get('/auth/cekapproval');
    } catch (e) {
      throw Exception('Failed to check approval status: $e');
    }
  }

  Future<ApiResponse<dynamic>> createPin(PengepulPinRequest pinRequest) async {
    try {
      return await _apiClient.post('/pin/create', body: pinRequest.toJson());
    } catch (e) {
      throw Exception('Failed to create PIN: $e');
    }
  }

  Future<ApiResponse<dynamic>> requestOtpLogin(
    PengepulOtpRequest request,
  ) async {
    try {
      return await _apiClient.post('/auth/request-otp', body: request.toJson());
    } catch (e) {
      throw Exception('Failed to request OTP for login: $e');
    }
  }

  Future<ApiResponse<dynamic>> verifyOtpLogin(
    PengepulOtpVerification verification,
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

  Future<ApiResponse<dynamic>> verifyPin(PengepulPinRequest pinRequest) async {
    try {
      return await _apiClient.post('/pin/verif', body: pinRequest.toJson());
    } catch (e) {
      throw Exception('Failed to verify PIN: $e');
    }
  }

  Future<ApiResponse<dynamic>> refreshToken() async {
    try {
      final refreshToken = await _tokenManager.getRefreshToken();
      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      return await _apiClient.post(
        '/auth/refresh-token',
        body: {'refresh_token': refreshToken},
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

  Future<bool> isAwaitingApproval() async {
    return await _tokenManager.isAwaitingApproval();
  }

  Future<void> clearSession() async {
    await _tokenManager.clearSession();
    await _deviceIdHelper.clearDeviceId();
  }

  Future<void> storeSession({
    required String accessToken,
    required String refreshToken,
    required String sessionId,
    String? tokenType,
    String? registrationStatus,
    String? nextStep,
    int? expiresIn,
  }) async {
    await _tokenManager.storeSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      sessionId: sessionId,
      tokenType: tokenType,
      registrationStatus: registrationStatus,
      nextStep: nextStep,
      expiresIn: expiresIn,
      userRole: 'pengepul',
    );
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
    await _tokenManager.updateSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      sessionId: sessionId,
      tokenType: tokenType,
      registrationStatus: registrationStatus,
      nextStep: nextStep,
      expiresIn: expiresIn,
    );
  }
}
