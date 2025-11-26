import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../components/modern_components.dart';

class AdminPlansScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: EmptyState(
        icon: '📊',
        title: 'Plan Management',
        message: 'Manage subscription plans and pricing.\nComing Soon!',
        action: ModernButton(
          text: 'Back to Dashboard',
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
}