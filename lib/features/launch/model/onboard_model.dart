import 'dart:convert';

class OnboardingModel {
  String imagePath;
  String headline;
  String description;
  OnboardingModel({
    required this.imagePath,
    required this.headline,
    required this.description,
  });

  OnboardingModel copyWith({
    String? imagePath,
    String? headline,
    String? description,
  }) {
    return OnboardingModel(
      imagePath: imagePath ?? this.imagePath,
      headline: headline ?? this.headline,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'imagePath': imagePath,
      'headline': headline,
      'description': description,
    };
  }

  factory OnboardingModel.fromMap(Map<String, dynamic> map) {
    return OnboardingModel(
      imagePath: map['imagePath'] ?? '',
      headline: map['headline'] ?? '',
      description: map['description'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory OnboardingModel.fromJson(String source) =>
      OnboardingModel.fromMap(json.decode(source));

  @override
  String toString() =>
      'OnboardingData(imagePath: $imagePath, headline: $headline, description: $description)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OnboardingModel &&
        other.imagePath == imagePath &&
        other.headline == headline &&
        other.description == description;
  }

  @override
  int get hashCode =>
      imagePath.hashCode ^ headline.hashCode ^ description.hashCode;
}