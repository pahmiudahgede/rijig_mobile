import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/features/cart/model/cartitem_model.dart';
import 'package:rijig_mobile/features/cart/presentation/viewmodel/cartitem_vmod.dart';
import 'package:rijig_mobile/globaldata/trash/trash_viewmodel.dart';
import 'package:rijig_mobile/widget/appbar.dart';
import 'package:rijig_mobile/widget/skeletonize.dart';

class RequestPickScreen extends StatefulWidget {
  const RequestPickScreen({super.key});

  @override
  RequestPickScreenState createState() => RequestPickScreenState();
}

class RequestPickScreenState extends State<RequestPickScreen> {
  bool isCartLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final trashVM = Provider.of<TrashViewModel>(context, listen: false);
      final cartVM = Provider.of<CartViewModel>(context, listen: false);
      await trashVM.loadCategories();
      await cartVM.loadLocalCart();
      setState(() => isCartLoaded = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final String? baseUrl = dotenv.env["BASE_URL"];

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: CustomAppBar(judul: "Pilih Sampah"),
      body: CustomMaterialIndicator(
        onRefresh: () async {
          await Provider.of<TrashViewModel>(
            context,
            listen: false,
          ).loadCategories();
        },
        backgroundColor: whiteColor,
        indicatorBuilder: (context, controller) {
          return Padding(
            padding: PaddingCustom().paddingAll(6),
            child: CircularProgressIndicator(
              color: primaryColor,
              value:
                  controller.state.isLoading
                      ? null
                      : math.min(controller.value, 1.0),
            ),
          );
        },
        child: Consumer2<TrashViewModel, CartViewModel>(
          builder: (context, trashViewModel, cartViewModel, child) {
            if (!isCartLoaded || trashViewModel.isLoading) {
              return ListView.builder(
                shrinkWrap: true,
                itemCount: 5,
                itemBuilder: (context, index) => SkeletonCard(),
              );
            }

            if (trashViewModel.errorMessage != null) {
              return Center(child: Text(trashViewModel.errorMessage!));
            }

            final categories =
                trashViewModel.trashCategoryResponse?.categories ?? [];

            return ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final cartItems = cartViewModel.cartItems;
                final existingItem = cartItems.firstWhereOrNull(
                  (e) =>
                      e.trashId.trim().toLowerCase() ==
                      category.id.trim().toLowerCase(),
                );
                final amount = existingItem?.amount;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 15,
                  ),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Image.network(
                      "$baseUrl${category.icon}",
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(category.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Rp${category.price} per kg"),
                        const SizedBox(height: 6),
                        (amount != null && amount > 0)
                            ? Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    final newAmount = (amount - 0.25).clamp(
                                      0.25,
                                      double.infinity,
                                    );
                                    cartViewModel.addOrUpdateItem(
                                      CartItem(
                                        trashId: category.id,
                                        amount: newAmount,
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.remove),
                                ),
                                Text("${amount.toStringAsFixed(2)} kg"),
                                IconButton(
                                  onPressed: () {
                                    final newAmount = amount + 0.25;
                                    cartViewModel.addOrUpdateItem(
                                      CartItem(
                                        trashId: category.id,
                                        amount: newAmount,
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.add),
                                ),
                              ],
                            )
                            : ElevatedButton.icon(
                              onPressed: () {
                                cartViewModel.addOrUpdateItem(
                                  CartItem(trashId: category.id, amount: 0.25),
                                );
                              },
                              icon: const Icon(Icons.add),
                              label: const Text("Tambah ke Keranjang"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: whiteColor,
                              ),
                            ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
