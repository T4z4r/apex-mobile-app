import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/maintenance_request.dart';

class MaintenanceProvider extends ChangeNotifier {
  List<MaintenanceRequest> maintenanceRequests = [];
  bool loading = false;

  Future<void> fetchMaintenanceRequests(String token) async {
    loading = true;
    notifyListeners();
    try {
      final data = await ApiService().getMaintenanceRequests(token);
      maintenanceRequests = data.map<MaintenanceRequest>((e) => MaintenanceRequest.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching maintenance requests: $e');
    }
    loading = false;
    notifyListeners();
  }

  Future<MaintenanceRequest?> getMaintenanceRequest(String token, int id) async {
    try {
      final data = await ApiService().getMaintenanceRequest(token, id);
      return MaintenanceRequest.fromJson(data);
    } catch (e) {
      print('Error fetching maintenance request: $e');
      return null;
    }
  }

  Future<bool> createMaintenanceRequest(String token, Map<String, dynamic> requestData) async {
    try {
      final data = await ApiService().createMaintenanceRequest(token, requestData);
      final newRequest = MaintenanceRequest.fromJson(data);
      maintenanceRequests.add(newRequest);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error creating maintenance request: $e');
      return false;
    }
  }

  Future<bool> updateMaintenanceRequest(String token, int id, Map<String, dynamic> requestData) async {
    try {
      final data = await ApiService().updateMaintenanceRequest(token, id, requestData);
      final updatedRequest = MaintenanceRequest.fromJson(data);
      final index = maintenanceRequests.indexWhere((r) => r.id == id);
      if (index != -1) {
        maintenanceRequests[index] = updatedRequest;
        notifyListeners();
      }
      return true;
    } catch (e) {
      print('Error updating maintenance request: $e');
      return false;
    }
  }

  Future<bool> cancelMaintenanceRequest(String token, int id) async {
    try {
      await ApiService().cancelMaintenanceRequest(token, id);
      maintenanceRequests.removeWhere((r) => r.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error canceling maintenance request: $e');
      return false;
    }
  }
}