import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../components/modern_components.dart';

class AdminDashboardScreen extends StatefulWidget {
  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token != null) {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      await adminProvider.loadAllDashboardData(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);

    return Scaffold(
      body: adminProvider.loading
          ? const LoadingState(message: 'Loading dashboard...')
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // System Overview Cards
                    if (adminProvider.dashboardOverview != null)
                      _buildOverviewSection(adminProvider.dashboardOverview!),

                    const SizedBox(height: 32),

                    // Analytics Section
                    if (adminProvider.dashboardAnalytics != null)
                      _buildAnalyticsSection(adminProvider.dashboardAnalytics!),

                    const SizedBox(height: 32),

                    // Recent Activity
                    if (adminProvider.recentActivity != null)
                      _buildRecentActivitySection(adminProvider.recentActivity!),

                    const SizedBox(height: 32),

                    // Tenants Overview
                    if (adminProvider.tenants != null)
                      _buildTenantsSection(adminProvider.tenants!),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOverviewSection(Map<String, dynamic> overview) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Overview',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimaryColor,
              ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildOverviewCard(
              icon: Icons.people,
              title: 'Total Users',
              value: overview['total_users']?.toString() ?? '0',
              color: AppTheme.primaryColor,
            ),
            _buildOverviewCard(
              icon: Icons.business,
              title: 'Total Tenants',
              value: overview['total_tenants']?.toString() ?? '0',
              color: AppTheme.secondaryColor,
            ),
            _buildOverviewCard(
              icon: Icons.home,
              title: 'Total Properties',
              value: overview['total_properties']?.toString() ?? '0',
              color: AppTheme.accentColor,
            ),
            _buildOverviewCard(
              icon: Icons.apartment,
              title: 'Total Units',
              value: overview['total_units']?.toString() ?? '0',
              color: AppTheme.successColor,
            ),
            _buildOverviewCard(
              icon: Icons.description,
              title: 'Active Leases',
              value: overview['active_leases']?.toString() ?? '0',
              color: AppTheme.warningColor,
            ),
            _buildOverviewCard(
              icon: Icons.build,
              title: 'Pending Maintenance',
              value: overview['pending_maintenance']?.toString() ?? '0',
              color: AppTheme.errorColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOverviewCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsSection(Map<String, dynamic> analytics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analytics (Last 30 Days)',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimaryColor,
              ),
        ),
        const SizedBox(height: 16),
        ModernCard(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildAnalyticsItem(
                        icon: Icons.trending_up,
                        title: 'New Users',
                        value: analytics['new_users']?.toString() ?? '0',
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildAnalyticsItem(
                        icon: Icons.home_work,
                        title: 'New Properties',
                        value: analytics['new_properties']?.toString() ?? '0',
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildAnalyticsItem(
                        icon: Icons.attach_money,
                        title: 'Revenue',
                        value: 'KES ${analytics['total_revenue']?.toStringAsFixed(0) ?? '0'}',
                        color: AppTheme.successColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildAnalyticsItem(
                        icon: Icons.report_problem,
                        title: 'New Disputes',
                        value: analytics['new_disputes']?.toString() ?? '0',
                        color: AppTheme.errorColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimaryColor,
                    ),
              ),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivitySection(List<dynamic> activities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimaryColor,
              ),
        ),
        const SizedBox(height: 16),
        ModernCard(
          child: activities.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No recent activity'),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activities.length > 5 ? 5 : activities.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final activity = activities[index];
                    return ListTile(
                      leading: Icon(
                        _getActivityIcon(activity['type']),
                        color: AppTheme.primaryColor,
                      ),
                      title: Text(activity['description'] ?? ''),
                      subtitle: Text(
                        activity['timestamp'] ?? '',
                        style: TextStyle(color: AppTheme.textSecondaryColor),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTenantsSection(List<dynamic> tenants) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tenant Overview',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimaryColor,
              ),
        ),
        const SizedBox(height: 16),
        ModernCard(
          child: tenants.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No tenants found'),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tenants.length > 3 ? 3 : tenants.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final tenant = tenants[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                        child: Text(
                          tenant['name']?.substring(0, 1).toUpperCase() ?? 'T',
                          style: TextStyle(color: AppTheme.primaryColor),
                        ),
                      ),
                      title: Text(tenant['name'] ?? ''),
                      subtitle: Text('${tenant['user_count'] ?? 0} users • ${tenant['subscription_status'] ?? 'Unknown'}'),
                      trailing: Text(
                        '${tenant['property_count'] ?? 0} properties',
                        style: TextStyle(color: AppTheme.textSecondaryColor),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  IconData _getActivityIcon(String? type) {
    switch (type) {
      case 'user_registration':
        return Icons.person_add;
      case 'property_added':
        return Icons.home;
      case 'lease_created':
        return Icons.description;
      case 'dispute_opened':
        return Icons.report_problem;
      case 'payment_received':
        return Icons.attach_money;
      default:
        return Icons.info;
    }
  }
}