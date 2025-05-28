import 'dart:convert';
import 'dart:io';
import 'dart:async'; 

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'package:rijig_mobile/core/api/api_exception.dart';
import 'package:rijig_mobile/core/network/network_service.dart';
import 'package:rijig_mobile/core/storage/expired_token.dart';
import 'package:rijig_mobile/core/storage/secure_storage.dart';

class Https {
  static final Https _instance = Https.internal();
  Https.internal();
  factory Https() => _instance;

  final String? _baseUrl = dotenv.env["BASE_URL"];
  final String? _apiKey = dotenv.env["API_KEY"];
  final SecureStorage _secureStorage = SecureStorage();
  final NetworkService _networkService = NetworkService();

  final int _maxRetries = 3;
  final List<int> _retryStatusCodes = [408, 429, 500, 502, 503, 504];
  final Duration _baseRetryDelay = const Duration(seconds: 1);

  Future<Map<String, String>> _getHeaders() async {
    String? token = await _secureStorage.readSecureData('token');

    if (token == null || token.isEmpty) {
      return {
        "Content-type": "application/json; charset=UTF-8",
        "Accept": "application/json",
        "x-api-key": _apiKey ?? "",
      };
    }

    bool isExpired = await isTokenExpired();
    if (isExpired) {
      await deleteToken();
      throw Exception('Session expired, please log in again.');
    }

    return {
      "Content-type": "application/json; charset=UTF-8",
      "Accept": "application/json",
      "Authorization": "Bearer $token",
      "x-api-key": _apiKey ?? "",
    };
  }

  Future<dynamic> _request(
    String method, {
    required String desturl,
    Map<String, String> headers = const {},
    dynamic body,
    Encoding? encoding,
    String? baseUrl,
    http.MultipartRequest? multipartRequest,
    bool checkNetwork = true,
    int retryCount = 0,
  }) async {
    if (checkNetwork) {
      final bool isConnected = await _networkService.checkConnection();
      if (!isConnected) {
        throw NetworkException(
          'No internet connection available',
          NetworkErrorType.noConnection,
        );
      }
    }

    final requestHeaders = await _getHeaders();
    String url = "${baseUrl ?? _baseUrl}$desturl";
    debugPrint("Request URL: $url");
    debugPrint("Network Quality: ${_networkService.currentQuality}");

    final timeout = _networkService.getTimeoutDuration();

    http.Response response;
    try {
      if (multipartRequest != null) {
        response = await multipartRequest
            .send()
            .timeout(timeout)
            .then((response) => http.Response.fromStream(response));
      } else {
        switch (method.toLowerCase()) {
          case 'get':
            response = await http
                .get(Uri.parse(url), headers: requestHeaders)
                .timeout(timeout);
            break;
          case 'post':
            response = await http
                .post(
                  Uri.parse(url),
                  body: jsonEncode(body),
                  headers: requestHeaders,
                  encoding: encoding,
                )
                .timeout(timeout);
            break;
          case 'put':
            response = await http
                .put(
                  Uri.parse(url),
                  body: jsonEncode(body),
                  headers: requestHeaders,
                  encoding: encoding,
                )
                .timeout(timeout);
            break;
          case 'delete':
            response = await http
                .delete(
                  Uri.parse(url),
                  body: jsonEncode(body),
                  headers: requestHeaders,
                )
                .timeout(timeout);
            break;
          case 'patch':
            response = await http
                .patch(
                  Uri.parse(url),
                  body: jsonEncode(body),
                  headers: requestHeaders,
                  encoding: encoding,
                )
                .timeout(timeout);
            break;
          default:
            throw ApiException('Unsupported HTTP method: $method', 405);
        }
      }

      final int statusCode = response.statusCode;

      if (_shouldRetry(statusCode, retryCount)) {
        return await _retryRequest(
          method,
          desturl: desturl,
          headers: headers,
          body: body,
          encoding: encoding,
          baseUrl: baseUrl,
          multipartRequest: multipartRequest,
          retryCount: retryCount + 1,
        );
      }

      if (statusCode < 200 || statusCode >= 400) {
        throw ApiException(
          'Error during HTTP $method request: ${response.body}',
          statusCode,
        );
      }

      return jsonDecode(response.body);
    } on TimeoutException catch (e) {
      // Pindahkan TimeoutException ke atas sebelum SocketException
      debugPrint('Timeout Exception: $e');

      if (_shouldRetryOnNetworkError(retryCount)) {
        return await _retryRequest(
          method,
          desturl: desturl,
          headers: headers,
          body: body,
          encoding: encoding,
          baseUrl: baseUrl,
          multipartRequest: multipartRequest,
          retryCount: retryCount + 1,
          isNetworkError: true,
        );
      }

      throw NetworkException(
        'Request timeout: ${e.toString()}',
        NetworkErrorType.timeout,
      );
    } on SocketException catch (e) {
      debugPrint('Socket Exception: $e');

      if (_shouldRetryOnNetworkError(retryCount)) {
        return await _retryRequest(
          method,
          desturl: desturl,
          headers: headers,
          body: body,
          encoding: encoding,
          baseUrl: baseUrl,
          multipartRequest: multipartRequest,
          retryCount: retryCount + 1,
          isNetworkError: true,
        );
      }

      throw NetworkException(
        'Connection failed: ${e.message}',
        NetworkErrorType.connectionFailed,
      );
    } catch (error) {
      debugPrint('Request error: $error');

      if (error is ApiException || error is NetworkException) {
        rethrow;
      } else {
        throw ApiException('Network error: $error', 500);
      }
    }
  }

  bool _shouldRetry(int statusCode, int retryCount) {
    return retryCount < _maxRetries && _retryStatusCodes.contains(statusCode);
  }

  bool _shouldRetryOnNetworkError(int retryCount) {
    return retryCount < _maxRetries;
  }

  Future<dynamic> _retryRequest(
    String method, {
    required String desturl,
    Map<String, String> headers = const {},
    dynamic body,
    Encoding? encoding,
    String? baseUrl,
    http.MultipartRequest? multipartRequest,
    required int retryCount,
    bool isNetworkError = false,
  }) async {
    final delay = Duration(
      milliseconds: _baseRetryDelay.inMilliseconds * (retryCount * retryCount),
    );

    debugPrint(
      'Retrying request (attempt ${retryCount + 1}/$_maxRetries) after ${delay.inMilliseconds}ms',
    );

    await Future.delayed(delay);

    if (isNetworkError) {
      final bool isConnected = await _networkService.checkConnection();
      if (!isConnected) {
        throw NetworkException(
          'No internet connection available after retry',
          NetworkErrorType.noConnection,
        );
      }
    }

    return await _request(
      method,
      desturl: desturl,
      headers: headers,
      body: body,
      encoding: encoding,
      baseUrl: baseUrl,
      multipartRequest: multipartRequest,
      checkNetwork: false,
      retryCount: retryCount,
    );
  }

  Future<dynamic> get(
    String desturl, {
    Map<String, String> headers = const {},
    String? baseUrl,
  }) async {
    return await _request(
      'get',
      desturl: desturl,
      headers: headers,
      baseUrl: baseUrl,
    );
  }

  Future<dynamic> post(
    String desturl, {
    Map<String, String> headers = const {},
    dynamic body,
    Encoding? encoding,
    String? baseUrl,
  }) async {
    return await _request(
      'post',
      desturl: desturl,
      headers: headers,
      body: body,
      encoding: encoding,
      baseUrl: baseUrl,
    );
  }

  Future<dynamic> put(
    String desturl, {
    Map<String, String> headers = const {},
    dynamic body,
    Encoding? encoding,
    String? baseUrl,
  }) async {
    return await _request(
      'put',
      desturl: desturl,
      headers: headers,
      body: body,
      encoding: encoding,
      baseUrl: baseUrl,
    );
  }

  Future<dynamic> delete(
    String desturl, {
    Map<String, String> headers = const {},
    String? baseUrl,
    body = const {},
  }) async {
    return await _request(
      'delete',
      desturl: desturl,
      headers: headers,
      body: body,
      baseUrl: baseUrl,
    );
  }

  Future<dynamic> patch(
    String destUrl, {
    Map<String, String> headers = const {},
    dynamic body,
    Encoding? encoding,
    String? baseUrl,
  }) async {
    return await _request(
      'patch',
      desturl: destUrl,
      headers: headers,
      body: body,
      encoding: encoding,
      baseUrl: baseUrl,
    );
  }

  Future<dynamic> uploadFormData(
    String desturl, {
    required Map<String, dynamic> formData,
    Map<String, String> headers = const {},
    String? baseUrl,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("${baseUrl ?? _baseUrl}$desturl"),
    );

    request.headers.addAll(await _getHeaders());

    formData.forEach((key, value) async {
      if (value is String) {
        request.fields[key] = value;
      } else if (value is File) {
        String fileName = value.uri.pathSegments.last;

        if (value.lengthSync() > 10485760) {
          throw ApiException('File size exceeds 10MB', 401);
        }

        request.files.add(
          await http.MultipartFile.fromPath(
            key,
            value.path,
            filename: fileName,
            contentType: MediaType('image', 'png'),
          ),
        );
      } else {
        throw ApiException('Unsupported value type for field $key', 401);
      }
    });

    return await _request(
      'post',
      desturl: desturl,
      headers: headers,
      multipartRequest: request,
    );
  }
}

enum NetworkErrorType { noConnection, connectionFailed, timeout, poor }

class NetworkException implements Exception {
  final String message;
  final NetworkErrorType type;

  NetworkException(this.message, this.type);

  @override
  String toString() => 'NetworkException: $message';
}