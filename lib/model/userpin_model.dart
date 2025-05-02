import 'package:rijig_mobile/core/api_services.dart';
import 'package:rijig_mobile/model/response_model.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<ResponseModel?> cekPinStatus(String userid) async {
    try {
      var response = await _apiService.get('/cek-pin-status');
      return ResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    try {
      var response = await _apiService.post('/authmasyarakat/verify-otp', {
        'phone': phone,
        'otp': otp,
      });
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
