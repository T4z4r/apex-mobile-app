import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/agent.dart';

class AgentsProvider extends ChangeNotifier {
  List<Agent> agents = [];
  bool loading = false;

  Future<void> fetchAgents(String token) async {
    loading = true;
    notifyListeners();
    try {
      final data = await ApiService().getAgents(token);
      agents = data.map<Agent>((e) => Agent.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching agents: $e');
    }
    loading = false;
    notifyListeners();
  }

  Future<Agent?> getAgent(String token, int id) async {
    try {
      final data = await ApiService().getAgent(token, id);
      return Agent.fromJson(data);
    } catch (e) {
      print('Error fetching agent: $e');
      return null;
    }
  }

  Future<bool> registerAsAgent(String token, Map<String, dynamic> agentData) async {
    try {
      final data = await ApiService().registerAsAgent(token, agentData);
      final newAgent = Agent.fromJson(data);
      agents.add(newAgent);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error registering as agent: $e');
      return false;
    }
  }

  Future<bool> updateAgent(String token, int id, Map<String, dynamic> agentData) async {
    try {
      final data = await ApiService().updateAgent(token, id, agentData);
      final updatedAgent = Agent.fromJson(data);
      final index = agents.indexWhere((a) => a.id == id);
      if (index != -1) {
        agents[index] = updatedAgent;
        notifyListeners();
      }
      return true;
    } catch (e) {
      print('Error updating agent: $e');
      return false;
    }
  }

  Future<bool> verifyAgent(String token, int id) async {
    try {
      await ApiService().verifyAgent(token, id);
      // Refetch agents to get updated data
      await fetchAgents(token);
      return true;
    } catch (e) {
      print('Error verifying agent: $e');
      return false;
    }
  }

  Future<bool> deleteAgent(String token, int id) async {
    try {
      await ApiService().deleteAgent(token, id);
      agents.removeWhere((a) => a.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error deleting agent: $e');
      return false;
    }
  }
}