class TrashCategory {
  final String id;
  final String name;
  final String icon;
  final int price;
  final String variety;
  final DateTime createdAt;
  final DateTime updatedAt;

  TrashCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.price,
    required this.variety,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TrashCategory.fromJson(Map<String, dynamic> json) {
    return TrashCategory(
      id: json['id'] ?? '',
      name: json['trash_name'] ?? '',
      icon: json['trash_icon'] ?? '',
      price: json['estimated_price'] ?? 0,
      variety: json['variety'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trash_name': name,
      'trash_icon': icon,
      'estimated_price': price,
      'variety': variety,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
