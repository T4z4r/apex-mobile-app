import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/properties_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../components/modern_components.dart';

class AddPropertyScreen extends StatefulWidget {
  @override
  _AddPropertyScreenState createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _geoLatController = TextEditingController();
  final _geoLngController = TextEditingController();
  final _amenitiesController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Property'),
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
                  label: 'Property Title',
                  hint: 'Enter property title',
                  controller: _titleController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter property title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ModernTextField(
                  label: 'Description',
                  hint: 'Enter property description',
                  controller: _descriptionController,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                ModernTextField(
                  label: 'Address',
                  hint: 'Enter property address',
                  controller: _addressController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter property address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ModernTextField(
                  label: 'Neighborhood',
                  hint: 'Enter neighborhood',
                  controller: _neighborhoodController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter neighborhood';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ModernTextField(
                        label: 'Latitude',
                        hint: 'e.g. -1.2863890',
                        controller: _geoLatController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ModernTextField(
                        label: 'Longitude',
                        hint: 'e.g. 36.8172230',
                        controller: _geoLngController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ModernTextField(
                  label: 'Amenities',
                  hint: 'Enter amenities (comma separated) e.g. gym, pool, parking, security',
                  controller: _amenitiesController,
                ),
                const SizedBox(height: 32),
                ModernButton(
                  text: 'Add Property',
                  onPressed: _addProperty,
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

  Future<void> _addProperty() async {
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

    // Prepare amenities as list
    List<String> amenities = [];
    if (_amenitiesController.text.isNotEmpty) {
      amenities = _amenitiesController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    final propertyData = {
      'title': _titleController.text,
      'description': _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
      'address': _addressController.text,
      'neighborhood': _neighborhoodController.text,
      'geo_lat': _geoLatController.text.isNotEmpty ? double.parse(_geoLatController.text) : null,
      'geo_lng': _geoLngController.text.isNotEmpty ? double.parse(_geoLngController.text) : null,
      'amenities': amenities,
    };

    final success = await Provider.of<PropertiesProvider>(context, listen: false)
        .createProperty(token, propertyData);

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Property added successfully'),
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
          content: const Text('Failed to add property'),
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
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _neighborhoodController.dispose();
    _geoLatController.dispose();
    _geoLngController.dispose();
    _amenitiesController.dispose();
    super.dispose();
  }
}