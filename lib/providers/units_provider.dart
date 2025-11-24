import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/unit.dart';

class UnitsProvider extends ChangeNotifier {
  List<Unit> units = [];
  bool loading = false;

  Future<void> fetchUnits(String token) async {
    loading = true;
    notifyListeners();
    final data = await ApiService().get(token, "units");
    units = data.map<Unit>((e) => Unit.fromJson(e)).toList();
    loading = false;
    notifyListeners();
  }

  Future<bool> createUnit(String token, int propertyId, Map<String, dynamic> unitData) async {
    try {
      final data = await ApiService().createUnit(token, propertyId, unitData);
      final newUnit = Unit.fromJson(data);
      units.add(newUnit);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error creating unit: $e');
      return false;
    }
  }

  Future<Unit?> getUnit(String token, int id) async {
    try {
      final data = await ApiService().getUnit(token, id);
      return Unit.fromJson(data);
    } catch (e) {
      print('Error fetching unit: $e');
      return null;
    }
  }

  Future<bool> updateUnit(String token, int id, Map<String, dynamic> unitData) async {
    try {
      final data = await ApiService().updateUnit(token, id, unitData);
      final updatedUnit = Unit.fromJson(data);
      final index = units.indexWhere((u) => u.id == id);
      if (index != -1) {
        units[index] = updatedUnit;
        notifyListeners();
      }
      return true;
    } catch (e) {
      print('Error updating unit: $e');
      return false;
    }
  }

  Future<void> deleteUnit(String token, int id) async {
    await ApiService().delete(token, "units/$id");
    units.removeWhere((u) => u.id == id);
    notifyListeners();
  }
}
