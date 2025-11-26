import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/role.dart';
import '../models/tenant.dart';

class RolesProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _loading = false;
  List<Role> _roles = [];
  List<dynamic> _permissions = [];

  bool get loading => _loading;
  List<Role> get roles => _roles;
  List<dynamic> get permissions => _permissions;

  Future<void> loadRoles(String token) async {
    _loading = true;
    notifyListeners();

    try {
      final rolesData = await _apiService.getAdminRoles(token);
      _roles = rolesData.map((role) => Role.fromJson(role)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading roles: $e');
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadPermissions(String token) async {
    try {
      _permissions = await _apiService.getAdminPermissions(token);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading permissions: $e');
      }
    }
    notifyListeners();
  }

  Future<bool> createRole(String token, Map<String, dynamic> roleData) async {
    try {
      final newRole = await _apiService.createAdminRole(token, roleData);
      _roles.add(Role.fromJson(newRole));
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating role: $e');
      }
      return false;
    }
  }

  Future<bool> updateRole(String token, int roleId, Map<String, dynamic> roleData) async {
    try {
      final updatedRole = await _apiService.updateAdminRole(token, roleId, roleData);
      final index = _roles.indexWhere((role) => role.id == roleId);
      if (index != -1) {
        _roles[index] = Role.fromJson(updatedRole);
        notifyListeners();
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating role: $e');
      }
      return false;
    }
  }

  Future<bool> deleteRole(String token, int roleId) async {
    try {
      await _apiService.deleteAdminRole(token, roleId);
      _roles.removeWhere((role) => role.id == roleId);
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting role: $e');
      }
      return false;
    }
  }

  Future<bool> assignPermissionToRole(String token, int roleId, String permission) async {
    try {
      await _apiService.assignRoleToUser(token, roleId, permission);
      // Reload roles to get updated permissions
      await loadRoles(token);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error assigning permission to role: $e');
      }
      return false;
    }
  }

  Future<bool> removePermissionFromRole(String token, int roleId, String permission) async {
    try {
      await _apiService.removeRoleFromUser(token, roleId, permission);
      // Reload roles to get updated permissions
      await loadRoles(token);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error removing permission from role: $e');
      }
      return false;
    }
  }
}