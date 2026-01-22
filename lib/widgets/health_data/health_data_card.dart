import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:capsula_flutter/models/health_data_model.dart';
import 'package:capsula_flutter/theme/health_data_colors.dart';

/// 健康数据卡片组件
class HealthDataCard extends StatelessWidget {
  final HealthDataRecord record;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onView;

  const HealthDataCard({
    super.key,
    required this.record,
    this.onTap,
    this.onEdit,
    this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, theme),
              const SizedBox(height: 12),
              _buildContent(theme),
              const SizedBox(height: 12),
              _buildMetadata(theme),
              if (record.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildTags(theme),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.getHealthDataBackgroundColor(record.type),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            record.typeDisplayName,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.getHealthDataColor(record.type),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Row(
          children: [
            if (onEdit != null)
              IconButton(
                icon: const Icon(Iconsax.edit, size: 18),
                onPressed: onEdit,
              ),
            if (onView != null)
              IconButton(
                icon: const Icon(Iconsax.eye, size: 18),
                onPressed: onView,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildContent(ThemeData theme) {
    return Text(
      record.content,
      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
    );
  }

  Widget _buildMetadata(ThemeData theme) {
    return Row(
      children: [
        Icon(
          Iconsax.calendar,
          size: 14,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          _formatDateTime(record.dateTime),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 12),
        Icon(
          _getIconForSource(record.source),
          size: 14,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            record.notes ?? record.sourceDisplayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTags(ThemeData theme) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: record.tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            tag.name,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontSize: 11,
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _getIconForSource(DataSource source) {
    switch (source) {
      case DataSource.camera:
        return Iconsax.camera;
      case DataSource.upload:
        return Iconsax.document_upload;
      case DataSource.manual:
        return Iconsax.keyboard;
      case DataSource.device:
        return Iconsax.bluetooth;
      case DataSource.voice:
        return Iconsax.microphone;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
