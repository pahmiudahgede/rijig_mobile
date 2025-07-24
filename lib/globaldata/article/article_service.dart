import 'package:rijig_mobile/globaldata/article/article_model.dart';
import 'package:rijig_mobile/globaldata/article/article_repository.dart';

class ArticleService {
  final ArticleRepository _repository;

  ArticleService(this._repository);

  Future<List<ArticleModel>> getArticles() async {
    try {
      final articles = await _repository.getArticles();

      articles.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

      return articles;
    } catch (e) {
      throw Exception('Failed to load articles: $e');
    }
  }

  Future<ArticleModel> getArticleById(String articleId) async {
    try {
      if (articleId.isEmpty) {
        throw Exception('Article ID cannot be empty');
      }

      return await _repository.getArticleById(articleId);
    } catch (e) {
      throw Exception('Failed to load article: $e');
    }
  }

  Future<int> getArticleCount() async {
    try {
      return await _repository.getArticleCount();
    } catch (e) {
      throw Exception('Failed to get article count: $e');
    }
  }

  List<ArticleModel> searchArticles(List<ArticleModel> articles, String query) {
    if (query.isEmpty) return articles;

    final lowerQuery = query.toLowerCase();
    return articles.where((article) {
      return article.title.toLowerCase().contains(lowerQuery) ||
          article.heading.toLowerCase().contains(lowerQuery) ||
          article.content.toLowerCase().contains(lowerQuery) ||
          article.author.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  List<ArticleModel> getArticlesByAuthor(
    List<ArticleModel> articles,
    String author,
  ) {
    return articles
        .where(
          (article) => article.author.toLowerCase() == author.toLowerCase(),
        )
        .toList();
  }

  List<ArticleModel> getArticlesByTitle(
    List<ArticleModel> articles,
    String title,
  ) {
    return articles
        .where((article) => article.title.toLowerCase() == title.toLowerCase())
        .toList();
  }

  List<String> getUniqueAuthors(List<ArticleModel> articles) {
    final authors = articles.map((article) => article.author).toSet().toList();
    authors.sort();
    return authors;
  }

  List<String> getUniqueTitles(List<ArticleModel> articles) {
    final titles = articles.map((article) => article.title).toSet().toList();
    titles.sort();
    return titles;
  }

  bool isValidArticle(ArticleModel article) {
    return article.articleId.isNotEmpty &&
        article.title.isNotEmpty &&
        article.heading.isNotEmpty &&
        article.content.isNotEmpty &&
        article.author.isNotEmpty;
  }

  String getArticleSummary(ArticleModel article, {int maxLength = 150}) {
    if (article.content.length <= maxLength) {
      return article.content;
    }
    return '${article.content.substring(0, maxLength)}...';
  }

  String getFormattedPublishedDate(ArticleModel article) {
    try {
      return article.publishedAt;
    } catch (e) {
      return 'Unknown date';
    }
  }

  int getEstimatedReadingTime(ArticleModel article) {
    const int averageWPM = 200;
    final wordCount = article.content.split(' ').length;
    final readingTime = (wordCount / averageWPM).ceil();
    return readingTime > 0 ? readingTime : 1;
  }

  Map<String, dynamic> getArticlesStats(List<ArticleModel> articles) {
    final authors = getUniqueAuthors(articles);
    final titles = getUniqueTitles(articles);

    return {
      'total_articles': articles.length,
      'unique_authors': authors.length,
      'unique_categories': titles.length,
      'authors': authors,
      'categories': titles,
    };
  }
}
