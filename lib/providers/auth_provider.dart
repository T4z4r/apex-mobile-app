import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  String? token;
  String? userName;

  Future<bool> login(String email, String password) async {
    try {
      final data = await ApiService().login(email, password);
      if (data.containsKey('token') && data['user'] != null) {
        token = data['token'];
        userName = data['user']['name'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token!);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      // Handle network errors or other exceptions
      return false;
    }
  }

  Future<void> logout() async {
    token = null;
    userName = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    notifyListeners();
  }
}
