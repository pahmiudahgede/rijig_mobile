import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rijig_mobile/features/pengepul/auth/model/pengepul_auth_model.dart';
import 'package:rijig_mobile/features/pengepul/auth/presentation/viewmodel/pengepul_auth_viewmodel.dart';

class ApprovalWaitingScreen extends StatefulWidget {
  const ApprovalWaitingScreen({super.key});

  @override
  State<ApprovalWaitingScreen> createState() => _ApprovalWaitingScreenState();
}

class _ApprovalWaitingScreenState extends State<ApprovalWaitingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;

  bool _hasShownApprovedNotification = false;
  bool _hasShownRejectedNotification = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkInitialState();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(seconds: 120),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.linear),
    );

    _pulseController.repeat(reverse: true);
  }

  void _checkInitialState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<PengepulAuthViewModel>();

      debugPrint('=== APPROVAL WAITING INITIAL STATE ===');
      debugPrint('Current state: ${viewModel.state}');
      debugPrint('Registration status: ${viewModel.registrationStatus}');
      debugPrint('Is polling: ${viewModel.isPollingApproval}');

      if (viewModel.state == PengepulAuthState.approved) {
        debugPrint('Already approved, no need to poll');
        return;
      } else if (viewModel.state == PengepulAuthState.rejected) {
        debugPrint('Already rejected, no need to poll');
        return;
      }

      if (!viewModel.isPollingApproval &&
          viewModel.state != PengepulAuthState.approved &&
          viewModel.state != PengepulAuthState.rejected) {
        debugPrint('Starting approval polling from waiting screen');
        viewModel.checkApprovalStatus();
      }

      if (viewModel.state == PengepulAuthState.awaitingApproval ||
          viewModel.state == PengepulAuthState.ktpUploaded) {
        _progressController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Menunggu Persetujuan'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: Consumer<PengepulAuthViewModel>(
        builder: (context, viewModel, child) {
          return _buildBody(viewModel);
        },
      ),
    );
  }

  Widget _buildBody(PengepulAuthViewModel viewModel) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleStateChanges(viewModel);
    });

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        children: [
          SizedBox(height: 40.h),
          _buildStatusIcon(viewModel),
          SizedBox(height: 32.h),
          _buildStatusText(viewModel),
          SizedBox(height: 40.h),
          _buildProgressIndicator(viewModel),
          SizedBox(height: 32.h),
          _buildTimeInfo(viewModel),
          SizedBox(height: 40.h),
          _buildInfoCard(),
          SizedBox(height: 24.h),
          _buildActionButtons(viewModel),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(PengepulAuthViewModel viewModel) {
    Widget icon;
    Color color;

    switch (viewModel.state) {
      case PengepulAuthState.awaitingApproval:
        color = Colors.orange;
        icon = AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 3),
                ),
                child: Icon(Icons.access_time, size: 60.w, color: color),
              ),
            );
          },
        );
        break;
      case PengepulAuthState.approved:
        color = Colors.green;
        icon = Container(
          width: 120.w,
          height: 120.w,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
          ),
          child: Icon(Icons.check_circle, size: 60.w, color: color),
        );
        break;
      case PengepulAuthState.rejected:
        color = Colors.red;
        icon = Container(
          width: 120.w,
          height: 120.w,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
          ),
          child: Icon(Icons.cancel, size: 60.w, color: color),
        );
        break;
      default:
        color = Colors.grey;
        icon = Container(
          width: 120.w,
          height: 120.w,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
          ),
          child: Icon(Icons.help_outline, size: 60.w, color: color),
        );
    }

    return icon;
  }

  Widget _buildStatusText(PengepulAuthViewModel viewModel) {
    String title;
    String subtitle;
    Color color;

    switch (viewModel.state) {
      case PengepulAuthState.awaitingApproval:
        title = 'Menunggu Persetujuan';
        subtitle =
            'Data KTP Anda sedang diverifikasi oleh admin.\nProses ini biasanya memakan waktu 1x24 jam.';
        color = Colors.orange;
        break;
      case PengepulAuthState.approved:
        title = 'Disetujui!';
        subtitle =
            'Data KTP Anda telah diverifikasi dan disetujui.\nAnda dapat melanjutkan ke langkah berikutnya.';
        color = Colors.green;
        break;
      case PengepulAuthState.rejected:
        title = 'Ditolak';
        subtitle =
            'Data KTP Anda tidak dapat diverifikasi.\nSilakan periksa kembali data yang Anda masukkan.';
        color = Colors.red;
        break;
      default:
        title = 'Status Tidak Diketahui';
        subtitle = 'Terjadi kesalahan dalam mengecek status verifikasi.';
        color = Colors.grey;
    }

    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 12.h),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.grey[600],
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(PengepulAuthViewModel viewModel) {
    if (viewModel.state != PengepulAuthState.awaitingApproval) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return LinearProgressIndicator(
              value: _progressAnimation.value,
              backgroundColor: Colors.orange[100],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
              minHeight: 6.h,
            );
          },
        ),
        SizedBox(height: 12.h),
        Text(
          'Mengirim permintaan status... ${viewModel.pollingAttempts}/120',
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
        ),
      ],
    );
  }

  Widget _buildTimeInfo(PengepulAuthViewModel viewModel) {
    if (viewModel.state != PengepulAuthState.awaitingApproval) {
      return const SizedBox.shrink();
    }

    final int elapsed = viewModel.pollingAttempts;
    final int remaining = 120 - elapsed;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTimeInfoItem(
            'Elapsed',
            '${elapsed}s',
            Icons.timer,
            Colors.orange,
          ),
          Container(width: 1, height: 40.h, color: Colors.orange[200]),
          _buildTimeInfoItem(
            'Remaining',
            '${remaining}s',
            Icons.hourglass_empty,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfoItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20.w),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[600], size: 20.w),
              SizedBox(width: 8.w),
              Text(
                'Informasi Penting',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            '• Verifikasi KTP biasanya memakan waktu 1x24 jam\n'
            '• Pastikan data yang Anda masukkan sudah benar\n'
            '• Foto KTP harus jelas dan dapat dibaca\n'
            '• Admin akan mengirim notifikasi setelah verifikasi selesai\n'
            '• Anda dapat keluar dari halaman ini dan kembali lagi nanti',
            style: TextStyle(
              color: Colors.blue[700],
              fontSize: 14.sp,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(PengepulAuthViewModel viewModel) {
    switch (viewModel.state) {
      case PengepulAuthState.awaitingApproval:
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _refreshStatus(viewModel),
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Status'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _goToHome(),
                icon: const Icon(Icons.home),
                label: const Text('Kembali ke Beranda'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                ),
              ),
            ),
          ],
        );
      case PengepulAuthState.approved:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _proceedToNextStep(),
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Lanjutkan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14.h),
            ),
          ),
        );
      case PengepulAuthState.rejected:
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _retryKtpUpload(),
                icon: const Icon(Icons.upload),
                label: const Text('Upload Ulang KTP'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _goToHome(),
                icon: const Icon(Icons.home),
                label: const Text('Kembali ke Beranda'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                ),
              ),
            ),
          ],
        );
      default:
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _goToHome(),
            icon: const Icon(Icons.home),
            label: const Text('Kembali ke Beranda'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 14.h),
            ),
          ),
        );
    }
  }

  void _handleStateChanges(PengepulAuthViewModel viewModel) {
    if (viewModel.state == PengepulAuthState.approved &&
        !_hasShownApprovedNotification) {
      _hasShownApprovedNotification = true;
      _pulseController.stop();
      _progressController.stop();

      debugPrint('🎉 Showing approved notification');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8.w),
              const Expanded(child: Text('KTP Anda telah disetujui!')),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } else if (viewModel.state == PengepulAuthState.rejected &&
        !_hasShownRejectedNotification) {
      _hasShownRejectedNotification = true;
      _pulseController.stop();
      _progressController.stop();

      debugPrint('❌ Showing rejected notification');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8.w),
              const Expanded(
                child: Text('KTP Anda ditolak. Silakan upload ulang.'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _refreshStatus(PengepulAuthViewModel viewModel) {
    viewModel.checkApprovalStatus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mengecek status terbaru...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _proceedToNextStep() {
    final viewModel = context.read<PengepulAuthViewModel>();
    if (viewModel.isPollingApproval) {
      debugPrint('Force stopping polling before navigation');
    }

    context.go('/pengepul-pin-input?isLogin=false');
  }

  void _retryKtpUpload() {
    context.go('/pengepul-ktp-form');
  }

  void _goToHome() {
    context.go('/xlogin');
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();

    final viewModel = context.read<PengepulAuthViewModel>();
    if (viewModel.state == PengepulAuthState.approved ||
        viewModel.state == PengepulAuthState.rejected) {
      debugPrint('Stopping polling on screen dispose');
    }

    super.dispose();
  }
}
