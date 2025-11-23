import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/leases_provider.dart';
import '../providers/auth_provider.dart';
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

    return leasesProvider.loading
        ? Center(child: CircularProgressIndicator())
        : leasesProvider.leases.isEmpty
            ? Center(child: Text('No leases found'))
            : ListView.builder(
                itemCount: leasesProvider.leases.length,
                itemBuilder: (ctx, i) {
                  final lease = leasesProvider.leases[i];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text('Lease #${lease.id}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Unit: ${lease.unit?.unitLabel ?? 'N/A'}'),
                          Text('Tenant: ${lease.tenant?.name ?? 'N/A'}'),
                          Text('Status: ${lease.status}'),
                          Text('Period: ${lease.startDate.toLocal().toString().split(' ')[0]} - ${lease.endDate.toLocal().toString().split(' ')[0]}'),
                        ],
                      ),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: Text('View Details'),
                            value: 'view',
                          ),
                          PopupMenuItem(
                            child: Text('Sign Lease'),
                            value: 'sign',
                          ),
                          PopupMenuItem(
                            child: Text('Cancel'),
                            value: 'cancel',
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'cancel') {
                            _cancelLease(lease.id);
                          }
                        },
                      ),
                      onTap: () {
                        // TODO: Navigate to lease detail
                      },
                    ),
                  );
                },
              );
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
}