class ArticleModel {
  final String articleId;
  final String title;
  final String coverImage;
  final String author;
  final String heading;
  final String content;
  final String publishedAt;
  final String updatedAt;

  ArticleModel({
    required this.articleId,
    required this.title,
    required this.coverImage,
    required this.author,
    required this.heading,
    required this.content,
    required this.publishedAt,
    required this.updatedAt,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      articleId: json['article_id'],
      title: json['title'],
      coverImage: json['coverImage'],
      author: json['author'],
      heading: json['heading'],
      content: json['content'],
      publishedAt: json['publishedAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
