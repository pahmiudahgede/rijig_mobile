import 'package:flutter/material.dart';
import 'package:rijig_mobile/core/network/network_error_dialog.dart';

class NetworkDialogManager {
  static void showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoadingDialog(message: message),
    );
  }

  static void showNoInternetDialog({
    required BuildContext context,
    required VoidCallback onRetry,
    required VoidCallback onExit,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => NetworkErrorDialog(
            title: 'Tidak Ada Koneksi Internet',
            message:
                'Sepertinya koneksi internet Anda bermasalah. Periksa koneksi WiFi atau data seluler Anda, lalu coba lagi.',
            iconData: Icons.wifi_off,
            primaryButtonText: 'Coba Lagi',
            onPrimaryPressed: onRetry,
            secondaryButtonText: 'Keluar',
            onSecondaryPressed: onExit,
          ),
    );
  }

  static void showTimeoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => NetworkErrorDialog(
            title: 'Koneksi Timeout',
            message:
                'Permintaan memakan waktu terlalu lama. Periksa koneksi internet Anda dan coba lagi.',
            iconData: Icons.timer_off,
            primaryButtonText: 'Coba Lagi',
            onPrimaryPressed: () => Navigator.of(context).pop(),
            secondaryButtonText: 'Tutup',
            onSecondaryPressed: () => Navigator.of(context).pop(),
          ),
    );
  }

  static void showConnectionFailedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => NetworkErrorDialog(
            title: 'Koneksi Gagal',
            message:
                'Tidak dapat terhubung ke server. Pastikan koneksi internet Anda stabil.',
            iconData: Icons.error_outline,
            primaryButtonText: 'Coba Lagi',
            onPrimaryPressed: () => Navigator.of(context).pop(),
            secondaryButtonText: 'Tutup',
            onSecondaryPressed: () => Navigator.of(context).pop(),
          ),
    );
  }

  static void showPoorConnectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => NetworkErrorDialog(
            title: 'Koneksi Lambat',
            message:
                'Koneksi internet Anda lambat. Beberapa fitur mungkin tidak berfungsi optimal.',
            iconData: Icons.signal_wifi_bad,
            primaryButtonText: 'Lanjutkan',
            onPrimaryPressed: () => Navigator.of(context).pop(),
            secondaryButtonText: 'Tutup',
            onSecondaryPressed: () => Navigator.of(context).pop(),
          ),
    );
  }

  static void showApiErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
