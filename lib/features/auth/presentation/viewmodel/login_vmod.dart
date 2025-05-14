import 'package:flutter/material.dart';
import 'package:rijig_mobile/features/auth/model/login_model.dart';
import 'package:rijig_mobile/features/auth/service/login_service.dart';

class LoginViewModel extends ChangeNotifier {
  final LoginService _loginService;

  LoginViewModel(this._loginService);

  bool isLoading = false;
  String? errorMessage;
  LoginResponse? loginResponse;

  Future<void> loginOrRegister(String phone) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      loginResponse = await _loginService.loginOrRegister(phone);
    } catch (e) {
      errorMessage = "Error: ${e.toString()}";
    }

    isLoading = false;
    notifyListeners();
  }
}
