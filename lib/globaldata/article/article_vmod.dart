import 'package:flutter/material.dart';
import 'package:rijig_mobile/globaldata/article/article_model.dart';
import 'package:rijig_mobile/globaldata/article/article_service.dart';

class ArticleViewModel extends ChangeNotifier {
  final ArticleService _service;

  ArticleViewModel(this._service);

  List<ArticleModel> _articles = [];
  List<ArticleModel> _filteredArticles = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  int _totalCount = 0;

  List<ArticleModel> get articles =>
      _filteredArticles.isEmpty && _searchQuery.isEmpty
          ? _articles
          : _filteredArticles;
  List<ArticleModel> get allArticles => _articles;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasData => _articles.isNotEmpty;
  String get searchQuery => _searchQuery;
  int get totalCount => _totalCount;

  Future<void> loadArticles() async {
    _setLoading(true);
    _clearError();

    try {
      _articles = await _service.getArticles();
      _filteredArticles = [];
      _searchQuery = '';

      _totalCount = await _service.getArticleCount();
    } catch (e) {
      _setError(e.toString());
      _articles = [];
      _totalCount = 0;
    } finally {
      _setLoading(false);
    }
  }

  void searchArticles(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredArticles = [];
    } else {
      _filteredArticles = _service.searchArticles(_articles, query);
    }
    notifyListeners();
  }

  void filterByAuthor(String author) {
    if (author.isEmpty) {
      _filteredArticles = [];
    } else {
      _filteredArticles = _service.getArticlesByAuthor(_articles, author);
    }
    notifyListeners();
  }

  void filterByTitle(String title) {
    if (title.isEmpty) {
      _filteredArticles = [];
    } else {
      _filteredArticles = _service.getArticlesByTitle(_articles, title);
    }
    notifyListeners();
  }

  void clearFilter() {
    _searchQuery = '';
    _filteredArticles = [];
    notifyListeners();
  }

  ArticleModel? getArticleById(String articleId) {
    try {
      return _articles.firstWhere((article) => article.articleId == articleId);
    } catch (e) {
      return null;
    }
  }

  List<ArticleModel> getArticlesByAuthor(String author) {
    return _service.getArticlesByAuthor(_articles, author);
  }

  List<String> getUniqueAuthors() {
    return _service.getUniqueAuthors(_articles);
  }

  List<String> getUniqueTitles() {
    return _service.getUniqueTitles(_articles);
  }

  String getArticleSummary(ArticleModel article, {int maxLength = 150}) {
    return _service.getArticleSummary(article, maxLength: maxLength);
  }

  int getReadingTime(ArticleModel article) {
    return _service.getEstimatedReadingTime(article);
  }

  Map<String, dynamic> getArticlesStats() {
    return _service.getArticlesStats(_articles);
  }

  bool get isShowingFilteredResults =>
      _filteredArticles.isNotEmpty || _searchQuery.isNotEmpty;

  int get currentResultCount =>
      isShowingFilteredResults ? _filteredArticles.length : _articles.length;

  Future<void> refresh() async {
    await loadArticles();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

class ArticleDetailViewModel extends ChangeNotifier {
  final ArticleService _service;

  ArticleDetailViewModel(this._service);

  ArticleModel? _article;
  bool _isLoading = false;
  String? _errorMessage;

  ArticleModel? get article => _article;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasData => _article != null;

  Future<void> getArticle(String articleId) async {
    _setLoading(true);
    _clearError();

    try {
      _article = await _service.getArticleById(articleId);
    } catch (e) {
      _setError(e.toString());
      _article = null;
    } finally {
      _setLoading(false);
    }
  }

  void setArticle(ArticleModel article) {
    _article = article;
    _clearError();
    notifyListeners();
  }

  int getReadingTime() {
    if (_article == null) return 0;
    return _service.getEstimatedReadingTime(_article!);
  }

  void clearData() {
    _article = null;
    _clearError();
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
