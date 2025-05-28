import 'package:rijig_mobile/core/utils/exportimportview.dart';

final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => SplashScreen()),
    GoRoute(path: '/trashview', builder: (context, state) => TestRequestPickScreen()),
    GoRoute(path: '/ordersumary', builder: (context, state) => OrderSummaryScreen()),
    GoRoute(path: '/pinsecureinput', builder: (context, state) => SecurityCodeScreen()),
    GoRoute(
      path: '/cmapview',
      builder: (context, state) => CollectorRouteMapScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      pageBuilder: (context, state) {
        var key = state.pageKey;
        return transisi(OnboardingPageScreen(), key);
      },
    ),
    GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
    GoRoute(path: '/clogin', builder: (context, state) => CloginScreen()),
    GoRoute(
      path: '/welcomec',
      builder: (context, state) => WelcomeCollectorScreen(),
    ),
    GoRoute(
      path: '/verifidentity',
      builder: (context, state) => UploadKtpScreen(),
    ),
    GoRoute(
      path: '/berandapengepul',
      builder: (context, state) => ChomeCollectorScreen(),
    ),
    GoRoute(
      path: '/cpickuphistory',
      builder: (context, state) => PickupHistoryScreen(),
    ),

    // Rute untuk verifikasi OTP dengan ekstraksi data dari path
    GoRoute(
      path: '/verif-otp',
      builder: (context, state) {
        dynamic phoneNumber = state.extra;
        return VerifOtpScreen(phoneNumber: phoneNumber);
      },
    ),
    GoRoute(
      path: '/cverif-otp',
      builder: (context, state) {
        // dynamic phoneNumber = state.extra;
        return CverifOtpScreen();
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
    GoRoute(
      path: '/dataperforma',
      builder: (context, state) => DatavisualizedScreen(),
    ),
    GoRoute(path: '/activity', builder: (context, state) => ActivityScreen()),
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

CustomTransitionPage transisi(Widget page, key) {
  return CustomTransitionPage(
    transitionDuration: const Duration(milliseconds: 1200),
    child: page,
    key: key,
    transitionsBuilder: (key, animation, secondaryAnimation, page) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
        child: page,
      );
    },
  );
}
