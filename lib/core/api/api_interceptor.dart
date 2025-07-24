import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rijig_mobile/core/storage/token_manager.dart';

class ApiInterceptor {
  final TokenManager _tokenManager = TokenManager();
  final String _apiKey = dotenv.env['API_KEY'] ?? '';

  Future<Map<String, String>> getHeaders([
    Map<String, String>? customHeaders,
    bool isMultipart = false,
  ]) async {
    final Map<String, String> headers = {};

    if (!isMultipart) {
      headers['Content-Type'] = 'application/json; charset=UTF-8';
      headers['Accept'] = 'application/json';
    }

    if (_apiKey.isNotEmpty) {
      headers['x-api-key'] = _apiKey;
      if (kDebugMode) {
        debugPrint('API Key added to headers: ${_apiKey.substring(0, 10)}...');
      }
    } else {
      if (kDebugMode) {
        debugPrint('WARNING: API Key is empty!');
      }
    }

    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    final String? token = await _tokenManager.getToken();
    if (token != null && token.isNotEmpty) {
      if (await _tokenManager.isTokenExpired()) {
        await _tokenManager.clearSession();
        throw Exception('Session expired, please log in again.');
      }
      headers['Authorization'] = 'Bearer $token';
      if (kDebugMode) {
        debugPrint('Authorization token added to headers');
      }
    }

    return headers;
  }

  Future<Map<String, String>> getMultipartHeaders([
    Map<String, String>? customHeaders,
  ]) async {
    return await getHeaders(customHeaders, true);
  }

  String getApiKey() {
    return _apiKey;
  }

  bool isApiKeyValid() {
    return _apiKey.isNotEmpty;
  }
}
