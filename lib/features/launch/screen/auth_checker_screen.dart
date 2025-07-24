import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rijig_mobile/core/storage/token_manager.dart';
import 'package:rijig_mobile/features/auth/presentation/viewmodel/auth_viewmodel.dart';
import 'package:rijig_mobile/features/pengepul/auth/presentation/viewmodel/pengepul_auth_viewmodel.dart';

class AuthCheckerScreen extends StatefulWidget {
  const AuthCheckerScreen({super.key});

  @override
  State<AuthCheckerScreen> createState() => _AuthCheckerScreenState();
}

class _AuthCheckerScreenState extends State<AuthCheckerScreen> {
  final TokenManager _tokenManager = TokenManager();
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    if (_hasNavigated) return;

    try {
      String? userRole = await _tokenManager.getUserRole();

      debugPrint('=== AUTH CHECKER ===');
      debugPrint('User Role: $userRole');

      if (userRole == null || userRole.isEmpty) {
        debugPrint('No user role found, redirecting to welcome');
        _navigateAndMark('/welcome');
        return;
      }

      if (userRole == 'masyarakat') {
        await _checkMasyarakatAuth();
      } else if (userRole == 'pengepul') {
        await _checkPengepulAuth();
      } else {
        debugPrint('Unknown role: $userRole');
        await _tokenManager.clearSession();
        _navigateAndMark('/welcome');
      }
    } catch (e) {
      debugPrint('Auth check error: $e');
      await _tokenManager.clearSession();
      _navigateAndMark('/welcome');
    }
  }

  Future<void> _checkMasyarakatAuth() async {
    final authViewModel = context.read<AuthViewModel>();
    await authViewModel.checkAuthStatus();

    if (!mounted || _hasNavigated) return;

    debugPrint('Masyarakat Auth Status:');
    debugPrint('- isLoggedIn: ${authViewModel.isLoggedIn}');
    debugPrint(
      '- isRegistrationComplete: ${authViewModel.isRegistrationComplete()}',
    );
    debugPrint('- nextStep: ${authViewModel.nextStep}');

    if (authViewModel.isLoggedIn) {
      if (authViewModel.isRegistrationComplete()) {
        _navigateAndMark('/navigasi');
      } else {
        _navigateToMasyarakatIncompleteFlow(authViewModel.nextStep);
      }
    } else {
      _navigateAndMark('/xlogin');
    }
  }

  Future<void> _checkPengepulAuth() async {
    final pengepulViewModel = context.read<PengepulAuthViewModel>();
    await pengepulViewModel.checkAuthStatus();

    if (!mounted || _hasNavigated) return;

    debugPrint('Pengepul Auth Status:');
    debugPrint('- isLoggedIn: ${pengepulViewModel.isLoggedIn}');
    debugPrint(
      '- isRegistrationComplete: ${pengepulViewModel.isRegistrationComplete()}',
    );
    debugPrint('- registrationStatus: ${pengepulViewModel.registrationStatus}');
    debugPrint('- nextStep: ${pengepulViewModel.nextStep}');

    if (pengepulViewModel.isLoggedIn) {
      if (pengepulViewModel.isRegistrationComplete()) {
        _navigateAndMark('/berandapengepul');
      } else {
        _navigateToPengepulIncompleteFlow(
          pengepulViewModel.nextStep,
          pengepulViewModel.registrationStatus,
        );
      }
    } else {
      _navigateAndMark('/pengepul-login');
    }
  }

  void _navigateToMasyarakatIncompleteFlow(String? nextStep) {
    debugPrint('Navigating to masyarakat incomplete flow: $nextStep');

    switch (nextStep) {
      case 'complete_personal_data':
        _navigateAndMark('/xprofile-form');
        break;
      case 'create_pin':
        _navigateAndMark('/xpin-input?isLogin=false');
        break;
      case 'verif_pin':
        _navigateAndMark('/xpin-input?isLogin=true');
        break;
      default:
        debugPrint('Unknown masyarakat next step: $nextStep');
        _navigateAndMark('/xlogin');
    }
  }

  void _navigateToPengepulIncompleteFlow(
    String? nextStep,
    String? registrationStatus,
  ) {
    debugPrint(
      'Navigating to pengepul incomplete flow: $nextStep, status: $registrationStatus',
    );

    switch (nextStep) {
      case 'upload_ktp':
        _navigateAndMark('/pengepul-ktp-form');
        break;
      case 'awaiting_admin_approval':
        if (registrationStatus == 'awaiting_approval') {
          _navigateAndMark('/pengepul-approval-waiting');
        } else if (registrationStatus == 'approved') {
          _navigateAndMark('/pengepul-pin-input?isLogin=false');
        } else {
          _navigateAndMark('/pengepul-ktp-form');
        }
        break;
      case 'create_pin':
        _navigateAndMark('/pengepul-pin-input?isLogin=false');
        break;
      case 'verif_pin':
        _navigateAndMark('/pengepul-pin-input?isLogin=true');
        break;
      default:
        debugPrint('Unknown pengepul next step: $nextStep');
        _navigateAndMark('/pengepul-login');
    }
  }

  void _navigateAndMark(String route) {
    if (!_hasNavigated && mounted) {
      _hasNavigated = true;
      debugPrint('Navigating to: $route');
      context.go(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.recycling, size: 80, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'Rijig Mobile',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 32),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            SizedBox(height: 16),
            Text(
              'Memuat...',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
