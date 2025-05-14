import 'package:flutter/material.dart';
import 'package:rijig_mobile/features/auth/service/logout_service.dart';

class LogoutViewModel extends ChangeNotifier {
  final LogoutService _logoutService;

  LogoutViewModel(this._logoutService);

  bool isLoading = false;
  String? errorMessage;

  Future<void> logout() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _logoutService.logout();
    } catch (e) {
      errorMessage = "Error: ${e.toString()}";
    }

    isLoading = false;
    notifyListeners();
  }
}
