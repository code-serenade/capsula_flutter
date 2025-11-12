import '../models/health_asset.dart';
import '../models/health_data_model.dart';
import '../providers/health_data_view_provider.dart';

List<HealthAsset> applyHealthDataFilters(
  List<HealthAsset> assets,
  HealthDataViewState state,
) {
  Iterable<HealthAsset> filtered = assets;
  final now = DateTime.now();

  switch (state.selectedFilter) {
    case '7days':
      filtered = filtered.where(
        (asset) => asset.createdAt.isAfter(now.subtract(const Duration(days: 7))),
      );
      break;
    case 'checkup':
      filtered =
          filtered.where((asset) => asset.dataType == HealthDataType.checkup);
      break;
    case 'bp':
      filtered = filtered.where(
        (asset) => asset.dataType == HealthDataType.bloodPressure,
      );
      break;
    case 'bs':
      filtered = filtered.where(
        (asset) => asset.dataType == HealthDataType.bloodSugar,
      );
      break;
    case 'device':
      filtered =
          filtered.where((asset) => asset.dataSource == DataSource.device);
      break;
    default:
      break;
  }

  if (state.selectedTag != '全部标签') {
    filtered = filtered.where((asset) => asset.tags.contains(state.selectedTag));
  }

  return filtered.toList();
}
