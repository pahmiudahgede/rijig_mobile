import 'package:rijig_mobile/core/api/api_client.dart';
import 'package:rijig_mobile/core/api/api_response.dart';
import 'package:rijig_mobile/globaldata/trash/trash_model.dart';

class TrashRepository {
  final ApiClient _apiClient;

  TrashRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<TrashCategory>> getTrashCategories() async {
    try {
      final ApiResponse response = await _apiClient.get('/trash/category');
      
      if (response.isSuccess && response.data != null) {
        final List<dynamic> dataList = response.data['data'] ?? [];
        return dataList.map((json) => TrashCategory.fromJson(json)).toList();
      }
      
      throw Exception(response.message);
    } catch (e) {
      throw Exception('Failed to get trash categories: $e');
    }
  }
}