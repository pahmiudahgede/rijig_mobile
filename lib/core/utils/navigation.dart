import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/core/router.dart';
import 'package:rijig_mobile/features/activity/presentation/screen/activity_screen.dart';
import 'package:rijig_mobile/features/cart/presentation/screens/cart_screen.dart';
import 'package:rijig_mobile/features/home/presentation/screen/home_screen.dart';
import 'package:rijig_mobile/features/profil/presentation/screen/profil_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavigationPage extends StatefulWidget {
  final dynamic data;
  const NavigationPage({super.key, this.data});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
    _loadSelectedIndex();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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

  void _onItemTapped(int index) {
    if (index == 2) {
      router.push("/requestpickup");
    } else {
      setState(() => _selectedIndex = index);
      _saveSelectedIndex(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SlideTransition(
        position: _slideAnimation,
        child: Scaffold(
          extendBody: true,
          backgroundColor: whiteColor,
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
          bottomNavigationBar: Visibility(
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
                    activeIcon: Icon(Iconsax.home_2, size: 26),
                    label: 'Beranda',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Iconsax.note_favorite),
                    activeIcon: Icon(Iconsax.note_favorite, size: 26),
                    label: 'Aktivitas',
                  ),
                  const BottomNavigationBarItem(
                    icon: SizedBox.shrink(),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Iconsax.shopping_cart),
                    activeIcon: Icon(Iconsax.shopping_cart, size: 26),
                    label: 'Keranjang',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Iconsax.user),
                    activeIcon: Icon(Iconsax.user, size: 26),
                    label: 'Profil',
                  ),
                ],
                selectedLabelStyle: Tulisan.customText(
                  color: secondaryColor,
                  fontsize: 14,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: Tulisan.customText(
                  color: whiteColor,
                  fontsize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [secondaryColor, primaryColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: Border.all(color: whiteColor, width: 4),
            ),
            child: RawMaterialButton(
              onPressed: () => router.push("/requestpickup"),
              shape: const CircleBorder(),
              elevation: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.archive_2, color: whiteColor, size: 30),
                  Text(
                    "Mulai",
                    style: Tulisan.customText(
                      color: whiteColor,
                      fontsize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
