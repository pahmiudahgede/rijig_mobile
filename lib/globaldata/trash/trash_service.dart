import 'package:rijig_mobile/globaldata/trash/trash_model.dart';
import 'package:rijig_mobile/globaldata/trash/trash_repository.dart';

class TrashCategoryService {
  final TrashCategoryRepository _trashCategoryRepository;

  TrashCategoryService(this._trashCategoryRepository);

  Future<TrashCategoryResponse> getCategories() async {
    try {
      return await _trashCategoryRepository.fetchCategories();
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }
}
