import 'package:flutter/material.dart';
import 'package:rijig_mobile/core/utils/guide.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final titleofscreen = "Cart";
    return Scaffold(
      backgroundColor: whiteColor,
      body: Center(child: Text("ini adalah halaman $titleofscreen")),
    );
  }
}
