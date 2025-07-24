import 'package:flutter/material.dart';
import 'package:rijig_mobile/globaldata/about/about_model.dart';
import 'package:rijig_mobile/globaldata/about/about_service.dart';

class AboutViewModel extends ChangeNotifier {
  final AboutService _service;

  AboutViewModel(this._service);

  List<AboutModel>? _aboutList;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<AboutModel>? get aboutList => _aboutList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasData => _aboutList != null && _aboutList!.isNotEmpty;

  // Get about list
  Future<void> getAboutList() async {
    _setLoading(true);
    _clearError();

    try {
      _aboutList = await _service.getAboutList();
    } catch (e) {
      _setError(e.toString());
      _aboutList = null;
    } finally {
      _setLoading(false);
    }
  }

  // Refresh data
  Future<void> refresh() async {
    await getAboutList();
  }

  // Get about by ID
  AboutModel? getAboutById(String id) {
    if (_aboutList == null) return null;
    try {
      return _aboutList!.firstWhere((about) => about.id == id);
    } catch (e) {
      return null;
    }
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
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

// lib/globaldata/about/about_detail_vmod.dart
class AboutDetailViewModel extends ChangeNotifier {
  final AboutService _service;

  AboutDetailViewModel(this._service);

  AboutWithDetailsModel? _aboutWithDetails;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  AboutWithDetailsModel? get aboutWithDetails => _aboutWithDetails;
  List<AboutDetailModel> get details => _aboutWithDetails?.aboutDetails ?? [];
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasData => _aboutWithDetails != null;

  // Get about detail
  Future<void> getDetail(String aboutId) async {
    _setLoading(true);
    _clearError();

    try {
      _aboutWithDetails = await _service.getAboutDetail(aboutId);
    } catch (e) {
      _setError(e.toString());
      _aboutWithDetails = null;
    } finally {
      _setLoading(false);
    }
  }

  // Refresh data
  Future<void> refresh(String aboutId) async {
    await getDetail(aboutId);
  }

  // Clear data
  void clearData() {
    _aboutWithDetails = null;
    _clearError();
    notifyListeners();
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
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