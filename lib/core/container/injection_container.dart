import 'package:rijig_mobile/core/container/export_vmod.dart';

final sl = GetIt.instance;

void init() {
  sl.registerFactory(() => LoginViewModel(LoginService(LoginRepository())));
  sl.registerFactory(() => OtpViewModel(OtpService(OtpRepository())));
  sl.registerFactory(() => LogoutViewModel(LogoutService(LogoutRepository())));

  sl.registerFactory(
    () => TrashViewModel(TrashCategoryService(TrashCategoryRepository())),
  );
  sl.registerFactory(() => AboutViewModel(AboutService(AboutRepository())));
  sl.registerFactory(() => AboutDetailViewModel(AboutService(AboutRepository())));
  sl.registerFactory(() => ArticleViewModel(ArticleService(ArticleRepository())));
  sl.registerFactory(() => CartViewModel(CartRepository()));
}
