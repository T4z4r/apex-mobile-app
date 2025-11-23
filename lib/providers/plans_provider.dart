import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/plan.dart';

class PlansProvider extends ChangeNotifier {
  List<Plan> plans = [];
  List<Subscription> subscriptions = [];
  bool loading = false;

  Future<void> fetchPlans(String token) async {
    loading = true;
    notifyListeners();
    try {
      final data = await ApiService().getPlans(token);
      plans = data.map<Plan>((e) => Plan.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching plans: $e');
    }
    loading = false;
    notifyListeners();
  }

  Future<Plan?> getPlan(String token, int id) async {
    try {
      final data = await ApiService().getPlan(token, id);
      return Plan.fromJson(data);
    } catch (e) {
      print('Error fetching plan: $e');
      return null;
    }
  }

  Future<bool> createPlan(String token, Map<String, dynamic> planData) async {
    try {
      final data = await ApiService().createPlan(token, planData);
      final newPlan = Plan.fromJson(data);
      plans.add(newPlan);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error creating plan: $e');
      return false;
    }
  }

  Future<bool> updatePlan(String token, int id, Map<String, dynamic> planData) async {
    try {
      final data = await ApiService().updatePlan(token, id, planData);
      final updatedPlan = Plan.fromJson(data);
      final index = plans.indexWhere((p) => p.id == id);
      if (index != -1) {
        plans[index] = updatedPlan;
        notifyListeners();
      }
      return true;
    } catch (e) {
      print('Error updating plan: $e');
      return false;
    }
  }

  Future<bool> deletePlan(String token, int id) async {
    try {
      await ApiService().deletePlan(token, id);
      plans.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error deleting plan: $e');
      return false;
    }
  }

  Future<void> fetchSubscriptions(String token) async {
    loading = true;
    notifyListeners();
    try {
      final data = await ApiService().getSubscriptions(token);
      subscriptions = data.map<Subscription>((e) => Subscription.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching subscriptions: $e');
    }
    loading = false;
    notifyListeners();
  }

  Future<Subscription?> getSubscription(String token, int id) async {
    try {
      final data = await ApiService().getSubscription(token, id);
      return Subscription.fromJson(data);
    } catch (e) {
      print('Error fetching subscription: $e');
      return null;
    }
  }

  Future<bool> subscribeToPlan(String token, Map<String, dynamic> subscriptionData) async {
    try {
      final data = await ApiService().subscribeToPlan(token, subscriptionData);
      final newSubscription = Subscription.fromJson(data);
      subscriptions.add(newSubscription);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error subscribing to plan: $e');
      return false;
    }
  }

  Future<bool> updateSubscription(String token, int id, Map<String, dynamic> subscriptionData) async {
    try {
      final data = await ApiService().updateSubscription(token, id, subscriptionData);
      final updatedSubscription = Subscription.fromJson(data);
      final index = subscriptions.indexWhere((s) => s.id == id);
      if (index != -1) {
        subscriptions[index] = updatedSubscription;
        notifyListeners();
      }
      return true;
    } catch (e) {
      print('Error updating subscription: $e');
      return false;
    }
  }

  Future<bool> cancelSubscription(String token, int id) async {
    try {
      await ApiService().cancelSubscription(token, id);
      subscriptions.removeWhere((s) => s.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error canceling subscription: $e');
      return false;
    }
  }
}