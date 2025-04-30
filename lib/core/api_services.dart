import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final String baseUrl = dotenv.get('BASE_URL');
  final String apiKey = dotenv.get('API_KEY');

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.get(
        url,
        headers: {..._headers, 'API_KEY': apiKey},
      );

      return _processResponse(response);
    } catch (e) {
      throw NetworkException(
        'Failed to connect to the server. Please check your internet connection.',
      );
    }
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      
      // Debugging URL dan Body Request
      debugPrint('Request URL: $url');
      debugPrint('Request Body: ${jsonEncode(body)}');
      debugPrint('API_KEY: $apiKey');

      final response = await http.post(
        url,
        headers: {
          ..._headers, // Menggunakan _headers untuk Content-Type
          'x-api-key': apiKey, // Pastikan API_KEY dimasukkan dengan benar di sini
        },
        body: jsonEncode(body),
      );

      debugPrint('Response: ${response.body}');  // Debugging Response

      return _processResponse(response);
    } catch (e) {
      debugPrint('Error during API request: $e');
      throw NetworkException(
        'Failed to connect to the server. Please check your internet connection.',
      );
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.put(
        url,
        headers: {..._headers, 'API_KEY': apiKey},
        body: jsonEncode(body),
      );

      return _processResponse(response);
    } catch (e) {
      throw NetworkException(
        'Failed to connect to the server. Please check your internet connection.',
      );
    }
  }

  Future<Map<String, dynamic>> patch(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.patch(
        url,
        headers: {..._headers, 'API_KEY': apiKey},
        body: jsonEncode(body),
      );

      return _processResponse(response);
    } catch (e) {
      throw NetworkException(
        'Failed to connect to the server. Please check your internet connection.',
      );
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.delete(
        url,
        headers: {..._headers, 'API_KEY': apiKey},
      );

      return _processResponse(response);
    } catch (e) {
      throw NetworkException(
        'Failed to connect to the server. Please check your internet connection.',
      );
    }
  }

  Map<String, dynamic> _processResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        return jsonDecode(response.body);
      case 400:
        throw BadRequestException(
          'Bad request. The server could not process your request.',
        );
      case 401:
        throw UnauthorizedException(
          'Unauthorized. Please check your credentials.',
        );
      case 404:
        throw NotFoundException(
          'Not found. The requested resource could not be found.',
        );
      case 500:
        throw ServerException('Internal server error. Please try again later.');
      default:
        throw Exception('Failed with status code: ${response.statusCode}');
    }
  }
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}

class BadRequestException implements Exception {
  final String message;
  BadRequestException(this.message);
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException(this.message);
}

class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}
