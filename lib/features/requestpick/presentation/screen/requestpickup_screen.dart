import 'dart:math' as math;

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/globaldata/trash/trash_viewmodel.dart';
import 'package:rijig_mobile/widget/appbar.dart';
import 'package:rijig_mobile/widget/skeletonize.dart';

class RequestPickScreen extends StatefulWidget {
  const RequestPickScreen({super.key});

  @override
  RequestPickScreenState createState() => RequestPickScreenState();
}

class RequestPickScreenState extends State<RequestPickScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TrashViewModel>(context, listen: false).loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final String? baseUrl = dotenv.env["BASE_URL"];

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: CustomAppBar(judul: "Pilih sampah"),
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
        child: Consumer<TrashViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return ListView.builder(
                shrinkWrap: true,
                itemCount: 5,
                itemBuilder: (context, index) {
                  return SkeletonCard();
                },
              );
            }

            if (viewModel.errorMessage != null) {
              return Center(child: Text(viewModel.errorMessage!));
            }

            return ListView.builder(
              itemCount:
                  viewModel.trashCategoryResponse?.categories.length ?? 0,
              itemBuilder: (context, index) {
                final category =
                    viewModel.trashCategoryResponse!.categories[index];
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
                    subtitle: Text("${category.price}"),
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
