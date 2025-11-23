import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/lease.dart';

class LeasesProvider extends ChangeNotifier {
  List<Lease> leases = [];
  bool loading = false;

  Future<void> fetchLeases(String token) async {
    loading = true;
    notifyListeners();
    try {
      final data = await ApiService().getLeases(token);
      leases = data.map<Lease>((e) => Lease.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching leases: $e');
    }
    loading = false;
    notifyListeners();
  }

  Future<Lease?> getLease(String token, int id) async {
    try {
      final data = await ApiService().getLease(token, id);
      return Lease.fromJson(data);
    } catch (e) {
      print('Error fetching lease: $e');
      return null;
    }
  }

  Future<bool> requestLease(String token, int unitId, Map<String, dynamic> leaseData) async {
    try {
      final data = await ApiService().requestLease(token, unitId, leaseData);
      final newLease = Lease.fromJson(data);
      leases.add(newLease);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error requesting lease: $e');
      return false;
    }
  }

  Future<bool> updateLease(String token, int id, Map<String, dynamic> leaseData) async {
    try {
      final data = await ApiService().updateLease(token, id, leaseData);
      final updatedLease = Lease.fromJson(data);
      final index = leases.indexWhere((l) => l.id == id);
      if (index != -1) {
        leases[index] = updatedLease;
        notifyListeners();
      }
      return true;
    } catch (e) {
      print('Error updating lease: $e');
      return false;
    }
  }

  Future<bool> signLease(String token, int id, Map<String, dynamic> signatureData) async {
    try {
      final data = await ApiService().signLease(token, id, signatureData);
      final signedLease = Lease.fromJson(data);
      final index = leases.indexWhere((l) => l.id == id);
      if (index != -1) {
        leases[index] = signedLease;
        notifyListeners();
      }
      return true;
    } catch (e) {
      print('Error signing lease: $e');
      return false;
    }
  }

  Future<String?> generateLeasePdf(String token, int id) async {
    try {
      final data = await ApiService().generateLeasePdf(token, id);
      return data['pdf_url'];
    } catch (e) {
      print('Error generating PDF: $e');
      return null;
    }
  }

  Future<bool> cancelLease(String token, int id) async {
    try {
      await ApiService().cancelLease(token, id);
      leases.removeWhere((l) => l.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error canceling lease: $e');
      return false;
    }
  }
}