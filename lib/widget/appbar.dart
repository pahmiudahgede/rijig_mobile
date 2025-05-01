import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:rijig_mobile/core/guide.dart';
import 'package:rijig_mobile/core/router.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String judul;

  final List<Widget>? actions;

  const CustomAppBar({super.key, required this.judul, this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 3,
      title: Text(judul, style: Tulisan.subheading(color: whiteColor)),
      leading: IconButton(
        onPressed: () {
          router.pop();
        },
        icon: Icon(Iconsax.arrow_left_3_copy, color: whiteColor, size: 26),
      ),
      backgroundColor: primaryColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
