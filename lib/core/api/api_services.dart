import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'package:rijig_mobile/core/api/api_exception.dart';
import 'package:rijig_mobile/core/storage/expired_token.dart';
import 'package:rijig_mobile/core/storage/secure_storage.dart';

class Https {
  static final Https _instance = Https.internal();
  Https.internal();
  factory Https() => _instance;

  final String? _baseUrl = dotenv.env["BASE_URL"];
  final String? _apiKey = dotenv.env["API_KEY"];
  final SecureStorage _secureStorage = SecureStorage();

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
  }) async {
    final requestHeaders = await _getHeaders();
    String url = "${baseUrl ?? _baseUrl}$desturl";
    debugPrint("url $url");

    http.Response response;
    try {
      if (multipartRequest != null) {
        response = await multipartRequest.send().then(
          (response) => http.Response.fromStream(response),
        );
      } else {
        switch (method.toLowerCase()) {
          case 'get':
            response = await http.get(Uri.parse(url), headers: requestHeaders);
            break;
          case 'post':
            response = await http.post(
              Uri.parse(url),
              body: jsonEncode(body),
              headers: requestHeaders,
              encoding: encoding,
            );
            break;
          case 'put':
            response = await http.put(
              Uri.parse(url),
              body: jsonEncode(body),
              headers: requestHeaders,
              encoding: encoding,
            );
            break;
          case 'delete':
            response = await http.delete(
              Uri.parse(url),
              body: jsonEncode(body),
              headers: requestHeaders,
            );
            break;
          case 'patch':
            response = await http.patch(
              Uri.parse(url),
              body: jsonEncode(body),
              headers: requestHeaders,
              encoding: encoding,
            );
            break;
          default:
            throw ApiException('Unsupported HTTP method: $method', 405);
        }
      }

      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode >= 400) {
        throw ApiException(
          'Error during HTTP $method request: ${response.body}',
          statusCode,
        );
      }
      return jsonDecode(response.body);
    } catch (error) {
      if (error is ApiException) {
        rethrow;
      } else {
        throw ApiException('Network error: $error', 500);
      }
    }
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
