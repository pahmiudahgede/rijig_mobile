import 'package:rijig_mobile/core/api_services.dart';

class PinModel {
  final ApiService _apiService = ApiService();

  Future<bool> checkPinStatus() async {
    try {
      var response = await _apiService.get('/cek-pin-status');
      if (response['meta']['status'] == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> setPin(String userPin) async {
    try {
      var response = await _apiService.post('/set-pin', {'userpin': userPin});
      return response['meta']['status'] == 201;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> verifyPin(String userPin) async {
    try {
      var response = await _apiService.post('/verif-pin', {'userpin': userPin});
      return response['meta']['status'] == 200;
    } catch (e) {
      rethrow;
    }
  }
}
