import 'package:flutter/material.dart';
import 'package:rijig_mobile/core/network/network_info.dart';
import 'package:rijig_mobile/core/router.dart';
import 'package:rijig_mobile/core/storage/expired_token.dart';
// import 'package:rijig_mobile/core/storage/secure_storage.dart';

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset('assets/image/Go_Ride.png', height: 200),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 250.0),
              child: Text(
                'Rijig',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
          ),

          if (_isCheckingConnection)
            Align(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
