import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:rijig_mobile/core/router.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/features/home/model/c_request_list_dummymodel.dart';
import 'package:rijig_mobile/widget/tabbar_custom.dart';

class ChomeCollectorScreen extends StatefulWidget {
  const ChomeCollectorScreen({super.key});

  @override
  State<ChomeCollectorScreen> createState() => _ChomeCollectorScreenState();
}

class _ChomeCollectorScreenState extends State<ChomeCollectorScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: whiteColor,
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: Text('Request', style: Tulisan.subheading(color: whiteColor)),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.menu, color: whiteColor, size: 30),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: ClipRRect(
              child: Container(
                height: 40,
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.green.shade100),
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: primaryColor,
                    border: Border(
                      bottom: BorderSide(
                        color: secondaryColor,
                        width: 2.6,
                        style: BorderStyle.solid,
                      ),
                    ),
                  ),
                  labelColor: whiteColor,
                  unselectedLabelColor: Colors.black54,
                  tabs: [
                    TabItem(title: 'All Request', count: 6),
                    TabItem(title: 'Request to You', count: 1),
                  ],
                ),
              ),
            ),
          ),
        ),
        drawer: Drawer(
          backgroundColor: whiteColor,
          width: MediaQuery.of(context).size.width / 1.7,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: primaryColor),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundImage: AssetImage('assets/image/Go_Ride.png'),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Nama User',
                          style: Tulisan.body(color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Status: Active',
                          style: Tulisan.body(
                            color: Colors.white70,
                            fontsize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Iconsax.user),
                title: Text('Profil', style: Tulisan.customText(fontsize: 16)),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Iconsax.document_1),
                title: Text(
                  'Riwayat Pickup',
                  style: Tulisan.customText(fontsize: 16),
                ),
                onTap: () => router.push('/cpickuphistory'),
              ),
              ListTile(
                leading: const Icon(Iconsax.setting_2),
                title: Text(
                  'Pengaturan',
                  style: Tulisan.customText(fontsize: 16),
                ),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Iconsax.logout, color: redColor),
                title: Text(
                  'Keluar',
                  style: Tulisan.customText(color: redColor, fontsize: 16),
                ),
                onTap: () => router.go('/login'),
              ),
            ],
          ),
        ),
        body: CollectorRequestList(),
      ),
    );
  }
}
