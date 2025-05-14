import 'package:rijig_mobile/features/auth/model/login_model.dart';
import 'package:rijig_mobile/features/auth/repositories/login_repository.dart';

class LoginService {
  final LoginRepository _loginRepository;

  LoginService(this._loginRepository);

  Future<LoginResponse> loginOrRegister(String phone) async {
    try {
      return await _loginRepository.loginOrRegister(phone);
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }
}
