class OtpRequest {
  final String phone;
  final String roleId;

  OtpRequest({required this.phone, required this.roleId});

  Map<String, dynamic> toJson() {
    return {'phone': phone, 'role_name': roleId};
  }
}

class OtpVerification {
  final String phone;
  final String otp;
  final String deviceId;
  final String roleId;

  OtpVerification({
    required this.phone,
    required this.otp,
    required this.deviceId,
    required this.roleId,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'otp': otp,
      'device_id': deviceId,
      'role_name': roleId,
    };
  }
}

class UserProfile {
  final String name;
  final String phone;
  final String gender;
  final String dateOfBirth;
  final String placeOfBirth;

  UserProfile({
    required this.name,
    required this.phone,
    required this.gender,
    required this.dateOfBirth,
    required this.placeOfBirth,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'gender': gender,
      'dateofbirth': dateOfBirth,
      'placeofbirth': placeOfBirth,
    };
  }
}

class PinRequest {
  final String userPin;

  PinRequest({required this.userPin});

  Map<String, dynamic> toJson() {
    return {'userpin': userPin};
  }
}

class AuthResult {
  final bool isSuccess;
  final String message;
  final String? nextStep;
  final String? registrationStatus;
  final String? tokenType;
  final String? error;

  AuthResult({
    required this.isSuccess,
    required this.message,
    this.nextStep,
    this.registrationStatus,
    this.tokenType,
    this.error,
  });

  factory AuthResult.success({
    required String message,
    String? nextStep,
    String? registrationStatus,
    String? tokenType,
  }) {
    return AuthResult(
      isSuccess: true,
      message: message,
      nextStep: nextStep,
      registrationStatus: registrationStatus,
      tokenType: tokenType,
    );
  }

  factory AuthResult.failure({required String message, String? error}) {
    return AuthResult(isSuccess: false, message: message, error: error);
  }
}

class RefreshTokenRequest {
  final String refreshToken;

  RefreshTokenRequest({required this.refreshToken});

  Map<String, dynamic> toJson() {
    return {'refresh_token': refreshToken};
  }
}

enum AuthState {
  initial,
  loading,
  otpSent,
  otpVerified,
  profileUpdated,
  pinCreated,
  authenticated,
  error,
}

enum RegistrationStep {
  requestOtp,
  verifyOtp,
  completeProfile,
  createPin,
  completed,
}
