import 'package:rijig_mobile/core/api/api_services.dart';
import 'package:rijig_mobile/features/auth/model/otp_model.dart';

class OtpRepository {
  final Https _https = Https();

  Future<VerifOkResponse> verifyOtp(OtpModel otpModel) async {
    final response = await _https.post(
      '/authmasyarakat/verify-otp',
      body: otpModel.toJson(),
    );
    return VerifOkResponse.fromJson(response);
  }
}
