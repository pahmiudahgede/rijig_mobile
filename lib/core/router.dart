import 'package:go_router/go_router.dart';
import 'package:rijig_mobile/screen/auth/login_screen.dart';
import 'package:rijig_mobile/screen/auth/otp_screen.dart';

final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => LoginScreen()),
    GoRoute(path: '/verif-otp', builder: (context, state) => VerifotpScreen()),
  ],
);
