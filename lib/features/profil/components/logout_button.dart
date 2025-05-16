// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rijig_mobile/core/router.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/features/auth/presentation/viewmodel/logout_vmod.dart';
import 'package:rijig_mobile/widget/buttoncard.dart';

class ButtonLogout extends StatefulWidget {
  const ButtonLogout({super.key});

  @override
  State<ButtonLogout> createState() => _ButtonLogoutState();
}

class _ButtonLogoutState extends State<ButtonLogout> {
  @override
  Widget build(BuildContext context) {
    return Consumer<LogoutViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          children: [
            CardButtonOne(
              textButton: viewModel.isLoading ? 'Logging out...' : 'Logout',
              fontSized: 16,
              colorText: whiteColor,
              color: redColor,
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
        );
      },
    );
  }
}
