import 'package:flutter/material.dart';
import 'package:rijig_mobile/core/api/api_services.dart';
import 'package:rijig_mobile/globaldata/article/article_model.dart';

class ArticleRepository {
  final Https _https = Https();

  Future<List<ArticleModel>> fetchArticles() async {
    final response = await _https.get('/article-rijik/view-article');
    debugPrint("reponse article: $response");
    final List data = response['data'];
    return data.map((json) => ArticleModel.fromJson(json)).toList();
  }
}
