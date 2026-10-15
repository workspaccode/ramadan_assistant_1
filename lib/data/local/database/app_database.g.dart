// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PrayerLogsTable extends PrayerLogs
    with TableInfo<$PrayerLogsTable, PrayerLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrayerLogsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _prayerNameMeta = const VerificationMeta(
    'prayerName',
  );
  @override
  late final GeneratedColumn<String> prayerName = GeneratedColumn<String>(
    'prayer_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _prayerTimeMeta = const VerificationMeta(
    'prayerTime',
  );
  @override
  late final GeneratedColumn<DateTime> prayerTime = GeneratedColumn<DateTime>(
    'prayer_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    prayerName,
    prayerTime,
    completed,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prayer_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<PrayerLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('prayer_name')) {
      context.handle(
        _prayerNameMeta,
        prayerName.isAcceptableOrUnknown(data['prayer_name']!, _prayerNameMeta),
      );
    } else if (isInserting) {
      context.missing(_prayerNameMeta);
    }
    if (data.containsKey('prayer_time')) {
      context.handle(
        _prayerTimeMeta,
        prayerTime.isAcceptableOrUnknown(data['prayer_time']!, _prayerTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_prayerTimeMeta);
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PrayerLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PrayerLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      prayerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prayer_name'],
      )!,
      prayerTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}prayer_time'],
      )!,
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $PrayerLogsTable createAlias(String alias) {
    return $PrayerLogsTable(attachedDatabase, alias);
  }
}

class PrayerLog extends DataClass implements Insertable<PrayerLog> {
  final int id;
  final String prayerName;
  final DateTime prayerTime;
  final bool completed;
  final DateTime? completedAt;
  const PrayerLog({
    required this.id,
    required this.prayerName,
    required this.prayerTime,
    required this.completed,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['prayer_name'] = Variable<String>(prayerName);
    map['prayer_time'] = Variable<DateTime>(prayerTime);
    map['completed'] = Variable<bool>(completed);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  PrayerLogsCompanion toCompanion(bool nullToAbsent) {
    return PrayerLogsCompanion(
      id: Value(id),
      prayerName: Value(prayerName),
      prayerTime: Value(prayerTime),
      completed: Value(completed),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory PrayerLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PrayerLog(
      id: serializer.fromJson<int>(json['id']),
      prayerName: serializer.fromJson<String>(json['prayerName']),
      prayerTime: serializer.fromJson<DateTime>(json['prayerTime']),
      completed: serializer.fromJson<bool>(json['completed']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'prayerName': serializer.toJson<String>(prayerName),
      'prayerTime': serializer.toJson<DateTime>(prayerTime),
      'completed': serializer.toJson<bool>(completed),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  PrayerLog copyWith({
    int? id,
    String? prayerName,
    DateTime? prayerTime,
    bool? completed,
    Value<DateTime?> completedAt = const Value.absent(),
  }) => PrayerLog(
    id: id ?? this.id,
    prayerName: prayerName ?? this.prayerName,
    prayerTime: prayerTime ?? this.prayerTime,
    completed: completed ?? this.completed,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  PrayerLog copyWithCompanion(PrayerLogsCompanion data) {
    return PrayerLog(
      id: data.id.present ? data.id.value : this.id,
      prayerName: data.prayerName.present
          ? data.prayerName.value
          : this.prayerName,
      prayerTime: data.prayerTime.present
          ? data.prayerTime.value
          : this.prayerTime,
      completed: data.completed.present ? data.completed.value : this.completed,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PrayerLog(')
          ..write('id: $id, ')
          ..write('prayerName: $prayerName, ')
          ..write('prayerTime: $prayerTime, ')
          ..write('completed: $completed, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, prayerName, prayerTime, completed, completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PrayerLog &&
          other.id == this.id &&
          other.prayerName == this.prayerName &&
          other.prayerTime == this.prayerTime &&
          other.completed == this.completed &&
          other.completedAt == this.completedAt);
}

class PrayerLogsCompanion extends UpdateCompanion<PrayerLog> {
  final Value<int> id;
  final Value<String> prayerName;
  final Value<DateTime> prayerTime;
  final Value<bool> completed;
  final Value<DateTime?> completedAt;
  const PrayerLogsCompanion({
    this.id = const Value.absent(),
    this.prayerName = const Value.absent(),
    this.prayerTime = const Value.absent(),
    this.completed = const Value.absent(),
    this.completedAt = const Value.absent(),
  });
  PrayerLogsCompanion.insert({
    this.id = const Value.absent(),
    required String prayerName,
    required DateTime prayerTime,
    this.completed = const Value.absent(),
    this.completedAt = const Value.absent(),
  }) : prayerName = Value(prayerName),
       prayerTime = Value(prayerTime);
  static Insertable<PrayerLog> custom({
    Expression<int>? id,
    Expression<String>? prayerName,
    Expression<DateTime>? prayerTime,
    Expression<bool>? completed,
    Expression<DateTime>? completedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (prayerName != null) 'prayer_name': prayerName,
      if (prayerTime != null) 'prayer_time': prayerTime,
      if (completed != null) 'completed': completed,
      if (completedAt != null) 'completed_at': completedAt,
    });
  }

  PrayerLogsCompanion copyWith({
    Value<int>? id,
    Value<String>? prayerName,
    Value<DateTime>? prayerTime,
    Value<bool>? completed,
    Value<DateTime?>? completedAt,
  }) {
    return PrayerLogsCompanion(
      id: id ?? this.id,
      prayerName: prayerName ?? this.prayerName,
      prayerTime: prayerTime ?? this.prayerTime,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (prayerName.present) {
      map['prayer_name'] = Variable<String>(prayerName.value);
    }
    if (prayerTime.present) {
      map['prayer_time'] = Variable<DateTime>(prayerTime.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PrayerLogsCompanion(')
          ..write('id: $id, ')
          ..write('prayerName: $prayerName, ')
          ..write('prayerTime: $prayerTime, ')
          ..write('completed: $completed, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }
}

class $TasbihSessionsTable extends TasbihSessions
    with TableInfo<$TasbihSessionsTable, TasbihSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasbihSessionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dhikrNameMeta = const VerificationMeta(
    'dhikrName',
  );
  @override
  late final GeneratedColumn<String> dhikrName = GeneratedColumn<String>(
    'dhikr_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
    'count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetCountMeta = const VerificationMeta(
    'targetCount',
  );
  @override
  late final GeneratedColumn<int> targetCount = GeneratedColumn<int>(
    'target_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dhikrName,
    count,
    targetCount,
    createdAt,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasbih_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TasbihSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('dhikr_name')) {
      context.handle(
        _dhikrNameMeta,
        dhikrName.isAcceptableOrUnknown(data['dhikr_name']!, _dhikrNameMeta),
      );
    } else if (isInserting) {
      context.missing(_dhikrNameMeta);
    }
    if (data.containsKey('count')) {
      context.handle(
        _countMeta,
        count.isAcceptableOrUnknown(data['count']!, _countMeta),
      );
    } else if (isInserting) {
      context.missing(_countMeta);
    }
    if (data.containsKey('target_count')) {
      context.handle(
        _targetCountMeta,
        targetCount.isAcceptableOrUnknown(
          data['target_count']!,
          _targetCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetCountMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TasbihSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TasbihSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      dhikrName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dhikr_name'],
      )!,
      count: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count'],
      )!,
      targetCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $TasbihSessionsTable createAlias(String alias) {
    return $TasbihSessionsTable(attachedDatabase, alias);
  }
}

class TasbihSession extends DataClass implements Insertable<TasbihSession> {
  final int id;
  final String dhikrName;
  final int count;
  final int targetCount;
  final DateTime createdAt;
  final DateTime? completedAt;
  const TasbihSession({
    required this.id,
    required this.dhikrName,
    required this.count,
    required this.targetCount,
    required this.createdAt,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['dhikr_name'] = Variable<String>(dhikrName);
    map['count'] = Variable<int>(count);
    map['target_count'] = Variable<int>(targetCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  TasbihSessionsCompanion toCompanion(bool nullToAbsent) {
    return TasbihSessionsCompanion(
      id: Value(id),
      dhikrName: Value(dhikrName),
      count: Value(count),
      targetCount: Value(targetCount),
      createdAt: Value(createdAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory TasbihSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TasbihSession(
      id: serializer.fromJson<int>(json['id']),
      dhikrName: serializer.fromJson<String>(json['dhikrName']),
      count: serializer.fromJson<int>(json['count']),
      targetCount: serializer.fromJson<int>(json['targetCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dhikrName': serializer.toJson<String>(dhikrName),
      'count': serializer.toJson<int>(count),
      'targetCount': serializer.toJson<int>(targetCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  TasbihSession copyWith({
    int? id,
    String? dhikrName,
    int? count,
    int? targetCount,
    DateTime? createdAt,
    Value<DateTime?> completedAt = const Value.absent(),
  }) => TasbihSession(
    id: id ?? this.id,
    dhikrName: dhikrName ?? this.dhikrName,
    count: count ?? this.count,
    targetCount: targetCount ?? this.targetCount,
    createdAt: createdAt ?? this.createdAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  TasbihSession copyWithCompanion(TasbihSessionsCompanion data) {
    return TasbihSession(
      id: data.id.present ? data.id.value : this.id,
      dhikrName: data.dhikrName.present ? data.dhikrName.value : this.dhikrName,
      count: data.count.present ? data.count.value : this.count,
      targetCount: data.targetCount.present
          ? data.targetCount.value
          : this.targetCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TasbihSession(')
          ..write('id: $id, ')
          ..write('dhikrName: $dhikrName, ')
          ..write('count: $count, ')
          ..write('targetCount: $targetCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, dhikrName, count, targetCount, createdAt, completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TasbihSession &&
          other.id == this.id &&
          other.dhikrName == this.dhikrName &&
          other.count == this.count &&
          other.targetCount == this.targetCount &&
          other.createdAt == this.createdAt &&
          other.completedAt == this.completedAt);
}

class TasbihSessionsCompanion extends UpdateCompanion<TasbihSession> {
  final Value<int> id;
  final Value<String> dhikrName;
  final Value<int> count;
  final Value<int> targetCount;
  final Value<DateTime> createdAt;
  final Value<DateTime?> completedAt;
  const TasbihSessionsCompanion({
    this.id = const Value.absent(),
    this.dhikrName = const Value.absent(),
    this.count = const Value.absent(),
    this.targetCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
  });
  TasbihSessionsCompanion.insert({
    this.id = const Value.absent(),
    required String dhikrName,
    required int count,
    required int targetCount,
    required DateTime createdAt,
    this.completedAt = const Value.absent(),
  }) : dhikrName = Value(dhikrName),
       count = Value(count),
       targetCount = Value(targetCount),
       createdAt = Value(createdAt);
  static Insertable<TasbihSession> custom({
    Expression<int>? id,
    Expression<String>? dhikrName,
    Expression<int>? count,
    Expression<int>? targetCount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? completedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dhikrName != null) 'dhikr_name': dhikrName,
      if (count != null) 'count': count,
      if (targetCount != null) 'target_count': targetCount,
      if (createdAt != null) 'created_at': createdAt,
      if (completedAt != null) 'completed_at': completedAt,
    });
  }

  TasbihSessionsCompanion copyWith({
    Value<int>? id,
    Value<String>? dhikrName,
    Value<int>? count,
    Value<int>? targetCount,
    Value<DateTime>? createdAt,
    Value<DateTime?>? completedAt,
  }) {
    return TasbihSessionsCompanion(
      id: id ?? this.id,
      dhikrName: dhikrName ?? this.dhikrName,
      count: count ?? this.count,
      targetCount: targetCount ?? this.targetCount,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dhikrName.present) {
      map['dhikr_name'] = Variable<String>(dhikrName.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (targetCount.present) {
      map['target_count'] = Variable<int>(targetCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasbihSessionsCompanion(')
          ..write('id: $id, ')
          ..write('dhikrName: $dhikrName, ')
          ..write('count: $count, ')
          ..write('targetCount: $targetCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }
}

class $DuasTable extends Duas with TableInfo<$DuasTable, Dua> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DuasTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _arabicTextMeta = const VerificationMeta(
    'arabicText',
  );
  @override
  late final GeneratedColumn<String> arabicText = GeneratedColumn<String>(
    'arabic_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transliterationMeta = const VerificationMeta(
    'transliteration',
  );
  @override
  late final GeneratedColumn<String> transliteration = GeneratedColumn<String>(
    'transliteration',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _translationMeta = const VerificationMeta(
    'translation',
  );
  @override
  late final GeneratedColumn<String> translation = GeneratedColumn<String>(
    'translation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _audioPathMeta = const VerificationMeta(
    'audioPath',
  );
  @override
  late final GeneratedColumn<String> audioPath = GeneratedColumn<String>(
    'audio_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    category,
    arabicText,
    transliteration,
    translation,
    audioPath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'duas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Dua> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('arabic_text')) {
      context.handle(
        _arabicTextMeta,
        arabicText.isAcceptableOrUnknown(data['arabic_text']!, _arabicTextMeta),
      );
    } else if (isInserting) {
      context.missing(_arabicTextMeta);
    }
    if (data.containsKey('transliteration')) {
      context.handle(
        _transliterationMeta,
        transliteration.isAcceptableOrUnknown(
          data['transliteration']!,
          _transliterationMeta,
        ),
      );
    }
    if (data.containsKey('translation')) {
      context.handle(
        _translationMeta,
        translation.isAcceptableOrUnknown(
          data['translation']!,
          _translationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_translationMeta);
    }
    if (data.containsKey('audio_path')) {
      context.handle(
        _audioPathMeta,
        audioPath.isAcceptableOrUnknown(data['audio_path']!, _audioPathMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Dua map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Dua(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      arabicText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}arabic_text'],
      )!,
      transliteration: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transliteration'],
      ),
      translation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translation'],
      )!,
      audioPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_path'],
      ),
    );
  }

  @override
  $DuasTable createAlias(String alias) {
    return $DuasTable(attachedDatabase, alias);
  }
}

class Dua extends DataClass implements Insertable<Dua> {
  final int id;
  final String category;
  final String arabicText;
  final String? transliteration;
  final String translation;
  final String? audioPath;
  const Dua({
    required this.id,
    required this.category,
    required this.arabicText,
    this.transliteration,
    required this.translation,
    this.audioPath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['category'] = Variable<String>(category);
    map['arabic_text'] = Variable<String>(arabicText);
    if (!nullToAbsent || transliteration != null) {
      map['transliteration'] = Variable<String>(transliteration);
    }
    map['translation'] = Variable<String>(translation);
    if (!nullToAbsent || audioPath != null) {
      map['audio_path'] = Variable<String>(audioPath);
    }
    return map;
  }

  DuasCompanion toCompanion(bool nullToAbsent) {
    return DuasCompanion(
      id: Value(id),
      category: Value(category),
      arabicText: Value(arabicText),
      transliteration: transliteration == null && nullToAbsent
          ? const Value.absent()
          : Value(transliteration),
      translation: Value(translation),
      audioPath: audioPath == null && nullToAbsent
          ? const Value.absent()
          : Value(audioPath),
    );
  }

  factory Dua.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Dua(
      id: serializer.fromJson<int>(json['id']),
      category: serializer.fromJson<String>(json['category']),
      arabicText: serializer.fromJson<String>(json['arabicText']),
      transliteration: serializer.fromJson<String?>(json['transliteration']),
      translation: serializer.fromJson<String>(json['translation']),
      audioPath: serializer.fromJson<String?>(json['audioPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'category': serializer.toJson<String>(category),
      'arabicText': serializer.toJson<String>(arabicText),
      'transliteration': serializer.toJson<String?>(transliteration),
      'translation': serializer.toJson<String>(translation),
      'audioPath': serializer.toJson<String?>(audioPath),
    };
  }

  Dua copyWith({
    int? id,
    String? category,
    String? arabicText,
    Value<String?> transliteration = const Value.absent(),
    String? translation,
    Value<String?> audioPath = const Value.absent(),
  }) => Dua(
    id: id ?? this.id,
    category: category ?? this.category,
    arabicText: arabicText ?? this.arabicText,
    transliteration: transliteration.present
        ? transliteration.value
        : this.transliteration,
    translation: translation ?? this.translation,
    audioPath: audioPath.present ? audioPath.value : this.audioPath,
  );
  Dua copyWithCompanion(DuasCompanion data) {
    return Dua(
      id: data.id.present ? data.id.value : this.id,
      category: data.category.present ? data.category.value : this.category,
      arabicText: data.arabicText.present
          ? data.arabicText.value
          : this.arabicText,
      transliteration: data.transliteration.present
          ? data.transliteration.value
          : this.transliteration,
      translation: data.translation.present
          ? data.translation.value
          : this.translation,
      audioPath: data.audioPath.present ? data.audioPath.value : this.audioPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Dua(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('arabicText: $arabicText, ')
          ..write('transliteration: $transliteration, ')
          ..write('translation: $translation, ')
          ..write('audioPath: $audioPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    category,
    arabicText,
    transliteration,
    translation,
    audioPath,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Dua &&
          other.id == this.id &&
          other.category == this.category &&
          other.arabicText == this.arabicText &&
          other.transliteration == this.transliteration &&
          other.translation == this.translation &&
          other.audioPath == this.audioPath);
}

class DuasCompanion extends UpdateCompanion<Dua> {
  final Value<int> id;
  final Value<String> category;
  final Value<String> arabicText;
  final Value<String?> transliteration;
  final Value<String> translation;
  final Value<String?> audioPath;
  const DuasCompanion({
    this.id = const Value.absent(),
    this.category = const Value.absent(),
    this.arabicText = const Value.absent(),
    this.transliteration = const Value.absent(),
    this.translation = const Value.absent(),
    this.audioPath = const Value.absent(),
  });
  DuasCompanion.insert({
    this.id = const Value.absent(),
    required String category,
    required String arabicText,
    this.transliteration = const Value.absent(),
    required String translation,
    this.audioPath = const Value.absent(),
  }) : category = Value(category),
       arabicText = Value(arabicText),
       translation = Value(translation);
  static Insertable<Dua> custom({
    Expression<int>? id,
    Expression<String>? category,
    Expression<String>? arabicText,
    Expression<String>? transliteration,
    Expression<String>? translation,
    Expression<String>? audioPath,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (category != null) 'category': category,
      if (arabicText != null) 'arabic_text': arabicText,
      if (transliteration != null) 'transliteration': transliteration,
      if (translation != null) 'translation': translation,
      if (audioPath != null) 'audio_path': audioPath,
    });
  }

  DuasCompanion copyWith({
    Value<int>? id,
    Value<String>? category,
    Value<String>? arabicText,
    Value<String?>? transliteration,
    Value<String>? translation,
    Value<String?>? audioPath,
  }) {
    return DuasCompanion(
      id: id ?? this.id,
      category: category ?? this.category,
      arabicText: arabicText ?? this.arabicText,
      transliteration: transliteration ?? this.transliteration,
      translation: translation ?? this.translation,
      audioPath: audioPath ?? this.audioPath,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (arabicText.present) {
      map['arabic_text'] = Variable<String>(arabicText.value);
    }
    if (transliteration.present) {
      map['transliteration'] = Variable<String>(transliteration.value);
    }
    if (translation.present) {
      map['translation'] = Variable<String>(translation.value);
    }
    if (audioPath.present) {
      map['audio_path'] = Variable<String>(audioPath.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DuasCompanion(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('arabicText: $arabicText, ')
          ..write('transliteration: $transliteration, ')
          ..write('translation: $translation, ')
          ..write('audioPath: $audioPath')
          ..write(')'))
        .toString();
  }
}

class $WirdProgressTable extends WirdProgress
    with TableInfo<$WirdProgressTable, WirdProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WirdProgressTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _planTypeMeta = const VerificationMeta(
    'planType',
  );
  @override
  late final GeneratedColumn<String> planType = GeneratedColumn<String>(
    'plan_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _planValueMeta = const VerificationMeta(
    'planValue',
  );
  @override
  late final GeneratedColumn<int> planValue = GeneratedColumn<int>(
    'plan_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedPagesMeta = const VerificationMeta(
    'completedPages',
  );
  @override
  late final GeneratedColumn<int> completedPages = GeneratedColumn<int>(
    'completed_pages',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastReadPageMeta = const VerificationMeta(
    'lastReadPage',
  );
  @override
  late final GeneratedColumn<int> lastReadPage = GeneratedColumn<int>(
    'last_read_page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _lastUpdatedMeta = const VerificationMeta(
    'lastUpdated',
  );
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
    'last_updated',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    planType,
    planValue,
    completedPages,
    lastReadPage,
    lastUpdated,
    isCompleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wird_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<WirdProgressData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('plan_type')) {
      context.handle(
        _planTypeMeta,
        planType.isAcceptableOrUnknown(data['plan_type']!, _planTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_planTypeMeta);
    }
    if (data.containsKey('plan_value')) {
      context.handle(
        _planValueMeta,
        planValue.isAcceptableOrUnknown(data['plan_value']!, _planValueMeta),
      );
    } else if (isInserting) {
      context.missing(_planValueMeta);
    }
    if (data.containsKey('completed_pages')) {
      context.handle(
        _completedPagesMeta,
        completedPages.isAcceptableOrUnknown(
          data['completed_pages']!,
          _completedPagesMeta,
        ),
      );
    }
    if (data.containsKey('last_read_page')) {
      context.handle(
        _lastReadPageMeta,
        lastReadPage.isAcceptableOrUnknown(
          data['last_read_page']!,
          _lastReadPageMeta,
        ),
      );
    }
    if (data.containsKey('last_updated')) {
      context.handle(
        _lastUpdatedMeta,
        lastUpdated.isAcceptableOrUnknown(
          data['last_updated']!,
          _lastUpdatedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastUpdatedMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WirdProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WirdProgressData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      planType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_type'],
      )!,
      planValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plan_value'],
      )!,
      completedPages: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_pages'],
      )!,
      lastReadPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_read_page'],
      )!,
      lastUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_updated'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
    );
  }

  @override
  $WirdProgressTable createAlias(String alias) {
    return $WirdProgressTable(attachedDatabase, alias);
  }
}

class WirdProgressData extends DataClass
    implements Insertable<WirdProgressData> {
  final int id;
  final String planType;
  final int planValue;
  final int completedPages;
  final int lastReadPage;
  final DateTime lastUpdated;
  final bool isCompleted;
  const WirdProgressData({
    required this.id,
    required this.planType,
    required this.planValue,
    required this.completedPages,
    required this.lastReadPage,
    required this.lastUpdated,
    required this.isCompleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['plan_type'] = Variable<String>(planType);
    map['plan_value'] = Variable<int>(planValue);
    map['completed_pages'] = Variable<int>(completedPages);
    map['last_read_page'] = Variable<int>(lastReadPage);
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    map['is_completed'] = Variable<bool>(isCompleted);
    return map;
  }

  WirdProgressCompanion toCompanion(bool nullToAbsent) {
    return WirdProgressCompanion(
      id: Value(id),
      planType: Value(planType),
      planValue: Value(planValue),
      completedPages: Value(completedPages),
      lastReadPage: Value(lastReadPage),
      lastUpdated: Value(lastUpdated),
      isCompleted: Value(isCompleted),
    );
  }

  factory WirdProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WirdProgressData(
      id: serializer.fromJson<int>(json['id']),
      planType: serializer.fromJson<String>(json['planType']),
      planValue: serializer.fromJson<int>(json['planValue']),
      completedPages: serializer.fromJson<int>(json['completedPages']),
      lastReadPage: serializer.fromJson<int>(json['lastReadPage']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'planType': serializer.toJson<String>(planType),
      'planValue': serializer.toJson<int>(planValue),
      'completedPages': serializer.toJson<int>(completedPages),
      'lastReadPage': serializer.toJson<int>(lastReadPage),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
      'isCompleted': serializer.toJson<bool>(isCompleted),
    };
  }

  WirdProgressData copyWith({
    int? id,
    String? planType,
    int? planValue,
    int? completedPages,
    int? lastReadPage,
    DateTime? lastUpdated,
    bool? isCompleted,
  }) => WirdProgressData(
    id: id ?? this.id,
    planType: planType ?? this.planType,
    planValue: planValue ?? this.planValue,
    completedPages: completedPages ?? this.completedPages,
    lastReadPage: lastReadPage ?? this.lastReadPage,
    lastUpdated: lastUpdated ?? this.lastUpdated,
    isCompleted: isCompleted ?? this.isCompleted,
  );
  WirdProgressData copyWithCompanion(WirdProgressCompanion data) {
    return WirdProgressData(
      id: data.id.present ? data.id.value : this.id,
      planType: data.planType.present ? data.planType.value : this.planType,
      planValue: data.planValue.present ? data.planValue.value : this.planValue,
      completedPages: data.completedPages.present
          ? data.completedPages.value
          : this.completedPages,
      lastReadPage: data.lastReadPage.present
          ? data.lastReadPage.value
          : this.lastReadPage,
      lastUpdated: data.lastUpdated.present
          ? data.lastUpdated.value
          : this.lastUpdated,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WirdProgressData(')
          ..write('id: $id, ')
          ..write('planType: $planType, ')
          ..write('planValue: $planValue, ')
          ..write('completedPages: $completedPages, ')
          ..write('lastReadPage: $lastReadPage, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isCompleted: $isCompleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    planType,
    planValue,
    completedPages,
    lastReadPage,
    lastUpdated,
    isCompleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WirdProgressData &&
          other.id == this.id &&
          other.planType == this.planType &&
          other.planValue == this.planValue &&
          other.completedPages == this.completedPages &&
          other.lastReadPage == this.lastReadPage &&
          other.lastUpdated == this.lastUpdated &&
          other.isCompleted == this.isCompleted);
}

class WirdProgressCompanion extends UpdateCompanion<WirdProgressData> {
  final Value<int> id;
  final Value<String> planType;
  final Value<int> planValue;
  final Value<int> completedPages;
  final Value<int> lastReadPage;
  final Value<DateTime> lastUpdated;
  final Value<bool> isCompleted;
  const WirdProgressCompanion({
    this.id = const Value.absent(),
    this.planType = const Value.absent(),
    this.planValue = const Value.absent(),
    this.completedPages = const Value.absent(),
    this.lastReadPage = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isCompleted = const Value.absent(),
  });
  WirdProgressCompanion.insert({
    this.id = const Value.absent(),
    required String planType,
    required int planValue,
    this.completedPages = const Value.absent(),
    this.lastReadPage = const Value.absent(),
    required DateTime lastUpdated,
    this.isCompleted = const Value.absent(),
  }) : planType = Value(planType),
       planValue = Value(planValue),
       lastUpdated = Value(lastUpdated);
  static Insertable<WirdProgressData> custom({
    Expression<int>? id,
    Expression<String>? planType,
    Expression<int>? planValue,
    Expression<int>? completedPages,
    Expression<int>? lastReadPage,
    Expression<DateTime>? lastUpdated,
    Expression<bool>? isCompleted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (planType != null) 'plan_type': planType,
      if (planValue != null) 'plan_value': planValue,
      if (completedPages != null) 'completed_pages': completedPages,
      if (lastReadPage != null) 'last_read_page': lastReadPage,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (isCompleted != null) 'is_completed': isCompleted,
    });
  }

  WirdProgressCompanion copyWith({
    Value<int>? id,
    Value<String>? planType,
    Value<int>? planValue,
    Value<int>? completedPages,
    Value<int>? lastReadPage,
    Value<DateTime>? lastUpdated,
    Value<bool>? isCompleted,
  }) {
    return WirdProgressCompanion(
      id: id ?? this.id,
      planType: planType ?? this.planType,
      planValue: planValue ?? this.planValue,
      completedPages: completedPages ?? this.completedPages,
      lastReadPage: lastReadPage ?? this.lastReadPage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (planType.present) {
      map['plan_type'] = Variable<String>(planType.value);
    }
    if (planValue.present) {
      map['plan_value'] = Variable<int>(planValue.value);
    }
    if (completedPages.present) {
      map['completed_pages'] = Variable<int>(completedPages.value);
    }
    if (lastReadPage.present) {
      map['last_read_page'] = Variable<int>(lastReadPage.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WirdProgressCompanion(')
          ..write('id: $id, ')
          ..write('planType: $planType, ')
          ..write('planValue: $planValue, ')
          ..write('completedPages: $completedPages, ')
          ..write('lastReadPage: $lastReadPage, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isCompleted: $isCompleted')
          ..write(')'))
        .toString();
  }
}

class $WirdDailyLogsTable extends WirdDailyLogs
    with TableInfo<$WirdDailyLogsTable, WirdDailyLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WirdDailyLogsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fajrPagesMeta = const VerificationMeta(
    'fajrPages',
  );
  @override
  late final GeneratedColumn<int> fajrPages = GeneratedColumn<int>(
    'fajr_pages',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dhuhrPagesMeta = const VerificationMeta(
    'dhuhrPages',
  );
  @override
  late final GeneratedColumn<int> dhuhrPages = GeneratedColumn<int>(
    'dhuhr_pages',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _asrPagesMeta = const VerificationMeta(
    'asrPages',
  );
  @override
  late final GeneratedColumn<int> asrPages = GeneratedColumn<int>(
    'asr_pages',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _maghribPagesMeta = const VerificationMeta(
    'maghribPages',
  );
  @override
  late final GeneratedColumn<int> maghribPages = GeneratedColumn<int>(
    'maghrib_pages',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _ishaPagesMeta = const VerificationMeta(
    'ishaPages',
  );
  @override
  late final GeneratedColumn<int> ishaPages = GeneratedColumn<int>(
    'isha_pages',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _otherPagesMeta = const VerificationMeta(
    'otherPages',
  );
  @override
  late final GeneratedColumn<int> otherPages = GeneratedColumn<int>(
    'other_pages',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    fajrPages,
    dhuhrPages,
    asrPages,
    maghribPages,
    ishaPages,
    otherPages,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wird_daily_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<WirdDailyLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('fajr_pages')) {
      context.handle(
        _fajrPagesMeta,
        fajrPages.isAcceptableOrUnknown(data['fajr_pages']!, _fajrPagesMeta),
      );
    }
    if (data.containsKey('dhuhr_pages')) {
      context.handle(
        _dhuhrPagesMeta,
        dhuhrPages.isAcceptableOrUnknown(data['dhuhr_pages']!, _dhuhrPagesMeta),
      );
    }
    if (data.containsKey('asr_pages')) {
      context.handle(
        _asrPagesMeta,
        asrPages.isAcceptableOrUnknown(data['asr_pages']!, _asrPagesMeta),
      );
    }
    if (data.containsKey('maghrib_pages')) {
      context.handle(
        _maghribPagesMeta,
        maghribPages.isAcceptableOrUnknown(
          data['maghrib_pages']!,
          _maghribPagesMeta,
        ),
      );
    }
    if (data.containsKey('isha_pages')) {
      context.handle(
        _ishaPagesMeta,
        ishaPages.isAcceptableOrUnknown(data['isha_pages']!, _ishaPagesMeta),
      );
    }
    if (data.containsKey('other_pages')) {
      context.handle(
        _otherPagesMeta,
        otherPages.isAcceptableOrUnknown(data['other_pages']!, _otherPagesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WirdDailyLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WirdDailyLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      fajrPages: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fajr_pages'],
      )!,
      dhuhrPages: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dhuhr_pages'],
      )!,
      asrPages: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}asr_pages'],
      )!,
      maghribPages: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}maghrib_pages'],
      )!,
      ishaPages: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}isha_pages'],
      )!,
      otherPages: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}other_pages'],
      )!,
    );
  }

  @override
  $WirdDailyLogsTable createAlias(String alias) {
    return $WirdDailyLogsTable(attachedDatabase, alias);
  }
}

class WirdDailyLog extends DataClass implements Insertable<WirdDailyLog> {
  final int id;
  final DateTime date;
  final int fajrPages;
  final int dhuhrPages;
  final int asrPages;
  final int maghribPages;
  final int ishaPages;
  final int otherPages;
  const WirdDailyLog({
    required this.id,
    required this.date,
    required this.fajrPages,
    required this.dhuhrPages,
    required this.asrPages,
    required this.maghribPages,
    required this.ishaPages,
    required this.otherPages,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['fajr_pages'] = Variable<int>(fajrPages);
    map['dhuhr_pages'] = Variable<int>(dhuhrPages);
    map['asr_pages'] = Variable<int>(asrPages);
    map['maghrib_pages'] = Variable<int>(maghribPages);
    map['isha_pages'] = Variable<int>(ishaPages);
    map['other_pages'] = Variable<int>(otherPages);
    return map;
  }

  WirdDailyLogsCompanion toCompanion(bool nullToAbsent) {
    return WirdDailyLogsCompanion(
      id: Value(id),
      date: Value(date),
      fajrPages: Value(fajrPages),
      dhuhrPages: Value(dhuhrPages),
      asrPages: Value(asrPages),
      maghribPages: Value(maghribPages),
      ishaPages: Value(ishaPages),
      otherPages: Value(otherPages),
    );
  }

  factory WirdDailyLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WirdDailyLog(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      fajrPages: serializer.fromJson<int>(json['fajrPages']),
      dhuhrPages: serializer.fromJson<int>(json['dhuhrPages']),
      asrPages: serializer.fromJson<int>(json['asrPages']),
      maghribPages: serializer.fromJson<int>(json['maghribPages']),
      ishaPages: serializer.fromJson<int>(json['ishaPages']),
      otherPages: serializer.fromJson<int>(json['otherPages']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'fajrPages': serializer.toJson<int>(fajrPages),
      'dhuhrPages': serializer.toJson<int>(dhuhrPages),
      'asrPages': serializer.toJson<int>(asrPages),
      'maghribPages': serializer.toJson<int>(maghribPages),
      'ishaPages': serializer.toJson<int>(ishaPages),
      'otherPages': serializer.toJson<int>(otherPages),
    };
  }

  WirdDailyLog copyWith({
    int? id,
    DateTime? date,
    int? fajrPages,
    int? dhuhrPages,
    int? asrPages,
    int? maghribPages,
    int? ishaPages,
    int? otherPages,
  }) => WirdDailyLog(
    id: id ?? this.id,
    date: date ?? this.date,
    fajrPages: fajrPages ?? this.fajrPages,
    dhuhrPages: dhuhrPages ?? this.dhuhrPages,
    asrPages: asrPages ?? this.asrPages,
    maghribPages: maghribPages ?? this.maghribPages,
    ishaPages: ishaPages ?? this.ishaPages,
    otherPages: otherPages ?? this.otherPages,
  );
  WirdDailyLog copyWithCompanion(WirdDailyLogsCompanion data) {
    return WirdDailyLog(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      fajrPages: data.fajrPages.present ? data.fajrPages.value : this.fajrPages,
      dhuhrPages: data.dhuhrPages.present
          ? data.dhuhrPages.value
          : this.dhuhrPages,
      asrPages: data.asrPages.present ? data.asrPages.value : this.asrPages,
      maghribPages: data.maghribPages.present
          ? data.maghribPages.value
          : this.maghribPages,
      ishaPages: data.ishaPages.present ? data.ishaPages.value : this.ishaPages,
      otherPages: data.otherPages.present
          ? data.otherPages.value
          : this.otherPages,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WirdDailyLog(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('fajrPages: $fajrPages, ')
          ..write('dhuhrPages: $dhuhrPages, ')
          ..write('asrPages: $asrPages, ')
          ..write('maghribPages: $maghribPages, ')
          ..write('ishaPages: $ishaPages, ')
          ..write('otherPages: $otherPages')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    fajrPages,
    dhuhrPages,
    asrPages,
    maghribPages,
    ishaPages,
    otherPages,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WirdDailyLog &&
          other.id == this.id &&
          other.date == this.date &&
          other.fajrPages == this.fajrPages &&
          other.dhuhrPages == this.dhuhrPages &&
          other.asrPages == this.asrPages &&
          other.maghribPages == this.maghribPages &&
          other.ishaPages == this.ishaPages &&
          other.otherPages == this.otherPages);
}

class WirdDailyLogsCompanion extends UpdateCompanion<WirdDailyLog> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<int> fajrPages;
  final Value<int> dhuhrPages;
  final Value<int> asrPages;
  final Value<int> maghribPages;
  final Value<int> ishaPages;
  final Value<int> otherPages;
  const WirdDailyLogsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.fajrPages = const Value.absent(),
    this.dhuhrPages = const Value.absent(),
    this.asrPages = const Value.absent(),
    this.maghribPages = const Value.absent(),
    this.ishaPages = const Value.absent(),
    this.otherPages = const Value.absent(),
  });
  WirdDailyLogsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    this.fajrPages = const Value.absent(),
    this.dhuhrPages = const Value.absent(),
    this.asrPages = const Value.absent(),
    this.maghribPages = const Value.absent(),
    this.ishaPages = const Value.absent(),
    this.otherPages = const Value.absent(),
  }) : date = Value(date);
  static Insertable<WirdDailyLog> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<int>? fajrPages,
    Expression<int>? dhuhrPages,
    Expression<int>? asrPages,
    Expression<int>? maghribPages,
    Expression<int>? ishaPages,
    Expression<int>? otherPages,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (fajrPages != null) 'fajr_pages': fajrPages,
      if (dhuhrPages != null) 'dhuhr_pages': dhuhrPages,
      if (asrPages != null) 'asr_pages': asrPages,
      if (maghribPages != null) 'maghrib_pages': maghribPages,
      if (ishaPages != null) 'isha_pages': ishaPages,
      if (otherPages != null) 'other_pages': otherPages,
    });
  }

  WirdDailyLogsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<int>? fajrPages,
    Value<int>? dhuhrPages,
    Value<int>? asrPages,
    Value<int>? maghribPages,
    Value<int>? ishaPages,
    Value<int>? otherPages,
  }) {
    return WirdDailyLogsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      fajrPages: fajrPages ?? this.fajrPages,
      dhuhrPages: dhuhrPages ?? this.dhuhrPages,
      asrPages: asrPages ?? this.asrPages,
      maghribPages: maghribPages ?? this.maghribPages,
      ishaPages: ishaPages ?? this.ishaPages,
      otherPages: otherPages ?? this.otherPages,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (fajrPages.present) {
      map['fajr_pages'] = Variable<int>(fajrPages.value);
    }
    if (dhuhrPages.present) {
      map['dhuhr_pages'] = Variable<int>(dhuhrPages.value);
    }
    if (asrPages.present) {
      map['asr_pages'] = Variable<int>(asrPages.value);
    }
    if (maghribPages.present) {
      map['maghrib_pages'] = Variable<int>(maghribPages.value);
    }
    if (ishaPages.present) {
      map['isha_pages'] = Variable<int>(ishaPages.value);
    }
    if (otherPages.present) {
      map['other_pages'] = Variable<int>(otherPages.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WirdDailyLogsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('fajrPages: $fajrPages, ')
          ..write('dhuhrPages: $dhuhrPages, ')
          ..write('asrPages: $asrPages, ')
          ..write('maghribPages: $maghribPages, ')
          ..write('ishaPages: $ishaPages, ')
          ..write('otherPages: $otherPages')
          ..write(')'))
        .toString();
  }
}

class $FeatureDocumentsTable extends FeatureDocuments
    with TableInfo<$FeatureDocumentsTable, FeatureDocument> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeatureDocumentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _namespaceMeta = const VerificationMeta(
    'namespace',
  );
  @override
  late final GeneratedColumn<String> namespace = GeneratedColumn<String>(
    'namespace',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<String> documentId = GeneratedColumn<String>(
    'document_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadVersionMeta = const VerificationMeta(
    'payloadVersion',
  );
  @override
  late final GeneratedColumn<int> payloadVersion = GeneratedColumn<int>(
    'payload_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortKeyMeta = const VerificationMeta(
    'sortKey',
  );
  @override
  late final GeneratedColumn<String> sortKey = GeneratedColumn<String>(
    'sort_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pendingSyncMeta = const VerificationMeta(
    'pendingSync',
  );
  @override
  late final GeneratedColumn<bool> pendingSync = GeneratedColumn<bool>(
    'pending_sync',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending_sync" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    namespace,
    documentId,
    payload,
    revision,
    payloadVersion,
    updatedAt,
    sortKey,
    deletedAt,
    pendingSync,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feature_documents';
  @override
  VerificationContext validateIntegrity(
    Insertable<FeatureDocument> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('namespace')) {
      context.handle(
        _namespaceMeta,
        namespace.isAcceptableOrUnknown(data['namespace']!, _namespaceMeta),
      );
    } else if (isInserting) {
      context.missing(_namespaceMeta);
    }
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_documentIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    if (data.containsKey('payload_version')) {
      context.handle(
        _payloadVersionMeta,
        payloadVersion.isAcceptableOrUnknown(
          data['payload_version']!,
          _payloadVersionMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sort_key')) {
      context.handle(
        _sortKeyMeta,
        sortKey.isAcceptableOrUnknown(data['sort_key']!, _sortKeyMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('pending_sync')) {
      context.handle(
        _pendingSyncMeta,
        pendingSync.isAcceptableOrUnknown(
          data['pending_sync']!,
          _pendingSyncMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {namespace, documentId};
  @override
  FeatureDocument map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeatureDocument(
      namespace: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}namespace'],
      )!,
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      payloadVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payload_version'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      sortKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sort_key'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      pendingSync: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending_sync'],
      )!,
    );
  }

  @override
  $FeatureDocumentsTable createAlias(String alias) {
    return $FeatureDocumentsTable(attachedDatabase, alias);
  }
}

class FeatureDocument extends DataClass implements Insertable<FeatureDocument> {
  final String namespace;
  final String documentId;
  final String payload;
  final int revision;
  final int payloadVersion;
  final DateTime updatedAt;
  final String? sortKey;
  final DateTime? deletedAt;
  final bool pendingSync;
  const FeatureDocument({
    required this.namespace,
    required this.documentId,
    required this.payload,
    required this.revision,
    required this.payloadVersion,
    required this.updatedAt,
    this.sortKey,
    this.deletedAt,
    required this.pendingSync,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['namespace'] = Variable<String>(namespace);
    map['document_id'] = Variable<String>(documentId);
    map['payload'] = Variable<String>(payload);
    map['revision'] = Variable<int>(revision);
    map['payload_version'] = Variable<int>(payloadVersion);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || sortKey != null) {
      map['sort_key'] = Variable<String>(sortKey);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['pending_sync'] = Variable<bool>(pendingSync);
    return map;
  }

  FeatureDocumentsCompanion toCompanion(bool nullToAbsent) {
    return FeatureDocumentsCompanion(
      namespace: Value(namespace),
      documentId: Value(documentId),
      payload: Value(payload),
      revision: Value(revision),
      payloadVersion: Value(payloadVersion),
      updatedAt: Value(updatedAt),
      sortKey: sortKey == null && nullToAbsent
          ? const Value.absent()
          : Value(sortKey),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      pendingSync: Value(pendingSync),
    );
  }

  factory FeatureDocument.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeatureDocument(
      namespace: serializer.fromJson<String>(json['namespace']),
      documentId: serializer.fromJson<String>(json['documentId']),
      payload: serializer.fromJson<String>(json['payload']),
      revision: serializer.fromJson<int>(json['revision']),
      payloadVersion: serializer.fromJson<int>(json['payloadVersion']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      sortKey: serializer.fromJson<String?>(json['sortKey']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      pendingSync: serializer.fromJson<bool>(json['pendingSync']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'namespace': serializer.toJson<String>(namespace),
      'documentId': serializer.toJson<String>(documentId),
      'payload': serializer.toJson<String>(payload),
      'revision': serializer.toJson<int>(revision),
      'payloadVersion': serializer.toJson<int>(payloadVersion),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'sortKey': serializer.toJson<String?>(sortKey),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'pendingSync': serializer.toJson<bool>(pendingSync),
    };
  }

  FeatureDocument copyWith({
    String? namespace,
    String? documentId,
    String? payload,
    int? revision,
    int? payloadVersion,
    DateTime? updatedAt,
    Value<String?> sortKey = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
    bool? pendingSync,
  }) => FeatureDocument(
    namespace: namespace ?? this.namespace,
    documentId: documentId ?? this.documentId,
    payload: payload ?? this.payload,
    revision: revision ?? this.revision,
    payloadVersion: payloadVersion ?? this.payloadVersion,
    updatedAt: updatedAt ?? this.updatedAt,
    sortKey: sortKey.present ? sortKey.value : this.sortKey,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    pendingSync: pendingSync ?? this.pendingSync,
  );
  FeatureDocument copyWithCompanion(FeatureDocumentsCompanion data) {
    return FeatureDocument(
      namespace: data.namespace.present ? data.namespace.value : this.namespace,
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      payload: data.payload.present ? data.payload.value : this.payload,
      revision: data.revision.present ? data.revision.value : this.revision,
      payloadVersion: data.payloadVersion.present
          ? data.payloadVersion.value
          : this.payloadVersion,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      sortKey: data.sortKey.present ? data.sortKey.value : this.sortKey,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      pendingSync: data.pendingSync.present
          ? data.pendingSync.value
          : this.pendingSync,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeatureDocument(')
          ..write('namespace: $namespace, ')
          ..write('documentId: $documentId, ')
          ..write('payload: $payload, ')
          ..write('revision: $revision, ')
          ..write('payloadVersion: $payloadVersion, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('sortKey: $sortKey, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('pendingSync: $pendingSync')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    namespace,
    documentId,
    payload,
    revision,
    payloadVersion,
    updatedAt,
    sortKey,
    deletedAt,
    pendingSync,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeatureDocument &&
          other.namespace == this.namespace &&
          other.documentId == this.documentId &&
          other.payload == this.payload &&
          other.revision == this.revision &&
          other.payloadVersion == this.payloadVersion &&
          other.updatedAt == this.updatedAt &&
          other.sortKey == this.sortKey &&
          other.deletedAt == this.deletedAt &&
          other.pendingSync == this.pendingSync);
}

class FeatureDocumentsCompanion extends UpdateCompanion<FeatureDocument> {
  final Value<String> namespace;
  final Value<String> documentId;
  final Value<String> payload;
  final Value<int> revision;
  final Value<int> payloadVersion;
  final Value<DateTime> updatedAt;
  final Value<String?> sortKey;
  final Value<DateTime?> deletedAt;
  final Value<bool> pendingSync;
  final Value<int> rowid;
  const FeatureDocumentsCompanion({
    this.namespace = const Value.absent(),
    this.documentId = const Value.absent(),
    this.payload = const Value.absent(),
    this.revision = const Value.absent(),
    this.payloadVersion = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.sortKey = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.pendingSync = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FeatureDocumentsCompanion.insert({
    required String namespace,
    required String documentId,
    required String payload,
    required int revision,
    this.payloadVersion = const Value.absent(),
    required DateTime updatedAt,
    this.sortKey = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.pendingSync = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : namespace = Value(namespace),
       documentId = Value(documentId),
       payload = Value(payload),
       revision = Value(revision),
       updatedAt = Value(updatedAt);
  static Insertable<FeatureDocument> custom({
    Expression<String>? namespace,
    Expression<String>? documentId,
    Expression<String>? payload,
    Expression<int>? revision,
    Expression<int>? payloadVersion,
    Expression<DateTime>? updatedAt,
    Expression<String>? sortKey,
    Expression<DateTime>? deletedAt,
    Expression<bool>? pendingSync,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (namespace != null) 'namespace': namespace,
      if (documentId != null) 'document_id': documentId,
      if (payload != null) 'payload': payload,
      if (revision != null) 'revision': revision,
      if (payloadVersion != null) 'payload_version': payloadVersion,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (sortKey != null) 'sort_key': sortKey,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (pendingSync != null) 'pending_sync': pendingSync,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FeatureDocumentsCompanion copyWith({
    Value<String>? namespace,
    Value<String>? documentId,
    Value<String>? payload,
    Value<int>? revision,
    Value<int>? payloadVersion,
    Value<DateTime>? updatedAt,
    Value<String?>? sortKey,
    Value<DateTime?>? deletedAt,
    Value<bool>? pendingSync,
    Value<int>? rowid,
  }) {
    return FeatureDocumentsCompanion(
      namespace: namespace ?? this.namespace,
      documentId: documentId ?? this.documentId,
      payload: payload ?? this.payload,
      revision: revision ?? this.revision,
      payloadVersion: payloadVersion ?? this.payloadVersion,
      updatedAt: updatedAt ?? this.updatedAt,
      sortKey: sortKey ?? this.sortKey,
      deletedAt: deletedAt ?? this.deletedAt,
      pendingSync: pendingSync ?? this.pendingSync,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (namespace.present) {
      map['namespace'] = Variable<String>(namespace.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<String>(documentId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (payloadVersion.present) {
      map['payload_version'] = Variable<int>(payloadVersion.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (sortKey.present) {
      map['sort_key'] = Variable<String>(sortKey.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (pendingSync.present) {
      map['pending_sync'] = Variable<bool>(pendingSync.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeatureDocumentsCompanion(')
          ..write('namespace: $namespace, ')
          ..write('documentId: $documentId, ')
          ..write('payload: $payload, ')
          ..write('revision: $revision, ')
          ..write('payloadVersion: $payloadVersion, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('sortKey: $sortKey, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('pendingSync: $pendingSync, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PrayerLogsTable prayerLogs = $PrayerLogsTable(this);
  late final $TasbihSessionsTable tasbihSessions = $TasbihSessionsTable(this);
  late final $DuasTable duas = $DuasTable(this);
  late final $WirdProgressTable wirdProgress = $WirdProgressTable(this);
  late final $WirdDailyLogsTable wirdDailyLogs = $WirdDailyLogsTable(this);
  late final $FeatureDocumentsTable featureDocuments = $FeatureDocumentsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    prayerLogs,
    tasbihSessions,
    duas,
    wirdProgress,
    wirdDailyLogs,
    featureDocuments,
  ];
}

typedef $$PrayerLogsTableCreateCompanionBuilder =
    PrayerLogsCompanion Function({
      Value<int> id,
      required String prayerName,
      required DateTime prayerTime,
      Value<bool> completed,
      Value<DateTime?> completedAt,
    });
typedef $$PrayerLogsTableUpdateCompanionBuilder =
    PrayerLogsCompanion Function({
      Value<int> id,
      Value<String> prayerName,
      Value<DateTime> prayerTime,
      Value<bool> completed,
      Value<DateTime?> completedAt,
    });

class $$PrayerLogsTableFilterComposer
    extends Composer<_$AppDatabase, $PrayerLogsTable> {
  $$PrayerLogsTableFilterComposer({
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

  ColumnFilters<String> get prayerName => $composableBuilder(
    column: $table.prayerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get prayerTime => $composableBuilder(
    column: $table.prayerTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PrayerLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $PrayerLogsTable> {
  $$PrayerLogsTableOrderingComposer({
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

  ColumnOrderings<String> get prayerName => $composableBuilder(
    column: $table.prayerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get prayerTime => $composableBuilder(
    column: $table.prayerTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PrayerLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PrayerLogsTable> {
  $$PrayerLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get prayerName => $composableBuilder(
    column: $table.prayerName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get prayerTime => $composableBuilder(
    column: $table.prayerTime,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$PrayerLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PrayerLogsTable,
          PrayerLog,
          $$PrayerLogsTableFilterComposer,
          $$PrayerLogsTableOrderingComposer,
          $$PrayerLogsTableAnnotationComposer,
          $$PrayerLogsTableCreateCompanionBuilder,
          $$PrayerLogsTableUpdateCompanionBuilder,
          (
            PrayerLog,
            BaseReferences<_$AppDatabase, $PrayerLogsTable, PrayerLog>,
          ),
          PrayerLog,
          PrefetchHooks Function()
        > {
  $$PrayerLogsTableTableManager(_$AppDatabase db, $PrayerLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PrayerLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PrayerLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PrayerLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> prayerName = const Value.absent(),
                Value<DateTime> prayerTime = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
              }) => PrayerLogsCompanion(
                id: id,
                prayerName: prayerName,
                prayerTime: prayerTime,
                completed: completed,
                completedAt: completedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String prayerName,
                required DateTime prayerTime,
                Value<bool> completed = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
              }) => PrayerLogsCompanion.insert(
                id: id,
                prayerName: prayerName,
                prayerTime: prayerTime,
                completed: completed,
                completedAt: completedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PrayerLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PrayerLogsTable,
      PrayerLog,
      $$PrayerLogsTableFilterComposer,
      $$PrayerLogsTableOrderingComposer,
      $$PrayerLogsTableAnnotationComposer,
      $$PrayerLogsTableCreateCompanionBuilder,
      $$PrayerLogsTableUpdateCompanionBuilder,
      (PrayerLog, BaseReferences<_$AppDatabase, $PrayerLogsTable, PrayerLog>),
      PrayerLog,
      PrefetchHooks Function()
    >;
typedef $$TasbihSessionsTableCreateCompanionBuilder =
    TasbihSessionsCompanion Function({
      Value<int> id,
      required String dhikrName,
      required int count,
      required int targetCount,
      required DateTime createdAt,
      Value<DateTime?> completedAt,
    });
typedef $$TasbihSessionsTableUpdateCompanionBuilder =
    TasbihSessionsCompanion Function({
      Value<int> id,
      Value<String> dhikrName,
      Value<int> count,
      Value<int> targetCount,
      Value<DateTime> createdAt,
      Value<DateTime?> completedAt,
    });

class $$TasbihSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $TasbihSessionsTable> {
  $$TasbihSessionsTableFilterComposer({
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

  ColumnFilters<String> get dhikrName => $composableBuilder(
    column: $table.dhikrName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetCount => $composableBuilder(
    column: $table.targetCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TasbihSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TasbihSessionsTable> {
  $$TasbihSessionsTableOrderingComposer({
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

  ColumnOrderings<String> get dhikrName => $composableBuilder(
    column: $table.dhikrName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetCount => $composableBuilder(
    column: $table.targetCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasbihSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasbihSessionsTable> {
  $$TasbihSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dhikrName =>
      $composableBuilder(column: $table.dhikrName, builder: (column) => column);

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);

  GeneratedColumn<int> get targetCount => $composableBuilder(
    column: $table.targetCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$TasbihSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasbihSessionsTable,
          TasbihSession,
          $$TasbihSessionsTableFilterComposer,
          $$TasbihSessionsTableOrderingComposer,
          $$TasbihSessionsTableAnnotationComposer,
          $$TasbihSessionsTableCreateCompanionBuilder,
          $$TasbihSessionsTableUpdateCompanionBuilder,
          (
            TasbihSession,
            BaseReferences<_$AppDatabase, $TasbihSessionsTable, TasbihSession>,
          ),
          TasbihSession,
          PrefetchHooks Function()
        > {
  $$TasbihSessionsTableTableManager(
    _$AppDatabase db,
    $TasbihSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasbihSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasbihSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasbihSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> dhikrName = const Value.absent(),
                Value<int> count = const Value.absent(),
                Value<int> targetCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
              }) => TasbihSessionsCompanion(
                id: id,
                dhikrName: dhikrName,
                count: count,
                targetCount: targetCount,
                createdAt: createdAt,
                completedAt: completedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String dhikrName,
                required int count,
                required int targetCount,
                required DateTime createdAt,
                Value<DateTime?> completedAt = const Value.absent(),
              }) => TasbihSessionsCompanion.insert(
                id: id,
                dhikrName: dhikrName,
                count: count,
                targetCount: targetCount,
                createdAt: createdAt,
                completedAt: completedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TasbihSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasbihSessionsTable,
      TasbihSession,
      $$TasbihSessionsTableFilterComposer,
      $$TasbihSessionsTableOrderingComposer,
      $$TasbihSessionsTableAnnotationComposer,
      $$TasbihSessionsTableCreateCompanionBuilder,
      $$TasbihSessionsTableUpdateCompanionBuilder,
      (
        TasbihSession,
        BaseReferences<_$AppDatabase, $TasbihSessionsTable, TasbihSession>,
      ),
      TasbihSession,
      PrefetchHooks Function()
    >;
typedef $$DuasTableCreateCompanionBuilder =
    DuasCompanion Function({
      Value<int> id,
      required String category,
      required String arabicText,
      Value<String?> transliteration,
      required String translation,
      Value<String?> audioPath,
    });
typedef $$DuasTableUpdateCompanionBuilder =
    DuasCompanion Function({
      Value<int> id,
      Value<String> category,
      Value<String> arabicText,
      Value<String?> transliteration,
      Value<String> translation,
      Value<String?> audioPath,
    });

class $$DuasTableFilterComposer extends Composer<_$AppDatabase, $DuasTable> {
  $$DuasTableFilterComposer({
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

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get arabicText => $composableBuilder(
    column: $table.arabicText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transliteration => $composableBuilder(
    column: $table.transliteration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioPath => $composableBuilder(
    column: $table.audioPath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DuasTableOrderingComposer extends Composer<_$AppDatabase, $DuasTable> {
  $$DuasTableOrderingComposer({
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

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get arabicText => $composableBuilder(
    column: $table.arabicText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transliteration => $composableBuilder(
    column: $table.transliteration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioPath => $composableBuilder(
    column: $table.audioPath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DuasTableAnnotationComposer
    extends Composer<_$AppDatabase, $DuasTable> {
  $$DuasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get arabicText => $composableBuilder(
    column: $table.arabicText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transliteration => $composableBuilder(
    column: $table.transliteration,
    builder: (column) => column,
  );

  GeneratedColumn<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get audioPath =>
      $composableBuilder(column: $table.audioPath, builder: (column) => column);
}

class $$DuasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DuasTable,
          Dua,
          $$DuasTableFilterComposer,
          $$DuasTableOrderingComposer,
          $$DuasTableAnnotationComposer,
          $$DuasTableCreateCompanionBuilder,
          $$DuasTableUpdateCompanionBuilder,
          (Dua, BaseReferences<_$AppDatabase, $DuasTable, Dua>),
          Dua,
          PrefetchHooks Function()
        > {
  $$DuasTableTableManager(_$AppDatabase db, $DuasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DuasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DuasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DuasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> arabicText = const Value.absent(),
                Value<String?> transliteration = const Value.absent(),
                Value<String> translation = const Value.absent(),
                Value<String?> audioPath = const Value.absent(),
              }) => DuasCompanion(
                id: id,
                category: category,
                arabicText: arabicText,
                transliteration: transliteration,
                translation: translation,
                audioPath: audioPath,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String category,
                required String arabicText,
                Value<String?> transliteration = const Value.absent(),
                required String translation,
                Value<String?> audioPath = const Value.absent(),
              }) => DuasCompanion.insert(
                id: id,
                category: category,
                arabicText: arabicText,
                transliteration: transliteration,
                translation: translation,
                audioPath: audioPath,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DuasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DuasTable,
      Dua,
      $$DuasTableFilterComposer,
      $$DuasTableOrderingComposer,
      $$DuasTableAnnotationComposer,
      $$DuasTableCreateCompanionBuilder,
      $$DuasTableUpdateCompanionBuilder,
      (Dua, BaseReferences<_$AppDatabase, $DuasTable, Dua>),
      Dua,
      PrefetchHooks Function()
    >;
typedef $$WirdProgressTableCreateCompanionBuilder =
    WirdProgressCompanion Function({
      Value<int> id,
      required String planType,
      required int planValue,
      Value<int> completedPages,
      Value<int> lastReadPage,
      required DateTime lastUpdated,
      Value<bool> isCompleted,
    });
typedef $$WirdProgressTableUpdateCompanionBuilder =
    WirdProgressCompanion Function({
      Value<int> id,
      Value<String> planType,
      Value<int> planValue,
      Value<int> completedPages,
      Value<int> lastReadPage,
      Value<DateTime> lastUpdated,
      Value<bool> isCompleted,
    });

class $$WirdProgressTableFilterComposer
    extends Composer<_$AppDatabase, $WirdProgressTable> {
  $$WirdProgressTableFilterComposer({
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

  ColumnFilters<String> get planType => $composableBuilder(
    column: $table.planType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get planValue => $composableBuilder(
    column: $table.planValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedPages => $composableBuilder(
    column: $table.completedPages,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastReadPage => $composableBuilder(
    column: $table.lastReadPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WirdProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $WirdProgressTable> {
  $$WirdProgressTableOrderingComposer({
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

  ColumnOrderings<String> get planType => $composableBuilder(
    column: $table.planType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get planValue => $composableBuilder(
    column: $table.planValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedPages => $composableBuilder(
    column: $table.completedPages,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastReadPage => $composableBuilder(
    column: $table.lastReadPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WirdProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $WirdProgressTable> {
  $$WirdProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get planType =>
      $composableBuilder(column: $table.planType, builder: (column) => column);

  GeneratedColumn<int> get planValue =>
      $composableBuilder(column: $table.planValue, builder: (column) => column);

  GeneratedColumn<int> get completedPages => $composableBuilder(
    column: $table.completedPages,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastReadPage => $composableBuilder(
    column: $table.lastReadPage,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );
}

class $$WirdProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WirdProgressTable,
          WirdProgressData,
          $$WirdProgressTableFilterComposer,
          $$WirdProgressTableOrderingComposer,
          $$WirdProgressTableAnnotationComposer,
          $$WirdProgressTableCreateCompanionBuilder,
          $$WirdProgressTableUpdateCompanionBuilder,
          (
            WirdProgressData,
            BaseReferences<_$AppDatabase, $WirdProgressTable, WirdProgressData>,
          ),
          WirdProgressData,
          PrefetchHooks Function()
        > {
  $$WirdProgressTableTableManager(_$AppDatabase db, $WirdProgressTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WirdProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WirdProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WirdProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> planType = const Value.absent(),
                Value<int> planValue = const Value.absent(),
                Value<int> completedPages = const Value.absent(),
                Value<int> lastReadPage = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
              }) => WirdProgressCompanion(
                id: id,
                planType: planType,
                planValue: planValue,
                completedPages: completedPages,
                lastReadPage: lastReadPage,
                lastUpdated: lastUpdated,
                isCompleted: isCompleted,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String planType,
                required int planValue,
                Value<int> completedPages = const Value.absent(),
                Value<int> lastReadPage = const Value.absent(),
                required DateTime lastUpdated,
                Value<bool> isCompleted = const Value.absent(),
              }) => WirdProgressCompanion.insert(
                id: id,
                planType: planType,
                planValue: planValue,
                completedPages: completedPages,
                lastReadPage: lastReadPage,
                lastUpdated: lastUpdated,
                isCompleted: isCompleted,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WirdProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WirdProgressTable,
      WirdProgressData,
      $$WirdProgressTableFilterComposer,
      $$WirdProgressTableOrderingComposer,
      $$WirdProgressTableAnnotationComposer,
      $$WirdProgressTableCreateCompanionBuilder,
      $$WirdProgressTableUpdateCompanionBuilder,
      (
        WirdProgressData,
        BaseReferences<_$AppDatabase, $WirdProgressTable, WirdProgressData>,
      ),
      WirdProgressData,
      PrefetchHooks Function()
    >;
typedef $$WirdDailyLogsTableCreateCompanionBuilder =
    WirdDailyLogsCompanion Function({
      Value<int> id,
      required DateTime date,
      Value<int> fajrPages,
      Value<int> dhuhrPages,
      Value<int> asrPages,
      Value<int> maghribPages,
      Value<int> ishaPages,
      Value<int> otherPages,
    });
typedef $$WirdDailyLogsTableUpdateCompanionBuilder =
    WirdDailyLogsCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<int> fajrPages,
      Value<int> dhuhrPages,
      Value<int> asrPages,
      Value<int> maghribPages,
      Value<int> ishaPages,
      Value<int> otherPages,
    });

class $$WirdDailyLogsTableFilterComposer
    extends Composer<_$AppDatabase, $WirdDailyLogsTable> {
  $$WirdDailyLogsTableFilterComposer({
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

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fajrPages => $composableBuilder(
    column: $table.fajrPages,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dhuhrPages => $composableBuilder(
    column: $table.dhuhrPages,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get asrPages => $composableBuilder(
    column: $table.asrPages,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maghribPages => $composableBuilder(
    column: $table.maghribPages,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ishaPages => $composableBuilder(
    column: $table.ishaPages,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get otherPages => $composableBuilder(
    column: $table.otherPages,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WirdDailyLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $WirdDailyLogsTable> {
  $$WirdDailyLogsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fajrPages => $composableBuilder(
    column: $table.fajrPages,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dhuhrPages => $composableBuilder(
    column: $table.dhuhrPages,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get asrPages => $composableBuilder(
    column: $table.asrPages,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maghribPages => $composableBuilder(
    column: $table.maghribPages,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ishaPages => $composableBuilder(
    column: $table.ishaPages,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get otherPages => $composableBuilder(
    column: $table.otherPages,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WirdDailyLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WirdDailyLogsTable> {
  $$WirdDailyLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get fajrPages =>
      $composableBuilder(column: $table.fajrPages, builder: (column) => column);

  GeneratedColumn<int> get dhuhrPages => $composableBuilder(
    column: $table.dhuhrPages,
    builder: (column) => column,
  );

  GeneratedColumn<int> get asrPages =>
      $composableBuilder(column: $table.asrPages, builder: (column) => column);

  GeneratedColumn<int> get maghribPages => $composableBuilder(
    column: $table.maghribPages,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ishaPages =>
      $composableBuilder(column: $table.ishaPages, builder: (column) => column);

  GeneratedColumn<int> get otherPages => $composableBuilder(
    column: $table.otherPages,
    builder: (column) => column,
  );
}

class $$WirdDailyLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WirdDailyLogsTable,
          WirdDailyLog,
          $$WirdDailyLogsTableFilterComposer,
          $$WirdDailyLogsTableOrderingComposer,
          $$WirdDailyLogsTableAnnotationComposer,
          $$WirdDailyLogsTableCreateCompanionBuilder,
          $$WirdDailyLogsTableUpdateCompanionBuilder,
          (
            WirdDailyLog,
            BaseReferences<_$AppDatabase, $WirdDailyLogsTable, WirdDailyLog>,
          ),
          WirdDailyLog,
          PrefetchHooks Function()
        > {
  $$WirdDailyLogsTableTableManager(_$AppDatabase db, $WirdDailyLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WirdDailyLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WirdDailyLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WirdDailyLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> fajrPages = const Value.absent(),
                Value<int> dhuhrPages = const Value.absent(),
                Value<int> asrPages = const Value.absent(),
                Value<int> maghribPages = const Value.absent(),
                Value<int> ishaPages = const Value.absent(),
                Value<int> otherPages = const Value.absent(),
              }) => WirdDailyLogsCompanion(
                id: id,
                date: date,
                fajrPages: fajrPages,
                dhuhrPages: dhuhrPages,
                asrPages: asrPages,
                maghribPages: maghribPages,
                ishaPages: ishaPages,
                otherPages: otherPages,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                Value<int> fajrPages = const Value.absent(),
                Value<int> dhuhrPages = const Value.absent(),
                Value<int> asrPages = const Value.absent(),
                Value<int> maghribPages = const Value.absent(),
                Value<int> ishaPages = const Value.absent(),
                Value<int> otherPages = const Value.absent(),
              }) => WirdDailyLogsCompanion.insert(
                id: id,
                date: date,
                fajrPages: fajrPages,
                dhuhrPages: dhuhrPages,
                asrPages: asrPages,
                maghribPages: maghribPages,
                ishaPages: ishaPages,
                otherPages: otherPages,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WirdDailyLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WirdDailyLogsTable,
      WirdDailyLog,
      $$WirdDailyLogsTableFilterComposer,
      $$WirdDailyLogsTableOrderingComposer,
      $$WirdDailyLogsTableAnnotationComposer,
      $$WirdDailyLogsTableCreateCompanionBuilder,
      $$WirdDailyLogsTableUpdateCompanionBuilder,
      (
        WirdDailyLog,
        BaseReferences<_$AppDatabase, $WirdDailyLogsTable, WirdDailyLog>,
      ),
      WirdDailyLog,
      PrefetchHooks Function()
    >;
typedef $$FeatureDocumentsTableCreateCompanionBuilder =
    FeatureDocumentsCompanion Function({
      required String namespace,
      required String documentId,
      required String payload,
      required int revision,
      Value<int> payloadVersion,
      required DateTime updatedAt,
      Value<String?> sortKey,
      Value<DateTime?> deletedAt,
      Value<bool> pendingSync,
      Value<int> rowid,
    });
typedef $$FeatureDocumentsTableUpdateCompanionBuilder =
    FeatureDocumentsCompanion Function({
      Value<String> namespace,
      Value<String> documentId,
      Value<String> payload,
      Value<int> revision,
      Value<int> payloadVersion,
      Value<DateTime> updatedAt,
      Value<String?> sortKey,
      Value<DateTime?> deletedAt,
      Value<bool> pendingSync,
      Value<int> rowid,
    });

class $$FeatureDocumentsTableFilterComposer
    extends Composer<_$AppDatabase, $FeatureDocumentsTable> {
  $$FeatureDocumentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get namespace => $composableBuilder(
    column: $table.namespace,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get payloadVersion => $composableBuilder(
    column: $table.payloadVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sortKey => $composableBuilder(
    column: $table.sortKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FeatureDocumentsTableOrderingComposer
    extends Composer<_$AppDatabase, $FeatureDocumentsTable> {
  $$FeatureDocumentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get namespace => $composableBuilder(
    column: $table.namespace,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get payloadVersion => $composableBuilder(
    column: $table.payloadVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sortKey => $composableBuilder(
    column: $table.sortKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FeatureDocumentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FeatureDocumentsTable> {
  $$FeatureDocumentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get namespace =>
      $composableBuilder(column: $table.namespace, builder: (column) => column);

  GeneratedColumn<String> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<int> get payloadVersion => $composableBuilder(
    column: $table.payloadVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get sortKey =>
      $composableBuilder(column: $table.sortKey, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => column,
  );
}

class $$FeatureDocumentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FeatureDocumentsTable,
          FeatureDocument,
          $$FeatureDocumentsTableFilterComposer,
          $$FeatureDocumentsTableOrderingComposer,
          $$FeatureDocumentsTableAnnotationComposer,
          $$FeatureDocumentsTableCreateCompanionBuilder,
          $$FeatureDocumentsTableUpdateCompanionBuilder,
          (
            FeatureDocument,
            BaseReferences<
              _$AppDatabase,
              $FeatureDocumentsTable,
              FeatureDocument
            >,
          ),
          FeatureDocument,
          PrefetchHooks Function()
        > {
  $$FeatureDocumentsTableTableManager(
    _$AppDatabase db,
    $FeatureDocumentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeatureDocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeatureDocumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeatureDocumentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> namespace = const Value.absent(),
                Value<String> documentId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> payloadVersion = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> sortKey = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> pendingSync = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FeatureDocumentsCompanion(
                namespace: namespace,
                documentId: documentId,
                payload: payload,
                revision: revision,
                payloadVersion: payloadVersion,
                updatedAt: updatedAt,
                sortKey: sortKey,
                deletedAt: deletedAt,
                pendingSync: pendingSync,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String namespace,
                required String documentId,
                required String payload,
                required int revision,
                Value<int> payloadVersion = const Value.absent(),
                required DateTime updatedAt,
                Value<String?> sortKey = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> pendingSync = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FeatureDocumentsCompanion.insert(
                namespace: namespace,
                documentId: documentId,
                payload: payload,
                revision: revision,
                payloadVersion: payloadVersion,
                updatedAt: updatedAt,
                sortKey: sortKey,
                deletedAt: deletedAt,
                pendingSync: pendingSync,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FeatureDocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FeatureDocumentsTable,
      FeatureDocument,
      $$FeatureDocumentsTableFilterComposer,
      $$FeatureDocumentsTableOrderingComposer,
      $$FeatureDocumentsTableAnnotationComposer,
      $$FeatureDocumentsTableCreateCompanionBuilder,
      $$FeatureDocumentsTableUpdateCompanionBuilder,
      (
        FeatureDocument,
        BaseReferences<_$AppDatabase, $FeatureDocumentsTable, FeatureDocument>,
      ),
      FeatureDocument,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PrayerLogsTableTableManager get prayerLogs =>
      $$PrayerLogsTableTableManager(_db, _db.prayerLogs);
  $$TasbihSessionsTableTableManager get tasbihSessions =>
      $$TasbihSessionsTableTableManager(_db, _db.tasbihSessions);
  $$DuasTableTableManager get duas => $$DuasTableTableManager(_db, _db.duas);
  $$WirdProgressTableTableManager get wirdProgress =>
      $$WirdProgressTableTableManager(_db, _db.wirdProgress);
  $$WirdDailyLogsTableTableManager get wirdDailyLogs =>
      $$WirdDailyLogsTableTableManager(_db, _db.wirdDailyLogs);
  $$FeatureDocumentsTableTableManager get featureDocuments =>
      $$FeatureDocumentsTableTableManager(_db, _db.featureDocuments);
}
