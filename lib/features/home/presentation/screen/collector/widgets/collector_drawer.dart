import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rijig_mobile/core/router.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/features/auth/presentation/viewmodel/auth_viewmodel.dart';
import 'package:rijig_mobile/widget/buttoncard.dart';
import 'package:toastification/toastification.dart';

class PengepulDrawer extends StatelessWidget {
  const PengepulDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: whiteColor,
      width: MediaQuery.of(context).size.width * 0.8,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  icon: Iconsax.user,
                  title: 'Profil',
                  subtitle: 'Kelola profil Anda',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _buildMenuItem(
                  icon: Iconsax.box,
                  title: 'Stok Sampah',
                  subtitle: 'Lihat stok sampah yang dimiliki',
                  onTap: () {
                    router.push("/stoksampahpengepul");
                  },
                ),
                _buildMenuItem(
                  icon: Iconsax.document_1,
                  title: 'Riwayat Pembelian',
                  subtitle: 'Riwayat beli dari masyarakat',
                  onTap: () {
                    router.push("/riwayatpembelian");
                  },
                ),
                _buildMenuItem(
                  icon: Iconsax.send_2,
                  title: 'Penyetoran',
                  subtitle: 'Setor sampah ke pengelola',
                  onTap: () {
                    router.push("/setor");
                  },
                ),
                const Divider(height: 32),
                _buildMenuItem(
                  icon: Iconsax.chart_21,
                  title: 'Laporan',
                  subtitle: 'Lihat laporan keuangan',
                  onTap: () {
                    router.push("/cpickuphistory");
                  },
                ),
                _buildMenuItem(
                  icon: Iconsax.setting_2,
                  title: 'Pengaturan',
                  subtitle: 'Konfigurasi aplikasi',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _buildMenuItem(
                  icon: Iconsax.info_circle,
                  title: 'Bantuan',
                  subtitle: 'Dapatkan bantuan',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, primaryColor.withValues(alpha: 0.8)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage('assets/image/Go_Ride.png'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ridwan',
                          style: Tulisan.subheading(color: whiteColor),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade400,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Aktif',
                            style: Tulisan.body(
                              color: whiteColor,
                              fontsize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildStatCard('450kg', 'Total Stok'),
                  const SizedBox(width: 12),
                  _buildStatCard('28', 'Transaksi'),
                  const SizedBox(width: 12),
                  _buildStatCard('4.9', 'Rating'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: whiteColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(value, style: Tulisan.body(color: whiteColor, fontsize: 14)),
            Text(
              label,
              style: Tulisan.body(
                color: whiteColor.withValues(alpha: 0.8),
                fontsize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: primaryColor, size: 20),
      ),
      title: Text(title, style: Tulisan.body(fontsize: 16)),
      subtitle: Text(
        subtitle,
        style: Tulisan.body(fontsize: 12, color: Colors.grey.shade600),
      ),
      trailing: Icon(
        Iconsax.arrow_right_3,
        size: 16,
        color: Colors.grey.shade400,
      ),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton() {
    return Consumer<AuthViewModel>(
      builder: (context, viewModel, child) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CardButtonOne(
                textButton: viewModel.isLoading ? 'Logging out...' : 'Logout',
                fontSized: 16,
                colorText: whiteColor,
                color: primaryColor,
                borderRadius: 10,
                horizontal: double.infinity,
                vertical: 50,

                onTap: () async {
                  await viewModel.logout();

                  if (viewModel.errorMessage == "") {
                    router.go("/welcome");
                  } else {
                    toastification.show(
                      type: ToastificationType.error,
                      title: Text("Belum berhsail logout"),
                      autoCloseDuration: const Duration(seconds: 3),
                      showProgressBar: true,
                    );
                  }
                },
                loadingTrue: viewModel.isLoading,
                usingRow: false,
              ),
              if (viewModel.errorMessage != "")
                Text(
                  viewModel.errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        );
      },
    );
    // return Container(
    //   padding: const EdgeInsets.all(16),
    //   child: ListTile(
    //     leading: Container(
    //       padding: const EdgeInsets.all(8),
    //       decoration: BoxDecoration(
    //         color: redColor.withValues(alpha: 0.1),
    //         borderRadius: BorderRadius.circular(8),
    //       ),
    //       child: Icon(Iconsax.logout, color: redColor, size: 20),
    //     ),
    //     title: Text(
    //       'Keluar',
    //       style: Tulisan.body(color: redColor, fontsize: 16),
    //     ),
    //     subtitle: Text(
    //       'Logout dari akun Anda',
    //       style: Tulisan.body(fontsize: 12, color: Colors.grey.shade600),
    //     ),
    //     onTap: () => router.go('/login'),
    //   ),
    // );
  }
}
