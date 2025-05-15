class AboutModel {
  final String id;
  final String title;
  final String coverImage;
  final String createdAt;
  final String updatedAt;

  AboutModel({
    required this.id,
    required this.title,
    required this.coverImage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AboutModel.fromJson(Map<String, dynamic> json) {
    return AboutModel(
      id: json['id'],
      title: json['title'],
      coverImage: json['cover_image'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class AboutDetailModel {
  final String id;
  final String aboutId; // nullable jika perlu
  final String imageDetail;
  final String description;
  final String createdAt;
  final String updatedAt;

  AboutDetailModel({
    required this.id,
    required this.aboutId,
    required this.imageDetail,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AboutDetailModel.fromJson(Map<String, dynamic> json) {
    return AboutDetailModel(
      id: json['id'],
      aboutId: json['about_id'] ?? '',  // Use empty string or null as fallback
      imageDetail: json['image_detail'],
      description: json['description'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

