import 'package:flutter/material.dart';
import 'package:rijig_mobile/features/auth/model/otp_model.dart';
import 'package:rijig_mobile/features/auth/service/otp_service.dart';

class OtpViewModel extends ChangeNotifier {
  final OtpService _otpService;

  OtpViewModel(this._otpService);

  bool isLoading = false;
  String? errorMessage;
  VerifOkResponse? authResponse;

  Future<void> verifyOtp(String phone, String otp) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      String deviceId = await _otpService.getDeviceInfo();

      OtpModel otpModel = OtpModel(phone: phone, otp: otp, deviceId: deviceId);

      authResponse = await _otpService.verifyOtp(otpModel);

      if (authResponse != null) {
        await _otpService.storeSessionData(
          authResponse!.token,
          authResponse!.userId,
          authResponse!.userRole,
        );
      }
    } catch (e) {
      errorMessage = "Error: ${e.toString()}";
    }

    isLoading = false;
    notifyListeners();
  }
}
