import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rijig_mobile/core/router.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/globaldata/article/article_vmod.dart';
import 'package:rijig_mobile/widget/skeletonize.dart';

class ArticleScreen extends StatefulWidget {
  const ArticleScreen({super.key});

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ArticleViewModel>(context, listen: false).loadArticles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final String? baseUrl = dotenv.env["BASE_URL"];

    return Consumer<ArticleViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: 1,
            itemBuilder: (context, index) {
              return SkeletonCard();
            },
          );
        }

        if (viewModel.errorMessage != null) {
          return Center(child: Text("Error: ${viewModel.errorMessage}"));
        }

        if (viewModel.articles.isEmpty) {
          return const Center(child: Text("Tidak ada artikel ditemukan."));
        }

        return SizedBox(
          height: 190,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: viewModel.articles.length,
            separatorBuilder: (_, __) => Gap(12),
            itemBuilder: (context, index) {
              final article = viewModel.articles[index];
              return GestureDetector(
                onTap: () {
                  router.push("/artikeldetail", extra: article);
                },
                child: Container(
                  padding: PaddingCustom().paddingAll(3),
                  width: 180,
                  decoration: BoxDecoration(
                    border: Border.all(color: greyColor),
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: Image.network(
                          "$baseUrl${article.coverImage}",
                          width: double.infinity,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  const Icon(Icons.image_not_supported),
                        ),
                      ),
                      Padding(
                        padding: PaddingCustom().paddingAll(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              article.heading,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "by ${article.author} • ${article.publishedAt}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
