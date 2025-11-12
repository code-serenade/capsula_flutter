import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class EmptyHealthDataState extends StatelessWidget {
  const EmptyHealthDataState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.document, size: 48, color: theme.colorScheme.primary),
          const SizedBox(height: 12),
          const Text('还没有健康数据'),
          const SizedBox(height: 8),
          Text(
            '通过上方的采集方式添加第一条记录吧',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
