class Category {
  final String id;
  final String name;
  final dynamic price; // Consider using num or double instead of dynamic
  final String icon;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.price,
    required this.icon,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: json['estimatedprice'] ?? 0,
      icon: json['icon'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'estimatedprice': price,
      'icon': icon,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, price: $price, icon: $icon)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
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
    try {
      final dataList = json['data'] as List? ?? [];
      final meta = json['meta'] as Map<String, dynamic>? ?? {};

      return TrashCategoryResponse(
        categories:
            dataList
                .map((e) => Category.fromJson(e as Map<String, dynamic>))
                .toList(),
        message: meta['message'] as String? ?? '',
        total: meta['total'] as int? ?? 0,
      );
    } catch (e) {
      throw FormatException('Failed to parse TrashCategoryResponse: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'data': categories.map((e) => e.toJson()).toList(),
      'meta': {'message': message, 'total': total},
    };
  }

  @override
  String toString() {
    return 'TrashCategoryResponse(categories: ${categories.length}, message: $message, total: $total)';
  }
}
