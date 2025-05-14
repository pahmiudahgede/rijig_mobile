import 'package:rijig_mobile/core/storage/secure_storage.dart';
import 'package:rijig_mobile/features/auth/repositories/logout_repository.dart';

class LogoutService {
  final LogoutRepository _logoutRepository;
  final _storage = SecureStorage();

  LogoutService(this._logoutRepository);

  Future<void> clearSession() async {
    await _storage.deleteSecureData('token');
    await _storage.deleteSecureData('user_id');
    await _storage.deleteSecureData('user_role');
  }

  Future<void> logout() async {
    try {
      await _logoutRepository.logout();
      await clearSession();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }
}
