import 'dart:io';

import 'package:capsula_flutter/models/health_asset.dart';
import 'package:capsula_flutter/providers/sandbox/sandbox_provider.dart';
import 'package:capsula_flutter/helpers/health_asset/health_asset_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'health_asset_provider.g.dart';

@riverpod
HealthAssetRepository healthAssetRepository(Ref ref) {
  final sandbox = ref.watch(sandboxServiceProvider);
  return HealthAssetRepository(sandboxService: sandbox);
}

@riverpod
class HealthAssets extends _$HealthAssets {
  @override
  Future<List<HealthAsset>> build({
    String query = '',
    List<String> tags = const [],
  }) async {
    final repo = ref.watch(healthAssetRepositoryProvider);
    return repo.fetchAssets(
      keyword: query.isEmpty ? null : query,
      tags: tags.isEmpty ? null : tags,
    );
  }

  Future<void> refresh() async {
    final repo = ref.read(healthAssetRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => repo.fetchAssets(
        keyword: query.isEmpty ? null : query,
        tags: tags.isEmpty ? null : tags,
      ),
    );
  }

  Future<void> addManualAsset(HealthAssetDraft draft) async {
    final repo = ref.read(healthAssetRepositoryProvider);
    final newAsset = await repo.createManualEntry(draft);
    state = state.whenData((value) => [newAsset, ...value]);
  }

  Future<void> addFileAsset({
    required File file,
    required HealthAssetDraft draft,
  }) async {
    final repo = ref.read(healthAssetRepositoryProvider);
    final newAsset = await repo.importFile(
      file,
      dataSource: draft.dataSource,
      dataType: draft.dataType,
      tags: draft.normalizedTags,
      note: draft.note,
      metadata: {
        ...?draft.metadata,
        if (draft.content?.isNotEmpty == true) 'content': draft.content,
        'displayTitle': draft.title,
      },
      displayName: draft.title,
    );
    state = state.whenData((value) => [newAsset, ...value]);
  }

  Future<void> deleteAsset(int id) async {
    final repo = ref.read(healthAssetRepositoryProvider);
    await repo.deleteAsset(id);
    state = state.whenData(
      (value) => value.where((asset) => asset.id != id).toList(),
    );
  }
}
