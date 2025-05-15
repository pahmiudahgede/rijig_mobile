import 'package:flutter/material.dart';
import 'package:rijig_mobile/core/api/api_services.dart';
import 'package:rijig_mobile/features/home/model/about_model.dart';

class AboutRepository {
  final Https _https = Https();

  Future<List<AboutModel>> getAboutList() async {
    final response = await _https.get('/about');
    debugPrint("response about: $response");
    final List data = response['data'] ?? [];
    return data.map((e) => AboutModel.fromJson(e)).toList();
  }

  Future<List<AboutDetailModel>> getAboutDetail(String id) async {
    final response = await _https.get('/about/$id');
    debugPrint("response about detail: $response");
    final List aboutDetail = response['data']['about_detail'] ?? [];
    return aboutDetail.map((e) => AboutDetailModel.fromJson(e)).toList();
  }
}
