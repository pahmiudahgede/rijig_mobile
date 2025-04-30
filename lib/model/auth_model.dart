class AuthModel {
  final int status;
  final String message;

  AuthModel({required this.status, required this.message});

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      status: json['meta']['status'],
      message: json['meta']['message'],
    );
  }
}
