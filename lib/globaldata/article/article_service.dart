
import 'package:rijig_mobile/globaldata/article/article_model.dart';
import 'package:rijig_mobile/globaldata/article/article_repository.dart';

class ArticleService {
  final ArticleRepository _repository;

  ArticleService(this._repository);

  Future<List<ArticleModel>> getAllArticles() async {
    try {
      return await _repository.fetchArticles();
    } catch (e) {
      throw Exception('Failed to load articles: $e');
    }
  }
}
