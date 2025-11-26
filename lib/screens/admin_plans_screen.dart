import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../components/modern_components.dart';

class AdminPlansScreen extends StatefulWidget {
  @override
  _AdminPlansScreenState createState() => _AdminPlansScreenState();
}

class _AdminPlansScreenState extends State<AdminPlansScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _plans = [];
  bool _loading = false;
  bool _showInactive = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans({bool refresh = false}) async {
    if (refresh) {
      _plans.clear();
    }

    setState(() => _loading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) return;

    try {
      final query = <String, String>{};
      if (_searchController.text.isNotEmpty) {
        query['search'] = _searchController.text;
      }

      final plansData = await _apiService.getAdminPlans(token, query: query);
      setState(() {
        _plans = plansData.where((plan) => _showInactive || plan['is_active'] == true).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading plans: $e'),
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
                        label: 'Search Plans',
                        hint: 'Search by name or description',
                        controller: _searchController,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ModernButton(
                      text: 'Search',
                      onPressed: () => _loadPlans(refresh: true),
                      height: 48,
                      width: 80,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ModernButton(
                        text: 'Create Plan',
                        onPressed: _showCreatePlanDialog,
                        height: 48,
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilterChip(
                      label: Text(_showInactive ? 'Hide Inactive' : 'Show Inactive'),
                      selected: _showInactive,
                      onSelected: (selected) {
                        setState(() => _showInactive = selected);
                        _loadPlans(refresh: true);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Plans List
          Expanded(
            child: _loading
                ? const LoadingState(message: 'Loading plans...')
                : _plans.isEmpty
                    ? EmptyState(
                        icon: '📊',
                        title: 'No Plans Found',
                        message: _showInactive ? 'No plans match your criteria.' : 'No active plans found.',
                        action: ModernButton(
                          text: 'Refresh',
                          onPressed: () => _loadPlans(refresh: true),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => _loadPlans(refresh: true),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _plans.length,
                          itemBuilder: (context, index) {
                            final plan = _plans[index];
                            final isActive = plan['is_active'] == true || plan['is_active'] == 1;

                            return ModernCard(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListTile(
                                    title: Text(
                                      plan['name'] ?? 'Unnamed Plan',
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (plan['description'] != null)
                                          Text(plan['description']),
                                        Text('Monthly: KES ${plan['monthly_price'] ?? 0} | Yearly: KES ${plan['yearly_price'] ?? 0}'),
                                        Text('Limits: ${plan['max_properties'] ?? 0} properties, ${plan['max_units'] ?? 0} units, ${plan['max_users'] ?? 0} users'),
                                        Row(
                                          children: [
                                            Text('Status: '),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: isActive ? AppTheme.successColor.withOpacity(0.1) : AppTheme.errorColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                isActive ? 'Active' : 'Inactive',
                                                style: TextStyle(
                                                  color: isActive ? AppTheme.successColor : AppTheme.errorColor,
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
                                      onSelected: (value) => _handlePlanAction(value, plan),
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Text('Edit Plan'),
                                        ),
                                        PopupMenuItem(
                                          value: isActive ? 'deactivate' : 'activate',
                                          child: Text(isActive ? 'Deactivate' : 'Activate'),
                                        ),
                                        const PopupMenuItem(
                                          value: 'duplicate',
                                          child: Text('Duplicate Plan'),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Text('Delete Plan'),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (plan['features'] != null && (plan['features'] as List).isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Features:',
                                            style: TextStyle(fontWeight: FontWeight.w600),
                                          ),
                                          const SizedBox(height: 8),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 4,
                                            children: (plan['features'] as List).map<Widget>((feature) {
                                              return Chip(
                                                label: Text(feature.toString()),
                                                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                                                labelStyle: TextStyle(color: AppTheme.primaryColor),
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      ),
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

  void _handlePlanAction(String action, dynamic plan) {
    switch (action) {
      case 'edit':
        _showEditPlanDialog(plan);
        break;
      case 'activate':
      case 'deactivate':
        _togglePlanStatus(plan['id']);
        break;
      case 'duplicate':
        _duplicatePlan(plan['id']);
        break;
      case 'delete':
        _showDeletePlanDialog(plan);
        break;
    }
  }

  void _showCreatePlanDialog() {
    showDialog(
      context: context,
      builder: (context) => PlanFormDialog(
        title: 'Create New Plan',
        onSubmit: _createPlan,
      ),
    );
  }

  void _showEditPlanDialog(dynamic plan) {
    showDialog(
      context: context,
      builder: (context) => PlanFormDialog(
        title: 'Edit Plan',
        initialData: plan,
        onSubmit: (data) => _updatePlan(plan['id'], data),
      ),
    );
  }

  void _showDeletePlanDialog(dynamic plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Delete Plan'),
        content: Text('Are you sure you want to delete plan "${plan['name']}"? This action cannot be undone and may affect existing subscriptions.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _deletePlan(plan['id']),
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

  Future<void> _createPlan(Map<String, dynamic> planData) async {
    Navigator.pop(context); // Close dialog

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) return;

    try {
      await _apiService.createAdminPlan(token, planData);
      _loadPlans(refresh: true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Plan created successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating plan: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _updatePlan(int planId, Map<String, dynamic> planData) async {
    Navigator.pop(context); // Close dialog

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) return;

    try {
      await _apiService.updateAdminPlan(token, planId, planData);
      _loadPlans(refresh: true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Plan updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating plan: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _togglePlanStatus(int planId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) return;

    try {
      await _apiService.toggleAdminPlan(token, planId);
      _loadPlans(refresh: true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Plan status updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating plan status: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _duplicatePlan(int planId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) return;

    try {
      await _apiService.duplicateAdminPlan(token, planId);
      _loadPlans(refresh: true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Plan duplicated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error duplicating plan: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _deletePlan(int planId) async {
    Navigator.pop(context); // Close dialog

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) return;

    try {
      await _apiService.deleteAdminPlan(token, planId);
      _loadPlans(refresh: true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Plan deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting plan: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
}

class PlanFormDialog extends StatefulWidget {
  final String title;
  final dynamic initialData;
  final Function(Map<String, dynamic>) onSubmit;

  const PlanFormDialog({
    Key? key,
    required this.title,
    this.initialData,
    required this.onSubmit,
  }) : super(key: key);

  @override
  _PlanFormDialogState createState() => _PlanFormDialogState();
}

class _PlanFormDialogState extends State<PlanFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _monthlyPriceController = TextEditingController();
  final _yearlyPriceController = TextEditingController();
  final _maxPropertiesController = TextEditingController();
  final _maxUnitsController = TextEditingController();
  final _maxUsersController = TextEditingController();
  final _trialDaysController = TextEditingController();
  final _featuresController = TextEditingController();
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _nameController.text = widget.initialData['name'] ?? '';
      _descriptionController.text = widget.initialData['description'] ?? '';
      _monthlyPriceController.text = widget.initialData['monthly_price']?.toString() ?? '';
      _yearlyPriceController.text = widget.initialData['yearly_price']?.toString() ?? '';
      _maxPropertiesController.text = widget.initialData['max_properties']?.toString() ?? '';
      _maxUnitsController.text = widget.initialData['max_units']?.toString() ?? '';
      _maxUsersController.text = widget.initialData['max_users']?.toString() ?? '';
      _trialDaysController.text = widget.initialData['trial_days']?.toString() ?? '';
      _featuresController.text = (widget.initialData['features'] as List?)?.join(', ') ?? '';
      _isActive = widget.initialData['is_active'] == true || widget.initialData['is_active'] == 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ModernTextField(
                label: 'Plan Name',
                controller: _nameController,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              ModernTextField(
                label: 'Description',
                controller: _descriptionController,
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ModernTextField(
                      label: 'Monthly Price',
                      controller: _monthlyPriceController,
                      keyboardType: TextInputType.number,
                      validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ModernTextField(
                      label: 'Yearly Price',
                      controller: _yearlyPriceController,
                      keyboardType: TextInputType.number,
                      validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ModernTextField(
                      label: 'Max Properties',
                      controller: _maxPropertiesController,
                      keyboardType: TextInputType.number,
                      validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ModernTextField(
                      label: 'Max Units',
                      controller: _maxUnitsController,
                      keyboardType: TextInputType.number,
                      validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ModernTextField(
                      label: 'Max Users',
                      controller: _maxUsersController,
                      keyboardType: TextInputType.number,
                      validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ModernTextField(
                      label: 'Trial Days',
                      controller: _trialDaysController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ModernTextField(
                label: 'Features (comma separated)',
                controller: _featuresController,
                hint: 'e.g. Property management, Tenant screening, Maintenance tracking',
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Active Plan'),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final features = _featuresController.text.isNotEmpty
        ? _featuresController.text.split(',').map((f) => f.trim()).where((f) => f.isNotEmpty).toList()
        : [];

    final planData = {
      'name': _nameController.text,
      'description': _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
      'monthly_price': double.parse(_monthlyPriceController.text),
      'yearly_price': double.parse(_yearlyPriceController.text),
      'max_properties': int.parse(_maxPropertiesController.text),
      'max_units': int.parse(_maxUnitsController.text),
      'max_users': int.parse(_maxUsersController.text),
      'features': features,
      'is_active': _isActive,
      if (_trialDaysController.text.isNotEmpty) 'trial_days': int.parse(_trialDaysController.text),
    };

    widget.onSubmit(planData);
  }
}