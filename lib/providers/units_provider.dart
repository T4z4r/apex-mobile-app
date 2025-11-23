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

  Future<void> deleteUnit(String token, int id) async {
    await ApiService().delete(token, "units/$id");
    units.removeWhere((u) => u.id == id);
    notifyListeners();
  }
}
