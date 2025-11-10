import '../../models/health_asset.dart';

class HealthAssetDatabase {
  HealthAssetDatabase._();

  static final HealthAssetDatabase instance = HealthAssetDatabase._();

  Never _unsupported() => throw UnsupportedError(
        'Local database is not supported on this platform.',
      );

  Future<void> initialize() async => _unsupported();

  Future<int> insertAsset(HealthAsset asset) => _unsupported();

  Future<int> updateAsset(HealthAsset asset) => _unsupported();

  Future<int> deleteAsset(int id) => _unsupported();

  Future<HealthAsset?> getAsset(int id) => _unsupported();

  Future<List<HealthAsset>> fetchAssets({String? keyword, List<String>? tags}) => _unsupported();
}
