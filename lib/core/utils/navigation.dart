import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/core/router.dart';
import 'package:rijig_mobile/features/activity/activity_screen.dart';
import 'package:rijig_mobile/features/cart/cart_screen.dart';
import 'package:rijig_mobile/features/home/home_screen.dart';
import 'package:rijig_mobile/features/profil/profil_screen.dart';
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
            color: Colors.white,
            clipBehavior: Clip.antiAlias,
            notchMargin: 3.0,
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedItemColor: Colors.blue,
              unselectedItemColor: Colors.grey,
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Iconsax.home_1, color: Colors.grey),
                  activeIcon: Icon(Iconsax.home_1, color: Colors.blue),
                  label: 'Beranda',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Iconsax.home, color: Colors.grey),
                  activeIcon: Icon(Iconsax.home, color: Colors.blue),
                  label: 'Pesan',
                ),
                const BottomNavigationBarItem(
                  icon: SizedBox.shrink(),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Iconsax.document, color: Colors.grey),
                  activeIcon: Icon(Iconsax.document, color: Colors.blue),
                  label: 'Tutorial',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Iconsax.home, color: Colors.grey),
                  activeIcon: Icon(Iconsax.home, color: Colors.blue),
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
          backgroundColor: Colors.white,
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
              Icon(Iconsax.home, color: primaryColor, size: 30),
              Text("data", style: TextStyle(color: blackNavyColor)),
            ],
          ),
        ),
      ),
    );
  }
}
