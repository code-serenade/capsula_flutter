import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../models/health_data_model.dart';
import 'data_collection_grid.dart';

class HealthDataCollectionSection extends StatelessWidget {
  const HealthDataCollectionSection({
    super.key,
    required this.onMethodTap,
  });

  final void Function(DataCollectionMethod method) onMethodTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.add_circle,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '数据采集',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DataCollectionGrid(onMethodTap: onMethodTap),
        ],
      ),
    );
  }
}
