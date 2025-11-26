import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../components/modern_components.dart';

class AdminDisputesScreen extends StatefulWidget {
  @override
  _AdminDisputesScreenState createState() => _AdminDisputesScreenState();
}

class _AdminDisputesScreenState extends State<AdminDisputesScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _disputes = [];
  bool _loading = false;
  String _selectedStatus = 'all';
  final TextEditingController _searchController = TextEditingController();
  List<int> _selectedDisputes = [];

  @override
  void initState() {
    super.initState();
    _loadDisputes();
  }

  Future<void> _loadDisputes({bool refresh = false}) async {
    if (refresh) {
      _disputes.clear();
    }

    setState(() => _loading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) return;

    try {
      final query = <String, String>{};
      if (_selectedStatus != 'all') {
        query['status'] = _selectedStatus;
      }
      if (_searchController.text.isNotEmpty) {
        query['search'] = _searchController.text;
      }

      final disputesData = await _apiService.getAdminDisputes(token, query: query);
      setState(() {
        _disputes = disputesData;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading disputes: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ModernTextField(
                        label: 'Search Disputes',
                        hint: 'Search by issue, tenant, or lease',
                        controller: _searchController,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ModernButton(
                      text: 'Search',
                      onPressed: () => _loadDisputes(refresh: true),
                      height: 48,
                      width: 80,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: InputDecoration(
                          labelText: 'Filter by Status',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('All Disputes')),
                          DropdownMenuItem(value: 'open', child: Text('Open')),
                          DropdownMenuItem(value: 'resolved', child: Text('Resolved')),
                          DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedStatus = value!);
                          _loadDisputes(refresh: true);
                        },
                      ),
                    ),
                    if (_selectedDisputes.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      ModernButton(
                        text: 'Bulk Update (${_selectedDisputes.length})',
                        onPressed: _showBulkUpdateDialog,
                        color: AppTheme.primaryColor,
                        height: 48,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Disputes List
          Expanded(
            child: _loading
                ? const LoadingState(message: 'Loading disputes...')
                : _disputes.isEmpty
                    ? EmptyState(
                        icon: '⚖️',
                        title: 'No Disputes Found',
                        message: 'No disputes match your criteria.',
                        action: ModernButton(
                          text: 'Refresh',
                          onPressed: () => _loadDisputes(refresh: true),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => _loadDisputes(refresh: true),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _disputes.length,
                          itemBuilder: (context, index) {
                            final dispute = _disputes[index];
                            return ModernCard(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                children: [
                                  CheckboxListTile(
                                    value: _selectedDisputes.contains(dispute['id']),
                                    onChanged: (selected) {
                                      setState(() {
                                        if (selected!) {
                                          _selectedDisputes.add(dispute['id']);
                                        } else {
                                          _selectedDisputes.remove(dispute['id']);
                                        }
                                      });
                                    },
                                    title: Text(
                                      dispute['issue'] ?? 'No issue description',
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Lease ID: ${dispute['lease_id']}'),
                                        Text('Tenant: ${dispute['tenant']?['name'] ?? 'Unknown'}'),
                                        Text('Status: ${dispute['status']}'),
                                        if (dispute['created_at'] != null)
                                          Text('Created: ${dispute['created_at']}'),
                                      ],
                                    ),
                                  ),
                                  ButtonBar(
                                    children: [
                                      TextButton(
                                        onPressed: () => _showDisputeDetails(dispute),
                                        child: const Text('View Details'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => _showUpdateDisputeDialog(dispute),
                                        child: const Text('Update Status'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  void _showDisputeDetails(dynamic dispute) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dispute Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Issue: ${dispute['issue'] ?? 'N/A'}'),
              const SizedBox(height: 8),
              Text('Status: ${dispute['status'] ?? 'N/A'}'),
              const SizedBox(height: 8),
              Text('Lease ID: ${dispute['lease_id'] ?? 'N/A'}'),
              const SizedBox(height: 8),
              Text('Tenant: ${dispute['tenant']?['name'] ?? 'N/A'}'),
              const SizedBox(height: 8),
              Text('Created: ${dispute['created_at'] ?? 'N/A'}'),
              if (dispute['admin_resolution_notes'] != null) ...[
                const SizedBox(height: 8),
                Text('Resolution Notes: ${dispute['admin_resolution_notes']}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showUpdateDisputeDialog(dynamic dispute) {
    String selectedStatus = dispute['status'] ?? 'open';
    final notesController = TextEditingController(text: dispute['admin_resolution_notes'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Dispute Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedStatus,
              decoration: const InputDecoration(labelText: 'Status'),
              items: const [
                DropdownMenuItem(value: 'open', child: Text('Open')),
                DropdownMenuItem(value: 'resolved', child: Text('Resolved')),
                DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
              ],
              onChanged: (value) => selectedStatus = value!,
            ),
            const SizedBox(height: 16),
            ModernTextField(
              label: 'Resolution Notes',
              controller: notesController,
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _updateDispute(dispute['id'], selectedStatus, notesController.text),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showBulkUpdateDialog() {
    String selectedStatus = 'resolved';
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bulk Update ${_selectedDisputes.length} Disputes'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedStatus,
              decoration: const InputDecoration(labelText: 'Status'),
              items: const [
                DropdownMenuItem(value: 'resolved', child: Text('Resolved')),
                DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
              ],
              onChanged: (value) => selectedStatus = value!,
            ),
            const SizedBox(height: 16),
            ModernTextField(
              label: 'Resolution Notes (Optional)',
              controller: notesController,
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _bulkUpdateDisputes(selectedStatus, notesController.text),
            child: const Text('Update All'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateDispute(int disputeId, String status, String notes) async {
    Navigator.pop(context); // Close dialog

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) return;

    try {
      await _apiService.updateAdminDispute(token, disputeId, {
        'status': status,
        if (notes.isNotEmpty) 'admin_resolution_notes': notes,
      });

      _loadDisputes(refresh: true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dispute updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating dispute: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _bulkUpdateDisputes(String status, String notes) async {
    Navigator.pop(context); // Close dialog

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) return;

    try {
      await _apiService.bulkUpdateAdminDisputes(token, _selectedDisputes, status, notes: notes.isNotEmpty ? notes : null);

      setState(() => _selectedDisputes.clear());
      _loadDisputes(refresh: true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Disputes updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating disputes: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
}