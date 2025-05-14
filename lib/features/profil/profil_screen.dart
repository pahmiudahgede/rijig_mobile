// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rijig_mobile/core/router.dart';
import 'package:rijig_mobile/features/auth/presentation/viewmodel/logout_vmod.dart';
import 'package:rijig_mobile/widget/buttoncard.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<LogoutViewModel>(
        builder: (context, viewModel, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Are you sure you want to logout?"),
                SizedBox(height: 20),
                CardButtonOne(
                  textButton: viewModel.isLoading ? 'Logging out...' : 'Logout',
                  fontSized: 16,
                  colorText: Colors.white,
                  borderRadius: 10,
                  horizontal: double.infinity,
                  vertical: 50,
                  onTap: () async {
                    await viewModel.logout();

                    if (viewModel.errorMessage == null) {
                      router.go("/login");
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(viewModel.errorMessage!)),
                      );
                    }
                  },
                  loadingTrue: viewModel.isLoading,
                  usingRow: false,
                ),
                if (viewModel.errorMessage != null)
                  Text(
                    viewModel.errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
