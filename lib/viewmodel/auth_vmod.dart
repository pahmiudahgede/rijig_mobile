import 'package:flutter/material.dart';
import 'package:rijig_mobile/core/getinfodevice.dart';
import 'package:rijig_mobile/model/response_model.dart';
import 'package:rijig_mobile/model/auth_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rijig_mobile/model/userpin_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthModel _authModel = AuthModel();
  final PinModel _pinModel = PinModel();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  bool isLoading = false;
  String? errorMessage;
  ResponseModel? authModel;
  bool? pinExists;

  Future<void> login(String phone) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final response = await _authModel.login(phone);

      if (response != null && response.status == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', false);
        authModel = response;
      } else {
        errorMessage = response?.message ?? 'Failed to send OTP';
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

      String deviceId = await getDeviceId();

      var response = await _authModel.verifyOtp(phone, otp, deviceId);

      if (response != null && response.status == 200) {
        await _secureStorage.write(
          key: 'token',
          value: response.data?['token'],
        );
        await _secureStorage.write(
          key: 'user_id',
          value: response.data?['user_id'],
        );
        await _secureStorage.write(
          key: 'user_role',
          value: response.data?['user_role'],
        );

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        pinExists = await _pinModel.checkPinStatus();

        authModel = response;
        notifyListeners();
      } else {
        errorMessage = response?.message ?? 'Failed to verify OTP';
      }
    } catch (e) {
      errorMessage = 'Error: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: 'token');
  }

  Future<String?> getUserId() async {
    return await _secureStorage.read(key: 'user_id');
  }

  Future<String?> getUserRole() async {
    return await _secureStorage.read(key: 'user_role');
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: 'token');
    await _secureStorage.delete(key: 'user_id');
    await _secureStorage.delete(key: 'user_role');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    notifyListeners();
  }

  Future<bool> isUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }
}
