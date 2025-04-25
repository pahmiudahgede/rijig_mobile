import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final String baseUrl;

  ApiService({this.baseUrl = ''});

  static String get apiUrl => dotenv.env['BASE_URL'] ?? '';

  Future<Map<String, dynamic>> get(String endpoint) async {
    final url = Uri.parse('$apiUrl/$endpoint');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$apiUrl/$endpoint');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to submit data');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$apiUrl/$endpoint');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update data');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    final url = Uri.parse('$apiUrl/$endpoint');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to delete data');
      }
    } catch (e) {
      rethrow;
    }
  }
}
