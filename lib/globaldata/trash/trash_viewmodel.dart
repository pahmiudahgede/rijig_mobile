import 'package:flutter/material.dart';
import 'package:rijig_mobile/globaldata/trash/trash_model.dart';
import 'package:rijig_mobile/globaldata/trash/trash_service.dart';

class TrashViewModel extends ChangeNotifier {
  final TrashCategoryService _trashCategoryService;

  TrashViewModel(this._trashCategoryService);

  bool isLoading = false;
  String? errorMessage;
  TrashCategoryResponse? trashCategoryResponse;

  Future<void> loadCategories() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      trashCategoryResponse = await _trashCategoryService.getCategories();
    } catch (e) {
      errorMessage = "Error: ${e.toString()}";
    }

    isLoading = false;
    notifyListeners();
  }
}
