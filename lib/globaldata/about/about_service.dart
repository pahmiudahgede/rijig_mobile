import 'package:rijig_mobile/globaldata/about/about_repository.dart';
import 'package:rijig_mobile/globaldata/about/about_model.dart';

class AboutService {
  final AboutRepository _aboutRepository;

  AboutService(this._aboutRepository);

  Future<List<AboutModel>> getAboutList() async {
    try {
      return await _aboutRepository.getAboutList();
    } catch (e) {
      throw Exception('Failed to load About list: $e');
    }
  }

  Future<List<AboutDetailModel>> getAboutDetail(String id) async {
    try {
      return await _aboutRepository.getAboutDetail(id);
    } catch (e) {
      throw Exception('Failed to load About Detail: $e');
    }
  }
}
