import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/units_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../components/modern_components.dart';
import '../models/unit.dart';
import 'add_unit_screen.dart';
import 'edit_unit_screen.dart';
import 'unit_details_screen.dart';

class UnitsScreen extends StatefulWidget {
  @override
  _UnitsScreenState createState() => _UnitsScreenState();
}

class _UnitsScreenState extends State<UnitsScreen> {
  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token != null) {
      Provider.of<UnitsProvider>(context, listen: false).fetchUnits(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final unitsProvider = Provider.of<UnitsProvider>(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          if (unitsProvider.loading)
            const SliverFillRemaining(
              child: LoadingState(message: 'Loading units...'),
            )
          else if (unitsProvider.units.isEmpty)
            SliverFillRemaining(
              child: EmptyState(
                icon: '🏠',
                title: 'No Units Yet',
                message:
                    'Add your first unit to start managing your property inventory.',
                action: ModernButton(
                  text: 'Add Unit',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddUnitScreen()),
                    );
                  },
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(2),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final unit = unitsProvider.units[index];
                    return _buildUnitCard(unit);
                  },
                  childCount: unitsProvider.units.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: unitsProvider.units.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddUnitScreen()),
                );
              },
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildUnitCard(Unit unit) {
    return ModernCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UnitDetailsScreen(unit: unit),
          ),
        );
      },
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, size: 20),
          onPressed: () {
            _showUnitOptions(unit);
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
                      unit.unitLabel,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.home_outlined,
                          size: 16,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${unit.bedrooms} bed, ${unit.bathrooms} bath',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondaryColor,
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
                  gradient: unit.isAvailable
                      ? AppTheme.successGradient
                      : AppTheme.errorGradient,
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
                        Icons.attach_money,
                        color: AppTheme.primaryColor,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'KES ${unit.rentAmount.toStringAsFixed(0)}',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimaryColor,
                                ),
                      ),
                      Text(
                        'Rent',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        color: AppTheme.secondaryColor,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'KES ${unit.depositAmount.toStringAsFixed(0)}',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimaryColor,
                                ),
                      ),
                      Text(
                        'Deposit',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Icon(
                        Icons.square_foot,
                        color: AppTheme.accentColor,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        unit.sizeM2?.toStringAsFixed(0) ?? 'N/A',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimaryColor,
                                ),
                      ),
                      Text(
                        'm²',
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
                        builder: (context) => UnitDetailsScreen(unit: unit),
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
                        builder: (context) => EditUnitScreen(unit: unit),
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

  void _showUnitOptions(Unit unit) {
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
              'Unit Actions',
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
                    builder: (context) => UnitDetailsScreen(unit: unit),
                  ),
                );
              },
            ),
            _buildBottomSheetItem(
              icon: Icons.edit,
              title: 'Edit Unit',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditUnitScreen(unit: unit),
                  ),
                );
              },
            ),
            _buildBottomSheetItem(
              icon: Icons.delete,
              title: 'Delete Unit',
              color: AppTheme.errorColor,
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(unit);
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

  void _showDeleteConfirmation(Unit unit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Delete Unit',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        content: Text(
          'Are you sure you want to delete unit "${unit.unitLabel}"? This action cannot be undone.',
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
              await _deleteUnit(unit.id);
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

  Future<void> _deleteUnit(int id) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token!;
    await Provider.of<UnitsProvider>(context, listen: false)
        .deleteUnit(token, id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Unit deleted successfully'),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
