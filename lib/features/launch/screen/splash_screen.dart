import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:rijig_mobile/core/network/network_service.dart';
import 'package:rijig_mobile/core/network/network_status_indicator.dart';
import 'package:rijig_mobile/core/router.dart';
import 'package:rijig_mobile/core/storage/token_manager.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/features/auth/presentation/viewmodel/auth_viewmodel.dart';
import 'package:rijig_mobile/features/pengepul/auth/presentation/viewmodel/pengepul_auth_viewmodel.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  UpdatedSplashScreenState createState() => UpdatedSplashScreenState();
}

class UpdatedSplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool _isCheckingConnection = true;
  String _statusMessage = 'Memeriksa koneksi...';

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final NetworkService _networkService = NetworkService();
  final TokenManager _tokenManager = TokenManager();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAppInitialization();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  Future<void> _startAppInitialization() async {
    try {
      await _networkService.initialize();

      await Future.delayed(const Duration(milliseconds: 2000));

      await _checkNetworkAndProceed();
    } catch (e) {
      debugPrint('App initialization error: $e');
      _handleInitializationError();
    }
  }

  Future<void> _checkNetworkAndProceed() async {
    _updateStatus('Memeriksa koneksi...');

    bool isConnected = await _networkService.checkConnection();

    if (!isConnected) {
      _showNoInternetDialog();
      return;
    }

    await _checkAuthenticationStatus();
  }

  Future<void> _checkAuthenticationStatus() async {
    _updateStatus('Memeriksa sesi pengguna...');

    try {
      bool hasActiveSession = await _tokenManager.isLoggedIn();

      if (!hasActiveSession) {
        debugPrint("No active session - redirecting to onboarding");
        await Future.delayed(const Duration(milliseconds: 500));
        router.go("/onboarding");
        return;
      }

      await _handleExistingSession();
    } catch (e) {
      debugPrint("Authentication status check error: $e");

      router.go("/onboarding");
    }
  }

  Future<void> _handleExistingSession() async {
    _updateStatus('Memuat profil pengguna...');

    try {
      String? userRole = await _tokenManager.getUserRole();
      bool isRegistrationComplete =
          await _tokenManager.isRegistrationComplete();

      debugPrint("=== EXISTING SESSION FOUND ===");
      debugPrint("User Role: $userRole");
      debugPrint("Registration Complete: $isRegistrationComplete");

      if (userRole == null || userRole.isEmpty) {
        debugPrint("Invalid user role, redirecting to onboarding");
        await _tokenManager.clearSession();
        router.go("/onboarding");
        return;
      }

      if (userRole == 'masyarakat') {
        await _initializeMasyarakatAuth();
      } else if (userRole == 'pengepul') {
        await _initializePengepulAuth();
      } else {
        debugPrint("Unknown user role: $userRole");
        await _tokenManager.clearSession();
        router.go("/onboarding");
      }
    } catch (e) {
      debugPrint("Session handling error: $e");
      await _tokenManager.clearSession();
      router.go("/onboarding");
    }
  }

  Future<void> _initializeMasyarakatAuth() async {
    try {
      final authViewModel = context.read<AuthViewModel>();
      await authViewModel.checkAuthStatus();

      String? nextStep = await _tokenManager.getNextStep();
      bool isComplete = await _tokenManager.isRegistrationComplete();

      debugPrint("Masyarakat - Next Step: $nextStep, Complete: $isComplete");

      if (isComplete) {
        router.go("/navigasi");
      } else {
        _navigateToMasyarakatIncompleteFlow(nextStep);
      }
    } catch (e) {
      debugPrint("Masyarakat auth initialization error: $e");
      router.go("/onboarding");
    }
  }

  Future<void> _initializePengepulAuth() async {
    try {
      final pengepulViewModel = context.read<PengepulAuthViewModel>();
      await pengepulViewModel.checkAuthStatus();

      String? nextStep = await _tokenManager.getNextStep();
      String? registrationStatus = await _tokenManager.getRegistrationStatus();
      bool isComplete = await _tokenManager.isRegistrationComplete();

      debugPrint(
        "Pengepul - Next Step: $nextStep, Status: $registrationStatus, Complete: $isComplete",
      );

      if (isComplete) {
        router.go("/berandapengepul");
      } else {
        _navigateToPengepulIncompleteFlow(nextStep, registrationStatus);
      }
    } catch (e) {
      debugPrint("Pengepul auth initialization error: $e");
      router.go("/onboarding");
    }
  }

  void _navigateToMasyarakatIncompleteFlow(String? nextStep) {
    switch (nextStep) {
      case 'complete_personal_data':
        router.go('/xprofile-form');
        break;
      case 'create_pin':
        router.go('/xpin-input?isLogin=false');
        break;
      case 'verif_pin':
        router.go('/xpin-input?isLogin=true');
        break;
      default:
        router.go('/xlogin');
    }
  }

  void _navigateToPengepulIncompleteFlow(
    String? nextStep,
    String? registrationStatus,
  ) {
    switch (nextStep) {
      case 'upload_ktp':
        router.go('/pengepul-ktp-form');
        break;
      case 'awaiting_admin_approval':
        if (registrationStatus == 'awaiting_approval') {
          router.go('/pengepul-approval-waiting');
        } else {
          router.go('/pengepul-ktp-form');
        }
        break;
      case 'create_pin':
        router.go('/pengepul-pin-input?isLogin=false');
        break;
      case 'verif_pin':
        router.go('/pengepul-pin-input?isLogin=true');
        break;
      default:
        router.go('/pengepul-login');
    }
  }

  void _updateStatus(String message) {
    if (mounted) {
      setState(() {
        _statusMessage = message;
      });
    }
  }

  void _handleInitializationError() {
    _updateStatus('Terjadi kesalahan...');

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        router.go("/onboarding");
      }
    });
  }

  void _showNoInternetDialog() {
    setState(() {
      _isCheckingConnection = false;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Tidak Ada Koneksi Internet'),
            content: const Text(
              'Aplikasi memerlukan koneksi internet untuk berjalan. '
              'Periksa koneksi internet Anda dan coba lagi.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _isCheckingConnection = true;
                  });
                  _checkNetworkAndProceed();
                },
                child: const Text('Coba Lagi'),
              ),
              TextButton(
                onPressed: () {
                  SystemNavigator.pop();
                },
                child: const Text('Keluar'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NetworkStatusIndicator(
      child: Scaffold(
        backgroundColor: primaryColor,
        body: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icon/logorijig.svg',
                      height: 120,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.recycling,
                            size: 60,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 40),

                    Text(
                      'Rijig Mobile',
                      style: TextStyle(
                        color: whiteColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 60),

                    if (_isCheckingConnection) ...[
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: whiteColor,
                          strokeWidth: 2.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _statusMessage,
                        style: TextStyle(
                          color: whiteColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
