import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/property.dart';

class PropertiesProvider extends ChangeNotifier {
  List<Property> properties = [];
  bool loading = false;

  Future<void> fetchProperties(String token, {Map<String, String>? query}) async {
    loading = true;
    notifyListeners();
    try {
      final data = await ApiService().getProperties(token, query: query);
      properties = data.map<Property>((e) => Property.fromJson(e)).toList();
    } catch (e) {
      // Handle error
      print('Error fetching properties: $e');
    }
    loading = false;
    notifyListeners();
  }

  Future<Property?> getProperty(String token, int id) async {
    try {
      final data = await ApiService().getProperty(token, id);
      return Property.fromJson(data);
    } catch (e) {
      print('Error fetching property: $e');
      return null;
    }
  }

  Future<bool> createProperty(String token, Map<String, dynamic> propertyData) async {
    try {
      final data = await ApiService().createProperty(token, propertyData);
      final newProperty = Property.fromJson(data);
      properties.add(newProperty);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error creating property: $e');
      return false;
    }
  }

  Future<bool> updateProperty(String token, int id, Map<String, dynamic> propertyData) async {
    try {
      final data = await ApiService().updateProperty(token, id, propertyData);
      final updatedProperty = Property.fromJson(data);
      final index = properties.indexWhere((p) => p.id == id);
      if (index != -1) {
        properties[index] = updatedProperty;
        notifyListeners();
      }
      return true;
    } catch (e) {
      print('Error updating property: $e');
      return false;
    }
  }

  Future<bool> deleteProperty(String token, int id) async {
    try {
      await ApiService().deleteProperty(token, id);
      properties.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error deleting property: $e');
      return false;
    }
  }
}