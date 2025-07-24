import 'dart:io';

class KtpIdentity {
  final String identificationNumber;
  final String fullname;
  final String placeOfBirth;
  final String dateOfBirth;
  final String gender;
  final String bloodType;
  final String province;
  final String district;
  final String subdistrict;
  final String hamlet;
  final String village;
  final String neighbourhood;
  final String postalCode;
  final String religion;
  final String maritalStatus;
  final String job;
  final String citizenship;
  final String validUntil;
  final File cardPhoto;

  KtpIdentity({
    required this.identificationNumber,
    required this.fullname,
    required this.placeOfBirth,
    required this.dateOfBirth,
    required this.gender,
    required this.bloodType,
    required this.province,
    required this.district,
    required this.subdistrict,
    required this.hamlet,
    required this.village,
    required this.neighbourhood,
    required this.postalCode,
    required this.religion,
    required this.maritalStatus,
    required this.job,
    required this.citizenship,
    required this.validUntil,
    required this.cardPhoto,
  });

  Map<String, dynamic> toFormData() {
    return {
      'identificationumber': identificationNumber,
      'fullname': fullname,
      'placeofbirth': placeOfBirth,
      'dateofbirth': dateOfBirth,
      'gender': gender,
      'bloodtype': bloodType,
      'province': province,
      'district': district,
      'subdistrict': subdistrict,
      'hamlet': hamlet,
      'village': village,
      'neighbourhood': neighbourhood,
      'postalcode': postalCode,
      'religion': religion,
      'maritalstatus': maritalStatus,
      'job': job,
      'citizenship': citizenship,
      'validuntil': validUntil,
      'cardphoto': cardPhoto,
    };
  }
}

class ApprovalStatus {
  final String message;
  final String registrationStatus;
  final String nextStep;
  final String? accessToken;
  final String? refreshToken;
  final String? tokenType;
  final int? expiresIn;
  final String? sessionId;

  ApprovalStatus({
    required this.message,
    required this.registrationStatus,
    required this.nextStep,
    this.accessToken,
    this.refreshToken,
    this.tokenType,
    this.expiresIn,
    this.sessionId,
  });

  factory ApprovalStatus.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return ApprovalStatus(
      message: data['message'] ?? '',
      registrationStatus: data['registration_status'] ?? '',
      nextStep: data['next_step'] ?? '',
      accessToken: data['access_token'],
      refreshToken: data['refresh_token'],
      tokenType: data['token_type'],
      expiresIn: data['expires_in'],
      sessionId: data['session_id'],
    );
  }

  bool get isApproved => registrationStatus == 'approved';
  bool get isAwaitingApproval => registrationStatus == 'awaiting_approval';
  bool get isRejected => registrationStatus == 'rejected';
}

class PengepulOtpRequest {
  final String phone;
  final String roleId;

  PengepulOtpRequest({required this.phone, required this.roleId});

  Map<String, dynamic> toJson() {
    return {'phone': phone, 'role_name': roleId};
  }
}

class PengepulOtpVerification {
  final String phone;
  final String otp;
  final String deviceId;
  final String roleId;

  PengepulOtpVerification({
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

class PengepulPinRequest {
  final String userPin;

  PengepulPinRequest({required this.userPin});

  Map<String, dynamic> toJson() {
    return {'userpin': userPin};
  }
}

class PengepulAuthResult {
  final bool isSuccess;
  final String message;
  final String? nextStep;
  final String? registrationStatus;
  final String? tokenType;
  final String? error;

  PengepulAuthResult({
    required this.isSuccess,
    required this.message,
    this.nextStep,
    this.registrationStatus,
    this.tokenType,
    this.error,
  });

  factory PengepulAuthResult.success({
    required String message,
    String? nextStep,
    String? registrationStatus,
    String? tokenType,
  }) {
    return PengepulAuthResult(
      isSuccess: true,
      message: message,
      nextStep: nextStep,
      registrationStatus: registrationStatus,
      tokenType: tokenType,
    );
  }

  factory PengepulAuthResult.failure({required String message, String? error}) {
    return PengepulAuthResult(isSuccess: false, message: message, error: error);
  }
}

enum PengepulAuthState {
  initial,
  loading,
  otpSent,
  otpVerified,
  ktpUploaded,
  awaitingApproval,
  approved,
  rejected,
  pinCreated,
  authenticated,
  error,
}

enum PengepulRegistrationStep {
  requestOtp,
  verifyOtp,
  uploadKtp,
  awaitingApproval,
  createPin,
  completed,
}

class KtpValidator {
  static String? validateNik(String? nik) {
    if (nik == null || nik.isEmpty) {
      return 'NIK tidak boleh kosong';
    }

    if (nik.length != 16) {
      return 'NIK harus 16 digit';
    }

    if (!RegExp(r'^\d{16}$').hasMatch(nik)) {
      return 'NIK hanya boleh berisi angka';
    }

    return null;
  }

  static String? validateBloodType(String? bloodType) {
    if (bloodType == null || bloodType.isEmpty) {
      return 'Golongan darah harus dipilih';
    }

    List<String> validBloodTypes = ['a', 'b', 'ab', 'o'];
    if (!validBloodTypes.contains(bloodType.toLowerCase())) {
      return 'Golongan darah tidak valid';
    }

    return null;
  }

  static String? validateMaritalStatus(String? status) {
    if (status == null || status.isEmpty) {
      return 'Status perkawinan harus dipilih';
    }

    List<String> validStatuses = [
      'belum kawin',
      'kawin',
      'cerai hidup',
      'cerai mati',
    ];
    if (!validStatuses.contains(status.toLowerCase())) {
      return 'Status perkawinan tidak valid';
    }

    return null;
  }

  static String? validateReligion(String? religion) {
    if (religion == null || religion.isEmpty) {
      return 'Agama harus dipilih';
    }

    List<String> validReligions = [
      'islam',
      'kristen',
      'katolik',
      'hindu',
      'buddha',
      'khonghucu',
    ];
    if (!validReligions.contains(religion.toLowerCase())) {
      return 'Agama tidak valid';
    }

    return null;
  }

  static String? validatePostalCode(String? postalCode) {
    if (postalCode == null || postalCode.isEmpty) {
      return 'Kode pos tidak boleh kosong';
    }

    if (postalCode.length != 5) {
      return 'Kode pos harus 5 digit';
    }

    if (!RegExp(r'^\d{5}$').hasMatch(postalCode)) {
      return 'Kode pos hanya boleh berisi angka';
    }

    return null;
  }

  static String? validateImageFile(File? file) {
    if (file == null) {
      return 'Foto KTP harus dipilih';
    }

    if (!file.existsSync()) {
      return 'File tidak ditemukan';
    }

    int fileSizeInBytes = file.lengthSync();
    if (fileSizeInBytes > 10 * 1024 * 1024) {
      return 'Ukuran file maksimal 10MB';
    }

    String extension = file.path.split('.').last.toLowerCase();
    List<String> allowedExtensions = ['jpg', 'jpeg', 'png'];
    if (!allowedExtensions.contains(extension)) {
      return 'Format file harus JPG, JPEG, atau PNG';
    }

    return null;
  }
}
