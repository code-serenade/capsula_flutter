import 'package:capsula_flutter/models/health_asset.dart';
import 'package:capsula_flutter/models/health_data_model.dart';
import 'package:capsula_flutter/providers/health_data_view/health_data_view_provider.dart';
import 'package:capsula_flutter/helpers/health_asset/health_asset_filter_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('applyHealthDataFilters', () {
    final now = DateTime.now();
    final assets = [
      _buildAsset(
        filename: 'bp_recent.pdf',
        dataType: HealthDataType.bloodPressure,
        dataSource: DataSource.device,
        createdAt: now.subtract(const Duration(days: 2)),
        tags: const ['近7天', '血压'],
      ),
      _buildAsset(
        filename: 'checkup.pdf',
        dataType: HealthDataType.checkup,
        dataSource: DataSource.manual,
        createdAt: now.subtract(const Duration(days: 30)),
        tags: const ['体检'],
      ),
      _buildAsset(
        filename: 'blood_sugar.txt',
        dataType: HealthDataType.bloodSugar,
        dataSource: DataSource.manual,
        createdAt: now.subtract(const Duration(days: 1)),
        tags: const ['血糖'],
      ),
    ];

    test('returns all assets when filter is default', () {
      final state = const HealthDataViewState();
      final result = applyHealthDataFilters(assets, state);

      expect(result, hasLength(3));
    });

    test('filters by predefined type filters', () {
      final bpState = const HealthDataViewState(selectedFilter: 'bp');
      final bpResult = applyHealthDataFilters(assets, bpState);
      expect(bpResult.map((a) => a.filename), ['bp_recent.pdf']);

      final checkupState = const HealthDataViewState(selectedFilter: 'checkup');
      final checkupResult = applyHealthDataFilters(assets, checkupState);
      expect(checkupResult.map((a) => a.filename), ['checkup.pdf']);
    });

    test('filters by data source and tags', () {
      final deviceState = const HealthDataViewState(selectedFilter: 'device');
      final deviceResult = applyHealthDataFilters(assets, deviceState);
      expect(deviceResult.map((a) => a.filename), ['bp_recent.pdf']);

      final tagState = const HealthDataViewState(selectedTag: '血糖');
      final tagResult = applyHealthDataFilters(assets, tagState);
      expect(tagResult.map((a) => a.filename), ['blood_sugar.txt']);
    });

    test('filters recent assets when using 7days filter', () {
      final state = const HealthDataViewState(selectedFilter: '7days');
      final result = applyHealthDataFilters(assets, state);

      expect(result, hasLength(2));
      expect(
        result.map((a) => a.filename),
        containsAll(['bp_recent.pdf', 'blood_sugar.txt']),
      );
    });
  });
}

HealthAsset _buildAsset({
  required String filename,
  required HealthDataType dataType,
  required DataSource dataSource,
  required DateTime createdAt,
  List<String> tags = const [],
}) {
  return HealthAsset(
    filename: filename,
    path: '/$filename',
    dataSource: dataSource,
    dataType: dataType,
    tags: tags,
    createdAt: createdAt,
    updatedAt: createdAt,
  );
}
