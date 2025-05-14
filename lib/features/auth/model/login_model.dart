class LoginModel {
  final String phone;

  LoginModel({required this.phone});

  Map<String, dynamic> toJson() {
    return {'phone': phone};
  }
}

class LoginResponse {
  final String message;

  LoginResponse({required this.message});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(message: json['meta']['message']);
  }
}
