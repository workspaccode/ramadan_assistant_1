// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quran_database.dart';

// ignore_for_file: type=lint
class $SurahsTable extends Surahs with TableInfo<$SurahsTable, SurahEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SurahsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameArMeta = const VerificationMeta('nameAr');
  @override
  late final GeneratedColumn<String> nameAr = GeneratedColumn<String>(
    'name_ar',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameEnMeta = const VerificationMeta('nameEn');
  @override
  late final GeneratedColumn<String> nameEn = GeneratedColumn<String>(
    'name_en',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameTransliterationMeta =
      const VerificationMeta('nameTransliteration');
  @override
  late final GeneratedColumn<String> nameTransliteration =
      GeneratedColumn<String>(
        'name_transliteration',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _revelationPlaceArMeta = const VerificationMeta(
    'revelationPlaceAr',
  );
  @override
  late final GeneratedColumn<String> revelationPlaceAr =
      GeneratedColumn<String>(
        'revelation_place_ar',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _revelationPlaceEnMeta = const VerificationMeta(
    'revelationPlaceEn',
  );
  @override
  late final GeneratedColumn<String> revelationPlaceEn =
      GeneratedColumn<String>(
        'revelation_place_en',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _versesCountMeta = const VerificationMeta(
    'versesCount',
  );
  @override
  late final GeneratedColumn<int> versesCount = GeneratedColumn<int>(
    'verses_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wordsCountMeta = const VerificationMeta(
    'wordsCount',
  );
  @override
  late final GeneratedColumn<int> wordsCount = GeneratedColumn<int>(
    'words_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lettersCountMeta = const VerificationMeta(
    'lettersCount',
  );
  @override
  late final GeneratedColumn<int> lettersCount = GeneratedColumn<int>(
    'letters_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    number,
    nameAr,
    nameEn,
    nameTransliteration,
    revelationPlaceAr,
    revelationPlaceEn,
    versesCount,
    wordsCount,
    lettersCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'surahs';
  @override
  VerificationContext validateIntegrity(
    Insertable<SurahEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    }
    if (data.containsKey('name_ar')) {
      context.handle(
        _nameArMeta,
        nameAr.isAcceptableOrUnknown(data['name_ar']!, _nameArMeta),
      );
    } else if (isInserting) {
      context.missing(_nameArMeta);
    }
    if (data.containsKey('name_en')) {
      context.handle(
        _nameEnMeta,
        nameEn.isAcceptableOrUnknown(data['name_en']!, _nameEnMeta),
      );
    }
    if (data.containsKey('name_transliteration')) {
      context.handle(
        _nameTransliterationMeta,
        nameTransliteration.isAcceptableOrUnknown(
          data['name_transliteration']!,
          _nameTransliterationMeta,
        ),
      );
    }
    if (data.containsKey('revelation_place_ar')) {
      context.handle(
        _revelationPlaceArMeta,
        revelationPlaceAr.isAcceptableOrUnknown(
          data['revelation_place_ar']!,
          _revelationPlaceArMeta,
        ),
      );
    }
    if (data.containsKey('revelation_place_en')) {
      context.handle(
        _revelationPlaceEnMeta,
        revelationPlaceEn.isAcceptableOrUnknown(
          data['revelation_place_en']!,
          _revelationPlaceEnMeta,
        ),
      );
    }
    if (data.containsKey('verses_count')) {
      context.handle(
        _versesCountMeta,
        versesCount.isAcceptableOrUnknown(
          data['verses_count']!,
          _versesCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_versesCountMeta);
    }
    if (data.containsKey('words_count')) {
      context.handle(
        _wordsCountMeta,
        wordsCount.isAcceptableOrUnknown(data['words_count']!, _wordsCountMeta),
      );
    }
    if (data.containsKey('letters_count')) {
      context.handle(
        _lettersCountMeta,
        lettersCount.isAcceptableOrUnknown(
          data['letters_count']!,
          _lettersCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {number};
  @override
  SurahEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SurahEntity(
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number'],
      )!,
      nameAr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_ar'],
      )!,
      nameEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_en'],
      ),
      nameTransliteration: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_transliteration'],
      ),
      revelationPlaceAr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}revelation_place_ar'],
      ),
      revelationPlaceEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}revelation_place_en'],
      ),
      versesCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}verses_count'],
      )!,
      wordsCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}words_count'],
      ),
      lettersCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}letters_count'],
      ),
    );
  }

  @override
  $SurahsTable createAlias(String alias) {
    return $SurahsTable(attachedDatabase, alias);
  }
}

class SurahEntity extends DataClass implements Insertable<SurahEntity> {
  final int number;
  final String nameAr;
  final String? nameEn;
  final String? nameTransliteration;
  final String? revelationPlaceAr;
  final String? revelationPlaceEn;
  final int versesCount;
  final int? wordsCount;
  final int? lettersCount;
  const SurahEntity({
    required this.number,
    required this.nameAr,
    this.nameEn,
    this.nameTransliteration,
    this.revelationPlaceAr,
    this.revelationPlaceEn,
    required this.versesCount,
    this.wordsCount,
    this.lettersCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['number'] = Variable<int>(number);
    map['name_ar'] = Variable<String>(nameAr);
    if (!nullToAbsent || nameEn != null) {
      map['name_en'] = Variable<String>(nameEn);
    }
    if (!nullToAbsent || nameTransliteration != null) {
      map['name_transliteration'] = Variable<String>(nameTransliteration);
    }
    if (!nullToAbsent || revelationPlaceAr != null) {
      map['revelation_place_ar'] = Variable<String>(revelationPlaceAr);
    }
    if (!nullToAbsent || revelationPlaceEn != null) {
      map['revelation_place_en'] = Variable<String>(revelationPlaceEn);
    }
    map['verses_count'] = Variable<int>(versesCount);
    if (!nullToAbsent || wordsCount != null) {
      map['words_count'] = Variable<int>(wordsCount);
    }
    if (!nullToAbsent || lettersCount != null) {
      map['letters_count'] = Variable<int>(lettersCount);
    }
    return map;
  }

  SurahsCompanion toCompanion(bool nullToAbsent) {
    return SurahsCompanion(
      number: Value(number),
      nameAr: Value(nameAr),
      nameEn: nameEn == null && nullToAbsent
          ? const Value.absent()
          : Value(nameEn),
      nameTransliteration: nameTransliteration == null && nullToAbsent
          ? const Value.absent()
          : Value(nameTransliteration),
      revelationPlaceAr: revelationPlaceAr == null && nullToAbsent
          ? const Value.absent()
          : Value(revelationPlaceAr),
      revelationPlaceEn: revelationPlaceEn == null && nullToAbsent
          ? const Value.absent()
          : Value(revelationPlaceEn),
      versesCount: Value(versesCount),
      wordsCount: wordsCount == null && nullToAbsent
          ? const Value.absent()
          : Value(wordsCount),
      lettersCount: lettersCount == null && nullToAbsent
          ? const Value.absent()
          : Value(lettersCount),
    );
  }

  factory SurahEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SurahEntity(
      number: serializer.fromJson<int>(json['number']),
      nameAr: serializer.fromJson<String>(json['nameAr']),
      nameEn: serializer.fromJson<String?>(json['nameEn']),
      nameTransliteration: serializer.fromJson<String?>(
        json['nameTransliteration'],
      ),
      revelationPlaceAr: serializer.fromJson<String?>(
        json['revelationPlaceAr'],
      ),
      revelationPlaceEn: serializer.fromJson<String?>(
        json['revelationPlaceEn'],
      ),
      versesCount: serializer.fromJson<int>(json['versesCount']),
      wordsCount: serializer.fromJson<int?>(json['wordsCount']),
      lettersCount: serializer.fromJson<int?>(json['lettersCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'number': serializer.toJson<int>(number),
      'nameAr': serializer.toJson<String>(nameAr),
      'nameEn': serializer.toJson<String?>(nameEn),
      'nameTransliteration': serializer.toJson<String?>(nameTransliteration),
      'revelationPlaceAr': serializer.toJson<String?>(revelationPlaceAr),
      'revelationPlaceEn': serializer.toJson<String?>(revelationPlaceEn),
      'versesCount': serializer.toJson<int>(versesCount),
      'wordsCount': serializer.toJson<int?>(wordsCount),
      'lettersCount': serializer.toJson<int?>(lettersCount),
    };
  }

  SurahEntity copyWith({
    int? number,
    String? nameAr,
    Value<String?> nameEn = const Value.absent(),
    Value<String?> nameTransliteration = const Value.absent(),
    Value<String?> revelationPlaceAr = const Value.absent(),
    Value<String?> revelationPlaceEn = const Value.absent(),
    int? versesCount,
    Value<int?> wordsCount = const Value.absent(),
    Value<int?> lettersCount = const Value.absent(),
  }) => SurahEntity(
    number: number ?? this.number,
    nameAr: nameAr ?? this.nameAr,
    nameEn: nameEn.present ? nameEn.value : this.nameEn,
    nameTransliteration: nameTransliteration.present
        ? nameTransliteration.value
        : this.nameTransliteration,
    revelationPlaceAr: revelationPlaceAr.present
        ? revelationPlaceAr.value
        : this.revelationPlaceAr,
    revelationPlaceEn: revelationPlaceEn.present
        ? revelationPlaceEn.value
        : this.revelationPlaceEn,
    versesCount: versesCount ?? this.versesCount,
    wordsCount: wordsCount.present ? wordsCount.value : this.wordsCount,
    lettersCount: lettersCount.present ? lettersCount.value : this.lettersCount,
  );
  SurahEntity copyWithCompanion(SurahsCompanion data) {
    return SurahEntity(
      number: data.number.present ? data.number.value : this.number,
      nameAr: data.nameAr.present ? data.nameAr.value : this.nameAr,
      nameEn: data.nameEn.present ? data.nameEn.value : this.nameEn,
      nameTransliteration: data.nameTransliteration.present
          ? data.nameTransliteration.value
          : this.nameTransliteration,
      revelationPlaceAr: data.revelationPlaceAr.present
          ? data.revelationPlaceAr.value
          : this.revelationPlaceAr,
      revelationPlaceEn: data.revelationPlaceEn.present
          ? data.revelationPlaceEn.value
          : this.revelationPlaceEn,
      versesCount: data.versesCount.present
          ? data.versesCount.value
          : this.versesCount,
      wordsCount: data.wordsCount.present
          ? data.wordsCount.value
          : this.wordsCount,
      lettersCount: data.lettersCount.present
          ? data.lettersCount.value
          : this.lettersCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SurahEntity(')
          ..write('number: $number, ')
          ..write('nameAr: $nameAr, ')
          ..write('nameEn: $nameEn, ')
          ..write('nameTransliteration: $nameTransliteration, ')
          ..write('revelationPlaceAr: $revelationPlaceAr, ')
          ..write('revelationPlaceEn: $revelationPlaceEn, ')
          ..write('versesCount: $versesCount, ')
          ..write('wordsCount: $wordsCount, ')
          ..write('lettersCount: $lettersCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    number,
    nameAr,
    nameEn,
    nameTransliteration,
    revelationPlaceAr,
    revelationPlaceEn,
    versesCount,
    wordsCount,
    lettersCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SurahEntity &&
          other.number == this.number &&
          other.nameAr == this.nameAr &&
          other.nameEn == this.nameEn &&
          other.nameTransliteration == this.nameTransliteration &&
          other.revelationPlaceAr == this.revelationPlaceAr &&
          other.revelationPlaceEn == this.revelationPlaceEn &&
          other.versesCount == this.versesCount &&
          other.wordsCount == this.wordsCount &&
          other.lettersCount == this.lettersCount);
}

class SurahsCompanion extends UpdateCompanion<SurahEntity> {
  final Value<int> number;
  final Value<String> nameAr;
  final Value<String?> nameEn;
  final Value<String?> nameTransliteration;
  final Value<String?> revelationPlaceAr;
  final Value<String?> revelationPlaceEn;
  final Value<int> versesCount;
  final Value<int?> wordsCount;
  final Value<int?> lettersCount;
  const SurahsCompanion({
    this.number = const Value.absent(),
    this.nameAr = const Value.absent(),
    this.nameEn = const Value.absent(),
    this.nameTransliteration = const Value.absent(),
    this.revelationPlaceAr = const Value.absent(),
    this.revelationPlaceEn = const Value.absent(),
    this.versesCount = const Value.absent(),
    this.wordsCount = const Value.absent(),
    this.lettersCount = const Value.absent(),
  });
  SurahsCompanion.insert({
    this.number = const Value.absent(),
    required String nameAr,
    this.nameEn = const Value.absent(),
    this.nameTransliteration = const Value.absent(),
    this.revelationPlaceAr = const Value.absent(),
    this.revelationPlaceEn = const Value.absent(),
    required int versesCount,
    this.wordsCount = const Value.absent(),
    this.lettersCount = const Value.absent(),
  }) : nameAr = Value(nameAr),
       versesCount = Value(versesCount);
  static Insertable<SurahEntity> custom({
    Expression<int>? number,
    Expression<String>? nameAr,
    Expression<String>? nameEn,
    Expression<String>? nameTransliteration,
    Expression<String>? revelationPlaceAr,
    Expression<String>? revelationPlaceEn,
    Expression<int>? versesCount,
    Expression<int>? wordsCount,
    Expression<int>? lettersCount,
  }) {
    return RawValuesInsertable({
      if (number != null) 'number': number,
      if (nameAr != null) 'name_ar': nameAr,
      if (nameEn != null) 'name_en': nameEn,
      if (nameTransliteration != null)
        'name_transliteration': nameTransliteration,
      if (revelationPlaceAr != null) 'revelation_place_ar': revelationPlaceAr,
      if (revelationPlaceEn != null) 'revelation_place_en': revelationPlaceEn,
      if (versesCount != null) 'verses_count': versesCount,
      if (wordsCount != null) 'words_count': wordsCount,
      if (lettersCount != null) 'letters_count': lettersCount,
    });
  }

  SurahsCompanion copyWith({
    Value<int>? number,
    Value<String>? nameAr,
    Value<String?>? nameEn,
    Value<String?>? nameTransliteration,
    Value<String?>? revelationPlaceAr,
    Value<String?>? revelationPlaceEn,
    Value<int>? versesCount,
    Value<int?>? wordsCount,
    Value<int?>? lettersCount,
  }) {
    return SurahsCompanion(
      number: number ?? this.number,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      nameTransliteration: nameTransliteration ?? this.nameTransliteration,
      revelationPlaceAr: revelationPlaceAr ?? this.revelationPlaceAr,
      revelationPlaceEn: revelationPlaceEn ?? this.revelationPlaceEn,
      versesCount: versesCount ?? this.versesCount,
      wordsCount: wordsCount ?? this.wordsCount,
      lettersCount: lettersCount ?? this.lettersCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (nameAr.present) {
      map['name_ar'] = Variable<String>(nameAr.value);
    }
    if (nameEn.present) {
      map['name_en'] = Variable<String>(nameEn.value);
    }
    if (nameTransliteration.present) {
      map['name_transliteration'] = Variable<String>(nameTransliteration.value);
    }
    if (revelationPlaceAr.present) {
      map['revelation_place_ar'] = Variable<String>(revelationPlaceAr.value);
    }
    if (revelationPlaceEn.present) {
      map['revelation_place_en'] = Variable<String>(revelationPlaceEn.value);
    }
    if (versesCount.present) {
      map['verses_count'] = Variable<int>(versesCount.value);
    }
    if (wordsCount.present) {
      map['words_count'] = Variable<int>(wordsCount.value);
    }
    if (lettersCount.present) {
      map['letters_count'] = Variable<int>(lettersCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SurahsCompanion(')
          ..write('number: $number, ')
          ..write('nameAr: $nameAr, ')
          ..write('nameEn: $nameEn, ')
          ..write('nameTransliteration: $nameTransliteration, ')
          ..write('revelationPlaceAr: $revelationPlaceAr, ')
          ..write('revelationPlaceEn: $revelationPlaceEn, ')
          ..write('versesCount: $versesCount, ')
          ..write('wordsCount: $wordsCount, ')
          ..write('lettersCount: $lettersCount')
          ..write(')'))
        .toString();
  }
}

class $VersesTable extends Verses with TableInfo<$VersesTable, VerseEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VersesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _surahNumberMeta = const VerificationMeta(
    'surahNumber',
  );
  @override
  late final GeneratedColumn<int> surahNumber = GeneratedColumn<int>(
    'surah_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textArMeta = const VerificationMeta('textAr');
  @override
  late final GeneratedColumn<String> textAr = GeneratedColumn<String>(
    'text_ar',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textEnMeta = const VerificationMeta('textEn');
  @override
  late final GeneratedColumn<String> textEn = GeneratedColumn<String>(
    'text_en',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _textTajweedMeta = const VerificationMeta(
    'textTajweed',
  );
  @override
  late final GeneratedColumn<String> textTajweed = GeneratedColumn<String>(
    'text_tajweed',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _juzMeta = const VerificationMeta('juz');
  @override
  late final GeneratedColumn<int> juz = GeneratedColumn<int>(
    'juz',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageMeta = const VerificationMeta('page');
  @override
  late final GeneratedColumn<int> page = GeneratedColumn<int>(
    'page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sajdaMeta = const VerificationMeta('sajda');
  @override
  late final GeneratedColumn<bool> sajda = GeneratedColumn<bool>(
    'sajda',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sajda" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    surahNumber,
    number,
    textAr,
    textEn,
    textTajweed,
    juz,
    page,
    sajda,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'verses';
  @override
  VerificationContext validateIntegrity(
    Insertable<VerseEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('surah_number')) {
      context.handle(
        _surahNumberMeta,
        surahNumber.isAcceptableOrUnknown(
          data['surah_number']!,
          _surahNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_surahNumberMeta);
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('text_ar')) {
      context.handle(
        _textArMeta,
        textAr.isAcceptableOrUnknown(data['text_ar']!, _textArMeta),
      );
    } else if (isInserting) {
      context.missing(_textArMeta);
    }
    if (data.containsKey('text_en')) {
      context.handle(
        _textEnMeta,
        textEn.isAcceptableOrUnknown(data['text_en']!, _textEnMeta),
      );
    }
    if (data.containsKey('text_tajweed')) {
      context.handle(
        _textTajweedMeta,
        textTajweed.isAcceptableOrUnknown(
          data['text_tajweed']!,
          _textTajweedMeta,
        ),
      );
    }
    if (data.containsKey('juz')) {
      context.handle(
        _juzMeta,
        juz.isAcceptableOrUnknown(data['juz']!, _juzMeta),
      );
    } else if (isInserting) {
      context.missing(_juzMeta);
    }
    if (data.containsKey('page')) {
      context.handle(
        _pageMeta,
        page.isAcceptableOrUnknown(data['page']!, _pageMeta),
      );
    } else if (isInserting) {
      context.missing(_pageMeta);
    }
    if (data.containsKey('sajda')) {
      context.handle(
        _sajdaMeta,
        sajda.isAcceptableOrUnknown(data['sajda']!, _sajdaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {surahNumber, number};
  @override
  VerseEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VerseEntity(
      surahNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}surah_number'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number'],
      )!,
      textAr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_ar'],
      )!,
      textEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_en'],
      ),
      textTajweed: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_tajweed'],
      ),
      juz: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}juz'],
      )!,
      page: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page'],
      )!,
      sajda: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sajda'],
      ),
    );
  }

  @override
  $VersesTable createAlias(String alias) {
    return $VersesTable(attachedDatabase, alias);
  }
}

class VerseEntity extends DataClass implements Insertable<VerseEntity> {
  final int surahNumber;
  final int number;
  final String textAr;
  final String? textEn;
  final String? textTajweed;
  final int juz;
  final int page;
  final bool? sajda;
  const VerseEntity({
    required this.surahNumber,
    required this.number,
    required this.textAr,
    this.textEn,
    this.textTajweed,
    required this.juz,
    required this.page,
    this.sajda,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['surah_number'] = Variable<int>(surahNumber);
    map['number'] = Variable<int>(number);
    map['text_ar'] = Variable<String>(textAr);
    if (!nullToAbsent || textEn != null) {
      map['text_en'] = Variable<String>(textEn);
    }
    if (!nullToAbsent || textTajweed != null) {
      map['text_tajweed'] = Variable<String>(textTajweed);
    }
    map['juz'] = Variable<int>(juz);
    map['page'] = Variable<int>(page);
    if (!nullToAbsent || sajda != null) {
      map['sajda'] = Variable<bool>(sajda);
    }
    return map;
  }

  VersesCompanion toCompanion(bool nullToAbsent) {
    return VersesCompanion(
      surahNumber: Value(surahNumber),
      number: Value(number),
      textAr: Value(textAr),
      textEn: textEn == null && nullToAbsent
          ? const Value.absent()
          : Value(textEn),
      textTajweed: textTajweed == null && nullToAbsent
          ? const Value.absent()
          : Value(textTajweed),
      juz: Value(juz),
      page: Value(page),
      sajda: sajda == null && nullToAbsent
          ? const Value.absent()
          : Value(sajda),
    );
  }

  factory VerseEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VerseEntity(
      surahNumber: serializer.fromJson<int>(json['surahNumber']),
      number: serializer.fromJson<int>(json['number']),
      textAr: serializer.fromJson<String>(json['textAr']),
      textEn: serializer.fromJson<String?>(json['textEn']),
      textTajweed: serializer.fromJson<String?>(json['textTajweed']),
      juz: serializer.fromJson<int>(json['juz']),
      page: serializer.fromJson<int>(json['page']),
      sajda: serializer.fromJson<bool?>(json['sajda']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'surahNumber': serializer.toJson<int>(surahNumber),
      'number': serializer.toJson<int>(number),
      'textAr': serializer.toJson<String>(textAr),
      'textEn': serializer.toJson<String?>(textEn),
      'textTajweed': serializer.toJson<String?>(textTajweed),
      'juz': serializer.toJson<int>(juz),
      'page': serializer.toJson<int>(page),
      'sajda': serializer.toJson<bool?>(sajda),
    };
  }

  VerseEntity copyWith({
    int? surahNumber,
    int? number,
    String? textAr,
    Value<String?> textEn = const Value.absent(),
    Value<String?> textTajweed = const Value.absent(),
    int? juz,
    int? page,
    Value<bool?> sajda = const Value.absent(),
  }) => VerseEntity(
    surahNumber: surahNumber ?? this.surahNumber,
    number: number ?? this.number,
    textAr: textAr ?? this.textAr,
    textEn: textEn.present ? textEn.value : this.textEn,
    textTajweed: textTajweed.present ? textTajweed.value : this.textTajweed,
    juz: juz ?? this.juz,
    page: page ?? this.page,
    sajda: sajda.present ? sajda.value : this.sajda,
  );
  VerseEntity copyWithCompanion(VersesCompanion data) {
    return VerseEntity(
      surahNumber: data.surahNumber.present
          ? data.surahNumber.value
          : this.surahNumber,
      number: data.number.present ? data.number.value : this.number,
      textAr: data.textAr.present ? data.textAr.value : this.textAr,
      textEn: data.textEn.present ? data.textEn.value : this.textEn,
      textTajweed: data.textTajweed.present
          ? data.textTajweed.value
          : this.textTajweed,
      juz: data.juz.present ? data.juz.value : this.juz,
      page: data.page.present ? data.page.value : this.page,
      sajda: data.sajda.present ? data.sajda.value : this.sajda,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VerseEntity(')
          ..write('surahNumber: $surahNumber, ')
          ..write('number: $number, ')
          ..write('textAr: $textAr, ')
          ..write('textEn: $textEn, ')
          ..write('textTajweed: $textTajweed, ')
          ..write('juz: $juz, ')
          ..write('page: $page, ')
          ..write('sajda: $sajda')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    surahNumber,
    number,
    textAr,
    textEn,
    textTajweed,
    juz,
    page,
    sajda,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VerseEntity &&
          other.surahNumber == this.surahNumber &&
          other.number == this.number &&
          other.textAr == this.textAr &&
          other.textEn == this.textEn &&
          other.textTajweed == this.textTajweed &&
          other.juz == this.juz &&
          other.page == this.page &&
          other.sajda == this.sajda);
}

class VersesCompanion extends UpdateCompanion<VerseEntity> {
  final Value<int> surahNumber;
  final Value<int> number;
  final Value<String> textAr;
  final Value<String?> textEn;
  final Value<String?> textTajweed;
  final Value<int> juz;
  final Value<int> page;
  final Value<bool?> sajda;
  final Value<int> rowid;
  const VersesCompanion({
    this.surahNumber = const Value.absent(),
    this.number = const Value.absent(),
    this.textAr = const Value.absent(),
    this.textEn = const Value.absent(),
    this.textTajweed = const Value.absent(),
    this.juz = const Value.absent(),
    this.page = const Value.absent(),
    this.sajda = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VersesCompanion.insert({
    required int surahNumber,
    required int number,
    required String textAr,
    this.textEn = const Value.absent(),
    this.textTajweed = const Value.absent(),
    required int juz,
    required int page,
    this.sajda = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : surahNumber = Value(surahNumber),
       number = Value(number),
       textAr = Value(textAr),
       juz = Value(juz),
       page = Value(page);
  static Insertable<VerseEntity> custom({
    Expression<int>? surahNumber,
    Expression<int>? number,
    Expression<String>? textAr,
    Expression<String>? textEn,
    Expression<String>? textTajweed,
    Expression<int>? juz,
    Expression<int>? page,
    Expression<bool>? sajda,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (surahNumber != null) 'surah_number': surahNumber,
      if (number != null) 'number': number,
      if (textAr != null) 'text_ar': textAr,
      if (textEn != null) 'text_en': textEn,
      if (textTajweed != null) 'text_tajweed': textTajweed,
      if (juz != null) 'juz': juz,
      if (page != null) 'page': page,
      if (sajda != null) 'sajda': sajda,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VersesCompanion copyWith({
    Value<int>? surahNumber,
    Value<int>? number,
    Value<String>? textAr,
    Value<String?>? textEn,
    Value<String?>? textTajweed,
    Value<int>? juz,
    Value<int>? page,
    Value<bool?>? sajda,
    Value<int>? rowid,
  }) {
    return VersesCompanion(
      surahNumber: surahNumber ?? this.surahNumber,
      number: number ?? this.number,
      textAr: textAr ?? this.textAr,
      textEn: textEn ?? this.textEn,
      textTajweed: textTajweed ?? this.textTajweed,
      juz: juz ?? this.juz,
      page: page ?? this.page,
      sajda: sajda ?? this.sajda,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (surahNumber.present) {
      map['surah_number'] = Variable<int>(surahNumber.value);
    }
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (textAr.present) {
      map['text_ar'] = Variable<String>(textAr.value);
    }
    if (textEn.present) {
      map['text_en'] = Variable<String>(textEn.value);
    }
    if (textTajweed.present) {
      map['text_tajweed'] = Variable<String>(textTajweed.value);
    }
    if (juz.present) {
      map['juz'] = Variable<int>(juz.value);
    }
    if (page.present) {
      map['page'] = Variable<int>(page.value);
    }
    if (sajda.present) {
      map['sajda'] = Variable<bool>(sajda.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VersesCompanion(')
          ..write('surahNumber: $surahNumber, ')
          ..write('number: $number, ')
          ..write('textAr: $textAr, ')
          ..write('textEn: $textEn, ')
          ..write('textTajweed: $textTajweed, ')
          ..write('juz: $juz, ')
          ..write('page: $page, ')
          ..write('sajda: $sajda, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AudiosTable extends Audios with TableInfo<$AudiosTable, AudioEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AudiosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _surahNumberMeta = const VerificationMeta(
    'surahNumber',
  );
  @override
  late final GeneratedColumn<int> surahNumber = GeneratedColumn<int>(
    'surah_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reciterArMeta = const VerificationMeta(
    'reciterAr',
  );
  @override
  late final GeneratedColumn<String> reciterAr = GeneratedColumn<String>(
    'reciter_ar',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reciterEnMeta = const VerificationMeta(
    'reciterEn',
  );
  @override
  late final GeneratedColumn<String> reciterEn = GeneratedColumn<String>(
    'reciter_en',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rewayaArMeta = const VerificationMeta(
    'rewayaAr',
  );
  @override
  late final GeneratedColumn<String> rewayaAr = GeneratedColumn<String>(
    'rewaya_ar',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rewayaEnMeta = const VerificationMeta(
    'rewayaEn',
  );
  @override
  late final GeneratedColumn<String> rewayaEn = GeneratedColumn<String>(
    'rewaya_en',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverMeta = const VerificationMeta('server');
  @override
  late final GeneratedColumn<String> server = GeneratedColumn<String>(
    'server',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _linkMeta = const VerificationMeta('link');
  @override
  late final GeneratedColumn<String> link = GeneratedColumn<String>(
    'link',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    surahNumber,
    reciterAr,
    reciterEn,
    rewayaAr,
    rewayaEn,
    server,
    link,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audio';
  @override
  VerificationContext validateIntegrity(
    Insertable<AudioEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('surah_number')) {
      context.handle(
        _surahNumberMeta,
        surahNumber.isAcceptableOrUnknown(
          data['surah_number']!,
          _surahNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_surahNumberMeta);
    }
    if (data.containsKey('reciter_ar')) {
      context.handle(
        _reciterArMeta,
        reciterAr.isAcceptableOrUnknown(data['reciter_ar']!, _reciterArMeta),
      );
    } else if (isInserting) {
      context.missing(_reciterArMeta);
    }
    if (data.containsKey('reciter_en')) {
      context.handle(
        _reciterEnMeta,
        reciterEn.isAcceptableOrUnknown(data['reciter_en']!, _reciterEnMeta),
      );
    }
    if (data.containsKey('rewaya_ar')) {
      context.handle(
        _rewayaArMeta,
        rewayaAr.isAcceptableOrUnknown(data['rewaya_ar']!, _rewayaArMeta),
      );
    }
    if (data.containsKey('rewaya_en')) {
      context.handle(
        _rewayaEnMeta,
        rewayaEn.isAcceptableOrUnknown(data['rewaya_en']!, _rewayaEnMeta),
      );
    }
    if (data.containsKey('server')) {
      context.handle(
        _serverMeta,
        server.isAcceptableOrUnknown(data['server']!, _serverMeta),
      );
    }
    if (data.containsKey('link')) {
      context.handle(
        _linkMeta,
        link.isAcceptableOrUnknown(data['link']!, _linkMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AudioEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AudioEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      surahNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}surah_number'],
      )!,
      reciterAr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reciter_ar'],
      )!,
      reciterEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reciter_en'],
      ),
      rewayaAr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rewaya_ar'],
      ),
      rewayaEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rewaya_en'],
      ),
      server: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server'],
      ),
      link: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}link'],
      ),
    );
  }

  @override
  $AudiosTable createAlias(String alias) {
    return $AudiosTable(attachedDatabase, alias);
  }
}

class AudioEntity extends DataClass implements Insertable<AudioEntity> {
  final int id;
  final int surahNumber;
  final String reciterAr;
  final String? reciterEn;
  final String? rewayaAr;
  final String? rewayaEn;
  final String? server;
  final String? link;
  const AudioEntity({
    required this.id,
    required this.surahNumber,
    required this.reciterAr,
    this.reciterEn,
    this.rewayaAr,
    this.rewayaEn,
    this.server,
    this.link,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['surah_number'] = Variable<int>(surahNumber);
    map['reciter_ar'] = Variable<String>(reciterAr);
    if (!nullToAbsent || reciterEn != null) {
      map['reciter_en'] = Variable<String>(reciterEn);
    }
    if (!nullToAbsent || rewayaAr != null) {
      map['rewaya_ar'] = Variable<String>(rewayaAr);
    }
    if (!nullToAbsent || rewayaEn != null) {
      map['rewaya_en'] = Variable<String>(rewayaEn);
    }
    if (!nullToAbsent || server != null) {
      map['server'] = Variable<String>(server);
    }
    if (!nullToAbsent || link != null) {
      map['link'] = Variable<String>(link);
    }
    return map;
  }

  AudiosCompanion toCompanion(bool nullToAbsent) {
    return AudiosCompanion(
      id: Value(id),
      surahNumber: Value(surahNumber),
      reciterAr: Value(reciterAr),
      reciterEn: reciterEn == null && nullToAbsent
          ? const Value.absent()
          : Value(reciterEn),
      rewayaAr: rewayaAr == null && nullToAbsent
          ? const Value.absent()
          : Value(rewayaAr),
      rewayaEn: rewayaEn == null && nullToAbsent
          ? const Value.absent()
          : Value(rewayaEn),
      server: server == null && nullToAbsent
          ? const Value.absent()
          : Value(server),
      link: link == null && nullToAbsent ? const Value.absent() : Value(link),
    );
  }

  factory AudioEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AudioEntity(
      id: serializer.fromJson<int>(json['id']),
      surahNumber: serializer.fromJson<int>(json['surahNumber']),
      reciterAr: serializer.fromJson<String>(json['reciterAr']),
      reciterEn: serializer.fromJson<String?>(json['reciterEn']),
      rewayaAr: serializer.fromJson<String?>(json['rewayaAr']),
      rewayaEn: serializer.fromJson<String?>(json['rewayaEn']),
      server: serializer.fromJson<String?>(json['server']),
      link: serializer.fromJson<String?>(json['link']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'surahNumber': serializer.toJson<int>(surahNumber),
      'reciterAr': serializer.toJson<String>(reciterAr),
      'reciterEn': serializer.toJson<String?>(reciterEn),
      'rewayaAr': serializer.toJson<String?>(rewayaAr),
      'rewayaEn': serializer.toJson<String?>(rewayaEn),
      'server': serializer.toJson<String?>(server),
      'link': serializer.toJson<String?>(link),
    };
  }

  AudioEntity copyWith({
    int? id,
    int? surahNumber,
    String? reciterAr,
    Value<String?> reciterEn = const Value.absent(),
    Value<String?> rewayaAr = const Value.absent(),
    Value<String?> rewayaEn = const Value.absent(),
    Value<String?> server = const Value.absent(),
    Value<String?> link = const Value.absent(),
  }) => AudioEntity(
    id: id ?? this.id,
    surahNumber: surahNumber ?? this.surahNumber,
    reciterAr: reciterAr ?? this.reciterAr,
    reciterEn: reciterEn.present ? reciterEn.value : this.reciterEn,
    rewayaAr: rewayaAr.present ? rewayaAr.value : this.rewayaAr,
    rewayaEn: rewayaEn.present ? rewayaEn.value : this.rewayaEn,
    server: server.present ? server.value : this.server,
    link: link.present ? link.value : this.link,
  );
  AudioEntity copyWithCompanion(AudiosCompanion data) {
    return AudioEntity(
      id: data.id.present ? data.id.value : this.id,
      surahNumber: data.surahNumber.present
          ? data.surahNumber.value
          : this.surahNumber,
      reciterAr: data.reciterAr.present ? data.reciterAr.value : this.reciterAr,
      reciterEn: data.reciterEn.present ? data.reciterEn.value : this.reciterEn,
      rewayaAr: data.rewayaAr.present ? data.rewayaAr.value : this.rewayaAr,
      rewayaEn: data.rewayaEn.present ? data.rewayaEn.value : this.rewayaEn,
      server: data.server.present ? data.server.value : this.server,
      link: data.link.present ? data.link.value : this.link,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AudioEntity(')
          ..write('id: $id, ')
          ..write('surahNumber: $surahNumber, ')
          ..write('reciterAr: $reciterAr, ')
          ..write('reciterEn: $reciterEn, ')
          ..write('rewayaAr: $rewayaAr, ')
          ..write('rewayaEn: $rewayaEn, ')
          ..write('server: $server, ')
          ..write('link: $link')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    surahNumber,
    reciterAr,
    reciterEn,
    rewayaAr,
    rewayaEn,
    server,
    link,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AudioEntity &&
          other.id == this.id &&
          other.surahNumber == this.surahNumber &&
          other.reciterAr == this.reciterAr &&
          other.reciterEn == this.reciterEn &&
          other.rewayaAr == this.rewayaAr &&
          other.rewayaEn == this.rewayaEn &&
          other.server == this.server &&
          other.link == this.link);
}

class AudiosCompanion extends UpdateCompanion<AudioEntity> {
  final Value<int> id;
  final Value<int> surahNumber;
  final Value<String> reciterAr;
  final Value<String?> reciterEn;
  final Value<String?> rewayaAr;
  final Value<String?> rewayaEn;
  final Value<String?> server;
  final Value<String?> link;
  const AudiosCompanion({
    this.id = const Value.absent(),
    this.surahNumber = const Value.absent(),
    this.reciterAr = const Value.absent(),
    this.reciterEn = const Value.absent(),
    this.rewayaAr = const Value.absent(),
    this.rewayaEn = const Value.absent(),
    this.server = const Value.absent(),
    this.link = const Value.absent(),
  });
  AudiosCompanion.insert({
    this.id = const Value.absent(),
    required int surahNumber,
    required String reciterAr,
    this.reciterEn = const Value.absent(),
    this.rewayaAr = const Value.absent(),
    this.rewayaEn = const Value.absent(),
    this.server = const Value.absent(),
    this.link = const Value.absent(),
  }) : surahNumber = Value(surahNumber),
       reciterAr = Value(reciterAr);
  static Insertable<AudioEntity> custom({
    Expression<int>? id,
    Expression<int>? surahNumber,
    Expression<String>? reciterAr,
    Expression<String>? reciterEn,
    Expression<String>? rewayaAr,
    Expression<String>? rewayaEn,
    Expression<String>? server,
    Expression<String>? link,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (surahNumber != null) 'surah_number': surahNumber,
      if (reciterAr != null) 'reciter_ar': reciterAr,
      if (reciterEn != null) 'reciter_en': reciterEn,
      if (rewayaAr != null) 'rewaya_ar': rewayaAr,
      if (rewayaEn != null) 'rewaya_en': rewayaEn,
      if (server != null) 'server': server,
      if (link != null) 'link': link,
    });
  }

  AudiosCompanion copyWith({
    Value<int>? id,
    Value<int>? surahNumber,
    Value<String>? reciterAr,
    Value<String?>? reciterEn,
    Value<String?>? rewayaAr,
    Value<String?>? rewayaEn,
    Value<String?>? server,
    Value<String?>? link,
  }) {
    return AudiosCompanion(
      id: id ?? this.id,
      surahNumber: surahNumber ?? this.surahNumber,
      reciterAr: reciterAr ?? this.reciterAr,
      reciterEn: reciterEn ?? this.reciterEn,
      rewayaAr: rewayaAr ?? this.rewayaAr,
      rewayaEn: rewayaEn ?? this.rewayaEn,
      server: server ?? this.server,
      link: link ?? this.link,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (surahNumber.present) {
      map['surah_number'] = Variable<int>(surahNumber.value);
    }
    if (reciterAr.present) {
      map['reciter_ar'] = Variable<String>(reciterAr.value);
    }
    if (reciterEn.present) {
      map['reciter_en'] = Variable<String>(reciterEn.value);
    }
    if (rewayaAr.present) {
      map['rewaya_ar'] = Variable<String>(rewayaAr.value);
    }
    if (rewayaEn.present) {
      map['rewaya_en'] = Variable<String>(rewayaEn.value);
    }
    if (server.present) {
      map['server'] = Variable<String>(server.value);
    }
    if (link.present) {
      map['link'] = Variable<String>(link.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AudiosCompanion(')
          ..write('id: $id, ')
          ..write('surahNumber: $surahNumber, ')
          ..write('reciterAr: $reciterAr, ')
          ..write('reciterEn: $reciterEn, ')
          ..write('rewayaAr: $rewayaAr, ')
          ..write('rewayaEn: $rewayaEn, ')
          ..write('server: $server, ')
          ..write('link: $link')
          ..write(')'))
        .toString();
  }
}

abstract class _$QuranDatabase extends GeneratedDatabase {
  _$QuranDatabase(QueryExecutor e) : super(e);
  $QuranDatabaseManager get managers => $QuranDatabaseManager(this);
  late final $SurahsTable surahs = $SurahsTable(this);
  late final $VersesTable verses = $VersesTable(this);
  late final $AudiosTable audios = $AudiosTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [surahs, verses, audios];
}

typedef $$SurahsTableCreateCompanionBuilder =
    SurahsCompanion Function({
      Value<int> number,
      required String nameAr,
      Value<String?> nameEn,
      Value<String?> nameTransliteration,
      Value<String?> revelationPlaceAr,
      Value<String?> revelationPlaceEn,
      required int versesCount,
      Value<int?> wordsCount,
      Value<int?> lettersCount,
    });
typedef $$SurahsTableUpdateCompanionBuilder =
    SurahsCompanion Function({
      Value<int> number,
      Value<String> nameAr,
      Value<String?> nameEn,
      Value<String?> nameTransliteration,
      Value<String?> revelationPlaceAr,
      Value<String?> revelationPlaceEn,
      Value<int> versesCount,
      Value<int?> wordsCount,
      Value<int?> lettersCount,
    });

class $$SurahsTableFilterComposer
    extends Composer<_$QuranDatabase, $SurahsTable> {
  $$SurahsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameAr => $composableBuilder(
    column: $table.nameAr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameTransliteration => $composableBuilder(
    column: $table.nameTransliteration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get revelationPlaceAr => $composableBuilder(
    column: $table.revelationPlaceAr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get revelationPlaceEn => $composableBuilder(
    column: $table.revelationPlaceEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get versesCount => $composableBuilder(
    column: $table.versesCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wordsCount => $composableBuilder(
    column: $table.wordsCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lettersCount => $composableBuilder(
    column: $table.lettersCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SurahsTableOrderingComposer
    extends Composer<_$QuranDatabase, $SurahsTable> {
  $$SurahsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameAr => $composableBuilder(
    column: $table.nameAr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameTransliteration => $composableBuilder(
    column: $table.nameTransliteration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get revelationPlaceAr => $composableBuilder(
    column: $table.revelationPlaceAr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get revelationPlaceEn => $composableBuilder(
    column: $table.revelationPlaceEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get versesCount => $composableBuilder(
    column: $table.versesCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wordsCount => $composableBuilder(
    column: $table.wordsCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lettersCount => $composableBuilder(
    column: $table.lettersCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SurahsTableAnnotationComposer
    extends Composer<_$QuranDatabase, $SurahsTable> {
  $$SurahsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get nameAr =>
      $composableBuilder(column: $table.nameAr, builder: (column) => column);

  GeneratedColumn<String> get nameEn =>
      $composableBuilder(column: $table.nameEn, builder: (column) => column);

  GeneratedColumn<String> get nameTransliteration => $composableBuilder(
    column: $table.nameTransliteration,
    builder: (column) => column,
  );

  GeneratedColumn<String> get revelationPlaceAr => $composableBuilder(
    column: $table.revelationPlaceAr,
    builder: (column) => column,
  );

  GeneratedColumn<String> get revelationPlaceEn => $composableBuilder(
    column: $table.revelationPlaceEn,
    builder: (column) => column,
  );

  GeneratedColumn<int> get versesCount => $composableBuilder(
    column: $table.versesCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get wordsCount => $composableBuilder(
    column: $table.wordsCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lettersCount => $composableBuilder(
    column: $table.lettersCount,
    builder: (column) => column,
  );
}

class $$SurahsTableTableManager
    extends
        RootTableManager<
          _$QuranDatabase,
          $SurahsTable,
          SurahEntity,
          $$SurahsTableFilterComposer,
          $$SurahsTableOrderingComposer,
          $$SurahsTableAnnotationComposer,
          $$SurahsTableCreateCompanionBuilder,
          $$SurahsTableUpdateCompanionBuilder,
          (
            SurahEntity,
            BaseReferences<_$QuranDatabase, $SurahsTable, SurahEntity>,
          ),
          SurahEntity,
          PrefetchHooks Function()
        > {
  $$SurahsTableTableManager(_$QuranDatabase db, $SurahsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SurahsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SurahsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SurahsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> number = const Value.absent(),
                Value<String> nameAr = const Value.absent(),
                Value<String?> nameEn = const Value.absent(),
                Value<String?> nameTransliteration = const Value.absent(),
                Value<String?> revelationPlaceAr = const Value.absent(),
                Value<String?> revelationPlaceEn = const Value.absent(),
                Value<int> versesCount = const Value.absent(),
                Value<int?> wordsCount = const Value.absent(),
                Value<int?> lettersCount = const Value.absent(),
              }) => SurahsCompanion(
                number: number,
                nameAr: nameAr,
                nameEn: nameEn,
                nameTransliteration: nameTransliteration,
                revelationPlaceAr: revelationPlaceAr,
                revelationPlaceEn: revelationPlaceEn,
                versesCount: versesCount,
                wordsCount: wordsCount,
                lettersCount: lettersCount,
              ),
          createCompanionCallback:
              ({
                Value<int> number = const Value.absent(),
                required String nameAr,
                Value<String?> nameEn = const Value.absent(),
                Value<String?> nameTransliteration = const Value.absent(),
                Value<String?> revelationPlaceAr = const Value.absent(),
                Value<String?> revelationPlaceEn = const Value.absent(),
                required int versesCount,
                Value<int?> wordsCount = const Value.absent(),
                Value<int?> lettersCount = const Value.absent(),
              }) => SurahsCompanion.insert(
                number: number,
                nameAr: nameAr,
                nameEn: nameEn,
                nameTransliteration: nameTransliteration,
                revelationPlaceAr: revelationPlaceAr,
                revelationPlaceEn: revelationPlaceEn,
                versesCount: versesCount,
                wordsCount: wordsCount,
                lettersCount: lettersCount,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SurahsTableProcessedTableManager =
    ProcessedTableManager<
      _$QuranDatabase,
      $SurahsTable,
      SurahEntity,
      $$SurahsTableFilterComposer,
      $$SurahsTableOrderingComposer,
      $$SurahsTableAnnotationComposer,
      $$SurahsTableCreateCompanionBuilder,
      $$SurahsTableUpdateCompanionBuilder,
      (SurahEntity, BaseReferences<_$QuranDatabase, $SurahsTable, SurahEntity>),
      SurahEntity,
      PrefetchHooks Function()
    >;
typedef $$VersesTableCreateCompanionBuilder =
    VersesCompanion Function({
      required int surahNumber,
      required int number,
      required String textAr,
      Value<String?> textEn,
      Value<String?> textTajweed,
      required int juz,
      required int page,
      Value<bool?> sajda,
      Value<int> rowid,
    });
typedef $$VersesTableUpdateCompanionBuilder =
    VersesCompanion Function({
      Value<int> surahNumber,
      Value<int> number,
      Value<String> textAr,
      Value<String?> textEn,
      Value<String?> textTajweed,
      Value<int> juz,
      Value<int> page,
      Value<bool?> sajda,
      Value<int> rowid,
    });

class $$VersesTableFilterComposer
    extends Composer<_$QuranDatabase, $VersesTable> {
  $$VersesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get surahNumber => $composableBuilder(
    column: $table.surahNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textAr => $composableBuilder(
    column: $table.textAr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textEn => $composableBuilder(
    column: $table.textEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textTajweed => $composableBuilder(
    column: $table.textTajweed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get juz => $composableBuilder(
    column: $table.juz,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get sajda => $composableBuilder(
    column: $table.sajda,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VersesTableOrderingComposer
    extends Composer<_$QuranDatabase, $VersesTable> {
  $$VersesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get surahNumber => $composableBuilder(
    column: $table.surahNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textAr => $composableBuilder(
    column: $table.textAr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textEn => $composableBuilder(
    column: $table.textEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textTajweed => $composableBuilder(
    column: $table.textTajweed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get juz => $composableBuilder(
    column: $table.juz,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get sajda => $composableBuilder(
    column: $table.sajda,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VersesTableAnnotationComposer
    extends Composer<_$QuranDatabase, $VersesTable> {
  $$VersesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get surahNumber => $composableBuilder(
    column: $table.surahNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get textAr =>
      $composableBuilder(column: $table.textAr, builder: (column) => column);

  GeneratedColumn<String> get textEn =>
      $composableBuilder(column: $table.textEn, builder: (column) => column);

  GeneratedColumn<String> get textTajweed => $composableBuilder(
    column: $table.textTajweed,
    builder: (column) => column,
  );

  GeneratedColumn<int> get juz =>
      $composableBuilder(column: $table.juz, builder: (column) => column);

  GeneratedColumn<int> get page =>
      $composableBuilder(column: $table.page, builder: (column) => column);

  GeneratedColumn<bool> get sajda =>
      $composableBuilder(column: $table.sajda, builder: (column) => column);
}

class $$VersesTableTableManager
    extends
        RootTableManager<
          _$QuranDatabase,
          $VersesTable,
          VerseEntity,
          $$VersesTableFilterComposer,
          $$VersesTableOrderingComposer,
          $$VersesTableAnnotationComposer,
          $$VersesTableCreateCompanionBuilder,
          $$VersesTableUpdateCompanionBuilder,
          (
            VerseEntity,
            BaseReferences<_$QuranDatabase, $VersesTable, VerseEntity>,
          ),
          VerseEntity,
          PrefetchHooks Function()
        > {
  $$VersesTableTableManager(_$QuranDatabase db, $VersesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VersesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VersesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VersesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> surahNumber = const Value.absent(),
                Value<int> number = const Value.absent(),
                Value<String> textAr = const Value.absent(),
                Value<String?> textEn = const Value.absent(),
                Value<String?> textTajweed = const Value.absent(),
                Value<int> juz = const Value.absent(),
                Value<int> page = const Value.absent(),
                Value<bool?> sajda = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VersesCompanion(
                surahNumber: surahNumber,
                number: number,
                textAr: textAr,
                textEn: textEn,
                textTajweed: textTajweed,
                juz: juz,
                page: page,
                sajda: sajda,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int surahNumber,
                required int number,
                required String textAr,
                Value<String?> textEn = const Value.absent(),
                Value<String?> textTajweed = const Value.absent(),
                required int juz,
                required int page,
                Value<bool?> sajda = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VersesCompanion.insert(
                surahNumber: surahNumber,
                number: number,
                textAr: textAr,
                textEn: textEn,
                textTajweed: textTajweed,
                juz: juz,
                page: page,
                sajda: sajda,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VersesTableProcessedTableManager =
    ProcessedTableManager<
      _$QuranDatabase,
      $VersesTable,
      VerseEntity,
      $$VersesTableFilterComposer,
      $$VersesTableOrderingComposer,
      $$VersesTableAnnotationComposer,
      $$VersesTableCreateCompanionBuilder,
      $$VersesTableUpdateCompanionBuilder,
      (VerseEntity, BaseReferences<_$QuranDatabase, $VersesTable, VerseEntity>),
      VerseEntity,
      PrefetchHooks Function()
    >;
typedef $$AudiosTableCreateCompanionBuilder =
    AudiosCompanion Function({
      Value<int> id,
      required int surahNumber,
      required String reciterAr,
      Value<String?> reciterEn,
      Value<String?> rewayaAr,
      Value<String?> rewayaEn,
      Value<String?> server,
      Value<String?> link,
    });
typedef $$AudiosTableUpdateCompanionBuilder =
    AudiosCompanion Function({
      Value<int> id,
      Value<int> surahNumber,
      Value<String> reciterAr,
      Value<String?> reciterEn,
      Value<String?> rewayaAr,
      Value<String?> rewayaEn,
      Value<String?> server,
      Value<String?> link,
    });

class $$AudiosTableFilterComposer
    extends Composer<_$QuranDatabase, $AudiosTable> {
  $$AudiosTableFilterComposer({
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

  ColumnFilters<int> get surahNumber => $composableBuilder(
    column: $table.surahNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reciterAr => $composableBuilder(
    column: $table.reciterAr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reciterEn => $composableBuilder(
    column: $table.reciterEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rewayaAr => $composableBuilder(
    column: $table.rewayaAr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rewayaEn => $composableBuilder(
    column: $table.rewayaEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get server => $composableBuilder(
    column: $table.server,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get link => $composableBuilder(
    column: $table.link,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AudiosTableOrderingComposer
    extends Composer<_$QuranDatabase, $AudiosTable> {
  $$AudiosTableOrderingComposer({
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

  ColumnOrderings<int> get surahNumber => $composableBuilder(
    column: $table.surahNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reciterAr => $composableBuilder(
    column: $table.reciterAr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reciterEn => $composableBuilder(
    column: $table.reciterEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rewayaAr => $composableBuilder(
    column: $table.rewayaAr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rewayaEn => $composableBuilder(
    column: $table.rewayaEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get server => $composableBuilder(
    column: $table.server,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get link => $composableBuilder(
    column: $table.link,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AudiosTableAnnotationComposer
    extends Composer<_$QuranDatabase, $AudiosTable> {
  $$AudiosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get surahNumber => $composableBuilder(
    column: $table.surahNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reciterAr =>
      $composableBuilder(column: $table.reciterAr, builder: (column) => column);

  GeneratedColumn<String> get reciterEn =>
      $composableBuilder(column: $table.reciterEn, builder: (column) => column);

  GeneratedColumn<String> get rewayaAr =>
      $composableBuilder(column: $table.rewayaAr, builder: (column) => column);

  GeneratedColumn<String> get rewayaEn =>
      $composableBuilder(column: $table.rewayaEn, builder: (column) => column);

  GeneratedColumn<String> get server =>
      $composableBuilder(column: $table.server, builder: (column) => column);

  GeneratedColumn<String> get link =>
      $composableBuilder(column: $table.link, builder: (column) => column);
}

class $$AudiosTableTableManager
    extends
        RootTableManager<
          _$QuranDatabase,
          $AudiosTable,
          AudioEntity,
          $$AudiosTableFilterComposer,
          $$AudiosTableOrderingComposer,
          $$AudiosTableAnnotationComposer,
          $$AudiosTableCreateCompanionBuilder,
          $$AudiosTableUpdateCompanionBuilder,
          (
            AudioEntity,
            BaseReferences<_$QuranDatabase, $AudiosTable, AudioEntity>,
          ),
          AudioEntity,
          PrefetchHooks Function()
        > {
  $$AudiosTableTableManager(_$QuranDatabase db, $AudiosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AudiosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AudiosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AudiosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> surahNumber = const Value.absent(),
                Value<String> reciterAr = const Value.absent(),
                Value<String?> reciterEn = const Value.absent(),
                Value<String?> rewayaAr = const Value.absent(),
                Value<String?> rewayaEn = const Value.absent(),
                Value<String?> server = const Value.absent(),
                Value<String?> link = const Value.absent(),
              }) => AudiosCompanion(
                id: id,
                surahNumber: surahNumber,
                reciterAr: reciterAr,
                reciterEn: reciterEn,
                rewayaAr: rewayaAr,
                rewayaEn: rewayaEn,
                server: server,
                link: link,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int surahNumber,
                required String reciterAr,
                Value<String?> reciterEn = const Value.absent(),
                Value<String?> rewayaAr = const Value.absent(),
                Value<String?> rewayaEn = const Value.absent(),
                Value<String?> server = const Value.absent(),
                Value<String?> link = const Value.absent(),
              }) => AudiosCompanion.insert(
                id: id,
                surahNumber: surahNumber,
                reciterAr: reciterAr,
                reciterEn: reciterEn,
                rewayaAr: rewayaAr,
                rewayaEn: rewayaEn,
                server: server,
                link: link,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AudiosTableProcessedTableManager =
    ProcessedTableManager<
      _$QuranDatabase,
      $AudiosTable,
      AudioEntity,
      $$AudiosTableFilterComposer,
      $$AudiosTableOrderingComposer,
      $$AudiosTableAnnotationComposer,
      $$AudiosTableCreateCompanionBuilder,
      $$AudiosTableUpdateCompanionBuilder,
      (AudioEntity, BaseReferences<_$QuranDatabase, $AudiosTable, AudioEntity>),
      AudioEntity,
      PrefetchHooks Function()
    >;

class $QuranDatabaseManager {
  final _$QuranDatabase _db;
  $QuranDatabaseManager(this._db);
  $$SurahsTableTableManager get surahs =>
      $$SurahsTableTableManager(_db, _db.surahs);
  $$VersesTableTableManager get verses =>
      $$VersesTableTableManager(_db, _db.verses);
  $$AudiosTableTableManager get audios =>
      $$AudiosTableTableManager(_db, _db.audios);
}
