import 'package:json_annotation/json_annotation.dart';

part 'health_data_model.g.dart';

/// 健康数据类型枚举
enum HealthDataType {
  @JsonValue('blood_pressure')
  bloodPressure,
  @JsonValue('blood_sugar')
  bloodSugar,
  @JsonValue('heart_rate')
  heartRate,
  @JsonValue('checkup')
  checkup,
  @JsonValue('medication')
  medication,
  @JsonValue('other')
  other,
}

/// 数据来源枚举
enum DataSource {
  @JsonValue('camera')
  camera,
  @JsonValue('upload')
  upload,
  @JsonValue('manual')
  manual,
  @JsonValue('device')
  device,
  @JsonValue('voice')
  voice,
}

/// 健康数据标签模型
@JsonSerializable()
class HealthTag {
  final String id;
  final String name;
  final String? color;

  const HealthTag({
    required this.id,
    required this.name,
    this.color,
  });

  factory HealthTag.fromJson(Map<String, dynamic> json) =>
      _$HealthTagFromJson(json);
  Map<String, dynamic> toJson() => _$HealthTagToJson(this);
}

/// 健康数据记录模型
@JsonSerializable()
class HealthDataRecord {
  final String id;
  final HealthDataType type;
  final String content;
  final DateTime dateTime;
  final DataSource source;
  final List<HealthTag> tags;
  final String? notes;
  final Map<String, dynamic>? metadata;

  const HealthDataRecord({
    required this.id,
    required this.type,
    required this.content,
    required this.dateTime,
    required this.source,
    required this.tags,
    this.notes,
    this.metadata,
  });

  factory HealthDataRecord.fromJson(Map<String, dynamic> json) =>
      _$HealthDataRecordFromJson(json);
  Map<String, dynamic> toJson() => _$HealthDataRecordToJson(this);

  /// 获取类型显示名称
  String get typeDisplayName {
    return type.displayName;
  }

  /// 获取来源显示名称
  String get sourceDisplayName {
    return source.displayName;
  }
}

/// 数据采集方式
class DataCollectionMethod {
  final String id;
  final String title;
  final String description;
  final String icon;
  final DataSource source;

  const DataCollectionMethod({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.source,
  });

  static const List<DataCollectionMethod> methods = [
    DataCollectionMethod(
      id: 'camera',
      title: '拍照录入',
      description: '拍摄化验单、报告等',
      icon: 'camera',
      source: DataSource.camera,
    ),
    DataCollectionMethod(
      id: 'upload',
      title: '上传文件',
      description: '上传PDF、图片等文件',
      icon: 'upload',
      source: DataSource.upload,
    ),
    DataCollectionMethod(
      id: 'manual',
      title: '手动录入',
      description: '填写血压、血糖等数据',
      icon: 'keyboard',
      source: DataSource.manual,
    ),
    DataCollectionMethod(
      id: 'device',
      title: '设备同步',
      description: '连接可穿戴设备',
      icon: 'bluetooth',
      source: DataSource.device,
    ),
    DataCollectionMethod(
      id: 'voice',
      title: '语音录入',
      description: '语音描述健康数据',
      icon: 'microphone',
      source: DataSource.voice,
    ),
  ];
}

extension DataSourceDisplayName on DataSource {
  String get displayName {
    switch (this) {
      case DataSource.camera:
        return '拍照';
      case DataSource.upload:
        return '文件上传';
      case DataSource.manual:
        return '手动输入';
      case DataSource.device:
        return '设备同步';
      case DataSource.voice:
        return '语音录入';
    }
  }
}

extension HealthDataTypeDisplayName on HealthDataType {
  String get displayName {
    switch (this) {
      case HealthDataType.bloodPressure:
        return '血压';
      case HealthDataType.bloodSugar:
        return '血糖';
      case HealthDataType.heartRate:
        return '心率';
      case HealthDataType.checkup:
        return '体检报告';
      case HealthDataType.medication:
        return '用药记录';
      case HealthDataType.other:
        return '其他';
    }
  }
}
