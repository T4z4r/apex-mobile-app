import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  String? token;
  String? userName;
  String? userRole;

  Future<bool> login(String email, String password) async {
    try {
      final data = await ApiService().login(email, password);
      if (data.containsKey('token') && data['user'] != null) {
        token = data['token'];
        userName = data['user']['name'];
        userRole = data['user']['role'] ?? 'tenant';
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token!);
        await prefs.setString('userRole', userRole!);
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
    userRole = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userRole');
    notifyListeners();
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    userRole = prefs.getString('userRole');
    notifyListeners();
  }
}
