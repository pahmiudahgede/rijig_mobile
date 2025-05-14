import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rijig_mobile/core/utils/guide.dart';

class CardWithIcon extends StatelessWidget {
  final IconData icon;
  final String text;
  final String number;
  final Function() onTap;

  const CardWithIcon({
    super.key,
    required this.icon,
    required this.text,
    required this.number,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 164,
        height: 120,
        padding: const EdgeInsets.fromLTRB(14, 8, 13, 9),
        decoration: BoxDecoration(
          color: Colors.transparent.withValues(alpha: 3.5),
          borderRadius: const BorderRadius.all(Radius.circular(13)),
          border: Border.all(color: greyColor, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 30, color: primaryColor),
            const SizedBox(width: 8, height: 20),
            Text(
              text,
              style: GoogleFonts.dmSans(
                textStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: regular,
                  color: greyColor,
                ),
              ),
            ),
            Text(
              number,
              style: GoogleFonts.roboto(
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: bold,
                  color: greyColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
