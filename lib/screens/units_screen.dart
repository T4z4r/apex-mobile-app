import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/units_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../components/modern_components.dart';
import '../models/unit.dart';

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

    return CustomScrollView(
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
              message: 'Add your first unit to start managing your property inventory.',
              action: ModernButton(
                text: 'Add Unit',
                onPressed: () {
                  // TODO: Navigate to add unit screen
                },
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
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
    );
  }


  Widget _buildUnitCard(Unit unit) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to unit detail
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.apartment,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Text('View Details'),
                        value: 'view',
                      ),
                      PopupMenuItem(
                        child: const Text('Edit'),
                        value: 'edit',
                      ),
                      PopupMenuItem(
                        child: const Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
                        value: 'delete',
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'delete') {
                        _showDeleteConfirmation(unit);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                unit.unitLabel,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              _buildUnitInfo(Icons.payments, 'Rent', '\$${unit.rentAmount.toStringAsFixed(2)}'),
              const SizedBox(height: 6),
              _buildUnitInfo(Icons.account_balance, 'Deposit', '\$${unit.depositAmount.toStringAsFixed(2)}'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Available',
                  style: TextStyle(
                    color: AppTheme.successColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnitInfo(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: AppTheme.textSecondaryColor,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            '$label: $value',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
