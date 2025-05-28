import 'package:flutter/material.dart';
import 'package:rijig_mobile/globaldata/trash/trash_model.dart';
import 'package:rijig_mobile/globaldata/trash/trash_service.dart';

enum TrashCategoryState { initial, loading, loaded, error }

class TrashViewModel extends ChangeNotifier {
  final ITrashCategoryService _service;

  TrashViewModel(this._service);

  TrashCategoryState _state = TrashCategoryState.initial;
  String? _errorMessage;
  TrashCategoryResponse? _trashCategoryResponse;

  TrashCategoryState get state => _state;
  bool get isLoading => _state == TrashCategoryState.loading;
  bool get hasError => _state == TrashCategoryState.error;
  bool get hasData =>
      _state == TrashCategoryState.loaded && _trashCategoryResponse != null;
  String? get errorMessage => _errorMessage;
  TrashCategoryResponse? get trashCategoryResponse => _trashCategoryResponse;
  List<Category> get categories => _trashCategoryResponse?.categories ?? [];

  void _setState(TrashCategoryState newState) {
    _state = newState;
    notifyListeners();
  }
  

  Future<void> loadCategories({bool forceRefresh = false}) async {
    if (_state == TrashCategoryState.loading) return;

    if (_state == TrashCategoryState.loaded && !forceRefresh) return;

    _setState(TrashCategoryState.loading);
    _errorMessage = null;

    try {
      _trashCategoryResponse = await _service.getCategories();
      _setState(TrashCategoryState.loaded);
    } on TrashCategoryServiceException catch (e) {
      _errorMessage = e.message;
      _setState(TrashCategoryState.error);
    } catch (e) {
      _errorMessage = "Unexpected error: ${e.toString()}";
      _setState(TrashCategoryState.error);
    }
  }

  void clearError() {
    if (_state == TrashCategoryState.error) {
      _errorMessage = null;
      _setState(TrashCategoryState.initial);
    }
  }

  void reset() {
    _state = TrashCategoryState.initial;
    _errorMessage = null;
    _trashCategoryResponse = null;
    notifyListeners();
  }

  Category? getCategoryById(String id) {
    try {
      return categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Category> searchCategories(String query) {
    if (query.isEmpty) return categories;

    return categories
        .where(
          (category) =>
              category.name.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }
}
