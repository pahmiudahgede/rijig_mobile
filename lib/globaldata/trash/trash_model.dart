class Category {
  final String id;
  final String name;
  final String icon;
  final String createdAt;
  final String updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}

class TrashCategoryResponse {
  final List<Category> categories;
  final String message;
  final int total;

  TrashCategoryResponse({
    required this.categories,
    required this.message,
    required this.total,
  });

  factory TrashCategoryResponse.fromJson(Map<String, dynamic> json) {
    return TrashCategoryResponse(
      categories:
          (json['data'] as List).map((e) => Category.fromJson(e)).toList(),
      message: json['meta']['message'],
      total: json['meta']['total'],
    );
  }
}
