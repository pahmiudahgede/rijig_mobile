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
      router.push("/trashview");
    } else {
      setState(() => _selectedIndex = index);
      _saveSelectedIndex(index);
    }
  }

  void _onCenterButtonTapped() {
    router.push("/trashview");
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SlideTransition(
        position: _slideAnimation,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          extendBody: true,
          backgroundColor: whiteColor,
          body: Stack(
            children: [
              IndexedStack(
                index: _selectedIndex,
                children: const [
                  HomeScreen(),
                  ActivityScreen(),
                  Text(""),
                  CartSummaryScreen(),
                  ProfilScreen(),
                ],
              ),

              Positioned(
                bottom: 0,
                left: 0,
                child: SizedBox(
                  width: size.width,
                  height: 65,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CustomPaint(
                        size: Size(size.width, 65),
                        painter: CustomBottomNavPainter(
                          backgroundColor: primaryColor,
                        ),
                      ),

                      Center(
                        heightFactor: 0.5,
                        child: GestureDetector(
                          onTap: _onCenterButtonTapped,
                          child: Container(
                            width: 65,
                            height: 65,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [secondaryColor, primaryColor],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Iconsax.archive_2,
                                  color: whiteColor,
                                  size: 26,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Mulai",
                                  style: TextStyle(
                                    color: whiteColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(
                        width: size.width,
                        height: 65,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildNavItem(
                              icon: Iconsax.home_2,
                              label: 'Beranda',
                              index: 0,
                            ),
                            _buildNavItem(
                              icon: Iconsax.note_favorite,
                              label: 'Aktivitas',
                              index: 1,
                            ),

                            SizedBox(width: size.width * 0.20),
                            _buildNavItem(
                              icon: Iconsax.shopping_cart,
                              label: 'Keranjang',
                              index: 3,
                            ),
                            _buildNavItem(
                              icon: Iconsax.user,
                              label: 'Profil',
                              index: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.only(top: 8, bottom: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: isSelected ? 26 : 24,
                color: isSelected ? secondaryColor : whiteColor,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? secondaryColor : whiteColor,
                  fontSize: isSelected ? 14 : 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomBottomNavPainter extends CustomPainter {
  final Color backgroundColor;

  CustomBottomNavPainter({required this.backgroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint =
        Paint()
          ..color = backgroundColor
          ..style = PaintingStyle.fill;

    Path path = Path();

    path.moveTo(0, 0);
    path.lineTo(size.width * 0.35, 0);

    path.quadraticBezierTo(size.width * 0.40, 0, size.width * 0.40, 15);

    path.arcToPoint(
      Offset(size.width * 0.60, 15),
      radius: const Radius.circular(17.0),
      clockwise: false,
    );

    path.quadraticBezierTo(size.width * 0.60, 0, size.width * 0.65, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class SimpleNavigationPage extends StatefulWidget {
  final dynamic data;
  const SimpleNavigationPage({super.key, this.data});

  @override
  State<SimpleNavigationPage> createState() => _SimpleNavigationPageState();
}

class _SimpleNavigationPageState extends State<SimpleNavigationPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      extendBody: true,
      backgroundColor: whiteColor,
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: const [
              HomeScreen(),
              ActivityScreen(),
              CartSummaryScreen(),
              ProfilScreen(),
            ],
          ),

          Positioned(
            bottom: 0,
            left: 0,
            child: SizedBox(
              width: size.width,
              height: 60,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CustomPaint(
                    size: Size(size.width, 60),
                    painter: PreciseBottomNavPainter(
                      backgroundColor: primaryColor,
                    ),
                  ),

                  Center(
                    heightFactor: 0.7,
                    child: GestureDetector(
                      onTap: () => router.push("/trashview"),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [secondaryColor, primaryColor],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Iconsax.archive_2,
                              color: whiteColor,
                              size: 22,
                            ),
                            Text(
                              "Mulai",
                              style: TextStyle(
                                color: whiteColor,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    width: size.width,
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _simpleNavItem(Iconsax.home_2, 'Beranda', 0),
                        _simpleNavItem(Iconsax.note_favorite, 'Aktivitas', 1),
                        SizedBox(width: size.width * 0.15),
                        _simpleNavItem(Iconsax.shopping_cart, 'Keranjang', 2),
                        _simpleNavItem(Iconsax.user, 'Profil', 3),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _simpleNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: isSelected ? 22 : 18,
              color: isSelected ? secondaryColor : whiteColor,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? secondaryColor : whiteColor,
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PreciseBottomNavPainter extends CustomPainter {
  final Color backgroundColor;

  PreciseBottomNavPainter({required this.backgroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint =
        Paint()
          ..color = backgroundColor
          ..style = PaintingStyle.fill;

    Path path = Path();

    final double centerX = size.width * 0.5;
    final double notchRadius = 30.0;
    final double notchMargin = 4.0;

    path.moveTo(0, 15);

    path.quadraticBezierTo(size.width * 0.15, 0, size.width * 0.35, 0);

    path.quadraticBezierTo(
      centerX - notchRadius - notchMargin,
      0,
      centerX - notchRadius - notchMargin,
      12,
    );

    path.arcToPoint(
      Offset(centerX + notchRadius + notchMargin, 12),
      radius: Radius.circular(notchRadius + notchMargin),
      clockwise: false,
    );

    path.quadraticBezierTo(
      centerX + notchRadius + notchMargin,
      0,
      size.width * 0.65,
      0,
    );

    path.quadraticBezierTo(size.width * 0.85, 0, size.width, 15);

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, 15);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
