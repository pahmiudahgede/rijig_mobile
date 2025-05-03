import 'package:rijig_mobile/core/api_services.dart';
import 'package:rijig_mobile/model/response_model.dart';

class PinModel {
  final ApiService _apiService = ApiService();

  Future<ResponseModel?> checkPinStatus(String userId) async {
    try {
      var response = await _apiService.get('/cek-pin-status');
      return ResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<ResponseModel?> setPin(String pin) async {
    try {
      var response = await _apiService.post('/set-pin', {'userpin': pin});
      return ResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<ResponseModel?> verifyPin(String pin) async {
    try {
      var response = await _apiService.post('/verif-pin', {'userpin': pin});
      return ResponseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
