import 'package:go_router/go_router.dart';
import 'package:rijig_mobile/core/navigation.dart';
import 'package:rijig_mobile/screen/app/home/home_screen.dart';
import 'package:rijig_mobile/screen/app/requestpick/requestpickup_screen.dart';
// import 'package:rijig_mobile/screen/auth/login_screen.dart';
import 'package:rijig_mobile/screen/auth/otp_screen.dart';
import 'package:rijig_mobile/screen/launch/onboardingpage_screen.dart';

final router = GoRouter(
  routes: [
    // GoRoute(path: '/', builder: (context, state) => SplashScreen()),
    GoRoute(path: '/', builder: (context, state) => NavigationPage()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => OnboardongPageScreen(),
    ),
    GoRoute(
      path: '/navigasi',
      builder: (context, state) {
        dynamic data = state.extra;
        return NavigationPage(data: data);
      },
    ),
    GoRoute(
      path: '/verif-otp',
      builder: (context, state) {
        final phone = state.extra as String?;
        return VerifotpScreen(phone: phone!);
      },
    ),
    GoRoute(path: '/home', builder: (context, state) => HomeScreen()),
    GoRoute(
      path: '/requestpickup',
      builder: (context, state) => RequestPickScreen(),
    ),
  ],
);
