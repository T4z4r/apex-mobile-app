import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/properties_provider.dart';
import '../providers/units_provider.dart';
import '../providers/leases_provider.dart';
import '../providers/maintenance_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token != null) {
      await Future.wait([
        Provider.of<PropertiesProvider>(context, listen: false).fetchProperties(token),
        Provider.of<UnitsProvider>(context, listen: false).fetchUnits(token),
        Provider.of<LeasesProvider>(context, listen: false).fetchLeases(token),
        Provider.of<MaintenanceProvider>(context, listen: false).fetchMaintenanceRequests(token),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final propertiesProvider = Provider.of<PropertiesProvider>(context);
    final unitsProvider = Provider.of<UnitsProvider>(context);
    final leasesProvider = Provider.of<LeasesProvider>(context);
    final maintenanceProvider = Provider.of<MaintenanceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Apex Property Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Text(
              'Welcome, ${authProvider.userName ?? 'User'}!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 24),
            _buildStatCard(
              'Properties',
              propertiesProvider.properties.length.toString(),
              Icons.home,
              Colors.blue,
              () => Navigator.pushNamed(context, '/properties'),
            ),
            _buildStatCard(
              'Units',
              unitsProvider.units.length.toString(),
              Icons.apartment,
              Colors.green,
              () => Navigator.pushNamed(context, '/units'),
            ),
            _buildStatCard(
              'Leases',
              leasesProvider.leases.length.toString(),
              Icons.description,
              Colors.orange,
              () => Navigator.pushNamed(context, '/leases'),
            ),
            _buildStatCard(
              'Maintenance',
              maintenanceProvider.maintenanceRequests.length.toString(),
              Icons.build,
              Colors.red,
              () => Navigator.pushNamed(context, '/maintenance'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Properties'),
            onTap: () => Navigator.pushNamed(context, '/properties'),
          ),
          ListTile(
            leading: Icon(Icons.apartment),
            title: Text('Units'),
            onTap: () => Navigator.pushNamed(context, '/units'),
          ),
          ListTile(
            leading: Icon(Icons.description),
            title: Text('Leases'),
            onTap: () => Navigator.pushNamed(context, '/leases'),
          ),
          ListTile(
            leading: Icon(Icons.build),
            title: Text('Maintenance'),
            onTap: () => Navigator.pushNamed(context, '/maintenance'),
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text('Agents'),
            onTap: () => Navigator.pushNamed(context, '/agents'),
          ),
          ListTile(
            leading: Icon(Icons.report),
            title: Text('Disputes'),
            onTap: () => Navigator.pushNamed(context, '/disputes'),
          ),
          ListTile(
            leading: Icon(Icons.message),
            title: Text('Messages'),
            onTap: () => Navigator.pushNamed(context, '/conversations'),
          ),
          ListTile(
            leading: Icon(Icons.subscriptions),
            title: Text('Plans'),
            onTap: () => Navigator.pushNamed(context, '/plans'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color,
                child: Icon(icon, color: Colors.white),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('$count items', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
}