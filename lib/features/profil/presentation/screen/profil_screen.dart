import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rijig_mobile/core/router.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/features/profil/components/logout_button.dart';
import 'package:rijig_mobile/widget/buttoncard.dart';
import 'package:rijig_mobile/widget/custom_bottom_sheet.dart';

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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Gap(50),
            Container(
              width: double.infinity,
              color: whiteColor,
              padding: PaddingCustom().paddingHorizontalVertical(20, 30),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 3,
                          ),
                        ),
                        child: CircleAvatar(
                          backgroundColor: primaryColor,
                          radius: 47,
                          backgroundImage: NetworkImage(
                            'https://plus.unsplash.com/premium_vector-1731922571914-9d0161b5e7b7?q=80&w=1760&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                          ),
                        ),
                      ),
                    ],
                  ),
                  Gap(16),

                  Text(
                    'Fahmi Kurniawan',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  Gap(4),

                  Text(
                    '+6287874527342',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            Gap(20),

            _buildMenuSection([
              _MenuItemData(
                icon: Icons.person,
                iconColor: const Color(0xFF3B82F6),
                title: 'Profil',
                subtitle: 'Edit profil, dan lain lain..',
              ),
              _MenuItemData(
                icon: Icons.pin,
                iconColor: const Color(0xFF10B981),
                title: 'Ubah Pin',
                subtitle: 'Ubah pin anda disini',
              ),
              _MenuItemData(
                icon: Icons.location_pin,
                iconColor: const Color(0xFF3B82F6),
                title: 'Alamat',
                subtitle: 'kelola daftar alamat anda disini',
              ),
              _MenuItemData(
                icon: Icons.help_center,
                iconColor: const Color(0xFF3B82F6),
                title: 'Bantuan',
                subtitle: 'Butuh bantuan tentang aplikasi?',
              ),
              _MenuItemData(
                icon: Icons.thumb_up,
                iconColor: const Color(0xFF6B7280),
                title: 'Ulasan',
                subtitle: 'Penilaian anda berarti bagi kami',
              ),
              _MenuItemData(
                icon: Icons.logout,
                iconColor: const Color(0xFF3B82F6),
                title: 'Keluar',
                subtitle: 'Keluar aplikasi atau ganti akun',
              ),
            ]),
            Gap(100),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(List<_MenuItemData> items) {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 80, left: 20, right: 20),
      padding: PaddingCustom().paddingAll(7),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children:
            items.asMap().entries.map((entry) {
              int index = entry.key;
              _MenuItemData item = entry.value;
              bool isLast = index == items.length - 1;

              return _buildMenuItem(
                item.icon,
                item.iconColor,
                item.title,
                item.subtitle,
                showDivider: !isLast,
                onTap: () => _handleMenuTap(item.title),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    Color iconColor,
    String title,
    String subtitle, {
    bool showDivider = true,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),

        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Gap(4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
            if (showDivider) ...[
              Gap(20),
              Divider(height: 1, color: Colors.grey.shade200),
            ],
          ],
        ),
      ),
    );
  }

  void _handleMenuTap(String menuTitle) {
    debugPrint('Tapped on: $menuTitle');

    switch (menuTitle) {
      case 'Profil':
        debugPrint('Profil');
        router.push('/akunprofil');
        break;

      case 'Ubah Pin':
        debugPrint('Ubah Pin');
        router.push('/pinsecureinput');
        break;

      case 'Alamat':
        debugPrint('Alamat');
        router.push('/address');
        break;

      case 'Bantuan':
        debugPrint('Bantuan');
        break;

      case 'Ulasan':
        debugPrint('Ulasan');
        break;

      case 'Keluar':
        CustomBottomSheet.show(
          context: context,
          title: "Logout Sekarang?",
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Yakin ingin logout dari akun ini?"),
              // tambahan konten
            ],
          ),
          button1: ButtonLogout(),
          button2: CardButtonOne(
            textButton: "Gak jadi..",
            onTap: () => router.pop(),
            fontSized: 14,
            colorText: primaryColor,
            color: whiteColor,
            borderRadius: 10,
            horizontal: double.infinity,
            vertical: 50,
            loadingTrue: false,
            usingRow: false,
          ),
        );
        break;

      default:
        debugPrint('Routing tidak dikenali: $menuTitle');
    }
  }
}

class _MenuItemData {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  _MenuItemData({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });
}
