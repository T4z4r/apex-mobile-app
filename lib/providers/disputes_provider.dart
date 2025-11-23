import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/dispute.dart';

class DisputesProvider extends ChangeNotifier {
  List<Dispute> disputes = [];
  bool loading = false;

  Future<void> fetchDisputes(String token) async {
    loading = true;
    notifyListeners();
    try {
      final data = await ApiService().getDisputes(token);
      disputes = data.map<Dispute>((e) => Dispute.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching disputes: $e');
    }
    loading = false;
    notifyListeners();
  }

  Future<Dispute?> getDispute(String token, int id) async {
    try {
      final data = await ApiService().getDispute(token, id);
      return Dispute.fromJson(data);
    } catch (e) {
      print('Error fetching dispute: $e');
      return null;
    }
  }

  Future<bool> createDispute(String token, Map<String, dynamic> disputeData) async {
    try {
      final data = await ApiService().createDispute(token, disputeData);
      final newDispute = Dispute.fromJson(data);
      disputes.add(newDispute);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error creating dispute: $e');
      return false;
    }
  }

  Future<bool> updateDispute(String token, int id, Map<String, dynamic> disputeData) async {
    try {
      final data = await ApiService().updateDispute(token, id, disputeData);
      final updatedDispute = Dispute.fromJson(data);
      final index = disputes.indexWhere((d) => d.id == id);
      if (index != -1) {
        disputes[index] = updatedDispute;
        notifyListeners();
      }
      return true;
    } catch (e) {
      print('Error updating dispute: $e');
      return false;
    }
  }

  Future<bool> cancelDispute(String token, int id) async {
    try {
      await ApiService().cancelDispute(token, id);
      disputes.removeWhere((d) => d.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error canceling dispute: $e');
      return false;
    }
  }
}