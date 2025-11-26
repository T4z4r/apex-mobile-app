import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../components/modern_components.dart';

class AdminDisputesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: EmptyState(
        icon: '⚖️',
        title: 'Dispute Management',
        message: 'Manage lease disputes and resolutions.\nComing Soon!',
        action: ModernButton(
          text: 'Back to Dashboard',
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
}