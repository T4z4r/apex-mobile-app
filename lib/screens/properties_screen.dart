import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/properties_provider.dart';
import '../providers/auth_provider.dart';
import '../models/property.dart';

class PropertiesScreen extends StatefulWidget {
  @override
  _PropertiesScreenState createState() => _PropertiesScreenState();
}

class _PropertiesScreenState extends State<PropertiesScreen> {
  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token != null) {
      Provider.of<PropertiesProvider>(context, listen: false).fetchProperties(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final propertiesProvider = Provider.of<PropertiesProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Properties'),
      ),
      body: propertiesProvider.loading
          ? Center(child: CircularProgressIndicator())
          : propertiesProvider.properties.isEmpty
              ? Center(child: Text('No properties found'))
              : ListView.builder(
                  itemCount: propertiesProvider.properties.length,
                  itemBuilder: (ctx, i) {
                    final property = propertiesProvider.properties[i];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(property.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(property.address),
                            Text('Neighborhood: ${property.neighborhood}'),
                            if (property.units != null)
                              Text('Units: ${property.units!.length}'),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: Text('Edit'),
                              value: 'edit',
                            ),
                            PopupMenuItem(
                              child: Text('Delete'),
                              value: 'delete',
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'delete') {
                              _deleteProperty(property.id);
                            }
                          },
                        ),
                        onTap: () {
                          // TODO: Navigate to property detail
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // TODO: Navigate to add property screen
        },
      ),
    );
  }

  Future<void> _deleteProperty(int id) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token != null) {
      final success = await Provider.of<PropertiesProvider>(context, listen: false)
          .deleteProperty(token, id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Property deleted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete property')),
        );
      }
    }
  }
}