import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/units_provider.dart';
import '../providers/auth_provider.dart';
import '../models/unit.dart';
import '../theme/app_theme.dart';
import '../components/modern_components.dart';
import 'edit_unit_screen.dart';

class UnitDetailsScreen extends StatefulWidget {
  final Unit unit;

  const UnitDetailsScreen({Key? key, required this.unit}) : super(key: key);

  @override
  _UnitDetailsScreenState createState() => _UnitDetailsScreenState();
}

class _UnitDetailsScreenState extends State<UnitDetailsScreen> {
  Unit? _unit;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadUnitDetails();
  }

  Future<void> _loadUnitDetails() async {
    setState(() => _loading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token != null) {
      final unit = await Provider.of<UnitsProvider>(context, listen: false)
          .getUnit(token, widget.unit.id);
      setState(() {
        _unit = unit;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final unit = _unit ?? widget.unit;

    return Scaffold(
      appBar: AppBar(
        title: Text(unit.unitLabel),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.textPrimaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditUnitScreen(unit: unit),
                ),
              ).then((_) => _loadUnitDetails()); // Refresh after edit
            },
          ),
        ],
      ),
      body: _loading
          ? const LoadingState(message: 'Loading unit details...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Unit Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          unit.unitLabel,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                unit.isAvailable ? 'Available' : 'Occupied',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Unit Stats
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.king_bed,
                          value: '${unit.bedrooms}',
                          label: 'Bedrooms',
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.bathtub,
                          value: '${unit.bathrooms}',
                          label: 'Bathrooms',
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Financial Information
                  Text(
                    'Financial Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
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
                            const Icon(Icons.attach_money, color: AppTheme.primaryColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Monthly Rent: KES ${unit.rentAmount.toStringAsFixed(0)}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.account_balance_wallet, color: AppTheme.secondaryColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Security Deposit: KES ${unit.depositAmount.toStringAsFixed(0)}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                        if (unit.sizeM2 != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.square_foot, color: AppTheme.accentColor),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Size: ${unit.sizeM2} m²',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Photos
                  if (unit.photos != null && unit.photos!.isNotEmpty) ...[
                    Text(
                      'Photos',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: unit.photos!.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 120,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceColor,
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: NetworkImage(unit.photos![index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
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