import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    // this.press,
  });

  final String title;
  // GestureTapCallback press;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        TextButton(
          onPressed: (){},
          style: TextButton.styleFrom(foregroundColor: Colors.grey),
          child: const Text("See more"),
        ),
      ],
    );
  }
}
