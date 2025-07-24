import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/widget/showmodal.dart';

class WelcomeRoleSelectionScreen extends StatefulWidget {
  const WelcomeRoleSelectionScreen({super.key});

  @override
  State<WelcomeRoleSelectionScreen> createState() =>
      _WelcomeRoleSelectionScreenState();
}

class _WelcomeRoleSelectionScreenState extends State<WelcomeRoleSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
  }

  Future<void> _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _slideController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryColor, primaryColor.withValues(alpha: 0.8)],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: Listenable.merge([_fadeAnimation, _slideAnimation]),
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Responsive layout based on screen size
                      final isSmallScreen = constraints.maxHeight < 600;
                      final isLargeScreen = constraints.maxHeight > 800;

                      return SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 24.w,
                                vertical: isSmallScreen ? 16.h : 24.h,
                              ),
                              child: Column(
                                children: [
                                  // Header section
                                  _buildHeader(
                                    isSmallScreen: isSmallScreen,
                                    isLargeScreen: isLargeScreen,
                                  ),

                                  // Flexible spacing
                                  SizedBox(height: isSmallScreen ? 24.h : 32.h),

                                  // Role options section
                                  _buildRoleOptions(
                                    isSmallScreen: isSmallScreen,
                                    isLargeScreen: isLargeScreen,
                                  ),

                                  // Flexible spacing
                                  SizedBox(height: isSmallScreen ? 24.h : 32.h),

                                  // Footer section
                                  _buildFooter(isSmallScreen: isSmallScreen),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader({
    required bool isSmallScreen,
    required bool isLargeScreen,
  }) {
    // Responsive icon size
    final iconSize =
        isSmallScreen
            ? 80.w
            : isLargeScreen
            ? 120.w
            : 100.w;
    final iconContainerSize =
        isSmallScreen
            ? 100.w
            : isLargeScreen
            ? 140.w
            : 120.w;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: iconContainerSize,
          height: iconContainerSize,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(isSmallScreen ? 20.r : 30.r),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Icon(Icons.recycling, size: iconSize * 0.5, color: whiteColor),
        ),

        SizedBox(height: isSmallScreen ? 20.h : 32.h),

        Text(
          'Selamat Datang di',
          style: TextStyle(
            fontSize: isSmallScreen ? 16.sp : 18.sp,
            color: whiteColor.withValues(alpha: 0.9),
            fontWeight: FontWeight.w400,
          ),
        ),

        SizedBox(height: 8.h),

        Text(
          'Rijig Mobile',
          style: TextStyle(
            fontSize:
                isSmallScreen
                    ? 28.sp
                    : isLargeScreen
                    ? 36.sp
                    : 32.sp,
            color: whiteColor,
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: isSmallScreen ? 12.h : 16.h),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'Pilih peran Anda untuk memulai\nperjalanan menuju lingkungan yang lebih bersih',
            style: TextStyle(
              fontSize: isSmallScreen ? 14.sp : 16.sp,
              color: whiteColor.withValues(alpha: 0.8),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildRoleOptions({
    required bool isSmallScreen,
    required bool isLargeScreen,
  }) {
    final cardSpacing = isSmallScreen ? 16.h : 20.h;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildRoleCard(
          title: 'Masyarakat',
          subtitle:
              'Saya ingin membuang sampah dan\nberkontribusi untuk lingkungan',
          icon: Icons.people_outline,
          gradient: [Colors.blue.shade400, Colors.blue.shade600],
          onTap: () => _navigateToRole('masyarakat'),
          isSmallScreen: isSmallScreen,
        ),

        SizedBox(height: cardSpacing),

        _buildDivider(),

        SizedBox(height: cardSpacing),

        _buildRoleCard(
          title: 'Pengepul',
          subtitle:
              'Saya ingin mengumpulkan dan mengelola\nsampah untuk didaur ulang',
          icon: Icons.business_outlined,
          gradient: [Colors.orange.shade400, Colors.orange.shade600],
          onTap: () => _navigateToRole('pengepul'),
          isSmallScreen: isSmallScreen,
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(height: 1, color: whiteColor.withValues(alpha: 0.3)),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'ATAU',
            style: TextStyle(
              color: whiteColor.withValues(alpha: 0.7),
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Expanded(
          child: Container(height: 1, color: whiteColor.withValues(alpha: 0.3)),
        ),
      ],
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
    required bool isSmallScreen,
  }) {
    // Responsive sizing for card elements
    final cardPadding = isSmallScreen ? 16.w : 20.w;
    final iconSize = isSmallScreen ? 60.w : 70.w;
    final iconContainerSize = isSmallScreen ? 50.w : 60.w;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(cardPadding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                icon,
                color: whiteColor,
                size: iconContainerSize * 0.6,
              ),
            ),

            SizedBox(width: isSmallScreen ? 12.w : 16.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 18.sp : 20.sp,
                      fontWeight: FontWeight.bold,
                      color: whiteColor,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12.sp : 14.sp,
                      color: whiteColor.withValues(alpha: 0.9),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios,
              color: whiteColor.withValues(alpha: 0.8),
              size: isSmallScreen ? 16.w : 20.w,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter({required bool isSmallScreen}) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 12.w : 16.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: whiteColor.withValues(alpha: 0.8),
                size: isSmallScreen ? 18.w : 20.w,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Anda dapat berganti peran kapan saja melalui pengaturan akun',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 11.sp : 12.sp,
                    color: whiteColor.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: isSmallScreen ? 16.h : 20.h),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'Butuh bantuan? Hubungi customer service kami',
            style: TextStyle(
              fontSize: isSmallScreen ? 11.sp : 12.sp,
              color: whiteColor.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  void _navigateToRole(String role) {
    HapticFeedback.mediumImpact();
    _showRoleSelectionDialog(role);
  }

  void _showRoleSelectionDialog(String role) {
    final roleDisplay = role == 'masyarakat' ? 'Masyarakat' : 'Pengepul';

    CustomModalDialog.showText(
      context: context,
      title: 'Konfirmasi Pilihan',
      content:
          'Anda akan melanjutkan sebagai $roleDisplay. '
          'Apakah Anda sudah memiliki akun?',
      buttonCount: 2,
      button1: _buildPrimaryButton(
        text: 'Ya, Masuk',
        onTap: () {
          Navigator.of(context).pop();
          if (role == 'masyarakat') {
            context.go('/xlogin');
          } else {
            context.go('/pengepul-login');
          }
        },
      ),
      button2: _buildSecondaryButton(
        text: 'Belum, Daftar',
        onTap: () {
          Navigator.of(context).pop();
          if (role == 'masyarakat') {
            context.go('/xregister');
          } else {
            context.go('/pengepul-register');
          }
        },
      ),
      showCloseIcon: true,
    );
  }

  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: whiteColor,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }
}
