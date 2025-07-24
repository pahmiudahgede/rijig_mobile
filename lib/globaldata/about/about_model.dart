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
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      coverImage: json['cover_image'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'cover_image': coverImage,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

// lib/globaldata/about/about_detail_model.dart
class AboutDetailModel {
  final String id;
  final String aboutId;
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
      id: json['id'] ?? '',
      aboutId: json['about_id'] ?? '',
      imageDetail: json['image_detail'] ?? '',
      description: json['description'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'about_id': aboutId,
      'image_detail': imageDetail,
      'description': description,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

// lib/globaldata/about/about_with_details_model.dart
class AboutWithDetailsModel {
  final String id;
  final String title;
  final String coverImage;
  final List<AboutDetailModel> aboutDetails;
  final String createdAt;
  final String updatedAt;

  AboutWithDetailsModel({
    required this.id,
    required this.title,
    required this.coverImage,
    required this.aboutDetails,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AboutWithDetailsModel.fromJson(Map<String, dynamic> json) {
    return AboutWithDetailsModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      coverImage: json['cover_image'] ?? '',
      aboutDetails:
          (json['about_detail'] as List<dynamic>?)
              ?.map((detail) => AboutDetailModel.fromJson(detail))
              .toList() ??
          [],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'cover_image': coverImage,
      'about_detail': aboutDetails.map((detail) => detail.toJson()).toList(),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
