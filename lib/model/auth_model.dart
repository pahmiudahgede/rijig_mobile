import 'package:rijig_mobile/core/api_services.dart';
import 'package:rijig_mobile/model/response_model.dart';

class AuthModel {
  final ApiService _apiService = ApiService();

  Future<ResponseModel?> login(String phone) async {
    try {
      var response = await _apiService.post('/authmasyarakat/auth', {
        'phone': phone,
      });
      return ResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<ResponseModel?> verifyOtp(
    String phone,
    String otp,
    String deviceId,
  ) async {
    try {
      var response = await _apiService.post('/authmasyarakat/verify-otp', {
        'phone': phone,
        'otp': otp,
        'device_id': deviceId,
      });
      return ResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
