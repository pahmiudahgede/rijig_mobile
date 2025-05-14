import 'package:rijig_mobile/core/api/api_services.dart';
import 'package:rijig_mobile/globaldata/trash/trash_model.dart';

class TrashCategoryRepository {
  final Https _https = Https();

  Future<TrashCategoryResponse> fetchCategories() async {
    final response = await _https.get('/trash/categories');
    return TrashCategoryResponse.fromJson(response);
  }
}
