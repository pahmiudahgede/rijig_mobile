import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/core/router.dart';
import 'package:rijig_mobile/features/activity/presentation/screen/activity_screen.dart';
import 'package:rijig_mobile/features/cart/cart_screen.dart';
import 'package:rijig_mobile/features/home/presentation/screen/home_screen.dart';
import 'package:rijig_mobile/features/profil/presentation/screen/profil_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavigationPage extends StatefulWidget {
  final dynamic data;
  const NavigationPage({super.key, this.data});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _selectedIndex = 0;

  _loadSelectedIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedIndex = prefs.getInt('last_selected_index') ?? 0;
    });
  }

  _saveSelectedIndex(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('last_selected_index', index);
  }

  @override
  void initState() {
    super.initState();
    _loadSelectedIndex();
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      router.push("/requestpickup");
    } else {
      setState(() {
        _selectedIndex = index;
      });
      _saveSelectedIndex(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          HomeScreen(),
          ActivityScreen(),
          Text(""),
          CartScreen(),
          ProfilScreen(),
        ],
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
        ),
        child: Visibility(
          visible: _selectedIndex != 2,
          child: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            padding: PaddingCustom().paddingHorizontal(2),
            elevation: 0,
            height: 67,
            color: primaryColor,
            clipBehavior: Clip.antiAlias,
            notchMargin: 3.0,
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedItemColor: secondaryColor,
              unselectedItemColor: whiteColor,
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Iconsax.home_2),
                  activeIcon: Icon(Iconsax.home_2, size: 28),
                  label: 'Beranda',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Iconsax.note_favorite),
                  activeIcon: Icon(Iconsax.note_favorite, size: 28),
                  label: 'Aktivitas',
                ),
                const BottomNavigationBarItem(
                  icon: SizedBox.shrink(),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Iconsax.shopping_cart),
                  activeIcon: Icon(Iconsax.shopping_cart, size: 28),
                  label: 'Keranjang',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Iconsax.user),
                  activeIcon: Icon(Iconsax.user, size: 28),
                  label: 'Profil',
                ),
              ],
              selectedLabelStyle: const TextStyle(fontSize: 14),
              unselectedLabelStyle: const TextStyle(fontSize: 12),
            ),
          ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 78,
        height: 78,
        child: FloatingActionButton(
          onPressed: () {
            router.push("/requestpickup");
          },
          backgroundColor: primaryColor,
          shape: const CircleBorder(
            side: BorderSide(color: Colors.white, width: 4),
          ),
          elevation: 0,
          highlightElevation: 0,
          hoverColor: Colors.blue,
          splashColor: Colors.transparent,
          foregroundColor: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(Iconsax.archive_2, color: whiteColor, size: 30),
              Text("mulai", style: TextStyle(color: whiteColor)),
            ],
          ),
        ),
      ),
    );
  }
}
