import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rijig_mobile/core/network/network_aware_widgets.dart';
import 'package:rijig_mobile/core/network/network_service.dart';
import 'package:rijig_mobile/core/router.dart';
import 'package:rijig_mobile/core/storage/expired_token.dart';
import 'package:rijig_mobile/core/utils/guide.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  UpdatedSplashScreenState createState() => UpdatedSplashScreenState();
}

class UpdatedSplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool _isCheckingConnection = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final NetworkService _networkService = NetworkService();

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
    // Initialize network service
    await _networkService.initialize();
    
    await Future.delayed(const Duration(milliseconds: 3000));
    await _checkNetworkAndProceed();
  }

  Future<void> _checkNetworkAndProceed() async {
    setState(() {
      _isCheckingConnection = true;
    });

    bool isConnected = await _networkService.checkConnection();

    setState(() {
      _isCheckingConnection = false;
    });

    if (!isConnected) {
      _showNoInternetDialog();
      return;
    }

    await _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      bool expired = await isTokenExpired();
      if (expired) {
        debugPrint("Token expired - redirecting to onboarding");
        router.go("/onboarding");
      } else {
        debugPrint("Token valid - redirecting to navigation");
        router.go("/navigasi");
      }
    } catch (e) {
      debugPrint("Login status check error: $e");
      router.go("/onboarding");
    }
  }

  void _showNoInternetDialog() {
    NetworkDialogManager.showNoInternetDialog(
      context: context,
      onRetry: () {
        Navigator.of(context).pop();
        _checkNetworkAndProceed();
      },
      onExit: () {
        SystemNavigator.pop();
      },
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
                    SvgPicture.asset('assets/icon/logorijig.svg', height: 120),
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
                        'Memeriksa koneksi...',
                        style: TextStyle(
                          color: whiteColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
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