import 'package:flutter/material.dart';
import 'package:rijig_mobile/globaldata/article/article_model.dart';
import 'package:rijig_mobile/globaldata/article/article_service.dart';

class ArticleViewModel extends ChangeNotifier {
  final ArticleService _articleService;

  ArticleViewModel(this._articleService);

  List<ArticleModel> _articles = [];
  List<ArticleModel> get articles => _articles;

  bool isLoading = false;
  String? errorMessage;

  Future<void> loadArticles() async {
    isLoading = true;
    notifyListeners();

    try {
      _articles = await _articleService.getAllArticles();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
