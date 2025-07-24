import 'package:rijig_mobile/core/api/api_client.dart';
import 'package:rijig_mobile/core/api/api_response.dart';
import 'package:rijig_mobile/globaldata/about/about_model.dart';

class AboutRepository {
  final ApiClient _apiClient;

  AboutRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<AboutModel>> getAboutList() async {
    try {
      final ApiResponse response = await _apiClient.get('/about');

      if (response.isSuccess && response.data != null) {
        final List<dynamic> dataList = response.data['data'] ?? [];
        return dataList.map((json) => AboutModel.fromJson(json)).toList();
      }

      throw Exception(response.message);
    } catch (e) {
      throw Exception('Failed to get about list: $e');
    }
  }

  Future<AboutWithDetailsModel> getAboutDetail(String aboutId) async {
    try {
      final ApiResponse response = await _apiClient.get('/about/$aboutId');

      if (response.isSuccess && response.data != null) {
        return AboutWithDetailsModel.fromJson(response.data['data']);
      }

      throw Exception(response.message);
    } catch (e) {
      throw Exception('Failed to get about detail: $e');
    }
  }
}
