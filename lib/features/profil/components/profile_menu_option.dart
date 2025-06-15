// import 'package:flutter/material.dart';
// import 'package:iconsax_flutter/iconsax_flutter.dart';
// import 'package:rijig_mobile/core/router.dart';
// import 'package:rijig_mobile/core/utils/guide.dart';
// import 'package:rijig_mobile/features/profil/components/profile_list_tile.dart';
// import 'package:rijig_mobile/widget/buttoncard.dart';
// import 'package:rijig_mobile/widget/custom_bottom_sheet.dart';

// class ProfileMenuOptions extends StatelessWidget {
//   const ProfileMenuOptions({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: PaddingCustom().paddingAll(10),
//       decoration: BoxDecoration(
//         color: whiteColor,
//         border: Border.all(color: greyColor),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Column(
//         children: [
//           ProfileListTile(
//             title: 'Pin',
//             iconColor: primaryColor,
//             icon: Iconsax.wallet,
//             onTap: () {
//               router.push('/pinsecureinput');
//             },
//           ),
//           Divider(thickness: 0.7, color: greyColor),
//           ProfileListTile(
//             title: 'Alamat',
//             iconColor: primaryColor,
//             icon: Iconsax.wallet,
//             onTap: () {
//               router.push('/address');
//             },
//           ),
//           Divider(thickness: 0.7, color: greyColor),
//           ProfileListTile(
//             title: 'Bantuan',
//             icon: Iconsax.wallet,
//             iconColor: primaryColor,
//             onTap: () {},
//           ),
//           Divider(thickness: 0.7, color: greyColor),
//           ProfileListTile(
//             title: 'Ulasan',
//             icon: Iconsax.wallet,
//             iconColor: primaryColor,
//             onTap: () {},
//           ),
//           Divider(thickness: 0.7, color: greyColor),
//           ProfileListTile(
//             title: 'Keluar',
//             icon: Iconsax.logout,
//             iconColor: redColor,
//             onTap:
//                 () => CustomBottomSheet.show(
//                   context: context,
//                   title: "Logout Sekarang?",
//                   content: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text("Yakin ingin logout dari akun ini?"),
//                       // tambahan konten
//                     ],
//                   ),
//                   button1: CardButtonOne(
//                     textButton: "Logout",
//                     onTap: () {},
//                     fontSized: 14,
//                     colorText: Colors.white,
//                     color: Colors.red,
//                     borderRadius: 10,
//                     horizontal: double.infinity,
//                     vertical: 50,
//                     loadingTrue: false,
//                     usingRow: false,
//                   ),
//                   button2: CardButtonOne(
//                     textButton: "Batal",
//                     onTap: () => router.pop(),
//                     fontSized: 14,
//                     colorText: Colors.red,
//                     color: Colors.white,
//                     borderRadius: 10,
//                     horizontal: double.infinity,
//                     vertical: 50,
//                     loadingTrue: false,
//                     usingRow: false,
//                   ),
//                 ),
//           ),
//         ],
//       ),
//     );
//   }
// }
