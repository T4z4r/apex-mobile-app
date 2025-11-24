import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/properties_provider.dart';
import '../providers/auth_provider.dart';
import '../models/property.dart';
import '../theme/app_theme.dart';
import '../components/modern_components.dart';
import 'add_property_screen.dart';
import 'edit_property_screen.dart';
import 'property_details_screen.dart';

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
      Provider.of<PropertiesProvider>(context, listen: false)
          .fetchProperties(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final propertiesProvider = Provider.of<PropertiesProvider>(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          if (propertiesProvider.loading)
            const SliverFillRemaining(
              child: LoadingState(message: 'Loading properties...'),
            )
          else if (propertiesProvider.properties.isEmpty)
            SliverFillRemaining(
              child: EmptyState(
                icon: '🏢',
                title: 'No Properties Yet',
                message:
                    'Start by adding your first property to manage your real estate portfolio.',
                action: ModernButton(
                  text: 'Add Property',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddPropertyScreen()),
                    );
                  },
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final property = propertiesProvider.properties[index];
                    return _buildPropertyCard(property);
                  },
                  childCount: propertiesProvider.properties.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: propertiesProvider.properties.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddPropertyScreen()),
                );
              },
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildPropertyCard(Property property) {
    return ModernCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PropertyDetailsScreen(property: property),
          ),
        );
      },
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, size: 20),
          onPressed: () {
            _showPropertyOptions(property);
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
                      property.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            property.address,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                  gradient: AppTheme.successGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Active',
                  style: TextStyle(
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
                        Icons.apartment,
                        color: AppTheme.primaryColor,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${property.units?.length ?? 0}',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimaryColor,
                                ),
                      ),
                      Text(
                        'Units',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Icon(
                        Icons.location_city,
                        color: AppTheme.secondaryColor,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        property.neighborhood,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimaryColor,
                                ),
                      ),
                      Text(
                        'Neighborhood',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Icon(
                        Icons.home,
                        color: AppTheme.accentColor,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Available',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimaryColor,
                                ),
                      ),
                      Text(
                        'Status',
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PropertyDetailsScreen(property: property),
                      ),
                    );
                  },
                  isOutlined: true,
                  height: 40,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ModernButton(
                  text: 'Edit',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditPropertyScreen(property: property),
                      ),
                    );
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

  void _showPropertyOptions(Property property) {
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
              'Property Actions',
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PropertyDetailsScreen(property: property),
                  ),
                );
              },
            ),
            _buildBottomSheetItem(
              icon: Icons.edit,
              title: 'Edit Property',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditPropertyScreen(property: property),
                  ),
                );
              },
            ),
            _buildBottomSheetItem(
              icon: Icons.add_business,
              title: 'Add Unit',
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to add unit
              },
            ),
            _buildBottomSheetItem(
              icon: Icons.delete,
              title: 'Delete Property',
              color: AppTheme.errorColor,
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(property);
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

  void _showDeleteConfirmation(Property property) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Delete Property',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        content: Text(
          'Are you sure you want to delete "${property.title}"? This action cannot be undone.',
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
              await _deleteProperty(property.id);
            },
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

  Future<void> _deleteProperty(int id) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token != null) {
      final success =
          await Provider.of<PropertiesProvider>(context, listen: false)
              .deleteProperty(token, id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Property deleted successfully'),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to delete property'),
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
}
