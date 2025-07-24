import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rijig_mobile/core/storage/token_manager.dart';
import 'package:rijig_mobile/features/auth/presentation/viewmodel/auth_viewmodel.dart';
import 'package:rijig_mobile/features/pengepul/auth/presentation/viewmodel/pengepul_auth_viewmodel.dart';

enum UserRole {
  masyarakat,
  pengepul,
  unknown;

  String get value {
    switch (this) {
      case UserRole.masyarakat:
        return 'masyarakat';
      case UserRole.pengepul:
        return 'pengepul';
      case UserRole.unknown:
        return 'unknown';
    }
  }

  static UserRole fromString(String? roleString) {
    if (roleString == null || roleString.isEmpty) {
      return UserRole.unknown;
    }

    switch (roleString.toLowerCase()) {
      case 'masyarakat':
        return UserRole.masyarakat;
      case 'pengepul':
        return UserRole.pengepul;
      default:
        return UserRole.unknown;
    }
  }
}

class RoleManager {
  static final RoleManager _instance = RoleManager._internal();
  factory RoleManager() => _instance;
  RoleManager._internal();

  final TokenManager _tokenManager = TokenManager();

  Future<UserRole> getCurrentRole() async {
    final roleString = await _tokenManager.getUserRole();
    return UserRole.fromString(roleString);
  }

  Future<bool> isLoggedIn() async {
    return await _tokenManager.isLoggedIn();
  }

  Future<bool> isRegistrationComplete() async {
    return await _tokenManager.isRegistrationComplete();
  }

  Future<String?> getNextStep() async {
    return await _tokenManager.getNextStep();
  }

  Future<String?> getRegistrationStatus() async {
    return await _tokenManager.getRegistrationStatus();
  }

  static Widget buildRoleBasedWidget({
    required BuildContext context,
    required Widget Function(AuthViewModel authViewModel) masyarakatBuilder,
    required Widget Function(PengepulAuthViewModel pengepulViewModel)
    pengepulBuilder,
    Widget Function()? unknownRoleBuilder,
  }) {
    return FutureBuilder<UserRole>(
      future: RoleManager().getCurrentRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final role = snapshot.data ?? UserRole.unknown;

        switch (role) {
          case UserRole.masyarakat:
            return Consumer<AuthViewModel>(
              builder: (context, authViewModel, child) {
                return masyarakatBuilder(authViewModel);
              },
            );
          case UserRole.pengepul:
            return Consumer<PengepulAuthViewModel>(
              builder: (context, pengepulViewModel, child) {
                return pengepulBuilder(pengepulViewModel);
              },
            );
          case UserRole.unknown:
            return unknownRoleBuilder?.call() ??
                const Center(child: Text('Unknown user role'));
        }
      },
    );
  }

  static String getHomeRouteForRole(UserRole role) {
    switch (role) {
      case UserRole.masyarakat:
        return '/navigasi';
      case UserRole.pengepul:
        return '/berandapengepul';
      case UserRole.unknown:
        return '/xlogin';
    }
  }

  static String getRegistrationRoute(UserRole role, String? nextStep) {
    switch (role) {
      case UserRole.masyarakat:
        switch (nextStep) {
          case 'complete_personal_data':
            return '/xprofile-form';
          case 'create_pin':
            return '/xpin-input?isLogin=false';
          case 'verif_pin':
            return '/xpin-input?isLogin=true';
          default:
            return '/xlogin';
        }
      case UserRole.pengepul:
        switch (nextStep) {
          case 'upload_ktp':
            return '/pengepul-ktp-form';
          case 'awaiting_admin_approval':
            return '/pengepul-approval-waiting';
          case 'create_pin':
            return '/pengepul-pin-input?isLogin=false';
          case 'verif_pin':
            return '/pengepul-pin-input?isLogin=true';
          default:
            return '/pengepul-login';
        }
      case UserRole.unknown:
        return '/xlogin';
    }
  }

  Future<bool> hasRole(UserRole expectedRole) async {
    final currentRole = await getCurrentRole();
    return currentRole == expectedRole;
  }

  static Future<void> logoutCurrentUser(BuildContext context) async {
    final roleManager = RoleManager();
    final currentRole = await roleManager.getCurrentRole();

    switch (currentRole) {
      case UserRole.masyarakat:
        if (context.mounted) {
          final authViewModel = context.read<AuthViewModel>();
          await authViewModel.logout();
        }
        break;
      case UserRole.pengepul:
        if (context.mounted) {
          final pengepulViewModel = context.read<PengepulAuthViewModel>();
          await pengepulViewModel.logout();
        }
        break;
      case UserRole.unknown:
        await TokenManager().clearSession();
        break;
    }
  }
}

extension RoleContextExtension on BuildContext {
  AuthViewModel get masyarakatAuth => read<AuthViewModel>();
  PengepulAuthViewModel get pengepulAuth => read<PengepulAuthViewModel>();

  Future<dynamic> getCurrentAuthViewModel() async {
    final role = await RoleManager().getCurrentRole();
    switch (role) {
      case UserRole.masyarakat:
        return read<AuthViewModel>();
      case UserRole.pengepul:
        return read<PengepulAuthViewModel>();
      case UserRole.unknown:
        return null;
    }
  }
}
