import 'package:flutter/material.dart';
import 'package:rijig_mobile/globaldata/trash/trash_model.dart';
import 'package:rijig_mobile/globaldata/trash/trash_repository.dart';

enum TrashState { initial, loading, loaded, error }

class TrashViewModel extends ChangeNotifier {
  final TrashRepository _repository;

  TrashViewModel(this._repository);

  TrashState _state = TrashState.initial;
  List<TrashCategory> _categories = [];
  String? _errorMessage;

  
  TrashState get state => _state;
  List<TrashCategory> get categories => _categories;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == TrashState.loading;
  bool get hasError => _state == TrashState.error;
  bool get hasData => _categories.isNotEmpty;

  
  TrashCategory? getCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  
  Future<void> loadCategories() async {
    _setState(TrashState.loading);
    _clearError();

    try {
      _categories = await _repository.getTrashCategories();
      _setState(TrashState.loaded);
    } catch (e) {
      _setError(e.toString());
      _setState(TrashState.error);
    }
  }

  
  Future<void> refresh() async {
    await loadCategories();
  }

  
  void _setState(TrashState state) {
    _state = state;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}