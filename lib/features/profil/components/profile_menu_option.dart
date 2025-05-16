import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/features/profil/components/profile_list_tile.dart';

class ProfileMenuOptions extends StatelessWidget {
  const ProfileMenuOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: PaddingCustom().paddingAll(7),
      decoration: BoxDecoration(
        color: whiteColor,
        border: Border.all(color: greyColor),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          ProfileListTile(
            title: 'Ubah Pin',
            iconColor: primaryColor,
            icon: Iconsax.wallet,
            onTap: () {},
          ),
          Divider(thickness: 0.7, color: greyColor),
          ProfileListTile(
            title: 'Alamat',
            iconColor: primaryColor,
            icon: Iconsax.wallet,
            onTap: () {},
          ),
          Divider(thickness: 0.7, color: greyColor),
          ProfileListTile(
            title: 'Bantuan',
            icon: Iconsax.wallet,
            iconColor: primaryColor,
            onTap: () {},
          ),
          Divider(thickness: 0.7, color: greyColor),
          ProfileListTile(
            title: 'Ulasan',
            icon: Iconsax.wallet,
            iconColor: primaryColor,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
