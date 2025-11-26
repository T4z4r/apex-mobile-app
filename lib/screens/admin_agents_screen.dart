import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../components/modern_components.dart';

class AdminAgentsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: EmptyState(
        icon: '👔',
        title: 'Agent Management',
        message: 'Manage real estate agents and their verifications.\nComing Soon!',
        action: ModernButton(
          text: 'Back to Dashboard',
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
}