
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class AuthService {
  final String baseUrl = AppConfig.apiBaseUrl; // Базовый URL бэкенда

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> register(String username, String password, String email, String fullName) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        // Backend принимает "password", хешируется на сервере
        'password': password,
        'email': email,
        'full_name': fullName,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> fetchCurrentUser(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/me/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch current user: ${response.body}');
    }
  }
}
