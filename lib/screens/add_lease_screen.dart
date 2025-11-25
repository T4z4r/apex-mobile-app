import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/leases_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/units_provider.dart';
import '../models/unit.dart';
import '../theme/app_theme.dart';
import '../components/modern_components.dart';

class AddLeaseScreen extends StatefulWidget {
  @override
  _AddLeaseScreenState createState() => _AddLeaseScreenState();
}

class _AddLeaseScreenState extends State<AddLeaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _rentAmountController = TextEditingController();
  final _depositAmountController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String _paymentFrequency = 'monthly';
  Unit? _selectedUnit;
  bool _isLoading = false;

  final List<String> _paymentFrequencies = ['monthly', 'quarterly', 'annually'];

  @override
  Widget build(BuildContext context) {
    final unitsProvider = Provider.of<UnitsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Lease'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.textPrimaryColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Unit Selection
                Text(
                  'Select Unit',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimaryColor,
                      ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<Unit>(
                  value: _selectedUnit,
                  decoration: InputDecoration(
                    hintText: 'Choose a unit',
                    filled: true,
                    fillColor: AppTheme.surfaceColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.dividerColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.dividerColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  items: unitsProvider.units.where((unit) => unit.isAvailable).map((unit) {
                    return DropdownMenuItem<Unit>(
                      value: unit,
                      child: Text('${unit.unitLabel} - ${unit.property?.title ?? 'Property'}'),
                    );
                  }).toList(),
                  onChanged: (Unit? value) {
                    setState(() {
                      _selectedUnit = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a unit';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Lease Period
                Text(
                  'Lease Period',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimaryColor,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDatePicker(
                        label: 'Start Date',
                        selectedDate: _startDate,
                        onDateSelected: (date) {
                          setState(() => _startDate = date);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDatePicker(
                        label: 'End Date',
                        selectedDate: _endDate,
                        onDateSelected: (date) {
                          setState(() => _endDate = date);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Financial Information
                Text(
                  'Financial Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimaryColor,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ModernTextField(
                        label: 'Rent Amount',
                        hint: 'Monthly rent',
                        controller: _rentAmountController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Invalid amount';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ModernTextField(
                        label: 'Deposit Amount',
                        hint: 'Security deposit',
                        controller: _depositAmountController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Invalid amount';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Payment Frequency
                Text(
                  'Payment Frequency',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimaryColor,
                      ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _paymentFrequency,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.surfaceColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.dividerColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.dividerColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  items: _paymentFrequencies.map((frequency) {
                    return DropdownMenuItem<String>(
                      value: frequency,
                      child: Text(frequency.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      _paymentFrequency = value ?? 'monthly';
                    });
                  },
                ),
                const SizedBox(height: 32),
                ModernButton(
                  text: 'Create Lease',
                  onPressed: _addLease,
                  isLoading: _isLoading,
                  height: 56,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? selectedDate,
    required Function(DateTime) onDateSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimaryColor,
              ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
            );
            if (pickedDate != null) {
              onDateSelected(pickedDate);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              border: Border.all(color: AppTheme.dividerColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                        : 'Select date',
                    style: TextStyle(
                      color: selectedDate != null
                          ? AppTheme.textPrimaryColor
                          : AppTheme.textHintColor,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: AppTheme.textSecondaryColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _addLease() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedUnit == null || _startDate == null || _endDate == null) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication error')),
      );
      setState(() => _isLoading = false);
      return;
    }

    final leaseData = {
      'start_date': _startDate!.toIso8601String().split('T')[0],
      'end_date': _endDate!.toIso8601String().split('T')[0],
      'rent_amount': double.parse(_rentAmountController.text),
      'deposit_amount': double.parse(_depositAmountController.text),
      'payment_frequency': _paymentFrequency,
    };

    final success = await Provider.of<LeasesProvider>(context, listen: false)
        .requestLease(token, _selectedUnit!.id, leaseData);

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Lease created successfully'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to create lease'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _rentAmountController.dispose();
    _depositAmountController.dispose();
    super.dispose();
  }
}