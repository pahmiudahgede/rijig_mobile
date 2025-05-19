// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rijig_mobile/core/router.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/features/cart/model/cartitem_model.dart';
import 'package:rijig_mobile/features/cart/presentation/viewmodel/cartitem_vmod.dart';
import 'package:rijig_mobile/widget/buttoncard.dart';
import 'package:rijig_mobile/widget/skeletonize.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with WidgetsBindingObserver {
  CartResponse? cart;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    fetchCart();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint("App resumed, flushing cart...");
      final vmod = Provider.of<CartViewModel>(context, listen: false);
      vmod.flushCartToServer();
    }
  }

  Future<void> fetchCart() async {
    final vmod = Provider.of<CartViewModel>(context, listen: false);
    final result = await vmod.fetchCartFromServer();
    setState(() {
      cart = result;
      isLoading = false;
    });
  }

  double get totalAmount => cart?.totalAmount ?? 0;
  double get totalPrice => cart?.estimatedTotalPrice ?? 0;

  String formatAmount(double value) {
    String formattedValue = value.toStringAsFixed(2);
    return formattedValue.endsWith('.00')
        ? formattedValue.split('.').first
        : formattedValue;
  }

  void _showEditDialog(String trashId, double currentAmount, int index) {
    double editedAmount = currentAmount;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Jumlah'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  setState(() {
                    if (editedAmount > 0.25) editedAmount -= 0.25;
                  });
                },
              ),
              Text('${formatAmount(editedAmount)} kg'),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    editedAmount += 0.25;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                final vmod = Provider.of<CartViewModel>(context, listen: false);
                vmod.addOrUpdateItem(
                  CartItem(trashId: trashId, amount: editedAmount),
                );

                final item = cart!.cartItems[index];
                setState(() {
                  cart!.cartItems[index] = CartItemResponse(
                    trashIcon: item.trashIcon,
                    trashName: item.trashName,
                    amount: editedAmount,
                    estimatedSubTotalPrice:
                        editedAmount *
                        (item.estimatedSubTotalPrice / item.amount),
                    trashId: item.trashId,
                  );
                });

                Navigator.of(context).pop();
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void recalculateCartSummary() {
    double totalWeight = 0;
    double totalPrice = 0;

    for (final item in cart!.cartItems) {
      totalWeight += item.amount;
      totalPrice += item.estimatedSubTotalPrice;
    }

    setState(() {
      cart = CartResponse(
        id: cart!.id,
        userId: cart!.userId,
        totalAmount: totalWeight,
        estimatedTotalPrice: totalPrice,
        createdAt: cart!.createdAt,
        updatedAt: cart!.updatedAt,
        cartItems: cart!.cartItems,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final String? baseUrl = dotenv.env["BASE_URL"];

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: Text("Keranjang Item", style: Tulisan.subheading()),
        backgroundColor: whiteColor,
        centerTitle: true,
      ),
      body: SafeArea(
        child:
            isLoading
                ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return SkeletonCard();
                  },
                )
                : Padding(
                  padding: PaddingCustom().paddingOnly(
                    left: 10,
                    right: 10,
                    bottom: 40,
                    top: 10,
                  ),
                  child: Column(
                    children: [
                      const Gap(20),
                      Expanded(
                        child: ListView.builder(
                          itemCount: cart?.cartItems.length ?? 0,
                          itemBuilder: (context, index) {
                            final item = cart!.cartItems[index];
                            final perKgPrice =
                                item.estimatedSubTotalPrice / item.amount;
                            final currentAmount = item.amount;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              padding: PaddingCustom().paddingAll(20),
                              decoration: BoxDecoration(
                                color: whiteColor,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: greyColor.withValues(alpha: 0.1),
                                    spreadRadius: 1,
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Image.network(
                                        "$baseUrl${item.trashIcon}",
                                        width: 50,
                                        height: 50,
                                      ),
                                      const Gap(10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.trashName,
                                              style: Tulisan.customText(),
                                            ),
                                            Text(
                                              "Rp${perKgPrice.toStringAsFixed(0)} / kg",
                                              style: Tulisan.body(fontsize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          final vmod =
                                              Provider.of<CartViewModel>(
                                                context,
                                                listen: false,
                                              );
                                          vmod.removeItem(item.trashId);

                                          setState(() {
                                            cart!.cartItems.removeAt(index);
                                          });

                                          recalculateCartSummary();
                                        },

                                        icon: Icon(
                                          Iconsax.trash,
                                          color: redColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Gap(10),
                                  Row(
                                    children: [
                                      Text(
                                        "berat",
                                        style: Tulisan.body(fontsize: 12),
                                      ),
                                      const Gap(12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: greyAbsolutColor,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                final newAmount =
                                                    (currentAmount - 0.25)
                                                        .clamp(
                                                          0.25,
                                                          double.infinity,
                                                        );
                                                Provider.of<CartViewModel>(
                                                  context,
                                                  listen: false,
                                                ).addOrUpdateItem(
                                                  CartItem(
                                                    trashId: item.trashId,
                                                    amount: newAmount,
                                                  ),
                                                );

                                                setState(() {
                                                  cart!.cartItems[index] =
                                                      CartItemResponse(
                                                        trashIcon:
                                                            item.trashIcon,
                                                        trashName:
                                                            item.trashName,
                                                        amount: newAmount,
                                                        estimatedSubTotalPrice:
                                                            newAmount *
                                                            (item.estimatedSubTotalPrice /
                                                                item.amount),
                                                        trashId: item.trashId,
                                                      );
                                                });

                                                recalculateCartSummary();
                                              },
                                              child: const Icon(
                                                Icons.remove,
                                                size: 20,
                                              ),
                                            ),
                                            const Gap(8),
                                            GestureDetector(
                                              onTap:
                                                  () => _showEditDialog(
                                                    item.trashId,
                                                    currentAmount,
                                                    index,
                                                  ),
                                              child: Text(
                                                formatAmount(currentAmount),
                                              ),
                                            ),
                                            const Gap(8),
                                            GestureDetector(
                                              onTap: () {
                                                final newAmount =
                                                    currentAmount + 0.25;
                                                Provider.of<CartViewModel>(
                                                  context,
                                                  listen: false,
                                                ).addOrUpdateItem(
                                                  CartItem(
                                                    trashId: item.trashId,
                                                    amount: newAmount,
                                                  ),
                                                );

                                                setState(() {
                                                  cart!.cartItems[index] =
                                                      CartItemResponse(
                                                        trashIcon:
                                                            item.trashIcon,
                                                        trashName:
                                                            item.trashName,
                                                        amount: newAmount,
                                                        estimatedSubTotalPrice:
                                                            newAmount *
                                                            (item.estimatedSubTotalPrice /
                                                                item.amount),
                                                        trashId: item.trashId,
                                                      );
                                                });

                                                recalculateCartSummary();
                                              },
                                              child: const Icon(
                                                Icons.add,
                                                size: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: greyAbsolutColor.withValues(alpha: 0.1),
                              spreadRadius: 1,
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Cart Total",
                                  style: Tulisan.subheading(fontsize: 14),
                                ),
                                Text(
                                  "${formatAmount(totalAmount)} kg",
                                  style: Tulisan.body(fontsize: 14),
                                ),
                              ],
                            ),
                            const Gap(10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Harga Total",
                                  style: Tulisan.subheading(fontsize: 14),
                                ),
                                Text(
                                  "Rp${totalPrice.toStringAsFixed(0)}",
                                  style: Tulisan.body(fontsize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Gap(20),
                      SizedBox(
                        width: double.infinity,
                        child: CardButtonOne(
                          textButton: "Request Pickup",
                          fontSized: 16.sp,
                          color: primaryColor,
                          colorText: whiteColor,
                          borderRadius: 9,
                          horizontal: double.infinity,
                          vertical: 50,
                          // onTap: () async {
                          //   final vmod = Provider.of<CartViewModel>(
                          //     context,
                          //     listen: false,
                          //   );
                          //   await vmod.flushCartToServer();

                          //   ScaffoldMessenger.of(context).showSnackBar(
                          //     const SnackBar(
                          //       content: Text(
                          //         "Keranjang berhasil dikirim ke server!",
                          //       ),
                          //     ),
                          //   );
                          // },
                          onTap: () {
                            router.push("/pickupmethod", extra: '');
                          },
                        ),
                      ),
                      const Gap(20),
                    ],
                  ),
                ),
      ),
    );
  }
}
