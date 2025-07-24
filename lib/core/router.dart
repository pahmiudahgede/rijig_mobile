import 'package:rijig_mobile/core/utils/exportimportview.dart';
import 'package:rijig_mobile/features/launch/screen/auth_checker_screen.dart';
import 'package:rijig_mobile/features/launch/screen/welcome_role_selection_screen.dart';
import 'package:rijig_mobile/features/pengepul/auth/presentation/screens/approval_waiting_screen.dart';
import 'package:rijig_mobile/features/pengepul/auth/presentation/screens/ktp_form_screen.dart';
import 'package:rijig_mobile/features/pengepul/auth/presentation/screens/pengepul_otp_verification_screen.dart';
import 'package:rijig_mobile/features/pengepul/auth/presentation/screens/pengepul_phone_input_screen.dart';
import 'package:rijig_mobile/features/pengepul/auth/presentation/screens/pengepul_pin_input_screen.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/auth-check',
      builder: (context, state) => const AuthCheckerScreen(),
    ),

    // Phone input for login
    GoRoute(
      path: '/xlogin',
      builder: (context, state) => const PhoneInputScreen(isLogin: true),
    ),

    // Phone input for register
    GoRoute(
      path: '/xregister',
      builder: (context, state) => const PhoneInputScreen(isLogin: false),
    ),

    // OTP verification with phone data
    GoRoute(
      path: '/xotp-verification',
      builder: (context, state) {
        final isLogin = state.uri.queryParameters['isLogin'] == 'true';
        return OtpVerificationScreen(isLogin: isLogin);
      },
    ),

    // Profile form (only for register)
    GoRoute(
      path: '/xprofile-form',
      builder: (context, state) => const ProfileFormScreen(),
    ),

    // PIN input
    GoRoute(
      path: '/xpin-input',
      builder: (context, state) {
        final isLogin = state.uri.queryParameters['isLogin'] == 'true';
        return PinInputScreen(isLogin: isLogin);
      },
    ),

    // Home screen (dashboard)
    // GoRoute(path: '/xhome', builder: (context, state) => const HomeScreen()),

    GoRoute(
      path: '/pengepul-login',
      builder:
          (context, state) => const PengepulPhoneInputScreen(isLogin: true),
    ),

    GoRoute(
      path: '/pengepul-register',
      builder:
          (context, state) => const PengepulPhoneInputScreen(isLogin: false),
    ),

    // OTP Verification
    GoRoute(
      path: '/pengepul-otp-verification',
      builder: (context, state) {
        final isLogin = state.uri.queryParameters['isLogin'] == 'true';
        return PengepulOtpVerificationScreen(isLogin: isLogin);
      },
    ),

    // KTP Form
    GoRoute(
      path: '/pengepul-ktp-form',
      builder: (context, state) => const KtpFormScreen(),
    ),

    // Approval Waiting
    GoRoute(
      path: '/pengepul-approval-waiting',
      builder: (context, state) => const ApprovalWaitingScreen(),
    ),

    // PIN Input
    GoRoute(
      path: '/pengepul-pin-input',
      builder: (context, state) {
        final isLogin = state.uri.queryParameters['isLogin'] == 'true';
        return PengepulPinInputScreen(isLogin: isLogin);
      },
    ),
    GoRoute(path: '/', builder: (context, state) => SplashScreen()),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeRoleSelectionScreen(),
    ),
    // GoRoute(path: '/', builder: (context, state) => ChomeCollectorScreen()),
    GoRoute(
      path: '/deteksiwajah',
      builder: (context, state) => FaceDetectionView(),
    ),
    /* GoRoute(
      path: '/',
      builder: (context, state) => UploadKtpScreen(),
    ), */
    GoRoute(path: '/trashview', builder: (context, state) => TrashPickScreen()),
    GoRoute(
      path: '/ordersumary',
      builder: (context, state) => CartSummaryScreen(),
    ),
    GoRoute(
      path: '/pinsecureinput',
      builder: (context, state) => SecurityCodeScreen(),
    ),
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
      path: '/notifikasi',
      builder: (context, state) => NotificationScreen(),
    ),
    GoRoute(path: '/chatlist', builder: (context, state) => ChatListScreen()),
    // Router config
    GoRoute(
      path: '/chatroom/:contactId',
      builder: (context, state) {
        final contactName = state.uri.queryParameters['name'] ?? 'Unknown';
        final contactImage = state.uri.queryParameters['image'] ?? '';
        final isOnline = state.uri.queryParameters['online'] == 'true';

        return ChatRoomScreen(
          contactName: contactName,
          contactImage: contactImage,
          isOnline: isOnline,
        );
      },
    ),

    GoRoute(
      path: '/dataperforma',
      builder: (context, state) => DatavisualizedScreen(),
    ),
    GoRoute(path: '/activity', builder: (context, state) => ActivityScreen()),
    GoRoute(path: '/profil', builder: (context, state) => ProfilScreen()),
    GoRoute(path: '/akunprofil', builder: (context, state) => AccountScreen()),
    GoRoute(path: '/address', builder: (context, state) => AddressScreen()),
    GoRoute(
      path: '/addaddress',
      builder: (context, state) => AddAddressScreen(),
    ),
    GoRoute(
      path: '/editaddress',
      builder: (context, state) {
        dynamic address = state.extra;
        return EditAddressScreen(address: address);
      },
    ),

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

    // ==============================pengepul==============================
    GoRoute(
      path: '/stoksampahpengepul',
      builder: (context, state) {
        return StokSampahScreen();
      },
    ),
    GoRoute(
      path: '/riwayatpembelian',
      builder: (context, state) {
        return RiwayatPembelianScreen();
      },
    ),
    GoRoute(
      path: '/setor',
      builder: (context, state) {
        return PenyetoranScreen();
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
