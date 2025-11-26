import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/units_provider.dart';
import '../providers/auth_provider.dart';
import '../models/unit.dart';
import '../theme/app_theme.dart';
import '../components/modern_components.dart';

class EditUnitScreen extends StatefulWidget {
  final Unit unit;

  const EditUnitScreen({Key? key, required this.unit}) : super(key: key);

  @override
  _EditUnitScreenState createState() => _EditUnitScreenState();
}

class _EditUnitScreenState extends State<EditUnitScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _unitLabelController;
  late final TextEditingController _bedroomsController;
  late final TextEditingController _bathroomsController;
  late final TextEditingController _sizeM2Controller;
  late final TextEditingController _rentAmountController;
  late final TextEditingController _depositAmountController;
  late final TextEditingController _photosController;
  late bool _isAvailable;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _unitLabelController = TextEditingController(text: widget.unit.unitLabel);
    _bedroomsController = TextEditingController(text: widget.unit.bedrooms?.toString());
    _bathroomsController = TextEditingController(text: widget.unit.bathrooms?.toString());
    _sizeM2Controller = TextEditingController(text: widget.unit.sizeM2?.toString());
    _rentAmountController = TextEditingController(text: widget.unit.rentAmount.toString());
    _depositAmountController = TextEditingController(text: widget.unit.depositAmount?.toString());
    _photosController = TextEditingController(text: widget.unit.photos?.join(', '));
    _isAvailable = widget.unit.isAvailable;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Unit'),
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
                ModernTextField(
                  label: 'Unit Label',
                  hint: 'e.g. A101, B202',
                  controller: _unitLabelController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter unit label';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ModernTextField(
                        label: 'Bedrooms',
                        hint: 'Number of bedrooms',
                        controller: _bedroomsController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
                            return 'Invalid number';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ModernTextField(
                        label: 'Bathrooms',
                        hint: 'Number of bathrooms',
                        controller: _bathroomsController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
                            return 'Invalid number';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ModernTextField(
                  label: 'Size (m²)',
                  hint: 'Size in square meters',
                  controller: _sizeM2Controller,
                  keyboardType: TextInputType.number,
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
                          if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
                            return 'Invalid amount';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ModernTextField(
                  label: 'Photos',
                  hint: 'Photo URLs (comma separated)',
                  controller: _photosController,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Available for rent',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textPrimaryColor,
                          ),
                    ),
                    const Spacer(),
                    Switch(
                      value: _isAvailable,
                      onChanged: (value) {
                        setState(() {
                          _isAvailable = value;
                        });
                      },
                      activeColor: AppTheme.primaryColor,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                ModernButton(
                  text: 'Update Unit',
                  onPressed: _updateUnit,
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

  Future<void> _updateUnit() async {
    if (!_formKey.currentState!.validate()) return;

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

    // Prepare photos as list
    List<String> photos = [];
    if (_photosController.text.isNotEmpty) {
      photos = _photosController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    final unitData = {
      'unit_label': _unitLabelController.text,
      'bedrooms': _bedroomsController.text.isNotEmpty ? int.parse(_bedroomsController.text) : null,
      'bathrooms': _bathroomsController.text.isNotEmpty ? int.parse(_bathroomsController.text) : null,
      'size_m2': _sizeM2Controller.text.isNotEmpty ? double.parse(_sizeM2Controller.text) : null,
      'rent_amount': double.parse(_rentAmountController.text),
      'deposit_amount': _depositAmountController.text.isNotEmpty ? double.parse(_depositAmountController.text) : null,
      'is_available': _isAvailable ? 1 : 0,
      'photos': photos,
    };

    final success = await Provider.of<UnitsProvider>(context, listen: false)
        .updateUnit(token, widget.unit.id, unitData);

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Unit updated successfully'),
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
          content: const Text('Failed to update unit'),
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
    _unitLabelController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _sizeM2Controller.dispose();
    _rentAmountController.dispose();
    _depositAmountController.dispose();
    _photosController.dispose();
    super.dispose();
  }
}