import 'package:flutter/material.dart';
import '../models/integration.dart';
import '../utils/theme.dart';

class IntegrationChip extends StatelessWidget {
  final Integration integration;

  const IntegrationChip({super.key, required this.integration});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: integration.isConnected
            ? AppTheme.success.withOpacity(0.1)
            : AppTheme.bgGlass,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: integration.isConnected
              ? AppTheme.success.withOpacity(0.3)
              : AppTheme.primaryCyan.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: integration.isConnected
                  ? AppTheme.success
                  : AppTheme.textMuted,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            integration.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: integration.isConnected
                  ? AppTheme.success
                  : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
