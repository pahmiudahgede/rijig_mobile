import 'package:rijig_mobile/core/api/api_client.dart';
import 'package:rijig_mobile/core/container/export_vmod.dart';
import 'package:rijig_mobile/core/network/network_service.dart';
import 'package:rijig_mobile/core/storage/token_manager.dart';
import 'package:rijig_mobile/core/utils/getinfodevice.dart';
import 'package:rijig_mobile/features/auth/presentation/viewmodel/auth_viewmodel.dart';
import 'package:rijig_mobile/features/auth/repositories/auth_repository.dart';
import 'package:rijig_mobile/features/auth/service/auth_service.dart';
import 'package:rijig_mobile/features/pengepul/auth/presentation/viewmodel/pengepul_auth_viewmodel.dart';
import 'package:rijig_mobile/features/pengepul/auth/repository/pengepul_auth_repository.dart';
import 'package:rijig_mobile/features/pengepul/auth/services/pengepul_auth_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core services
  sl.registerLazySingleton<NetworkService>(() => NetworkService());
  sl.registerLazySingleton<ApiClient>(() => ApiClient());
  sl.registerLazySingleton<TokenManager>(() => TokenManager());
  sl.registerLazySingleton<DeviceIdHelper>(() => DeviceIdHelper());

  // Auth
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      apiClient: sl(),
      tokenManager: sl(),
      deviceIdHelper: sl(),
    ),
  );

  sl.registerLazySingleton<AuthService>(
    () => AuthService(sl(), tokenManager: sl()),
  );

  sl.registerFactory<AuthViewModel>(() => AuthViewModel(sl()));

  sl.registerLazySingleton<PengepulAuthRepository>(
    () => PengepulAuthRepository(
      apiClient: sl(),
      tokenManager: sl(),
      deviceIdHelper: sl(),
    ),
  );

  // Service
  sl.registerLazySingleton<PengepulAuthService>(
    () => PengepulAuthService(sl(), tokenManager: sl()),
  );

  // ViewModel
  sl.registerFactory<PengepulAuthViewModel>(() => PengepulAuthViewModel(sl()));

  // Initialize network service
  await sl<NetworkService>().initialize();
  sl.registerFactory(() => LoginViewModel(LoginService(LoginRepository())));
  sl.registerFactory(() => OtpViewModel(OtpService(OtpRepository())));
  sl.registerFactory(() => LogoutViewModel(LogoutService(LogoutRepository())));

  // ==================== TRASH & CART ====================

  // Trash - Repository
  sl.registerLazySingleton<TrashRepository>(
    () => TrashRepository(apiClient: sl()),
  );

  // Trash - Service
  sl.registerLazySingleton<TrashService>(() => TrashService(sl()));

  // Trash - ViewModel
  sl.registerFactory<TrashViewModel>(() => TrashViewModel(sl()));

  // Cart - Repository
  sl.registerLazySingleton<CartRepository>(
    () => CartRepository(apiClient: sl()),
  );

  // Cart - Service
  sl.registerLazySingleton<CartService>(() => CartService(sl()));

  // Cart - ViewModel
  sl.registerFactory<CartViewModel>(() => CartViewModel(sl()));

  // ==================== END TRASH & CART ====================

  // ==================== ABOUT & ARTICLE ====================

  // About - Repository
  sl.registerLazySingleton<AboutRepository>(
    () => AboutRepository(apiClient: sl()),
  );

  // About - Service
  sl.registerLazySingleton<AboutService>(() => AboutService(sl()));

  // About - ViewModels
  sl.registerFactory<AboutViewModel>(() => AboutViewModel(sl()));
  sl.registerFactory<AboutDetailViewModel>(() => AboutDetailViewModel(sl()));

  // Article - Repository
  sl.registerLazySingleton<ArticleRepository>(
    () => ArticleRepository(apiClient: sl()),
  );

  // Article - Service
  sl.registerLazySingleton<ArticleService>(() => ArticleService(sl()));

  // Article - ViewModels
  sl.registerFactory<ArticleViewModel>(() => ArticleViewModel(sl()));
  sl.registerFactory<ArticleDetailViewModel>(
    () => ArticleDetailViewModel(sl()),
  );

  // ==================== END ABOUT & ARTICLE ====================
}

class Dependencies {
  // Core
  static NetworkService get networkService => sl<NetworkService>();
  static ApiClient get apiClient => sl<ApiClient>();
  static TokenManager get tokenManager => sl<TokenManager>();
  static DeviceIdHelper get deviceIdHelper => sl<DeviceIdHelper>();

  // Masyarakat Auth
  static AuthRepository get authRepository => sl<AuthRepository>();
  static AuthService get authService => sl<AuthService>();
  static AuthViewModel get authViewModel => sl<AuthViewModel>();

  // Pengepul Auth
  static PengepulAuthRepository get pengepulAuthRepository =>
      sl<PengepulAuthRepository>();
  static PengepulAuthService get pengepulAuthService =>
      sl<PengepulAuthService>();
  static PengepulAuthViewModel get pengepulAuthViewModel =>
      sl<PengepulAuthViewModel>();
}

// ================================================================
// SERVICE LOCATOR EXTENSIONS FOR EASIER ACCESS
// ================================================================
extension ServiceLocatorX on GetIt {
  // Core Extensions
  NetworkService get networkService => get<NetworkService>();
  ApiClient get apiClient => get<ApiClient>();
  TokenManager get tokenManager => get<TokenManager>();
  DeviceIdHelper get deviceIdHelper => get<DeviceIdHelper>();

  // Masyarakat Extensions
  AuthRepository get authRepository => get<AuthRepository>();
  AuthService get authService => get<AuthService>();
  AuthViewModel get authViewModel => get<AuthViewModel>();

  // Pengepul Extensions
  PengepulAuthRepository get pengepulAuthRepository =>
      get<PengepulAuthRepository>();
  PengepulAuthService get pengepulAuthService => get<PengepulAuthService>();
  PengepulAuthViewModel get pengepulAuthViewModel =>
      get<PengepulAuthViewModel>();
}
