import 'package:get_it/get_it.dart';
import 'package:rijig_mobile/features/auth/presentation/viewmodel/login_vmod.dart';
import 'package:rijig_mobile/features/auth/presentation/viewmodel/otp_vmod.dart';
import 'package:rijig_mobile/features/auth/repositories/login_repository.dart';
import 'package:rijig_mobile/features/auth/repositories/otp_repository.dart';
import 'package:rijig_mobile/features/auth/service/login_service.dart';
import 'package:rijig_mobile/features/auth/service/otp_service.dart';

final sl = GetIt.instance;

void init() {
  sl.registerFactory(() => LoginViewModel(LoginService(LoginRepository())));
  sl.registerFactory(() => OtpViewModel(OtpService(OtpRepository())));
}
