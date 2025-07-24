import 'package:rijig_mobile/globaldata/about/about_model.dart';
import 'package:rijig_mobile/globaldata/about/about_repository.dart';

class AboutService {
  final AboutRepository _repository;

  AboutService(this._repository);

  Future<List<AboutModel>> getAboutList() async {
    try {
      final aboutList = await _repository.getAboutList();

      aboutList.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return aboutList;
    } catch (e) {
      throw Exception('Failed to load about list: $e');
    }
  }

  Future<AboutWithDetailsModel> getAboutDetail(String aboutId) async {
    try {
      if (aboutId.isEmpty) {
        throw Exception('About ID cannot be empty');
      }

      final aboutDetail = await _repository.getAboutDetail(aboutId);

      if (aboutDetail.aboutDetails.isEmpty) {
        throw Exception('No details found for this about item');
      }

      return aboutDetail;
    } catch (e) {
      throw Exception('Failed to load about detail: $e');
    }
  }

  bool isValidAbout(AboutModel about) {
    return about.id.isNotEmpty &&
        about.title.isNotEmpty &&
        about.coverImage.isNotEmpty;
  }

  String getAboutSummary(AboutModel about, {int maxLength = 100}) {
    if (about.title.length <= maxLength) {
      return about.title;
    }
    return '${about.title.substring(0, maxLength)}...';
  }
}
