import 'package:flutter/material.dart';
import 'package:rijig_mobile/core/api_services.dart';
import 'package:rijig_mobile/model/auth_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool isLoading = false;
  String? errorMessage;
  AuthModel? authModel;

  Future<void> login(String phone) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      var response = await _apiService.post('/authmasyarakat/auth', {
        'phone': phone,
      });

      authModel = AuthModel.fromJson(response);

      if (authModel?.status == 200) {
      } else {
        errorMessage = authModel?.message ?? 'Failed to send OTP';
      }
    } catch (e) {
      if (e is NetworkException) {
        errorMessage = e.message;
      } else {
        errorMessage = 'Something went wrong. Please try again later.';
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyOtp(String phone, String otp) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      var response = await _apiService.post('/authmasyarakat/verify-otp', {
        'phone': phone,
        'otp': otp,
      });

      if (response['meta']['status'] == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', response['data']['token']);
        await prefs.setString('user_id', response['data']['user_id']);
        await prefs.setString('user_role', response['data']['user_role']);
        await prefs.setBool('isLoggedIn', true);

        debugPrint("berhasil login");
      } else {
        errorMessage = response['meta']['message'] ?? 'Failed to verify OTP';
      }
    } catch (e) {
      if (e is NetworkException) {
        errorMessage = e.message;
      } else {
        errorMessage = 'Something went wrong. Please try again later.';
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
