import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://your-laravel-api.test/api";

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(Uri.parse("$baseUrl/login"),
        headers: {"Accept": "application/json"},
        body: {"email": email, "password": password});
    return json.decode(response.body);
  }

  Future<List<dynamic>> get(String token, String endpoint) async {
    final response = await http.get(Uri.parse("$baseUrl/$endpoint"),
        headers: {"Authorization": "Bearer $token"});
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> post(
      String token, String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(Uri.parse("$baseUrl/$endpoint"),
        headers: {"Authorization": "Bearer $token"}, body: data);
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> put(
      String token, String endpoint, Map<String, dynamic> data) async {
    final response = await http.put(Uri.parse("$baseUrl/$endpoint"),
        headers: {"Authorization": "Bearer $token"}, body: data);
    return json.decode(response.body);
  }

  Future<void> delete(String token, String endpoint) async {
    await http.delete(Uri.parse("$baseUrl/$endpoint"),
        headers: {"Authorization": "Bearer $token"});
  }
}
