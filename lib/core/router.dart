import 'package:rijig_mobile/core/utils/exportimportview.dart';
import 'package:rijig_mobile/features/auth/presentation/screen/collector/clogin_screen.dart';
import 'package:rijig_mobile/features/auth/presentation/screen/collector/welcome_collector_screen.dart';

final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => SplashScreen()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => OnboardingPageScreen(),
    ),
    GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
    GoRoute(path: '/clogin', builder: (context, state) => CloginScreen()),
    GoRoute(path: '/welcomec', builder: (context, state) => WelcomeCollectorScreen()),

    // Rute untuk verifikasi OTP dengan ekstraksi data dari path
    GoRoute(
      path: '/verif-otp',
      builder: (context, state) {
        dynamic phoneNumber = state.extra;
        return VerifOtpScreen(phoneNumber: phoneNumber);
      },
    ),

    // GoRoute(path: '/setpin', builder: (context, state) => InputPinScreen()),
    // GoRoute(path: '/verifpin', builder: (context, state) => VerifPinScreen()),

    // Rute dengan parameter dinamis untuk halaman navigasi
    GoRoute(
      path: '/navigasi',
      builder: (context, state) {
        final data = state.extra;
        return NavigationPage(data: data);
      },
    ),

    // Rute untuk halaman-halaman utama
    GoRoute(path: '/home', builder: (context, state) => HomeScreen()),
    GoRoute(path: '/activity', builder: (context, state) => ActivityScreen()),
    GoRoute(
      path: '/requestpickup',
      builder: (context, state) => RequestPickScreen(),
    ),
    GoRoute(path: '/cart', builder: (context, state) => CartScreen()),
    GoRoute(path: '/profil', builder: (context, state) => ProfilScreen()),

    GoRoute(
      path: '/aboutdetail',
      builder: (context, state) {
        dynamic data = state.extra;
        return AboutDetailScreenComp(data: data);
      },
    ),

    GoRoute(
      path: '/artikeldetail',
      builder: (context, state) {
        dynamic data = state.extra;
        return ArticleDetailScreen(data: data);
      },
    ),

    GoRoute(
      path: '/pickupmethod',
      builder: (context, state) {
        dynamic data = state.extra;
        return PickupScreen(data: data);
      },
    ),

    GoRoute(
      path: '/pilihpengepul',
      builder: (context, state) {
        return SelectCollectorScreen();
      },
    ),
  ],
);
