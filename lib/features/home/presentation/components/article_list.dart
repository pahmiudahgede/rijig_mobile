import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rijig_mobile/globaldata/article/article_vmod.dart';

class ArticleScreen extends StatefulWidget {
  const ArticleScreen({super.key});

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch data setelah frame build pertama
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
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.errorMessage != null) {
          return Center(child: Text("Error: ${viewModel.errorMessage}"));
        }

        if (viewModel.articles.isEmpty) {
          return const Center(child: Text("Tidak ada artikel ditemukan."));
        }

        return ListView.builder(
          itemCount: viewModel.articles.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final article = viewModel.articles[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    "$baseUrl${article.coverImage}",
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) =>
                            const Icon(Icons.image_not_supported),
                  ),
                ),
                title: Text(
                  article.heading,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  "By ${article.author} • ${article.publishedAt}",
                  style: const TextStyle(fontSize: 12),
                ),
                onTap: () {
                  // Navigasi ke detail (jika tersedia)
                  // router.push('/article-detail', extra: article.articleId);
                },
              ),
            );
          },
        );
      },
    );
  }
}
