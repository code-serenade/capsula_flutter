import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../../models/health_asset.dart';
import '../../models/health_data_model.dart';
import '../../providers/health_asset_provider.dart';
import '../../widgets/health_data/data_collection_grid.dart';
import '../../widgets/health_data/data_import_dialog.dart';
import '../../widgets/health_data/health_data_card.dart';
import '../../widgets/health_data/page_header.dart';
import '../../widgets/health_data/quick_filters.dart';
import '../../widgets/health_data/tag_filters.dart';

@RoutePage()
class HealthDataPage extends ConsumerStatefulWidget {
  const HealthDataPage({super.key});

  @override
  ConsumerState<HealthDataPage> createState() => _HealthDataPageState();
}

class _HealthDataPageState extends ConsumerState<HealthDataPage> {
  String _selectedFilter = 'all';
  String _selectedTag = '全部标签';
  String _searchKeyword = '';
  bool _isListView = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final assetState = ref.watch(healthAssetsProvider(query: _searchKeyword));

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
            child: Padding(
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
                  DataCollectionGrid(
                    onMethodTap: (method) => _showImportDialog(method: method),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
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
                            onPressed: _showSearchDialog,
                          ),
                          IconButton(
                            icon: Icon(
                              _isListView ? Iconsax.element_3 : Iconsax.menu,
                            ),
                            onPressed: () {
                              setState(() {
                                _isListView = !_isListView;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  QuickFilters(
                    selectedFilter: _selectedFilter,
                    onFilterSelected: (filter) {
                      setState(() => _selectedFilter = filter);
                    },
                  ),
                  const SizedBox(height: 16),
                  TagFilters(
                    selectedTag: _selectedTag,
                    onTagSelected: (tag) {
                      setState(() => _selectedTag = tag);
                    },
                  ),
                ],
              ),
            ),
          ),
          _buildAssetSliver(assetState),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showImportDialog,
        icon: const Icon(Iconsax.add),
        label: const Text('添加数据'),
      ),
    );
  }

  Widget _buildAssetSliver(AsyncValue<List<HealthAsset>> state) {
    return state.when(
      data: (assets) {
        final filteredAssets = _applyFilters(assets);
        if (filteredAssets.isEmpty) {
          return const SliverToBoxAdapter(
            child: _EmptyHealthDataState(),
          );
        }
        final entries = filteredAssets
            .map(
              (asset) => (asset: asset, record: asset.toRecord()),
            )
            .toList();

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final entry = entries[index];
                return HealthDataCard(
                  record: entry.record,
                  onTap: () => _showAssetDetails(entry.asset),
                  onView: () => _showAssetDetails(entry.asset),
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
            const Icon(Iconsax.warning_2, size: 32),
            const SizedBox(height: 12),
            const Text('数据加载失败'),
            const SizedBox(height: 8),
            Text('$error', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => ref
                  .read(healthAssetsProvider(query: _searchKeyword).notifier)
                  .refresh(),
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  List<HealthAsset> _applyFilters(List<HealthAsset> assets) {
    Iterable<HealthAsset> filtered = assets;
    final now = DateTime.now();
    switch (_selectedFilter) {
      case '7days':
        filtered = filtered.where(
          (asset) => asset.createdAt.isAfter(now.subtract(const Duration(days: 7))),
        );
        break;
      case 'checkup':
        filtered = filtered.where((asset) => asset.dataType == HealthDataType.checkup);
        break;
      case 'bp':
        filtered = filtered.where((asset) => asset.dataType == HealthDataType.bloodPressure);
        break;
      case 'bs':
        filtered = filtered.where((asset) => asset.dataType == HealthDataType.bloodSugar);
        break;
      case 'device':
        filtered = filtered.where((asset) => asset.dataSource == DataSource.device);
        break;
      default:
        break;
    }

    if (_selectedTag != '全部标签') {
      filtered = filtered.where((asset) => asset.tags.contains(_selectedTag));
    }

    return filtered.toList();
  }

  void _showImportDialog({DataCollectionMethod? method}) {
    DataImportDialog.show(
      context,
      method: method,
      onSubmit: (draft) async {
        try {
          await ref
              .read(healthAssetsProvider(query: _searchKeyword).notifier)
              .addManualAsset(draft);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('健康数据已保存到本地沙盒')),
            );
          }
        } catch (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('保存失败: $error')),
            );
          }
          rethrow;
        }
      },
    );
  }

  Future<void> _showSearchDialog() async {
    final controller = TextEditingController(text: _searchKeyword);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('搜索健康数据'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: '输入关键字'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        _searchKeyword = result;
      });
    }
  }

  void _showAssetDetails(HealthAsset asset) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                asset.filename,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _DetailRow(label: '来源', value: asset.dataSource.displayName),
              _DetailRow(label: '类型', value: asset.dataType.displayName),
              _DetailRow(label: '更新时间', value: _formatDateTime(asset.updatedAt)),
              _DetailRow(label: '文件路径', value: asset.path),
              if (asset.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: asset.tags
                      .map((tag) => Chip(
                            label: Text(tag),
                            backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                          ))
                      .toList(),
                ),
              ],
              if (asset.note?.isNotEmpty == true) ...[
                const SizedBox(height: 12),
                Text(
                  asset.note!,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime value) {
    final date = '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
    final time = '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
    return '$date $time';
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHealthDataState extends StatelessWidget {
  const _EmptyHealthDataState();

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
