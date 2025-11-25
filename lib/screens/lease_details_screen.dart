import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/leases_provider.dart';
import '../providers/auth_provider.dart';
import '../models/lease.dart';
import '../theme/app_theme.dart';
import '../components/modern_components.dart';
import 'edit_lease_screen.dart';

class LeaseDetailsScreen extends StatefulWidget {
  final Lease lease;

  const LeaseDetailsScreen({Key? key, required this.lease}) : super(key: key);

  @override
  _LeaseDetailsScreenState createState() => _LeaseDetailsScreenState();
}

class _LeaseDetailsScreenState extends State<LeaseDetailsScreen> {
  Lease? _lease;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadLeaseDetails();
  }

  Future<void> _loadLeaseDetails() async {
    setState(() => _loading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token != null) {
      final lease = await Provider.of<LeasesProvider>(context, listen: false)
          .getLease(token, widget.lease.id);
      setState(() {
        _lease = lease;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lease = _lease ?? widget.lease;

    return Scaffold(
      appBar: AppBar(
        title: Text('${lease.unit?.unitLabel ?? 'Unit'} Lease'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.textPrimaryColor,
        actions: [
          if (lease.status == 'pending' || lease.status == 'active')
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditLeaseScreen(lease: lease),
                  ),
                ).then((_) => _loadLeaseDetails()); // Refresh after edit
              },
            ),
        ],
      ),
      body: _loading
          ? const LoadingState(message: 'Loading lease details...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Lease Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: _getStatusGradient(lease.status),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${lease.unit?.unitLabel ?? 'Unit'} - ${lease.tenant?.name ?? 'Tenant'}',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Lease Period
                  Text(
                    'Lease Period',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              const Icon(Icons.calendar_today, color: AppTheme.primaryColor),
                              const SizedBox(height: 4),
                              Text(
                                'Start Date',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.textSecondaryColor,
                                    ),
                              ),
                              Text(
                                lease.startDate.toLocal().toString().split(' ')[0],
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 40,
                          width: 1,
                          color: AppTheme.dividerColor,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              const Icon(Icons.event, color: AppTheme.secondaryColor),
                              const SizedBox(height: 4),
                              Text(
                                'End Date',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.textSecondaryColor,
                                    ),
                              ),
                              Text(
                                lease.endDate.toLocal().toString().split(' ')[0],
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Financial Information
                  Text(
                    'Financial Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.attach_money, color: AppTheme.primaryColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Monthly Rent: KES ${lease.rentAmount?.toStringAsFixed(0) ?? 'N/A'}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.account_balance_wallet, color: AppTheme.secondaryColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Security Deposit: KES ${lease.depositAmount?.toStringAsFixed(0) ?? 'N/A'}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.schedule, color: AppTheme.accentColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Payment Frequency: ${lease.paymentFrequency.toUpperCase()}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tenant Information
                  Text(
                    'Tenant Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ModernCard(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                        child: Icon(
                          Icons.person,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      title: Text(lease.tenant?.name ?? 'N/A'),
                      subtitle: Text(lease.tenant?.email ?? 'N/A'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Unit Information
                  Text(
                    'Unit Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ModernCard(
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.home,
                            color: AppTheme.primaryColor,
                          ),
                          title: Text(lease.unit?.unitLabel ?? 'N/A'),
                          subtitle: Text(lease.unit?.property?.title ?? 'Property'),
                        ),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.king_bed,
                                      color: AppTheme.secondaryColor,
                                      size: 24,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${lease.unit?.bedrooms ?? 0}',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    Text(
                                      'Bedrooms',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.bathtub,
                                      color: AppTheme.accentColor,
                                      size: 24,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${lease.unit?.bathrooms ?? 0}',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    Text(
                                      'Bathrooms',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.square_foot,
                                      color: AppTheme.primaryColor,
                                      size: 24,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      lease.unit?.sizeM2?.toStringAsFixed(0) ?? 'N/A',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    Text(
                                      'm²',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Lease Actions
                  if (lease.status == 'pending') ...[
                    const SizedBox(height: 24),
                    ModernButton(
                      text: 'Sign Lease',
                      onPressed: () => _signLease(lease),
                      height: 56,
                    ),
                  ],

                  if (lease.status == 'active') ...[
                    const SizedBox(height: 24),
                    ModernButton(
                      text: 'Cancel Lease',
                      onPressed: () => _showCancelConfirmation(lease),
                      color: AppTheme.errorColor,
                      height: 56,
                    ),
                  ],
                ],
              ),
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

  Future<void> _signLease(Lease lease) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) return;

    // TODO: Implement signature capture
    final signatureData = {
      'signature': 'signed',
      'signature_type': 'typed',
    };

    final success = await Provider.of<LeasesProvider>(context, listen: false)
        .signLease(token, lease.id, signatureData);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Lease signed successfully'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      _loadLeaseDetails(); // Refresh data
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to sign lease'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
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
          'Are you sure you want to cancel this lease? This action cannot be undone.',
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
              await _cancelLease(lease);
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

  Future<void> _cancelLease(Lease lease) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) return;

    final success = await Provider.of<LeasesProvider>(context, listen: false)
        .cancelLease(token, lease.id);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Lease cancelled successfully'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      Navigator.pop(context); // Go back to leases list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to cancel lease'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}