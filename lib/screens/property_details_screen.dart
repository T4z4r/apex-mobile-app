import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/properties_provider.dart';
import '../providers/auth_provider.dart';
import '../models/property.dart';
import '../theme/app_theme.dart';
import '../components/modern_components.dart';
import 'edit_property_screen.dart';

class PropertyDetailsScreen extends StatefulWidget {
  final Property property;

  const PropertyDetailsScreen({Key? key, required this.property})
      : super(key: key);

  @override
  _PropertyDetailsScreenState createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  Property? _property;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadPropertyDetails();
  }

  Future<void> _loadPropertyDetails() async {
    setState(() => _loading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token != null) {
      final property =
          await Provider.of<PropertiesProvider>(context, listen: false)
              .getProperty(token, widget.property.id);
      setState(() {
        _property = property;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final property = _property ?? widget.property;

    return Scaffold(
      appBar: AppBar(
        title: Text(property.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.textPrimaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditPropertyScreen(property: property),
                ),
              ).then((_) => _loadPropertyDetails()); // Refresh after edit
            },
          ),
        ],
      ),
      body: _loading
          ? const LoadingState(message: 'Loading property details...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Property Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                property.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
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
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              property.address,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Property Stats
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.apartment,
                          value: '${property.units?.length ?? 0}',
                          label: 'Units',
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.location_city,
                          value: property.neighborhood,
                          label: 'Neighborhood',
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description
                  if (property.description != null &&
                      property.description!.isNotEmpty) ...[
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      property.description!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Amenities
                  if (property.amenities != null &&
                      property.amenities!.isNotEmpty) ...[
                    Text(
                      'Amenities',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: property.amenities!
                          .map((amenity) => Chip(
                                label: Text(amenity),
                                backgroundColor:
                                    AppTheme.primaryColor.withOpacity(0.1),
                                labelStyle:
                                    TextStyle(color: AppTheme.primaryColor),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Location
                  Text(
                    'Location',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
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
                            const Icon(Icons.location_on,
                                color: AppTheme.primaryColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                property.address,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                        if (property.geoLat != null &&
                            property.geoLng != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.map,
                                  color: AppTheme.secondaryColor),
                              const SizedBox(width: 8),
                              Text(
                                '${property.geoLat}, ${property.geoLng}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppTheme.textSecondaryColor,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Units
                  if (property.units != null && property.units!.isNotEmpty) ...[
                    Text(
                      'Units',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 12),
                    ...property.units!.map((unit) => ModernCard(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.home,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            title: Text(unit.unitLabel),
                            subtitle: Text(
                                '${unit.bedrooms ?? 'N/A'} bed, ${unit.bathrooms ?? 'N/A'} bath'),
                            trailing: Text(
                              'KES ${unit.rentAmount.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        )),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimaryColor,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
          ),
        ],
      ),
    );
  }
}
