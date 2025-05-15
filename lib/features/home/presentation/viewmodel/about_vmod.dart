import 'package:flutter/material.dart';
import 'package:rijig_mobile/features/home/service/about_service.dart';
import 'package:rijig_mobile/features/home/model/about_model.dart';

class AboutViewModel extends ChangeNotifier {
  final AboutService _aboutService;

  AboutViewModel(this._aboutService);

  bool isLoading = false;
  String? errorMessage;
  List<AboutModel>? aboutList;

  Future<void> getAboutList() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      aboutList = await _aboutService.getAboutList();
    } catch (e) {
      errorMessage = "Error: ${e.toString()}";
    }

    isLoading = false;
    notifyListeners();
  }
}

class AboutDetailViewModel extends ChangeNotifier {
  final AboutService service;

  AboutDetailViewModel(this.service);

  bool isLoading = false;
  String? errorMessage;
  List<AboutDetailModel> details = [];

  Future<void> getDetail(String aboutId) async {
    isLoading = true;
    notifyListeners();

    try {
      details = await service.getAboutDetail(aboutId);
    } catch (e) {
      errorMessage = "Failed to fetch: $e";
    }

    isLoading = false;
    notifyListeners();
  }
}
