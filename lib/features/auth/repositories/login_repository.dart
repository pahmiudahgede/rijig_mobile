import 'package:rijig_mobile/core/api/api_client.dart';
import 'package:rijig_mobile/features/auth/model/login_model.dart';

class LoginRepository {
  final ApiClient _https = ApiClient();

  Future<LoginResponse> loginOrRegister(String phone) async {
    final response = await _https.post(
      '/authmasyarakat/auth',
      body: {'phone': phone},
    );
    return LoginResponse.fromJson(response as Map<String, dynamic>);
  }
}
