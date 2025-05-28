import 'package:rijig_mobile/core/container/export_vmod.dart';
// import 'package:rijig_mobile/features/cart/presentation/viewmodel/trashcart_vmod.dart';
// import 'package:rijig_mobile/features/cart/repositories/trashcart_repo.dart';
// import 'package:rijig_mobile/features/cart/service/trashcart_service.dart';

final sl = GetIt.instance;

void init() {
  sl.registerFactory(() => LoginViewModel(LoginService(LoginRepository())));
  sl.registerFactory(() => OtpViewModel(OtpService(OtpRepository())));
  sl.registerFactory(() => LogoutViewModel(LogoutService(LogoutRepository())));

  sl.registerLazySingleton<ITrashCategoryRepository>(
    () => TrashCategoryRepository(),
  );

  sl.registerLazySingleton<ITrashCategoryService>(
    () => TrashCategoryService(sl<ITrashCategoryRepository>()),
  );

  sl.registerFactory<TrashViewModel>(
    () => TrashViewModel(sl<ITrashCategoryService>()),
  );

  sl.registerFactory(() => AboutViewModel(AboutService(AboutRepository())));
  sl.registerFactory(
    () => AboutDetailViewModel(AboutService(AboutRepository())),
  );
  sl.registerFactory(
    () => ArticleViewModel(ArticleService(ArticleRepository())),
  );
  // sl.registerFactory(() => CartViewModel(CartRepository()));
  sl.registerLazySingleton<CartRepository>(
  () => CartRepositoryImpl(),
);

sl.registerLazySingleton<CartService>(
  () => CartServiceImpl(repository: sl<CartRepository>()),
);

sl.registerFactory<CartViewModel>(
  () => CartViewModel(cartService: sl<CartService>()),
);
}
