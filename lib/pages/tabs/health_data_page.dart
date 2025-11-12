import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../../providers/health_asset_provider.dart';
import '../../providers/health_data_view_provider.dart';
import '../../services/health_data_actions.dart';
import '../../widgets/health_data/health_data_asset_list.dart';
import '../../widgets/health_data/health_data_collection_section.dart';
import '../../widgets/health_data/health_data_management_section.dart';
import '../../widgets/health_data/page_header.dart';

@RoutePage()
class HealthDataPage extends ConsumerWidget {
  const HealthDataPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewState = ref.watch(healthDataViewProvider);
    final assetsState =
        ref.watch(healthAssetsProvider(query: viewState.searchKeyword));
    final actions = HealthDataActions(context: context, ref: ref);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: PageHeader(
              title: '我的健康数据',
              subtitle: '全方位记录和管理您的健康信息',
            ),
          ),
          SliverToBoxAdapter(
            child: HealthDataCollectionSection(
              onMethodTap: (method) => actions.startImport(method: method),
            ),
          ),
          SliverToBoxAdapter(
            child: HealthDataManagementSection(
              state: viewState,
              onFilterSelected: (filter) => ref
                  .read(healthDataViewProvider.notifier)
                  .selectFilter(filter),
              onTagSelected: (tag) =>
                  ref.read(healthDataViewProvider.notifier).selectTag(tag),
              onSearchTap: actions.startSearch,
              onToggleView: () => ref
                  .read(healthDataViewProvider.notifier)
                  .toggleViewMode(),
            ),
          ),
          HealthDataAssetList(
            assets: assetsState,
            viewState: viewState,
            onShowDetails: actions.showAssetDetails,
            onPreview: actions.previewAsset,
            onRetry: () => ref
                .read(
                  healthAssetsProvider(query: viewState.searchKeyword).notifier,
                )
                .refresh(),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => actions.startImport(),
        icon: const Icon(Iconsax.add),
        label: const Text('添加数据'),
      ),
    );
  }
}
