import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../providers/health_data_view/health_data_view_provider.dart';
import 'quick_filters.dart';
import 'tag_filters.dart';

class HealthDataManagementSection extends StatelessWidget {
  const HealthDataManagementSection({
    super.key,
    required this.state,
    required this.onFilterSelected,
    required this.onTagSelected,
    required this.onSearchTap,
    required this.onToggleView,
  });

  final HealthDataViewState state;
  final ValueChanged<String> onFilterSelected;
  final ValueChanged<String> onTagSelected;
  final VoidCallback onSearchTap;
  final VoidCallback onToggleView;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Iconsax.menu_board,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '数据管理',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Iconsax.search_normal),
                    onPressed: onSearchTap,
                  ),
                  IconButton(
                    icon: Icon(
                      state.isListView ? Iconsax.element_3 : Iconsax.menu,
                    ),
                    onPressed: onToggleView,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          QuickFilters(
            selectedFilter: state.selectedFilter,
            onFilterSelected: onFilterSelected,
          ),
          const SizedBox(height: 16),
          TagFilters(
            selectedTag: state.selectedTag,
            onTagSelected: onTagSelected,
          ),
        ],
      ),
    );
  }
}
