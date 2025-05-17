import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/features/profil/components/clip_path.dart';
import 'package:rijig_mobile/features/profil/components/logout_button.dart';
import 'package:rijig_mobile/features/profil/components/profile_menu_option.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: SafeArea(
        child: Stack(
          children: [
            ClipPath(
              clipper: ClipPathClass(),
              child: Container(
                height: 180,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor,
                      secondaryColor,
                    ], // Ganti dengan warna gradien pilihan Anda
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 60,
              left: 20,
              right: 20,
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.3),
                      spreadRadius: 1,
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Fahmi Kurniawan'),
                    SizedBox(height: 10),
                    Text('+62878774527342'),
                    SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tervalidasi',
                          style: TextStyle(color: Colors.green),
                        ),
                        Text('edit', style: TextStyle(color: Colors.blue)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.only(top: 245),
                child: Padding(
                  padding: PaddingCustom().paddingHorizontal(20),
                  child: Column(
                    children: [ProfileMenuOptions(), Gap(30), ButtonLogout()],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
