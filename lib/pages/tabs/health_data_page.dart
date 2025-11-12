import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import 'package:capsula_flutter/providers/health_asset/health_asset_provider.dart';
import 'package:capsula_flutter/providers/health_data_view/health_data_view_provider.dart';
import 'package:capsula_flutter/helpers/health_data/detail_controller.dart';
import 'package:capsula_flutter/helpers/health_data/import_controller.dart';
import 'package:capsula_flutter/helpers/health_data/search_controller.dart';
import 'package:capsula_flutter/widgets/health_data/health_data_asset_list.dart';
import 'package:capsula_flutter/widgets/health_data/health_data_collection_section.dart';
import 'package:capsula_flutter/widgets/health_data/health_data_management_section.dart';
import 'package:capsula_flutter/widgets/health_data/page_header.dart';

@RoutePage()
class HealthDataPage extends ConsumerWidget {
  const HealthDataPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewState = ref.watch(healthDataViewProvider);
    final assetsState = ref.watch(
      healthAssetsProvider(query: viewState.searchKeyword),
    );
    final importController = ref.read(healthDataImportControllerProvider);
    final searchController = ref.read(healthDataSearchControllerProvider);
    final detailController = ref.read(healthAssetDetailControllerProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: PageHeader(title: '我的健康数据', subtitle: '全方位记录和管理您的健康信息'),
          ),
          SliverToBoxAdapter(
            child: HealthDataCollectionSection(
              onMethodTap: (method) =>
                  importController.startImport(context, method: method),
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
              onSearchTap: () => searchController.startSearch(context),
              onToggleView: () =>
                  ref.read(healthDataViewProvider.notifier).toggleViewMode(),
            ),
          ),
          HealthDataAssetList(
            assets: assetsState,
            viewState: viewState,
            onShowDetails: (asset) =>
                detailController.showDetails(context, asset),
            onPreview: (asset) => detailController.previewAsset(context, asset),
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
        onPressed: () => importController.startImport(context),
        icon: const Icon(Iconsax.add),
        label: const Text('添加数据'),
      ),
    );
  }
}
