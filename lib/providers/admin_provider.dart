import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class AdminProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _loading = false;
  Map<String, dynamic>? _dashboardOverview;
  Map<String, dynamic>? _dashboardAnalytics;
  List<dynamic>? _recentActivity;
  List<dynamic>? _tenants;

  bool get loading => _loading;
  Map<String, dynamic>? get dashboardOverview => _dashboardOverview;
  Map<String, dynamic>? get dashboardAnalytics => _dashboardAnalytics;
  List<dynamic>? get recentActivity => _recentActivity;
  List<dynamic>? get tenants => _tenants;

  Future<void> loadDashboardOverview(String token) async {
    _loading = true;
    notifyListeners();

    try {
      _dashboardOverview = await _apiService.getAdminDashboardOverview(token);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading dashboard overview: $e');
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadDashboardAnalytics(String token, {int period = 30}) async {
    _loading = true;
    notifyListeners();

    try {
      _dashboardAnalytics = await _apiService.getAdminDashboardAnalytics(token, period: period);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading dashboard analytics: $e');
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadRecentActivity(String token) async {
    try {
      _recentActivity = await _apiService.getAdminDashboardRecentActivity(token);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading recent activity: $e');
      }
    }
    notifyListeners();
  }

  Future<void> loadTenants(String token) async {
    try {
      _tenants = await _apiService.getAdminDashboardTenants(token);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading tenants: $e');
      }
    }
    notifyListeners();
  }

  Future<void> loadAllDashboardData(String token) async {
    await Future.wait([
      loadDashboardOverview(token),
      loadDashboardAnalytics(token),
      loadRecentActivity(token),
      loadTenants(token),
    ]);
  }
}