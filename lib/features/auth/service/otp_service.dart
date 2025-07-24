import 'package:rijig_mobile/core/storage/secure_storage.dart';
import 'package:rijig_mobile/features/auth/model/otp_model.dart';
import 'package:rijig_mobile/features/auth/repositories/otp_repository.dart';

class OtpService {
  final OtpRepository _otpRepository;

  OtpService(this._otpRepository);

  Future<String> getDeviceInfo() async {
    return await getDeviceInfo();
  }

  Future<void> storeSessionData(
    String token,
    String userId,
    String userRole,
  ) async {
    await SecureStorage().writeSecureData('token', token);
    await SecureStorage().writeSecureData('user_id', userId);
    await SecureStorage().writeSecureData('user_role', userRole);
  }

  Future<VerifOkResponse> verifyOtp(OtpModel otpModel) async {
    try {
      return await _otpRepository.verifyOtp(otpModel);
    } catch (e) {
      throw Exception('OTP Verification failed: $e');
    }
  }
}
