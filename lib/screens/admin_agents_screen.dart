import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../components/modern_components.dart';

class AdminAgentsScreen extends StatefulWidget {
  @override
  _AdminAgentsScreenState createState() => _AdminAgentsScreenState();
}

class _AdminAgentsScreenState extends State<AdminAgentsScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _agents = [];
  bool _loading = false;
  String _selectedStatus = 'all';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAgents();
  }

  Future<void> _loadAgents({bool refresh = false}) async {
    if (refresh) {
      _agents.clear();
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

      final agentsData = await _apiService.getAdminAgents(token, query: query);
      setState(() {
        _agents = agentsData;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading agents: $e'),
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
                        label: 'Search Agents',
                        hint: 'Search by name, agency, or email',
                        controller: _searchController,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ModernButton(
                      text: 'Search',
                      onPressed: () => _loadAgents(refresh: true),
                      height: 48,
                      width: 80,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Filter by Status',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Agents')),
                    DropdownMenuItem(
                        value: 'verified', child: Text('Verified')),
                    DropdownMenuItem(
                        value: 'pending', child: Text('Pending Verification')),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedStatus = value!);
                    _loadAgents(refresh: true);
                  },
                ),
              ],
            ),
          ),

          // Agents List
          Expanded(
            child: _loading
                ? const LoadingState(message: 'Loading agents...')
                : _agents.isEmpty
                    ? EmptyState(
                        icon: '👔',
                        title: 'No Agents Found',
                        message: 'No agents match your criteria.',
                        action: ModernButton(
                          text: 'Refresh',
                          onPressed: () => _loadAgents(refresh: true),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => _loadAgents(refresh: true),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _agents.length,
                          itemBuilder: (context, index) {
                            final agent = _agents[index];
                            final isVerified = agent['is_verified'] == true ||
                                agent['is_verified'] == 1;

                            return ModernCard(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isVerified
                                      ? AppTheme.successColor.withOpacity(0.1)
                                      : AppTheme.warningColor.withOpacity(0.1),
                                  child: Icon(
                                    isVerified ? Icons.verified : Icons.pending,
                                    color: isVerified
                                        ? AppTheme.successColor
                                        : AppTheme.warningColor,
                                  ),
                                ),
                                title: Text(
                                    agent['user']?['name'] ?? 'Unknown Agent'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'Agency: ${agent['agency_name'] ?? 'N/A'}'),
                                    Text(
                                        'Email: ${agent['user']?['email'] ?? 'N/A'}'),
                                    Text(
                                        'Phone: ${agent['user']?['phone'] ?? 'N/A'}'),
                                    if (agent['commission_rate'] != null)
                                      Text(
                                          'Commission: ${agent['commission_rate']}%'),
                                    Row(
                                      children: [
                                        Text('Status: '),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isVerified
                                                ? AppTheme.successColor
                                                    .withOpacity(0.1)
                                                : AppTheme.warningColor
                                                    .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            isVerified ? 'Verified' : 'Pending',
                                            style: TextStyle(
                                              color: isVerified
                                                  ? AppTheme.successColor
                                                  : AppTheme.warningColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) =>
                                      _handleAgentAction(value, agent),
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Edit Agent'),
                                    ),
                                    PopupMenuItem(
                                      value: isVerified ? 'unverify' : 'verify',
                                      child: Text(isVerified
                                          ? 'Remove Verification'
                                          : 'Verify Agent'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Delete Agent'),
                                    ),
                                  ],
                                ),
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

  void _handleAgentAction(String action, dynamic agent) {
    switch (action) {
      case 'edit':
        _showEditAgentDialog(agent);
        break;
      case 'verify':
        _verifyAgent(agent['id']);
        break;
      case 'unverify':
        _unverifyAgent(agent['id']);
        break;
      case 'delete':
        _showDeleteAgentDialog(agent);
        break;
    }
  }

  void _showEditAgentDialog(dynamic agent) {
    final agencyController =
        TextEditingController(text: agent['agency_name'] ?? '');
    final commissionController =
        TextEditingController(text: agent['commission_rate']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Agent'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ModernTextField(
              label: 'Agency Name',
              controller: agencyController,
            ),
            const SizedBox(height: 12),
            ModernTextField(
              label: 'Commission Rate (%)',
              controller: commissionController,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _updateAgent(
                agent['id'], agencyController.text, commissionController.text),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAgentDialog(dynamic agent) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Delete Agent'),
        content: Text(
            'Are you sure you want to delete agent "${agent['user']?['name'] ?? 'Unknown'}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _deleteAgent(agent['id']),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateAgent(
      int agentId, String agencyName, String commissionRate) async {
    Navigator.pop(context); // Close dialog

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) return;

    try {
      final updateData = <String, dynamic>{};
      if (agencyName.isNotEmpty) updateData['agency_name'] = agencyName;
      if (commissionRate.isNotEmpty)
        updateData['commission_rate'] = double.parse(commissionRate);

      await _apiService.updateAdminAgent(token, agentId, updateData);

      _loadAgents(refresh: true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agent updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating agent: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _verifyAgent(int agentId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) return;

    try {
      await _apiService.verifyAdminAgent(token, agentId);
      _loadAgents(refresh: true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agent verified successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error verifying agent: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _unverifyAgent(int agentId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) return;

    try {
      await _apiService.unverifyAdminAgent(token, agentId);
      _loadAgents(refresh: true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agent verification removed'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error removing verification: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _deleteAgent(int agentId) async {
    Navigator.pop(context); // Close dialog

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) return;

    try {
      await _apiService.deleteAdminAgent(token, agentId);
      _loadAgents(refresh: true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agent deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting agent: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
}
