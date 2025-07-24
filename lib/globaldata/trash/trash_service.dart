import 'package:rijig_mobile/globaldata/trash/trash_model.dart';
import 'package:rijig_mobile/globaldata/trash/trash_repository.dart';

class TrashService {
  final TrashRepository _repository;

  TrashService(this._repository);

  Future<List<TrashCategory>> getTrashCategories() async {
    try {
      final categories = await _repository.getTrashCategories();
      
      
      categories.sort((a, b) => a.name.compareTo(b.name));
      
      return categories;
    } catch (e) {
      throw Exception('Failed to load trash categories: $e');
    }
  }

  
  bool isValidCategory(TrashCategory category) {
    return category.id.isNotEmpty && 
           category.name.isNotEmpty && 
           category.price > 0;
  }

  
  Map<String, int> getPriceRange(List<TrashCategory> categories) {
    if (categories.isEmpty) {
      return {'min': 0, 'max': 0};
    }
    
    final prices = categories.map((c) => c.price).toList();
    return {
      'min': prices.reduce((a, b) => a < b ? a : b),
      'max': prices.reduce((a, b) => a > b ? a : b),
    };
  }
}