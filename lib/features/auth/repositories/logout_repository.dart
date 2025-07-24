import 'package:rijig_mobile/core/api/api_client.dart';
import 'package:rijig_mobile/features/auth/model/logout_model.dart';

class LogoutRepository {
  final ApiClient _https = ApiClient();

  Future<LogoutResponse> logout() async {
    final response = await _https.post('/authmasyarakat/logout');
    return LogoutResponse.fromJson(response as Map<String, dynamic>);
  }
}
