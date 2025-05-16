import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/globaldata/trash/trash_viewmodel.dart';
import 'package:rijig_mobile/widget/appbar.dart';
import 'package:shimmer/shimmer.dart';

class RequestPickScreen extends StatelessWidget {
  const RequestPickScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.microtask(() {
      // ignore: use_build_context_synchronously
      Provider.of<TrashViewModel>(context, listen: false).loadCategories();
    });
    final String? baseUrl = dotenv.env["BASE_URL"];

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: CustomAppBar(judul: "Pilih sampah"),
      body: Consumer<TrashViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return ListView.builder(
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
            itemCount: viewModel.trashCategoryResponse?.categories.length ?? 0,
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
    );
  }
}

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: Container(width: 50, height: 50, color: Colors.white),
          title: Container(width: 100, height: 15, color: Colors.white),
          subtitle: Container(width: 150, height: 10, color: Colors.white),
        ),
      ),
    );
  }
}
