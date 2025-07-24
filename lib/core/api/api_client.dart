import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:rijig_mobile/core/api/api_exception.dart';
import 'package:rijig_mobile/core/api/api_interceptor.dart';
import 'package:rijig_mobile/core/api/api_response.dart';
import 'package:rijig_mobile/core/network/network_service.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final String _baseUrl = dotenv.env['BASE_URL'] ?? '';
  final NetworkService _networkService = NetworkService();
  final ApiInterceptor _interceptor = ApiInterceptor();

  final int _maxRetries = 3;
  final List<int> _retryStatusCodes = [408, 429, 500, 502, 503, 504];
  final Duration _baseRetryDelay = const Duration(seconds: 1);

  String get baseUrl => _baseUrl;

  bool get isApiKeyValid => _interceptor.isApiKeyValid();

  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    String? baseUrl,
  }) async {
    return _makeRequest<T>(
      'GET',
      endpoint,
      headers: headers,
      queryParameters: queryParameters,
      baseUrl: baseUrl,
    );
  }

  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
    String? baseUrl,
  }) async {
    return _makeRequest<T>(
      'POST',
      endpoint,
      headers: headers,
      body: body,
      baseUrl: baseUrl,
    );
  }

  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
    String? baseUrl,
  }) async {
    return _makeRequest<T>(
      'PUT',
      endpoint,
      headers: headers,
      body: body,
      baseUrl: baseUrl,
    );
  }

  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
    String? baseUrl,
  }) async {
    return _makeRequest<T>(
      'DELETE',
      endpoint,
      headers: headers,
      body: body,
      baseUrl: baseUrl,
    );
  }

  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
    String? baseUrl,
  }) async {
    return _makeRequest<T>(
      'PATCH',
      endpoint,
      headers: headers,
      body: body,
      baseUrl: baseUrl,
    );
  }

  Future<ApiResponse<T>> uploadFile<T>(
    String endpoint, {
    required Map<String, dynamic> fields,
    Map<String, String>? headers,
    String? baseUrl,
  }) async {
    return _makeMultipartRequest<T>(
      endpoint,
      fields: fields,
      headers: headers,
      baseUrl: baseUrl,
    );
  }

  Future<ApiResponse<T>> _makeRequest<T>(
    String method,
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    String? baseUrl,
    int retryCount = 0,
  }) async {
    try {
      if (!_interceptor.isApiKeyValid()) {
        throw ApiException('API key is not configured properly', 401);
      }

      if (!await _networkService.checkConnection()) {
        throw NetworkException(
          'No internet connection',
          NetworkErrorType.noConnection,
        );
      }

      final Uri uri = _buildUri(baseUrl ?? _baseUrl, endpoint, queryParameters);
      final Map<String, String> requestHeaders = await _interceptor.getHeaders(
        headers,
      );

      _logRequest(method, uri, requestHeaders, body);

      final http.Response response = await _executeRequest(
        method,
        uri,
        requestHeaders,
        body,
      );

      if (_shouldRetry(response.statusCode, retryCount, endpoint)) {
        return _retryRequest<T>(
          method,
          endpoint,
          headers: headers,
          body: body,
          queryParameters: queryParameters,
          baseUrl: baseUrl,
          retryCount: retryCount + 1,
        );
      }

      return _processResponse<T>(response);
    } on SocketException catch (e) {
      if (_shouldRetryOnNetworkError(retryCount)) {
        return _retryRequest<T>(
          method,
          endpoint,
          headers: headers,
          body: body,
          queryParameters: queryParameters,
          baseUrl: baseUrl,
          retryCount: retryCount + 1,
        );
      }
      throw NetworkException(
        'Connection failed: ${e.message}',
        NetworkErrorType.connectionFailed,
      );
    } on TimeoutException catch (e) {
      if (_shouldRetryOnNetworkError(retryCount)) {
        return _retryRequest<T>(
          method,
          endpoint,
          headers: headers,
          body: body,
          queryParameters: queryParameters,
          baseUrl: baseUrl,
          retryCount: retryCount + 1,
        );
      }
      throw NetworkException(
        'Request timeout: ${e.toString()}',
        NetworkErrorType.timeout,
      );
    } catch (e) {
      if (e is ApiException || e is NetworkException) {
        rethrow;
      }
      throw ApiException('Unexpected error: $e', 500);
    }
  }

  Future<http.Response> _executeRequest(
    String method,
    Uri uri,
    Map<String, String> headers,
    dynamic body,
  ) async {
    final timeout = _networkService.getTimeoutDuration();

    switch (method.toUpperCase()) {
      case 'GET':
        return await http.get(uri, headers: headers).timeout(timeout);
      case 'POST':
        return await http
            .post(
              uri,
              headers: headers,
              body: body != null ? jsonEncode(body) : null,
            )
            .timeout(timeout);
      case 'PUT':
        return await http
            .put(
              uri,
              headers: headers,
              body: body != null ? jsonEncode(body) : null,
            )
            .timeout(timeout);
      case 'DELETE':
        return await http
            .delete(
              uri,
              headers: headers,
              body: body != null ? jsonEncode(body) : null,
            )
            .timeout(timeout);
      case 'PATCH':
        return await http
            .patch(
              uri,
              headers: headers,
              body: body != null ? jsonEncode(body) : null,
            )
            .timeout(timeout);
      default:
        throw ApiException('Unsupported HTTP method: $method', 405);
    }
  }

  Future<ApiResponse<T>> _makeMultipartRequest<T>(
    String endpoint, {
    required Map<String, dynamic> fields,
    Map<String, String>? headers,
    String? baseUrl,
  }) async {
    try {
      if (!_interceptor.isApiKeyValid()) {
        throw ApiException('API key is not configured properly', 401);
      }

      if (!await _networkService.checkConnection()) {
        throw NetworkException(
          'No internet connection',
          NetworkErrorType.noConnection,
        );
      }

      final Uri uri = _buildUri(baseUrl ?? _baseUrl, endpoint, null);
      final request = http.MultipartRequest('POST', uri);

      final Map<String, String> requestHeaders = await _interceptor
          .getMultipartHeaders(headers);
      request.headers.addAll(requestHeaders);

      _logRequest('POST', uri, requestHeaders, fields);

      for (final entry in fields.entries) {
        if (entry.value is String) {
          request.fields[entry.key] = entry.value;
        } else if (entry.value is File) {
          final file = entry.value as File;

          if (file.lengthSync() > 10 * 1024 * 1024) {
            throw ApiException('File size exceeds 10MB limit', 413);
          }

          if (!file.existsSync()) {
            throw ApiException('File does not exist', 400);
          }

          request.files.add(
            await http.MultipartFile.fromPath(
              entry.key,
              file.path,
              filename: file.uri.pathSegments.last,
            ),
          );
        } else {
          request.fields[entry.key] = entry.value.toString();
        }
      }

      final streamedResponse = await request.send().timeout(
        _networkService.getTimeoutDuration(),
      );
      final response = await http.Response.fromStream(streamedResponse);

      return _processResponse<T>(response);
    } catch (e) {
      if (e is ApiException || e is NetworkException) {
        rethrow;
      }
      throw ApiException('Upload failed: $e', 500);
    }
  }

  ApiResponse<T> _processResponse<T>(http.Response response) {
    _logResponse(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final dynamic jsonData = jsonDecode(response.body);
        return ApiResponse<T>.success(
          data: jsonData,
          statusCode: response.statusCode,
          message: jsonData['meta']?['message'] ?? 'Success',
        );
      } catch (e) {
        return ApiResponse<T>.success(
          data: response.body as T,
          statusCode: response.statusCode,
          message: 'Success',
        );
      }
    } else {
      String errorMessage = 'Request failed';
      try {
        final errorData = jsonDecode(response.body);
        errorMessage =
            errorData['meta']?['message'] ??
            errorData['message'] ??
            errorData['error'] ??
            errorMessage;
      } catch (e) {
        errorMessage = response.body.isNotEmpty ? response.body : errorMessage;
      }

      throw ApiException(errorMessage, response.statusCode);
    }
  }

  Uri _buildUri(
    String baseUrl,
    String endpoint,
    Map<String, dynamic>? queryParameters,
  ) {
    final uri = Uri.parse('$baseUrl$endpoint');
    if (queryParameters != null && queryParameters.isNotEmpty) {
      return uri.replace(
        queryParameters: queryParameters.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );
    }
    return uri;
  }

  Future<ApiResponse<T>> _retryRequest<T>(
    String method,
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    String? baseUrl,
    required int retryCount,
  }) async {
    final delay = Duration(
      milliseconds: _baseRetryDelay.inMilliseconds * (retryCount * retryCount),
    );

    debugPrint(
      'Retrying request (attempt $retryCount/$_maxRetries) after ${delay.inMilliseconds}ms',
    );

    await Future.delayed(delay);

    return _makeRequest<T>(
      method,
      endpoint,
      headers: headers,
      body: body,
      queryParameters: queryParameters,
      baseUrl: baseUrl,
      retryCount: retryCount,
    );
  }

  bool _shouldRetry(int statusCode, int retryCount, String endpoint) {
    if (endpoint.contains('/auth/') || endpoint.contains('/pin/')) {
      return false;
    }
    return retryCount < _maxRetries && _retryStatusCodes.contains(statusCode);
  }

  bool _shouldRetryOnNetworkError(int retryCount) {
    return retryCount < _maxRetries;
  }

  void _logRequest(
    String method,
    Uri uri,
    Map<String, String> headers,
    dynamic body,
  ) {
    if (kDebugMode) {
      debugPrint('=== API REQUEST ===');
      debugPrint('Method: $method');
      debugPrint('URL: $uri');
      debugPrint('Headers: $headers');
      if (body != null) {
        debugPrint('Body: $body');
      }
    }
  }

  void _logResponse(http.Response response) {
    if (kDebugMode) {
      debugPrint('=== API RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Body: ${response.body}');
    }
  }
}
