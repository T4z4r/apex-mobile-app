import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'admin_dashboard_screen.dart';
import 'admin_users_screen.dart';
import 'admin_disputes_screen.dart';
import 'admin_agents_screen.dart';
import 'admin_plans_screen.dart';

class AdminNavigationScreen extends StatefulWidget {
  @override
  _AdminNavigationScreenState createState() => _AdminNavigationScreenState();
}

class _AdminNavigationScreenState extends State<AdminNavigationScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _screens = [
    AdminDashboardScreen(),
    AdminUsersScreen(),
    AdminDisputesScreen(),
    AdminAgentsScreen(),
    AdminPlansScreen(),
  ];

  static final List<String> _titles = [
    'Admin Dashboard',
    'Manage Users',
    'Manage Disputes',
    'Manage Agents',
    'Manage Plans',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showLogoutConfirmation(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.logout,
                color: AppTheme.primaryColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Logout',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppTheme.textSecondaryColor),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await authProvider.logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _titles[_selectedIndex],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                if (authProvider.userName != null)
                  Text(
                    'Welcome back, ${authProvider.userName}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
              ],
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Colors.white,
            leading: Builder(
              builder: (context) => Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.menu, size: 20),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  tooltip: 'Menu',
                ),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.logout, size: 20),
                  onPressed: () => _showLogoutConfirmation(context, authProvider),
                  tooltip: 'Logout',
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: _buildDrawer(context),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem),
            label: 'Disputes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Agents',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.subscriptions),
            label: 'Plans',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textSecondaryColor,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 8,
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Admin Panel',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'System Management',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Menu Items
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(8),
                    children: [
                      _buildDrawerItem(
                        icon: Icons.dashboard,
                        title: 'Dashboard',
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => _selectedIndex = 0);
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.people,
                        title: 'Manage Users',
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => _selectedIndex = 1);
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.report_problem,
                        title: 'Manage Disputes',
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => _selectedIndex = 2);
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.business,
                        title: 'Manage Agents',
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => _selectedIndex = 3);
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.subscriptions,
                        title: 'Manage Plans',
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => _selectedIndex = 4);
                        },
                      ),
                      const Divider(),
                      _buildDrawerItem(
                        icon: Icons.settings,
                        title: 'System Settings',
                        onTap: () {
                          Navigator.pop(context);
                          // TODO: Navigate to settings screen
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.analytics,
                        title: 'Analytics',
                        onTap: () {
                          Navigator.pop(context);
                          // TODO: Navigate to analytics screen
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.backup,
                        title: 'Backup & Restore',
                        onTap: () {
                          Navigator.pop(context);
                          // TODO: Navigate to backup screen
                        },
                      ),
                      const Divider(),
                      _buildDrawerItem(
                        icon: Icons.logout,
                        title: 'Logout',
                        color: AppTheme.errorColor,
                        onTap: () {
                          Navigator.pop(context);
                          final authProvider = Provider.of<AuthProvider>(context, listen: false);
                          _showLogoutConfirmation(context, authProvider);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: color ?? AppTheme.primaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? AppTheme.textPrimaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      tileColor: Colors.transparent,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
