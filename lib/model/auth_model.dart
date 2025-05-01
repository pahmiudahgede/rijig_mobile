import 'package:rijig_mobile/core/api_services.dart';

class AuthModel {
  final int status;
  final String message;

  AuthModel({required this.status, required this.message});

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      status: json['meta']?['status'] ?? 0, 
      message: json['meta']?['message'] ?? '',
    );
  }
}

class AuthService {
  final ApiService _apiService = ApiService();

  Future<AuthModel?> login(String phone) async {
    try {
      var response = await _apiService.post('/authmasyarakat/auth', {
        'phone': phone,
      });
      return AuthModel.fromJson(response);
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
