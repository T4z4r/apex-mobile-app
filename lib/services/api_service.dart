import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  final String baseUrl = "http://apex-backend.test//api";

  // Helper method for headers
  Map<String, String> _getHeaders([String? token]) {
    final headers = {"Accept": "application/json"};
    if (token != null) {
      headers["Authorization"] = "Bearer $token";
    }
    return headers;
  }

  // Authentication
  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final response = await http.post(Uri.parse("$baseUrl/auth/register"),
        headers: _getHeaders(),
        body: data.map((key, value) => MapEntry(key, value.toString())));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> login(
      String phoneOrEmail, String password) async {
    final response = await http.post(Uri.parse("$baseUrl/auth/login"),
        headers: _getHeaders(),
        body: {"phone_or_email": phoneOrEmail, "password": password});
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> logout(String token) async {
    final response = await http.post(Uri.parse("$baseUrl/auth/logout"),
        headers: _getHeaders(token));
    return json.decode(response.body);
  }

  // Properties
  Future<List<dynamic>> getProperties(String token,
      {Map<String, String>? query}) async {
    final uri =
        Uri.parse("$baseUrl/properties").replace(queryParameters: query);
    final response = await http.get(uri, headers: _getHeaders(token));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> getProperty(String token, int id) async {
    final response = await http.get(Uri.parse("$baseUrl/properties/$id"),
        headers: _getHeaders(token));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> createProperty(
      String token, Map<String, dynamic> data) async {
    final response = await http.post(Uri.parse("$baseUrl/properties"),
        headers: _getHeaders(token),
        body: data.map((key, value) => MapEntry(key, value.toString())));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> updateProperty(
      String token, int id, Map<String, dynamic> data) async {
    final response = await http.put(Uri.parse("$baseUrl/properties/$id"),
        headers: _getHeaders(token),
        body: data.map((key, value) => MapEntry(key, value.toString())));
    return json.decode(response.body);
  }

  Future<void> deleteProperty(String token, int id) async {
    await http.delete(Uri.parse("$baseUrl/properties/$id"),
        headers: _getHeaders(token));
  }

  // Units
  Future<List<dynamic>> getUnits(String token,
      {Map<String, String>? query}) async {
    final uri = Uri.parse("$baseUrl/units").replace(queryParameters: query);
    final response = await http.get(uri, headers: _getHeaders(token));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> getUnit(String token, int id) async {
    final response = await http.get(Uri.parse("$baseUrl/units/$id"),
        headers: _getHeaders(token));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> createUnit(
      String token, int propertyId, Map<String, dynamic> data) async {
    final response = await http.post(
        Uri.parse("$baseUrl/properties/$propertyId/units"),
        headers: _getHeaders(token),
        body: data.map((key, value) => MapEntry(key, value.toString())));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> updateUnit(
      String token, int id, Map<String, dynamic> data) async {
    final response = await http.put(Uri.parse("$baseUrl/units/$id"),
        headers: _getHeaders(token),
        body: data.map((key, value) => MapEntry(key, value.toString())));
    return json.decode(response.body);
  }

  Future<void> deleteUnit(String token, int id) async {
    await http.delete(Uri.parse("$baseUrl/units/$id"),
        headers: _getHeaders(token));
  }

  // Leases
  Future<List<dynamic>> getLeases(String token) async {
    final response = await http.get(Uri.parse("$baseUrl/leases"),
        headers: _getHeaders(token));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> requestLease(
      String token, int unitId, Map<String, dynamic> data) async {
    final response = await http.post(
        Uri.parse("$baseUrl/leases/$unitId/request"),
        headers: _getHeaders(token),
        body: data.map((key, value) => MapEntry(key, value.toString())));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> getLease(String token, int id) async {
    final response = await http.get(Uri.parse("$baseUrl/leases/$id"),
        headers: _getHeaders(token));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> updateLease(
      String token, int id, Map<String, dynamic> data) async {
    final response = await http.put(Uri.parse("$baseUrl/leases/$id"),
        headers: _getHeaders(token),
        body: data.map((key, value) => MapEntry(key, value.toString())));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> signLease(
      String token, int id, Map<String, dynamic> data) async {
    final response = await http.post(Uri.parse("$baseUrl/leases/$id/sign"),
        headers: _getHeaders(token),
        body: data.map((key, value) => MapEntry(key, value.toString())));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> generateLeasePdf(String token, int id) async {
    final response = await http.post(
        Uri.parse("$baseUrl/leases/$id/generate-pdf"),
        headers: _getHeaders(token));
    return json.decode(response.body);
  }

  Future<void> cancelLease(String token, int id) async {
    await http.delete(Uri.parse("$baseUrl/leases/$id"),
        headers: _getHeaders(token));
  }

  // Maintenance Requests
  Future<List<dynamic>> getMaintenanceRequests(String token) async {
    final response = await http.get(Uri.parse("$baseUrl/maintenance"),
        headers: _getHeaders(token));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> getMaintenanceRequest(
      String token, int id) async {
    final response = await http.get(Uri.parse("$baseUrl/maintenance/$id"),
        headers: _getHeaders(token));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> createMaintenanceRequest(
      String token, Map<String, dynamic> data) async {
    final response = await http.post(Uri.parse("$baseUrl/maintenance"),
        headers: _getHeaders(token),
        body: data.map((key, value) => MapEntry(key, value.toString())));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> updateMaintenanceRequest(
      String token, int id, Map<String, dynamic> data) async {
    final response = await http.patch(Uri.parse("$baseUrl/maintenance/$id"),
        headers: _getHeaders(token),
        body: data.map((key, value) => MapEntry(key, value.toString())));
    return json.decode(response.body);
  }

  Future<void> cancelMaintenanceRequest(String token, int id) async {
    await http.delete(Uri.parse("$baseUrl/maintenance/$id"),
        headers: _getHeaders(token));
  }

  // Agents
  Future<List<dynamic>> getAgents(String token) async {
    final response = await http.get(Uri.parse("$baseUrl/agents"),
        headers: _getHeaders(token));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> getAgent(String token, int id) async {
    final response = await http.get(Uri.parse("$baseUrl/agents/$id"),
        headers: _getHeaders(token));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> registerAsAgent(
      String token, Map<String, dynamic> data) async {
    final response = await http.post(Uri.parse("$baseUrl/agents"),
        headers: _getHeaders(token),
        body: data.map((key, value) => MapEntry(key, value.toString())));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> updateAgent(
      String token, int id, Map<String, dynamic> data) async {
    final response = await http.put(Uri.parse("$baseUrl/agents/$id"),
        headers: _getHeaders(token),
        body: data.map((key, value) => MapEntry(key, value.toString())));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> verifyAgent(String token, int id) async {
    final response = await http.post(Uri.parse("$baseUrl/agents/$id/verify"),
        headers: _getHeaders(token));
    return json.decode(response.body);
  }

  Future<void> deleteAgent(String token, int id) async {
    await http.delete(Uri.parse("$baseUrl/agents/$id"),
        headers: _getHeaders(token));
  }

  // Disputes
  Future<List<dynamic>> getDisputes(String token) async {
    final response = await http.get(Uri.parse("$baseUrl/disputes"),
        headers: _getHeaders(token));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> getDispute(String token, int id) async {
    final response = await http.get(Uri.parse("$baseUrl/disputes/$id"),
        headers: _getHeaders(token));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> createDispute(
      String token, Map<String, dynamic> data) async {
    final response = await http.post(Uri.parse("$baseUrl/disputes"),
        headers: _getHeaders(token),
        body: data.map((key, value) => MapEntry(key, value.toString())));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> updateDispute(
      String token, int id, Map<String, dynamic> data) async {
    final response = await http.patch(Uri.parse("$baseUrl/disputes/$id"),
        headers: _getHeaders(token),
        body: data.map((key, value) => MapEntry(key, value.toString())));
    return json.decode(response.body);
  }

  Future<void> cancelDispute(String token, int id) async {
    await http.delete(Uri.parse("$baseUrl/disputes/$id"),
        headers: _getHeaders(token));
  }

  // Conversations
  Future<List<dynamic>> getConversations(String token) async {
    final response = await http.get(Uri.parse("$baseUrl/conversations"),
        headers: _getHeaders(token));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> getConversation(String token, int id) async {
    final response = await http.get(Uri.parse("$baseUrl/conversations/$id"),
        headers: _getHeaders(token));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> createConversation(
      String token, Map<String, dynamic> data) async {
    final response = await http.post(Uri.parse("$baseUrl/conversations"),
        headers: _getHeaders(token),
        body: data.map((key, value) => MapEntry(key, value.toString())));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> updateConversation(
      String token, int id, Map<String, dynamic> data) async {
    final response = await http.put(Uri.parse("$baseUrl/conversations/$id"),
        headers: _getHeaders(token),
        body: data.map((key, value) => MapEntry(key, value.toString())));
    return json.decode(response.body);
  }

  Future<void> leaveConversation(String token, int id) async {
    await http.delete(Uri.parse("$baseUrl/conversations/$id"),
        headers: _getHeaders(token));
  }

  // Messages
  Future<List<dynamic>> getMessages(String token, int conversationId) async {
    final response = await http.get(
        Uri.parse("$baseUrl/conversations/$conversationId/messages"),
        headers: _getHeaders(token));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> getMessage(
      String token, int conversationId, int messageId) async {
    final response = await http.get(
        Uri.parse("$baseUrl/conversations/$conversationId/messages/$messageId"),
        headers: _getHeaders(token));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> sendMessage(
      String token, int conversationId, Map<String, dynamic> data) async {
    final response = await http.post(
        Uri.parse("$baseUrl/conversations/$conversationId/messages"),
        headers: _getHeaders(token),
        body: data.map((key, value) => MapEntry(key, value.toString())));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> updateMessage(String token, int conversationId,
      int messageId, Map<String, dynamic> data) async {
    final response = await http.put(
        Uri.parse("$baseUrl/conversations/$conversationId/messages/$messageId"),
        headers: _getHeaders(token),
        body: data.map((key, value) => MapEntry(key, value.toString())));
    return json.decode(response.body);
  }

  Future<void> deleteMessage(
      String token, int conversationId, int messageId) async {
    await http.delete(
        Uri.parse("$baseUrl/conversations/$conversationId/messages/$messageId"),
        headers: _getHeaders(token));
  }

  // Plans
  Future<List<dynamic>> getPlans(String token) async {
    final response = await http.get(Uri.parse("$baseUrl/plans"),
        headers: _getHeaders(token));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> getPlan(String token, int id) async {
    final response = await http.get(Uri.parse("$baseUrl/plans/$id"),
        headers: _getHeaders(token));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> createPlan(
      String token, Map<String, dynamic> data) async {
    final response = await http.post(Uri.parse("$baseUrl/plans"),
        headers: _getHeaders(token),
        body: data.map((key, value) => MapEntry(key, value.toString())));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> updatePlan(
      String token, int id, Map<String, dynamic> data) async {
    final response = await http.put(Uri.parse("$baseUrl/plans/$id"),
        headers: _getHeaders(token),
        body: data.map((key, value) => MapEntry(key, value.toString())));
    return json.decode(response.body);
  }

  Future<void> deletePlan(String token, int id) async {
    await http.delete(Uri.parse("$baseUrl/plans/$id"),
        headers: _getHeaders(token));
  }

  // Subscriptions
  Future<List<dynamic>> getSubscriptions(String token) async {
    final response = await http.get(Uri.parse("$baseUrl/subscriptions"),
        headers: _getHeaders(token));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> getSubscription(String token, int id) async {
    final response = await http.get(Uri.parse("$baseUrl/subscriptions/$id"),
        headers: _getHeaders(token));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> subscribeToPlan(
      String token, Map<String, dynamic> data) async {
    final response = await http.post(Uri.parse("$baseUrl/subscriptions"),
        headers: _getHeaders(token),
        body: data.map((key, value) => MapEntry(key, value.toString())));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> updateSubscription(
      String token, int id, Map<String, dynamic> data) async {
    final response = await http.put(Uri.parse("$baseUrl/subscriptions/$id"),
        headers: _getHeaders(token),
        body: data.map((key, value) => MapEntry(key, value.toString())));
    return json.decode(response.body);
  }

  Future<void> cancelSubscription(String token, int id) async {
    await http.delete(Uri.parse("$baseUrl/subscriptions/$id"),
        headers: _getHeaders(token));
  }

  // Languages
  Future<List<dynamic>> getAvailableLanguages(String token) async {
    final response = await http.get(Uri.parse("$baseUrl/languages"),
        headers: _getHeaders(token));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> getLanguageTranslations(
      String token, String locale) async {
    final response = await http.get(Uri.parse("$baseUrl/languages/$locale"),
        headers: _getHeaders(token));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> setUserLanguage(
      String token, String locale) async {
    final response = await http.post(Uri.parse("$baseUrl/languages/set"),
        headers: _getHeaders(token), body: {"locale": locale});
    return json.decode(response.body);
  }

  // Generic methods for backward compatibility
  Future<List<dynamic>> get(String token, String endpoint) async {
    final response = await http.get(Uri.parse("$baseUrl/$endpoint"),
        headers: _getHeaders(token));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> post(
      String token, String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(Uri.parse("$baseUrl/$endpoint"),
        headers: _getHeaders(token),
        body: data.map((key, value) => MapEntry(key, value.toString())));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> put(
      String token, String endpoint, Map<String, dynamic> data) async {
    final response = await http.put(Uri.parse("$baseUrl/$endpoint"),
        headers: _getHeaders(token),
        body: data.map((key, value) => MapEntry(key, value.toString())));
    return json.decode(response.body);
  }

  Future<void> delete(String token, String endpoint) async {
    await http.delete(Uri.parse("$baseUrl/$endpoint"),
        headers: _getHeaders(token));
  }
}
