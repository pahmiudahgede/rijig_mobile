import 'package:rijig_mobile/core/utils/exportimportview.dart';

final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => SplashScreen()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => OnboardingPageScreen(),
    ),
    GoRoute(path: '/login', builder: (context, state) => LoginScreen()),

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
  ],
);
