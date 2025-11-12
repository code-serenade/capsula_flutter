import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../models/health_asset.dart';
import '../../providers/health_data_view/health_data_view_provider.dart';
import '../../services/health_asset_filter_service.dart';
import '../../widgets/health_data/empty_health_data_state.dart';
import 'health_data_card.dart';

class HealthDataAssetList extends StatelessWidget {
  const HealthDataAssetList({
    super.key,
    required this.assets,
    required this.viewState,
    required this.onShowDetails,
    required this.onPreview,
    required this.onRetry,
  });

  final AsyncValue<List<HealthAsset>> assets;
  final HealthDataViewState viewState;
  final void Function(HealthAsset asset) onShowDetails;
  final void Function(HealthAsset asset) onPreview;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return assets.when(
      data: (items) {
        final filtered = applyHealthDataFilters(items, viewState);
        if (filtered.isEmpty) {
          return const SliverToBoxAdapter(child: EmptyHealthDataState());
        }
        final entries = filtered
            .map((asset) => (asset: asset, record: asset.toRecord()))
            .toList();

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final entry = entries[index];
                return HealthDataCard(
                  record: entry.record,
                  onTap: () => onShowDetails(entry.asset),
                  onView: () => onPreview(entry.asset),
                );
              },
              childCount: entries.length,
            ),
          ),
        );
      },
      loading: () => const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => SliverFillRemaining(
        hasScrollBody: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 32),
            const SizedBox(height: 12),
            const Text('数据加载失败'),
            const SizedBox(height: 8),
            Text('$error', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('重试')),
          ],
        ),
      ),
    );
  }
}
