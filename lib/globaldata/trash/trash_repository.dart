import 'package:rijig_mobile/core/api/api_services.dart';
import 'package:rijig_mobile/globaldata/trash/trash_model.dart';

abstract class ITrashCategoryRepository {
  Future<TrashCategoryResponse> fetchCategories();
}

class TrashCategoryRepository implements ITrashCategoryRepository {
  final Https _https = Https();

  @override
  Future<TrashCategoryResponse> fetchCategories() async {
    try {
      final response = await _https.get('/trash/categories');
      return TrashCategoryResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
