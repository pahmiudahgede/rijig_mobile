import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rijig_mobile/core/network/network_info.dart';
import 'package:rijig_mobile/core/router.dart';
import 'package:rijig_mobile/core/storage/expired_token.dart';
import 'package:rijig_mobile/core/utils/guide.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  bool _isCheckingConnection = true;

  @override
  void initState() {
    super.initState();
    _checkNetworkConnection();
    _checkLoginStatus();
  }

  Future<void> _checkNetworkConnection() async {
    bool isConnected = await NetworkInfo().checkConnection();

    setState(() {
      _isCheckingConnection = false;
    });

    if (!isConnected) {
      _showNoInternetDialog();
      return;
    }
  }

  Future<void> _checkLoginStatus() async {
    bool expired = await isTokenExpired();
    if (expired) {
      debugPrint("tets expired");
      router.go("/onboarding");
    } else {
      debugPrint("test not expired");
      router.go("/navigasi");
    }
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('No Internet'),
            content: Text('Mohon periksa koneksi internet anda, dan coba lagi'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const String assetName = 'assets/icon/logorijig.svg';
    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: SvgPicture.asset(assetName, height: 120),
            ),

            if (_isCheckingConnection)
              Align(
                alignment: Alignment.bottomCenter,
                child: CircularProgressIndicator(color: whiteColor,),
              ),
          ],
        ),
      ),
    );
  }
}
