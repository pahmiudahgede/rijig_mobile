import 'package:flutter/material.dart';
import 'package:rijig_mobile/model/auth_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool isLoading = false;
  String? errorMessage;
  AuthModel? authModel;

  Future<void> login(String phone) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      authModel = await _authService.login(phone);

      if (authModel?.status != 200) {
        errorMessage = authModel?.message ?? 'Failed to send OTP';
      }
    } catch (e) {
      errorMessage = 'Error: $e';
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

      var response = await _authService.verifyOtp(phone, otp);

      if (response['meta'] != null && response['meta']['status'] == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', response['data']['token']);
        await prefs.setString('user_id', response['data']['user_id']);
        await prefs.setString('user_role', response['data']['user_role']);
        await prefs.setBool('isLoggedIn', true);

        authModel = AuthModel.fromJson(response['data']);
      } else {
        errorMessage = response['meta']?['message'] ?? 'Failed to verify OTP';
      }
    } catch (e) {
      errorMessage = 'Error: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
