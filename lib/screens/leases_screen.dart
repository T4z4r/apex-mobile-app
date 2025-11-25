import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/leases_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../components/modern_components.dart';
import '../models/lease.dart';

class LeasesScreen extends StatefulWidget {
  @override
  _LeasesScreenState createState() => _LeasesScreenState();
}

class _LeasesScreenState extends State<LeasesScreen> {
  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token != null) {
      Provider.of<LeasesProvider>(context, listen: false).fetchLeases(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final leasesProvider = Provider.of<LeasesProvider>(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          if (leasesProvider.loading)
            const SliverFillRemaining(
              child: LoadingState(message: 'Loading leases...'),
            )
          else if (leasesProvider.leases.isEmpty)
            SliverFillRemaining(
              child: EmptyState(
                icon: '📄',
                title: 'No Leases Yet',
                message:
                    'Lease agreements will appear here once tenants sign them.',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(2),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final lease = leasesProvider.leases[index];
                    return _buildLeaseCard(lease);
                  },
                  childCount: leasesProvider.leases.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLeaseCard(Lease lease) {
    return ModernCard(
      onTap: () {
        // TODO: Navigate to lease details screen
      },
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, size: 20),
          onPressed: () {
            _showLeaseOptions(lease);
          },
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${lease.unit?.unitLabel ?? 'Unit'} - ${lease.tenant?.name ?? 'Tenant'}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${lease.startDate.toLocal().toString().split(' ')[0]} - ${lease.endDate.toLocal().toString().split(' ')[0]}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: _getStatusGradient(lease.status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  lease.status.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Icon(
                        Icons.attach_money,
                        color: AppTheme.primaryColor,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lease.rentAmount != null ? 'KES ${lease.rentAmount!.toStringAsFixed(0)}' : 'N/A',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimaryColor,
                                ),
                      ),
                      Text(
                        'Rent',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        color: AppTheme.secondaryColor,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lease.depositAmount != null ? 'KES ${lease.depositAmount!.toStringAsFixed(0)}' : 'N/A',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimaryColor,
                                ),
                      ),
                      Text(
                        'Deposit',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Icon(
                        Icons.schedule,
                        color: AppTheme.accentColor,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lease.paymentFrequency,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimaryColor,
                                ),
                      ),
                      Text(
                        'Frequency',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ModernButton(
                  text: 'View Details',
                  onPressed: () {
                    // TODO: Navigate to lease details screen
                  },
                  isOutlined: true,
                  height: 40,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ModernButton(
                  text: lease.status == 'pending' ? 'Sign Lease' : 'Manage',
                  onPressed: () {
                    if (lease.status == 'pending') {
                      _signLease(lease.id);
                    } else {
                      _showLeaseOptions(lease);
                    }
                  },
                  height: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  LinearGradient _getStatusGradient(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppTheme.successGradient;
      case 'pending':
        return AppTheme.warningGradient;
      case 'terminated':
        return AppTheme.errorGradient;
      default:
        return AppTheme.primaryGradient;
    }
  }

  Future<void> _cancelLease(int id) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token != null) {
      final success = await Provider.of<LeasesProvider>(context, listen: false)
          .cancelLease(token, id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lease cancelled successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to cancel lease')),
        );
      }
    }
  }

  Future<void> _signLease(int id) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token != null) {
      // TODO: Implement sign lease functionality
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign lease functionality not implemented yet')),
      );
    }
  }

  void _showLeaseOptions(Lease lease) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Lease Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 20),
            _buildBottomSheetItem(
              icon: Icons.visibility,
              title: 'View Details',
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to lease details screen
              },
            ),
            if (lease.status == 'pending')
              _buildBottomSheetItem(
                icon: Icons.edit,
                title: 'Sign Lease',
                onTap: () {
                  Navigator.pop(context);
                  _signLease(lease.id);
                },
              ),
            if (lease.status == 'active')
              _buildBottomSheetItem(
                icon: Icons.cancel,
                title: 'Cancel Lease',
                color: AppTheme.errorColor,
                onTap: () {
                  Navigator.pop(context);
                  _showCancelConfirmation(lease);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheetItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: color ?? AppTheme.textPrimaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? AppTheme.textPrimaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showCancelConfirmation(Lease lease) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Cancel Lease',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        content: Text(
          'Are you sure you want to cancel the lease for ${lease.unit?.unitLabel ?? 'Unit'}? This action cannot be undone.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _cancelLease(lease.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancel Lease'),
          ),
        ],
      ),
    );
  }
}