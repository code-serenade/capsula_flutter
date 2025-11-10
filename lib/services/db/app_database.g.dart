// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $HealthAssetEntriesTable extends HealthAssetEntries
    with TableInfo<$HealthAssetEntriesTable, HealthAssetEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HealthAssetEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _filenameMeta = const VerificationMeta(
    'filename',
  );
  @override
  late final GeneratedColumn<String> filename = GeneratedColumn<String>(
    'filename',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeMeta = const VerificationMeta('mime');
  @override
  late final GeneratedColumn<String> mime = GeneratedColumn<String>(
    'mime',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hashSha256Meta = const VerificationMeta(
    'hashSha256',
  );
  @override
  late final GeneratedColumn<String> hashSha256 = GeneratedColumn<String>(
    'hash_sha256',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dataSourceMeta = const VerificationMeta(
    'dataSource',
  );
  @override
  late final GeneratedColumn<String> dataSource = GeneratedColumn<String>(
    'data_source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataTypeMeta = const VerificationMeta(
    'dataType',
  );
  @override
  late final GeneratedColumn<String> dataType = GeneratedColumn<String>(
    'data_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('other'),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _metadataJsonMeta = const VerificationMeta(
    'metadataJson',
  );
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
    'metadata_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    filename,
    path,
    mime,
    sizeBytes,
    hashSha256,
    dataSource,
    dataType,
    note,
    tags,
    metadataJson,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'health_asset';
  @override
  VerificationContext validateIntegrity(
    Insertable<HealthAssetEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('filename')) {
      context.handle(
        _filenameMeta,
        filename.isAcceptableOrUnknown(data['filename']!, _filenameMeta),
      );
    } else if (isInserting) {
      context.missing(_filenameMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('mime')) {
      context.handle(
        _mimeMeta,
        mime.isAcceptableOrUnknown(data['mime']!, _mimeMeta),
      );
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    }
    if (data.containsKey('hash_sha256')) {
      context.handle(
        _hashSha256Meta,
        hashSha256.isAcceptableOrUnknown(data['hash_sha256']!, _hashSha256Meta),
      );
    }
    if (data.containsKey('data_source')) {
      context.handle(
        _dataSourceMeta,
        dataSource.isAcceptableOrUnknown(data['data_source']!, _dataSourceMeta),
      );
    } else if (isInserting) {
      context.missing(_dataSourceMeta);
    }
    if (data.containsKey('data_type')) {
      context.handle(
        _dataTypeMeta,
        dataType.isAcceptableOrUnknown(data['data_type']!, _dataTypeMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
        _metadataJsonMeta,
        metadataJson.isAcceptableOrUnknown(
          data['metadata_json']!,
          _metadataJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HealthAssetEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HealthAssetEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      filename: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}filename'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      mime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime'],
      ),
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      ),
      hashSha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hash_sha256'],
      ),
      dataSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data_source'],
      )!,
      dataType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data_type'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      ),
      metadataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata_json'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $HealthAssetEntriesTable createAlias(String alias) {
    return $HealthAssetEntriesTable(attachedDatabase, alias);
  }
}

class HealthAssetEntry extends DataClass
    implements Insertable<HealthAssetEntry> {
  final int id;
  final String filename;
  final String path;
  final String? mime;
  final int? sizeBytes;
  final String? hashSha256;
  final String dataSource;
  final String dataType;
  final String? note;
  final String? tags;
  final String? metadataJson;
  final String createdAt;
  final String updatedAt;
  const HealthAssetEntry({
    required this.id,
    required this.filename,
    required this.path,
    this.mime,
    this.sizeBytes,
    this.hashSha256,
    required this.dataSource,
    required this.dataType,
    this.note,
    this.tags,
    this.metadataJson,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['filename'] = Variable<String>(filename);
    map['path'] = Variable<String>(path);
    if (!nullToAbsent || mime != null) {
      map['mime'] = Variable<String>(mime);
    }
    if (!nullToAbsent || sizeBytes != null) {
      map['size_bytes'] = Variable<int>(sizeBytes);
    }
    if (!nullToAbsent || hashSha256 != null) {
      map['hash_sha256'] = Variable<String>(hashSha256);
    }
    map['data_source'] = Variable<String>(dataSource);
    map['data_type'] = Variable<String>(dataType);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || tags != null) {
      map['tags'] = Variable<String>(tags);
    }
    if (!nullToAbsent || metadataJson != null) {
      map['metadata_json'] = Variable<String>(metadataJson);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  HealthAssetEntriesCompanion toCompanion(bool nullToAbsent) {
    return HealthAssetEntriesCompanion(
      id: Value(id),
      filename: Value(filename),
      path: Value(path),
      mime: mime == null && nullToAbsent ? const Value.absent() : Value(mime),
      sizeBytes: sizeBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(sizeBytes),
      hashSha256: hashSha256 == null && nullToAbsent
          ? const Value.absent()
          : Value(hashSha256),
      dataSource: Value(dataSource),
      dataType: Value(dataType),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      tags: tags == null && nullToAbsent ? const Value.absent() : Value(tags),
      metadataJson: metadataJson == null && nullToAbsent
          ? const Value.absent()
          : Value(metadataJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory HealthAssetEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HealthAssetEntry(
      id: serializer.fromJson<int>(json['id']),
      filename: serializer.fromJson<String>(json['filename']),
      path: serializer.fromJson<String>(json['path']),
      mime: serializer.fromJson<String?>(json['mime']),
      sizeBytes: serializer.fromJson<int?>(json['sizeBytes']),
      hashSha256: serializer.fromJson<String?>(json['hashSha256']),
      dataSource: serializer.fromJson<String>(json['dataSource']),
      dataType: serializer.fromJson<String>(json['dataType']),
      note: serializer.fromJson<String?>(json['note']),
      tags: serializer.fromJson<String?>(json['tags']),
      metadataJson: serializer.fromJson<String?>(json['metadataJson']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'filename': serializer.toJson<String>(filename),
      'path': serializer.toJson<String>(path),
      'mime': serializer.toJson<String?>(mime),
      'sizeBytes': serializer.toJson<int?>(sizeBytes),
      'hashSha256': serializer.toJson<String?>(hashSha256),
      'dataSource': serializer.toJson<String>(dataSource),
      'dataType': serializer.toJson<String>(dataType),
      'note': serializer.toJson<String?>(note),
      'tags': serializer.toJson<String?>(tags),
      'metadataJson': serializer.toJson<String?>(metadataJson),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  HealthAssetEntry copyWith({
    int? id,
    String? filename,
    String? path,
    Value<String?> mime = const Value.absent(),
    Value<int?> sizeBytes = const Value.absent(),
    Value<String?> hashSha256 = const Value.absent(),
    String? dataSource,
    String? dataType,
    Value<String?> note = const Value.absent(),
    Value<String?> tags = const Value.absent(),
    Value<String?> metadataJson = const Value.absent(),
    String? createdAt,
    String? updatedAt,
  }) => HealthAssetEntry(
    id: id ?? this.id,
    filename: filename ?? this.filename,
    path: path ?? this.path,
    mime: mime.present ? mime.value : this.mime,
    sizeBytes: sizeBytes.present ? sizeBytes.value : this.sizeBytes,
    hashSha256: hashSha256.present ? hashSha256.value : this.hashSha256,
    dataSource: dataSource ?? this.dataSource,
    dataType: dataType ?? this.dataType,
    note: note.present ? note.value : this.note,
    tags: tags.present ? tags.value : this.tags,
    metadataJson: metadataJson.present ? metadataJson.value : this.metadataJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  HealthAssetEntry copyWithCompanion(HealthAssetEntriesCompanion data) {
    return HealthAssetEntry(
      id: data.id.present ? data.id.value : this.id,
      filename: data.filename.present ? data.filename.value : this.filename,
      path: data.path.present ? data.path.value : this.path,
      mime: data.mime.present ? data.mime.value : this.mime,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      hashSha256: data.hashSha256.present
          ? data.hashSha256.value
          : this.hashSha256,
      dataSource: data.dataSource.present
          ? data.dataSource.value
          : this.dataSource,
      dataType: data.dataType.present ? data.dataType.value : this.dataType,
      note: data.note.present ? data.note.value : this.note,
      tags: data.tags.present ? data.tags.value : this.tags,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HealthAssetEntry(')
          ..write('id: $id, ')
          ..write('filename: $filename, ')
          ..write('path: $path, ')
          ..write('mime: $mime, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('hashSha256: $hashSha256, ')
          ..write('dataSource: $dataSource, ')
          ..write('dataType: $dataType, ')
          ..write('note: $note, ')
          ..write('tags: $tags, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    filename,
    path,
    mime,
    sizeBytes,
    hashSha256,
    dataSource,
    dataType,
    note,
    tags,
    metadataJson,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HealthAssetEntry &&
          other.id == this.id &&
          other.filename == this.filename &&
          other.path == this.path &&
          other.mime == this.mime &&
          other.sizeBytes == this.sizeBytes &&
          other.hashSha256 == this.hashSha256 &&
          other.dataSource == this.dataSource &&
          other.dataType == this.dataType &&
          other.note == this.note &&
          other.tags == this.tags &&
          other.metadataJson == this.metadataJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class HealthAssetEntriesCompanion extends UpdateCompanion<HealthAssetEntry> {
  final Value<int> id;
  final Value<String> filename;
  final Value<String> path;
  final Value<String?> mime;
  final Value<int?> sizeBytes;
  final Value<String?> hashSha256;
  final Value<String> dataSource;
  final Value<String> dataType;
  final Value<String?> note;
  final Value<String?> tags;
  final Value<String?> metadataJson;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  const HealthAssetEntriesCompanion({
    this.id = const Value.absent(),
    this.filename = const Value.absent(),
    this.path = const Value.absent(),
    this.mime = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.hashSha256 = const Value.absent(),
    this.dataSource = const Value.absent(),
    this.dataType = const Value.absent(),
    this.note = const Value.absent(),
    this.tags = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  HealthAssetEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String filename,
    required String path,
    this.mime = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.hashSha256 = const Value.absent(),
    required String dataSource,
    this.dataType = const Value.absent(),
    this.note = const Value.absent(),
    this.tags = const Value.absent(),
    this.metadataJson = const Value.absent(),
    required String createdAt,
    required String updatedAt,
  }) : filename = Value(filename),
       path = Value(path),
       dataSource = Value(dataSource),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<HealthAssetEntry> custom({
    Expression<int>? id,
    Expression<String>? filename,
    Expression<String>? path,
    Expression<String>? mime,
    Expression<int>? sizeBytes,
    Expression<String>? hashSha256,
    Expression<String>? dataSource,
    Expression<String>? dataType,
    Expression<String>? note,
    Expression<String>? tags,
    Expression<String>? metadataJson,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (filename != null) 'filename': filename,
      if (path != null) 'path': path,
      if (mime != null) 'mime': mime,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (hashSha256 != null) 'hash_sha256': hashSha256,
      if (dataSource != null) 'data_source': dataSource,
      if (dataType != null) 'data_type': dataType,
      if (note != null) 'note': note,
      if (tags != null) 'tags': tags,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  HealthAssetEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? filename,
    Value<String>? path,
    Value<String?>? mime,
    Value<int?>? sizeBytes,
    Value<String?>? hashSha256,
    Value<String>? dataSource,
    Value<String>? dataType,
    Value<String?>? note,
    Value<String?>? tags,
    Value<String?>? metadataJson,
    Value<String>? createdAt,
    Value<String>? updatedAt,
  }) {
    return HealthAssetEntriesCompanion(
      id: id ?? this.id,
      filename: filename ?? this.filename,
      path: path ?? this.path,
      mime: mime ?? this.mime,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      hashSha256: hashSha256 ?? this.hashSha256,
      dataSource: dataSource ?? this.dataSource,
      dataType: dataType ?? this.dataType,
      note: note ?? this.note,
      tags: tags ?? this.tags,
      metadataJson: metadataJson ?? this.metadataJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (filename.present) {
      map['filename'] = Variable<String>(filename.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (mime.present) {
      map['mime'] = Variable<String>(mime.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (hashSha256.present) {
      map['hash_sha256'] = Variable<String>(hashSha256.value);
    }
    if (dataSource.present) {
      map['data_source'] = Variable<String>(dataSource.value);
    }
    if (dataType.present) {
      map['data_type'] = Variable<String>(dataType.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HealthAssetEntriesCompanion(')
          ..write('id: $id, ')
          ..write('filename: $filename, ')
          ..write('path: $path, ')
          ..write('mime: $mime, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('hashSha256: $hashSha256, ')
          ..write('dataSource: $dataSource, ')
          ..write('dataType: $dataType, ')
          ..write('note: $note, ')
          ..write('tags: $tags, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $HealthAssetEntriesTable healthAssetEntries =
      $HealthAssetEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [healthAssetEntries];
}

typedef $$HealthAssetEntriesTableCreateCompanionBuilder =
    HealthAssetEntriesCompanion Function({
      Value<int> id,
      required String filename,
      required String path,
      Value<String?> mime,
      Value<int?> sizeBytes,
      Value<String?> hashSha256,
      required String dataSource,
      Value<String> dataType,
      Value<String?> note,
      Value<String?> tags,
      Value<String?> metadataJson,
      required String createdAt,
      required String updatedAt,
    });
typedef $$HealthAssetEntriesTableUpdateCompanionBuilder =
    HealthAssetEntriesCompanion Function({
      Value<int> id,
      Value<String> filename,
      Value<String> path,
      Value<String?> mime,
      Value<int?> sizeBytes,
      Value<String?> hashSha256,
      Value<String> dataSource,
      Value<String> dataType,
      Value<String?> note,
      Value<String?> tags,
      Value<String?> metadataJson,
      Value<String> createdAt,
      Value<String> updatedAt,
    });

class $$HealthAssetEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $HealthAssetEntriesTable> {
  $$HealthAssetEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filename => $composableBuilder(
    column: $table.filename,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mime => $composableBuilder(
    column: $table.mime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hashSha256 => $composableBuilder(
    column: $table.hashSha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dataSource => $composableBuilder(
    column: $table.dataSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dataType => $composableBuilder(
    column: $table.dataType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HealthAssetEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $HealthAssetEntriesTable> {
  $$HealthAssetEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filename => $composableBuilder(
    column: $table.filename,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mime => $composableBuilder(
    column: $table.mime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hashSha256 => $composableBuilder(
    column: $table.hashSha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dataSource => $composableBuilder(
    column: $table.dataSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dataType => $composableBuilder(
    column: $table.dataType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HealthAssetEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HealthAssetEntriesTable> {
  $$HealthAssetEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get filename =>
      $composableBuilder(column: $table.filename, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get mime =>
      $composableBuilder(column: $table.mime, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<String> get hashSha256 => $composableBuilder(
    column: $table.hashSha256,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dataSource => $composableBuilder(
    column: $table.dataSource,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dataType =>
      $composableBuilder(column: $table.dataType, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$HealthAssetEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HealthAssetEntriesTable,
          HealthAssetEntry,
          $$HealthAssetEntriesTableFilterComposer,
          $$HealthAssetEntriesTableOrderingComposer,
          $$HealthAssetEntriesTableAnnotationComposer,
          $$HealthAssetEntriesTableCreateCompanionBuilder,
          $$HealthAssetEntriesTableUpdateCompanionBuilder,
          (
            HealthAssetEntry,
            BaseReferences<
              _$AppDatabase,
              $HealthAssetEntriesTable,
              HealthAssetEntry
            >,
          ),
          HealthAssetEntry,
          PrefetchHooks Function()
        > {
  $$HealthAssetEntriesTableTableManager(
    _$AppDatabase db,
    $HealthAssetEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HealthAssetEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HealthAssetEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HealthAssetEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> filename = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<String?> mime = const Value.absent(),
                Value<int?> sizeBytes = const Value.absent(),
                Value<String?> hashSha256 = const Value.absent(),
                Value<String> dataSource = const Value.absent(),
                Value<String> dataType = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> tags = const Value.absent(),
                Value<String?> metadataJson = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
              }) => HealthAssetEntriesCompanion(
                id: id,
                filename: filename,
                path: path,
                mime: mime,
                sizeBytes: sizeBytes,
                hashSha256: hashSha256,
                dataSource: dataSource,
                dataType: dataType,
                note: note,
                tags: tags,
                metadataJson: metadataJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String filename,
                required String path,
                Value<String?> mime = const Value.absent(),
                Value<int?> sizeBytes = const Value.absent(),
                Value<String?> hashSha256 = const Value.absent(),
                required String dataSource,
                Value<String> dataType = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> tags = const Value.absent(),
                Value<String?> metadataJson = const Value.absent(),
                required String createdAt,
                required String updatedAt,
              }) => HealthAssetEntriesCompanion.insert(
                id: id,
                filename: filename,
                path: path,
                mime: mime,
                sizeBytes: sizeBytes,
                hashSha256: hashSha256,
                dataSource: dataSource,
                dataType: dataType,
                note: note,
                tags: tags,
                metadataJson: metadataJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HealthAssetEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HealthAssetEntriesTable,
      HealthAssetEntry,
      $$HealthAssetEntriesTableFilterComposer,
      $$HealthAssetEntriesTableOrderingComposer,
      $$HealthAssetEntriesTableAnnotationComposer,
      $$HealthAssetEntriesTableCreateCompanionBuilder,
      $$HealthAssetEntriesTableUpdateCompanionBuilder,
      (
        HealthAssetEntry,
        BaseReferences<
          _$AppDatabase,
          $HealthAssetEntriesTable,
          HealthAssetEntry
        >,
      ),
      HealthAssetEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$HealthAssetEntriesTableTableManager get healthAssetEntries =>
      $$HealthAssetEntriesTableTableManager(_db, _db.healthAssetEntries);
}
