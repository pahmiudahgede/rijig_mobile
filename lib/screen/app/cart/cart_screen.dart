import 'package:flutter/material.dart';

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
      body: Center(child: Text("ini adalah halaman $titleofscreen")),
    );
  }
}
