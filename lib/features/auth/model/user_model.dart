class UserModel {
  final String userId;
  final String userRole;
  final String token;

  UserModel({required this.userId, required this.userRole, required this.token});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['data']['user_id'],
      userRole: json['data']['user_role'],
      token: json['data']['token'],
    );
  }
}
