class OtpModel {
  final String phone;
  final String otp;
  final String deviceId;

  OtpModel({required this.phone, required this.otp, required this.deviceId});

  factory OtpModel.fromJson(Map<String, dynamic> json) {
    return OtpModel(
      phone: json['phone'],
      otp: json['otp'],
      deviceId: json['device_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'phone': phone, 'otp': otp, 'device_id': deviceId};
  }
}

class VerifOkResponse {
  final String userId;
  final String userRole;
  final String token;

  VerifOkResponse({
    required this.userId,
    required this.userRole,
    required this.token,
  });

  factory VerifOkResponse.fromJson(Map<String, dynamic> json) {
    return VerifOkResponse(
      userId: json['data']['user_id'],
      userRole: json['data']['user_role'],
      token: json['data']['token'],
    );
  }
}
