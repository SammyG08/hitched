// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $GuestsTable extends Guests with TableInfo<$GuestsTable, Guest> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GuestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _rsvpStatusMeta =
      const VerificationMeta('rsvpStatus');
  @override
  late final GeneratedColumn<String> rsvpStatus = GeneratedColumn<String>(
      'rsvp_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _dietaryNotesMeta =
      const VerificationMeta('dietaryNotes');
  @override
  late final GeneratedColumn<String> dietaryNotes = GeneratedColumn<String>(
      'dietary_notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, email, rsvpStatus, dietaryNotes, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'guests';
  @override
  VerificationContext validateIntegrity(Insertable<Guest> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('rsvp_status')) {
      context.handle(
          _rsvpStatusMeta,
          rsvpStatus.isAcceptableOrUnknown(
              data['rsvp_status']!, _rsvpStatusMeta));
    }
    if (data.containsKey('dietary_notes')) {
      context.handle(
          _dietaryNotesMeta,
          dietaryNotes.isAcceptableOrUnknown(
              data['dietary_notes']!, _dietaryNotesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Guest map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Guest(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      rsvpStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rsvp_status'])!,
      dietaryNotes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dietary_notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $GuestsTable createAlias(String alias) {
    return $GuestsTable(attachedDatabase, alias);
  }
}

class Guest extends DataClass implements Insertable<Guest> {
  final int id;
  final String name;
  final String? email;
  final String rsvpStatus;
  final String? dietaryNotes;
  final DateTime createdAt;
  const Guest(
      {required this.id,
      required this.name,
      this.email,
      required this.rsvpStatus,
      this.dietaryNotes,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    map['rsvp_status'] = Variable<String>(rsvpStatus);
    if (!nullToAbsent || dietaryNotes != null) {
      map['dietary_notes'] = Variable<String>(dietaryNotes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  GuestsCompanion toCompanion(bool nullToAbsent) {
    return GuestsCompanion(
      id: Value(id),
      name: Value(name),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      rsvpStatus: Value(rsvpStatus),
      dietaryNotes: dietaryNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(dietaryNotes),
      createdAt: Value(createdAt),
    );
  }

  factory Guest.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Guest(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String?>(json['email']),
      rsvpStatus: serializer.fromJson<String>(json['rsvpStatus']),
      dietaryNotes: serializer.fromJson<String?>(json['dietaryNotes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String?>(email),
      'rsvpStatus': serializer.toJson<String>(rsvpStatus),
      'dietaryNotes': serializer.toJson<String?>(dietaryNotes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Guest copyWith(
          {int? id,
          String? name,
          Value<String?> email = const Value.absent(),
          String? rsvpStatus,
          Value<String?> dietaryNotes = const Value.absent(),
          DateTime? createdAt}) =>
      Guest(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email.present ? email.value : this.email,
        rsvpStatus: rsvpStatus ?? this.rsvpStatus,
        dietaryNotes:
            dietaryNotes.present ? dietaryNotes.value : this.dietaryNotes,
        createdAt: createdAt ?? this.createdAt,
      );
  Guest copyWithCompanion(GuestsCompanion data) {
    return Guest(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      rsvpStatus:
          data.rsvpStatus.present ? data.rsvpStatus.value : this.rsvpStatus,
      dietaryNotes: data.dietaryNotes.present
          ? data.dietaryNotes.value
          : this.dietaryNotes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Guest(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('rsvpStatus: $rsvpStatus, ')
          ..write('dietaryNotes: $dietaryNotes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, email, rsvpStatus, dietaryNotes, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Guest &&
          other.id == this.id &&
          other.name == this.name &&
          other.email == this.email &&
          other.rsvpStatus == this.rsvpStatus &&
          other.dietaryNotes == this.dietaryNotes &&
          other.createdAt == this.createdAt);
}

class GuestsCompanion extends UpdateCompanion<Guest> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> email;
  final Value<String> rsvpStatus;
  final Value<String?> dietaryNotes;
  final Value<DateTime> createdAt;
  const GuestsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.rsvpStatus = const Value.absent(),
    this.dietaryNotes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  GuestsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.email = const Value.absent(),
    this.rsvpStatus = const Value.absent(),
    this.dietaryNotes = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Guest> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? email,
    Expression<String>? rsvpStatus,
    Expression<String>? dietaryNotes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (rsvpStatus != null) 'rsvp_status': rsvpStatus,
      if (dietaryNotes != null) 'dietary_notes': dietaryNotes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  GuestsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String?>? email,
      Value<String>? rsvpStatus,
      Value<String?>? dietaryNotes,
      Value<DateTime>? createdAt}) {
    return GuestsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      rsvpStatus: rsvpStatus ?? this.rsvpStatus,
      dietaryNotes: dietaryNotes ?? this.dietaryNotes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (rsvpStatus.present) {
      map['rsvp_status'] = Variable<String>(rsvpStatus.value);
    }
    if (dietaryNotes.present) {
      map['dietary_notes'] = Variable<String>(dietaryNotes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GuestsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('rsvpStatus: $rsvpStatus, ')
          ..write('dietaryNotes: $dietaryNotes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _weddingDateMeta =
      const VerificationMeta('weddingDate');
  @override
  late final GeneratedColumn<String> weddingDate = GeneratedColumn<String>(
      'wedding_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _partnerANameMeta =
      const VerificationMeta('partnerAName');
  @override
  late final GeneratedColumn<String> partnerAName = GeneratedColumn<String>(
      'partner_a_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _partnerBNameMeta =
      const VerificationMeta('partnerBName');
  @override
  late final GeneratedColumn<String> partnerBName = GeneratedColumn<String>(
      'partner_b_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, weddingDate, partnerAName, partnerBName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(Insertable<Setting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('wedding_date')) {
      context.handle(
          _weddingDateMeta,
          weddingDate.isAcceptableOrUnknown(
              data['wedding_date']!, _weddingDateMeta));
    } else if (isInserting) {
      context.missing(_weddingDateMeta);
    }
    if (data.containsKey('partner_a_name')) {
      context.handle(
          _partnerANameMeta,
          partnerAName.isAcceptableOrUnknown(
              data['partner_a_name']!, _partnerANameMeta));
    } else if (isInserting) {
      context.missing(_partnerANameMeta);
    }
    if (data.containsKey('partner_b_name')) {
      context.handle(
          _partnerBNameMeta,
          partnerBName.isAcceptableOrUnknown(
              data['partner_b_name']!, _partnerBNameMeta));
    } else if (isInserting) {
      context.missing(_partnerBNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      weddingDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}wedding_date'])!,
      partnerAName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}partner_a_name'])!,
      partnerBName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}partner_b_name'])!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final int id;
  final String weddingDate;
  final String partnerAName;
  final String partnerBName;
  const Setting(
      {required this.id,
      required this.weddingDate,
      required this.partnerAName,
      required this.partnerBName});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['wedding_date'] = Variable<String>(weddingDate);
    map['partner_a_name'] = Variable<String>(partnerAName);
    map['partner_b_name'] = Variable<String>(partnerBName);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      id: Value(id),
      weddingDate: Value(weddingDate),
      partnerAName: Value(partnerAName),
      partnerBName: Value(partnerBName),
    );
  }

  factory Setting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      id: serializer.fromJson<int>(json['id']),
      weddingDate: serializer.fromJson<String>(json['weddingDate']),
      partnerAName: serializer.fromJson<String>(json['partnerAName']),
      partnerBName: serializer.fromJson<String>(json['partnerBName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'weddingDate': serializer.toJson<String>(weddingDate),
      'partnerAName': serializer.toJson<String>(partnerAName),
      'partnerBName': serializer.toJson<String>(partnerBName),
    };
  }

  Setting copyWith(
          {int? id,
          String? weddingDate,
          String? partnerAName,
          String? partnerBName}) =>
      Setting(
        id: id ?? this.id,
        weddingDate: weddingDate ?? this.weddingDate,
        partnerAName: partnerAName ?? this.partnerAName,
        partnerBName: partnerBName ?? this.partnerBName,
      );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      id: data.id.present ? data.id.value : this.id,
      weddingDate:
          data.weddingDate.present ? data.weddingDate.value : this.weddingDate,
      partnerAName: data.partnerAName.present
          ? data.partnerAName.value
          : this.partnerAName,
      partnerBName: data.partnerBName.present
          ? data.partnerBName.value
          : this.partnerBName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('id: $id, ')
          ..write('weddingDate: $weddingDate, ')
          ..write('partnerAName: $partnerAName, ')
          ..write('partnerBName: $partnerBName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, weddingDate, partnerAName, partnerBName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting &&
          other.id == this.id &&
          other.weddingDate == this.weddingDate &&
          other.partnerAName == this.partnerAName &&
          other.partnerBName == this.partnerBName);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<int> id;
  final Value<String> weddingDate;
  final Value<String> partnerAName;
  final Value<String> partnerBName;
  const SettingsCompanion({
    this.id = const Value.absent(),
    this.weddingDate = const Value.absent(),
    this.partnerAName = const Value.absent(),
    this.partnerBName = const Value.absent(),
  });
  SettingsCompanion.insert({
    this.id = const Value.absent(),
    required String weddingDate,
    required String partnerAName,
    required String partnerBName,
  })  : weddingDate = Value(weddingDate),
        partnerAName = Value(partnerAName),
        partnerBName = Value(partnerBName);
  static Insertable<Setting> custom({
    Expression<int>? id,
    Expression<String>? weddingDate,
    Expression<String>? partnerAName,
    Expression<String>? partnerBName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (weddingDate != null) 'wedding_date': weddingDate,
      if (partnerAName != null) 'partner_a_name': partnerAName,
      if (partnerBName != null) 'partner_b_name': partnerBName,
    });
  }

  SettingsCompanion copyWith(
      {Value<int>? id,
      Value<String>? weddingDate,
      Value<String>? partnerAName,
      Value<String>? partnerBName}) {
    return SettingsCompanion(
      id: id ?? this.id,
      weddingDate: weddingDate ?? this.weddingDate,
      partnerAName: partnerAName ?? this.partnerAName,
      partnerBName: partnerBName ?? this.partnerBName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (weddingDate.present) {
      map['wedding_date'] = Variable<String>(weddingDate.value);
    }
    if (partnerAName.present) {
      map['partner_a_name'] = Variable<String>(partnerAName.value);
    }
    if (partnerBName.present) {
      map['partner_b_name'] = Variable<String>(partnerBName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('id: $id, ')
          ..write('weddingDate: $weddingDate, ')
          ..write('partnerAName: $partnerAName, ')
          ..write('partnerBName: $partnerBName')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $GuestsTable guests = $GuestsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [guests, settings];
}

typedef $$GuestsTableCreateCompanionBuilder = GuestsCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> email,
  Value<String> rsvpStatus,
  Value<String?> dietaryNotes,
  Value<DateTime> createdAt,
});
typedef $$GuestsTableUpdateCompanionBuilder = GuestsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> email,
  Value<String> rsvpStatus,
  Value<String?> dietaryNotes,
  Value<DateTime> createdAt,
});

class $$GuestsTableFilterComposer
    extends Composer<_$AppDatabase, $GuestsTable> {
  $$GuestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rsvpStatus => $composableBuilder(
      column: $table.rsvpStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dietaryNotes => $composableBuilder(
      column: $table.dietaryNotes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$GuestsTableOrderingComposer
    extends Composer<_$AppDatabase, $GuestsTable> {
  $$GuestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rsvpStatus => $composableBuilder(
      column: $table.rsvpStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dietaryNotes => $composableBuilder(
      column: $table.dietaryNotes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$GuestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GuestsTable> {
  $$GuestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get rsvpStatus => $composableBuilder(
      column: $table.rsvpStatus, builder: (column) => column);

  GeneratedColumn<String> get dietaryNotes => $composableBuilder(
      column: $table.dietaryNotes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$GuestsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GuestsTable,
    Guest,
    $$GuestsTableFilterComposer,
    $$GuestsTableOrderingComposer,
    $$GuestsTableAnnotationComposer,
    $$GuestsTableCreateCompanionBuilder,
    $$GuestsTableUpdateCompanionBuilder,
    (Guest, BaseReferences<_$AppDatabase, $GuestsTable, Guest>),
    Guest,
    PrefetchHooks Function()> {
  $$GuestsTableTableManager(_$AppDatabase db, $GuestsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GuestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GuestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GuestsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String> rsvpStatus = const Value.absent(),
            Value<String?> dietaryNotes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              GuestsCompanion(
            id: id,
            name: name,
            email: email,
            rsvpStatus: rsvpStatus,
            dietaryNotes: dietaryNotes,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String?> email = const Value.absent(),
            Value<String> rsvpStatus = const Value.absent(),
            Value<String?> dietaryNotes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              GuestsCompanion.insert(
            id: id,
            name: name,
            email: email,
            rsvpStatus: rsvpStatus,
            dietaryNotes: dietaryNotes,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$GuestsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GuestsTable,
    Guest,
    $$GuestsTableFilterComposer,
    $$GuestsTableOrderingComposer,
    $$GuestsTableAnnotationComposer,
    $$GuestsTableCreateCompanionBuilder,
    $$GuestsTableUpdateCompanionBuilder,
    (Guest, BaseReferences<_$AppDatabase, $GuestsTable, Guest>),
    Guest,
    PrefetchHooks Function()>;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  Value<int> id,
  required String weddingDate,
  required String partnerAName,
  required String partnerBName,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<int> id,
  Value<String> weddingDate,
  Value<String> partnerAName,
  Value<String> partnerBName,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get weddingDate => $composableBuilder(
      column: $table.weddingDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get partnerAName => $composableBuilder(
      column: $table.partnerAName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get partnerBName => $composableBuilder(
      column: $table.partnerBName, builder: (column) => ColumnFilters(column));
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get weddingDate => $composableBuilder(
      column: $table.weddingDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get partnerAName => $composableBuilder(
      column: $table.partnerAName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get partnerBName => $composableBuilder(
      column: $table.partnerBName,
      builder: (column) => ColumnOrderings(column));
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get weddingDate => $composableBuilder(
      column: $table.weddingDate, builder: (column) => column);

  GeneratedColumn<String> get partnerAName => $composableBuilder(
      column: $table.partnerAName, builder: (column) => column);

  GeneratedColumn<String> get partnerBName => $composableBuilder(
      column: $table.partnerBName, builder: (column) => column);
}

class $$SettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
    Setting,
    PrefetchHooks Function()> {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> weddingDate = const Value.absent(),
            Value<String> partnerAName = const Value.absent(),
            Value<String> partnerBName = const Value.absent(),
          }) =>
              SettingsCompanion(
            id: id,
            weddingDate: weddingDate,
            partnerAName: partnerAName,
            partnerBName: partnerBName,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String weddingDate,
            required String partnerAName,
            required String partnerBName,
          }) =>
              SettingsCompanion.insert(
            id: id,
            weddingDate: weddingDate,
            partnerAName: partnerAName,
            partnerBName: partnerBName,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
    Setting,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$GuestsTableTableManager get guests =>
      $$GuestsTableTableManager(_db, _db.guests);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
