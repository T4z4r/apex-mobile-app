import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/roles_provider.dart';
import '../services/api_service.dart';
import '../models/role.dart';
import '../theme/app_theme.dart';
import '../components/modern_components.dart';

class AdminUsersScreen extends StatefulWidget {
  @override
  _AdminUsersScreenState createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _users = [];
  bool _loading = false;
  int _currentPage = 1;
  bool _hasMorePages = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadRoles();
  }

  Future<void> _loadUsers({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _users.clear();
      _hasMorePages = true;
    }

    if (!_hasMorePages && !refresh) return;

    setState(() => _loading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) return;

    try {
      final query = {
        'page': _currentPage.toString(),
        'per_page': '20',
        if (_searchController.text.isNotEmpty) 'search': _searchController.text,
      };

      final response = await _apiService.getAdminUsers(token, query: query);
      final usersData = response['data'] as List<dynamic>;
      final currentPage =
          int.tryParse(response['current_page'].toString()) ?? 1;
      final lastPage = int.tryParse(response['last_page'].toString()) ?? 1;

      setState(() {
        if (refresh) {
          _users = usersData;
        } else {
          _users.addAll(usersData);
        }
        _hasMorePages = currentPage < lastPage;
        if (_hasMorePages) _currentPage++;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading users: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadRoles() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token != null) {
      final rolesProvider = Provider.of<RolesProvider>(context, listen: false);
      await rolesProvider.loadRoles(token);
      await rolesProvider.loadPermissions(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rolesProvider = Provider.of<RolesProvider>(context);

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
                        label: 'Search Users',
                        hint: 'Search by name, email, or phone',
                        controller: _searchController,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ModernButton(
                      text: 'Search',
                      onPressed: () => _loadUsers(refresh: true),
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
                        text: 'Add User',
                        onPressed: _showAddUserDialog,
                        height: 40,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ModernButton(
                      text: 'Roles',
                      onPressed: () =>
                          _showRolesManagement(context, rolesProvider),
                      isOutlined: true,
                      height: 40,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Users List
          Expanded(
            child: _loading && _users.isEmpty
                ? const LoadingState(message: 'Loading users...')
                : _users.isEmpty
                    ? EmptyState(
                        icon: '👥',
                        title: 'No Users Found',
                        message: 'No users match your search criteria.',
                        action: ModernButton(
                          text: 'Refresh',
                          onPressed: () => _loadUsers(refresh: true),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => _loadUsers(refresh: true),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _users.length + (_hasMorePages ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _users.length) {
                              _loadUsers();
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final user = _users[index];
                            return ModernCard(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      AppTheme.primaryColor.withOpacity(0.1),
                                  child: Text(
                                    user['name']
                                            ?.substring(0, 1)
                                            .toUpperCase() ??
                                        'U',
                                    style:
                                        TextStyle(color: AppTheme.primaryColor),
                                  ),
                                ),
                                title: Text(user['name'] ?? ''),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(user['email'] ?? user['phone'] ?? ''),
                                    Text(
                                      'Role: ${user['role'] ?? 'N/A'}',
                                      style: TextStyle(
                                        color: AppTheme.textSecondaryColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) =>
                                      _handleUserAction(value, user),
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Edit User'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'assign_role',
                                      child: Text('Assign Role'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Delete User'),
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

  void _handleUserAction(String action, dynamic user) {
    switch (action) {
      case 'edit':
        _showEditUserDialog(user);
        break;
      case 'assign_role':
        _showAssignRoleDialog(user);
        break;
      case 'delete':
        _showDeleteUserDialog(user);
        break;
    }
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => AddUserDialog(
        onUserAdded: () => _loadUsers(refresh: true),
      ),
    );
  }

  void _showEditUserDialog(dynamic user) {
    showDialog(
      context: context,
      builder: (context) => EditUserDialog(
        user: user,
        onUserUpdated: () => _loadUsers(refresh: true),
      ),
    );
  }

  void _showAssignRoleDialog(dynamic user) {
    final rolesProvider = Provider.of<RolesProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AssignRoleDialog(
        user: user,
        roles: rolesProvider.roles,
        onRoleAssigned: () => _loadUsers(refresh: true),
      ),
    );
  }

  void _showDeleteUserDialog(dynamic user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Delete User'),
        content: Text(
            'Are you sure you want to delete ${user['name']}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _deleteUser(user['id']),
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

  Future<void> _deleteUser(int userId) async {
    Navigator.pop(context); // Close dialog

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) return;

    try {
      await _apiService.deleteAdminUser(token, userId);
      _loadUsers(refresh: true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting user: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _showRolesManagement(BuildContext context, RolesProvider rolesProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => RolesManagementSheet(rolesProvider: rolesProvider),
    );
  }
}

class AddUserDialog extends StatefulWidget {
  final VoidCallback onUserAdded;

  const AddUserDialog({Key? key, required this.onUserAdded}) : super(key: key);

  @override
  _AddUserDialogState createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Add New User'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ModernTextField(
                label: 'Full Name',
                controller: _nameController,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              ModernTextField(
                label: 'Phone Number',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              ModernTextField(
                label: 'Email (Optional)',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              ModernTextField(
                label: 'Password',
                controller: _passwordController,
                obscureText: true,
                validator: (value) =>
                    (value?.length ?? 0) < 8 ? 'Minimum 8 characters' : null,
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
          onPressed: _isLoading ? null : _addUser,
          child: _isLoading
              ? const CircularProgressIndicator()
              : const Text('Add User'),
        ),
      ],
    );
  }

  Future<void> _addUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) return;

    final ApiService apiService = ApiService();

    try {
      await apiService.createAdminUser(token, {
        'name': _nameController.text,
        'phone': _phoneController.text,
        'email':
            _emailController.text.isNotEmpty ? _emailController.text : null,
        'password': _passwordController.text,
      });

      Navigator.pop(context);
      widget.onUserAdded();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding user: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

class EditUserDialog extends StatefulWidget {
  final dynamic user;
  final VoidCallback onUserUpdated;

  const EditUserDialog(
      {Key? key, required this.user, required this.onUserUpdated})
      : super(key: key);

  @override
  _EditUserDialogState createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user['name']);
    _phoneController = TextEditingController(text: widget.user['phone']);
    _emailController = TextEditingController(text: widget.user['email']);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Edit User'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ModernTextField(
                label: 'Full Name',
                controller: _nameController,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              ModernTextField(
                label: 'Phone Number',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              ModernTextField(
                label: 'Email (Optional)',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
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
          onPressed: _isLoading ? null : _updateUser,
          child: _isLoading
              ? const CircularProgressIndicator()
              : const Text('Update'),
        ),
      ],
    );
  }

  Future<void> _updateUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) return;

    final ApiService apiService = ApiService();

    try {
      await apiService.updateAdminUser(token, widget.user['id'], {
        'name': _nameController.text,
        'phone': _phoneController.text,
        'email':
            _emailController.text.isNotEmpty ? _emailController.text : null,
      });

      Navigator.pop(context);
      widget.onUserUpdated();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating user: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

class AssignRoleDialog extends StatefulWidget {
  final dynamic user;
  final List<Role> roles;
  final VoidCallback onRoleAssigned;

  const AssignRoleDialog({
    Key? key,
    required this.user,
    required this.roles,
    required this.onRoleAssigned,
  }) : super(key: key);

  @override
  _AssignRoleDialogState createState() => _AssignRoleDialogState();
}

class _AssignRoleDialogState extends State<AssignRoleDialog> {
  String? _selectedRole;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Assign Role to ${widget.user['name']}'),
      content: DropdownButtonFormField<String>(
        value: _selectedRole,
        decoration: const InputDecoration(
          labelText: 'Select Role',
          border: OutlineInputBorder(),
        ),
        items: widget.roles.map((role) {
          return DropdownMenuItem(
            value: role.name,
            child: Text(role.name),
          );
        }).toList(),
        onChanged: (value) => setState(() => _selectedRole = value),
        validator: (value) => value == null ? 'Please select a role' : null,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading || _selectedRole == null ? null : _assignRole,
          child: _isLoading
              ? const CircularProgressIndicator()
              : const Text('Assign'),
        ),
      ],
    );
  }

  Future<void> _assignRole() async {
    if (_selectedRole == null) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) return;

    final ApiService apiService = ApiService();

    try {
      await apiService.assignRoleToUser(
          token, widget.user['id'], _selectedRole!);

      Navigator.pop(context);
      widget.onRoleAssigned();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Role assigned successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error assigning role: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

class RolesManagementSheet extends StatelessWidget {
  final RolesProvider rolesProvider;

  const RolesManagementSheet({Key? key, required this.rolesProvider})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Role Management',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: rolesProvider.loading
                ? const Center(child: CircularProgressIndicator())
                : rolesProvider.roles.isEmpty
                    ? const Center(child: Text('No roles found'))
                    : ListView.builder(
                        itemCount: rolesProvider.roles.length,
                        itemBuilder: (context, index) {
                          final role = rolesProvider.roles[index];
                          return ModernCard(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text(role.name),
                              subtitle: Text(
                                  '${role.permissions?.length ?? 0} permissions'),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) =>
                                    _handleRoleAction(context, value, role),
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Edit Role'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'permissions',
                                    child: Text('Manage Permissions'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete Role'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          ModernButton(
            text: 'Add New Role',
            onPressed: () => _showAddRoleDialog(context),
            height: 50,
          ),
        ],
      ),
    );
  }

  void _handleRoleAction(BuildContext context, String action, Role role) {
    // TODO: Implement role actions
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action for ${role.name} - Coming Soon')),
    );
  }

  void _showAddRoleDialog(BuildContext context) {
    // TODO: Implement add role dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Role - Coming Soon')),
    );
  }
}
