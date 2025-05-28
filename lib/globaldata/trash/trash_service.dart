import 'package:rijig_mobile/globaldata/trash/trash_model.dart';
import 'package:rijig_mobile/globaldata/trash/trash_repository.dart';

abstract class ITrashCategoryService {
  Future<TrashCategoryResponse> getCategories();
}

class TrashCategoryService implements ITrashCategoryService {
  final ITrashCategoryRepository _repository;

  TrashCategoryService(this._repository);

  @override
  Future<TrashCategoryResponse> getCategories() async {
    try {
      final response = await _repository.fetchCategories();

      return response;
    } catch (e) {
      throw TrashCategoryServiceException(
        'Service Error: Failed to load categories - $e',
        500,
      );
    }
  }
}

class TrashCategoryServiceException implements Exception {
  final String message;
  final int statusCode;

  TrashCategoryServiceException(this.message, this.statusCode);

  @override
  String toString() =>
      'TrashCategoryServiceException: $message (Status: $statusCode)';
}
