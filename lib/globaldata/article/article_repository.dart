import 'package:rijig_mobile/core/api/api_client.dart';
import 'package:rijig_mobile/core/api/api_response.dart';
import 'package:rijig_mobile/globaldata/article/article_model.dart';

class ArticleRepository {
  final ApiClient _apiClient;

  ArticleRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<ArticleModel>> getArticles() async {
    try {
      final ApiResponse response = await _apiClient.get(
        '/article/view?page=1&limit=10',
      );

      if (response.isSuccess && response.data != null) {
        final Map<String, dynamic> dataMap = response.data['data'] ?? {};
        final List<dynamic> articlesList = dataMap['articles'] ?? [];
        return articlesList.map((json) => ArticleModel.fromJson(json)).toList();
      }

      throw Exception(response.message);
    } catch (e) {
      throw Exception('Failed to get articles: $e');
    }
  }

  Future<ArticleModel> getArticleById(String articleId) async {
    try {
      final articles = await getArticles();
      final article = articles.firstWhere(
        (article) => article.articleId == articleId,
        orElse: () => throw Exception('Article not found'),
      );
      return article;
    } catch (e) {
      throw Exception('Failed to get article: $e');
    }
  }

  Future<int> getArticleCount() async {
    try {
      final ApiResponse response = await _apiClient.get(
        '/article/view?page=1&limit=10',
      );

      if (response.isSuccess && response.data != null) {
        final Map<String, dynamic> dataMap = response.data['data'] ?? {};
        return dataMap['total'] ?? 0;
      }

      return 0;
    } catch (e) {
      throw Exception('Failed to get article count: $e');
    }
  }
}
