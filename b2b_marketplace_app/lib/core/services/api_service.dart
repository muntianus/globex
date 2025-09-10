import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/company.dart';
import '../config.dart';

class ApiService {
  static final String _baseUrl = AppConfig.apiBaseUrl;
  static const Duration _timeoutDuration = Duration(seconds: 10);

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Get companies with pagination and filtering
  static Future<List<Company>> getCompanies({
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/companies/').replace(
        queryParameters: {
          'skip': skip.toString(),
          'limit': limit.toString(),
        },
      );

      final response = await http
          .get(uri, headers: _headers)
          .timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Company.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load companies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get specific company by ID
  static Future<Company> getCompany(int id) async {
    try {
      final uri = Uri.parse('$_baseUrl/companies/$id');
      
      final response = await http
          .get(uri, headers: _headers)
          .timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Company.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        throw Exception('Company not found');
      } else {
        throw Exception('Failed to load company: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get categories
  static Future<List<Map<String, String>>> getCategories() async {
    try {
      final uri = Uri.parse('$_baseUrl/categories/');
      
      final response = await http
          .get(uri, headers: _headers)
          .timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.cast<Map<String, dynamic>>().map((category) => {
          'id': category['id'].toString(),
          'nameKey': category['nameKey'].toString(),
          'icon': category['icon'].toString(),
        }).toList();
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Login user
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final uri = Uri.parse('$_baseUrl/token');
      
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'username': username,
          'password': password,
        },
      ).timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Register user
  static Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    String? email,
    String? fullName,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/register/');
      
      final body = {
        'username': username,
        'password': password,
        if (email != null) 'email': email,
        if (fullName != null) 'full_name': fullName,
      };

      final response = await http.post(
        uri,
        headers: _headers,
        body: json.encode(body),
      ).timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Registration failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get current user (requires authentication)
  static Future<Map<String, dynamic>> getCurrentUser(String token) async {
    try {
      final uri = Uri.parse('$_baseUrl/users/me/');
      
      final response = await http.get(
        uri,
        headers: {
          ..._headers,
          'Authorization': 'Bearer $token',
        },
      ).timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else {
        throw Exception('Failed to get user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Test connection
  static Future<bool> testConnection() async {
    try {
      final uri = Uri.parse('$_baseUrl/');
      
      final response = await http
          .get(uri, headers: _headers)
          .timeout(_timeoutDuration);

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
