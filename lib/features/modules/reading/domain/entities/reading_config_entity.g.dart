// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_config_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetReadingConfigEntityCollection on Isar {
  IsarCollection<ReadingConfigEntity> get readingConfigEntitys =>
      this.collection();
}

const ReadingConfigEntitySchema = CollectionSchema(
  name: r'ReadingConfigEntity',
  id: -2309873619300957126,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'currentStreak': PropertySchema(
      id: 1,
      name: r'currentStreak',
      type: IsarType.long,
    ),
    r'dailyPagesGoal': PropertySchema(
      id: 2,
      name: r'dailyPagesGoal',
      type: IsarType.long,
    ),
    r'enableDailyReminder': PropertySchema(
      id: 3,
      name: r'enableDailyReminder',
      type: IsarType.bool,
    ),
    r'enableNotifications': PropertySchema(
      id: 4,
      name: r'enableNotifications',
      type: IsarType.bool,
    ),
    r'enableStreakReminder': PropertySchema(
      id: 5,
      name: r'enableStreakReminder',
      type: IsarType.bool,
    ),
    r'isModuleActive': PropertySchema(
      id: 6,
      name: r'isModuleActive',
      type: IsarType.bool,
    ),
    r'lastReadingDate': PropertySchema(
      id: 7,
      name: r'lastReadingDate',
      type: IsarType.dateTime,
    ),
    r'longestStreakDays': PropertySchema(
      id: 8,
      name: r'longestStreakDays',
      type: IsarType.long,
    ),
    r'longestStreakEnd': PropertySchema(
      id: 9,
      name: r'longestStreakEnd',
      type: IsarType.dateTime,
    ),
    r'longestStreakStart': PropertySchema(
      id: 10,
      name: r'longestStreakStart',
      type: IsarType.dateTime,
    ),
    r'reminderHour': PropertySchema(
      id: 11,
      name: r'reminderHour',
      type: IsarType.long,
    ),
    r'reminderMinute': PropertySchema(
      id: 12,
      name: r'reminderMinute',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 13,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'userId': PropertySchema(
      id: 14,
      name: r'userId',
      type: IsarType.string,
    ),
    r'weeklyBooksGoal': PropertySchema(
      id: 15,
      name: r'weeklyBooksGoal',
      type: IsarType.long,
    )
  },
  estimateSize: _readingConfigEntityEstimateSize,
  serialize: _readingConfigEntitySerialize,
  deserialize: _readingConfigEntityDeserialize,
  deserializeProp: _readingConfigEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'userId': IndexSchema(
      id: -2005826577402374815,
      name: r'userId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'userId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _readingConfigEntityGetId,
  getLinks: _readingConfigEntityGetLinks,
  attach: _readingConfigEntityAttach,
  version: '3.1.0+1',
);

int _readingConfigEntityEstimateSize(
  ReadingConfigEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _readingConfigEntitySerialize(
  ReadingConfigEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeLong(offsets[1], object.currentStreak);
  writer.writeLong(offsets[2], object.dailyPagesGoal);
  writer.writeBool(offsets[3], object.enableDailyReminder);
  writer.writeBool(offsets[4], object.enableNotifications);
  writer.writeBool(offsets[5], object.enableStreakReminder);
  writer.writeBool(offsets[6], object.isModuleActive);
  writer.writeDateTime(offsets[7], object.lastReadingDate);
  writer.writeLong(offsets[8], object.longestStreakDays);
  writer.writeDateTime(offsets[9], object.longestStreakEnd);
  writer.writeDateTime(offsets[10], object.longestStreakStart);
  writer.writeLong(offsets[11], object.reminderHour);
  writer.writeLong(offsets[12], object.reminderMinute);
  writer.writeDateTime(offsets[13], object.updatedAt);
  writer.writeString(offsets[14], object.userId);
  writer.writeLong(offsets[15], object.weeklyBooksGoal);
}

ReadingConfigEntity _readingConfigEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ReadingConfigEntity(
    isModuleActive: reader.readBoolOrNull(offsets[6]) ?? false,
    userId: reader.readString(offsets[14]),
  );
  object.createdAt = reader.readDateTime(offsets[0]);
  object.currentStreak = reader.readLong(offsets[1]);
  object.dailyPagesGoal = reader.readLong(offsets[2]);
  object.enableDailyReminder = reader.readBool(offsets[3]);
  object.enableNotifications = reader.readBool(offsets[4]);
  object.enableStreakReminder = reader.readBool(offsets[5]);
  object.id = id;
  object.lastReadingDate = reader.readDateTimeOrNull(offsets[7]);
  object.longestStreakDays = reader.readLong(offsets[8]);
  object.longestStreakEnd = reader.readDateTimeOrNull(offsets[9]);
  object.longestStreakStart = reader.readDateTimeOrNull(offsets[10]);
  object.reminderHour = reader.readLong(offsets[11]);
  object.reminderMinute = reader.readLong(offsets[12]);
  object.updatedAt = reader.readDateTime(offsets[13]);
  object.weeklyBooksGoal = reader.readLong(offsets[15]);
  return object;
}

P _readingConfigEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 10:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (reader.readLong(offset)) as P;
    case 13:
      return (reader.readDateTime(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _readingConfigEntityGetId(ReadingConfigEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _readingConfigEntityGetLinks(
    ReadingConfigEntity object) {
  return [];
}

void _readingConfigEntityAttach(
    IsarCollection<dynamic> col, Id id, ReadingConfigEntity object) {
  object.id = id;
}

extension ReadingConfigEntityByIndex on IsarCollection<ReadingConfigEntity> {
  Future<ReadingConfigEntity?> getByUserId(String userId) {
    return getByIndex(r'userId', [userId]);
  }

  ReadingConfigEntity? getByUserIdSync(String userId) {
    return getByIndexSync(r'userId', [userId]);
  }

  Future<bool> deleteByUserId(String userId) {
    return deleteByIndex(r'userId', [userId]);
  }

  bool deleteByUserIdSync(String userId) {
    return deleteByIndexSync(r'userId', [userId]);
  }

  Future<List<ReadingConfigEntity?>> getAllByUserId(List<String> userIdValues) {
    final values = userIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'userId', values);
  }

  List<ReadingConfigEntity?> getAllByUserIdSync(List<String> userIdValues) {
    final values = userIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'userId', values);
  }

  Future<int> deleteAllByUserId(List<String> userIdValues) {
    final values = userIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'userId', values);
  }

  int deleteAllByUserIdSync(List<String> userIdValues) {
    final values = userIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'userId', values);
  }

  Future<Id> putByUserId(ReadingConfigEntity object) {
    return putByIndex(r'userId', object);
  }

  Id putByUserIdSync(ReadingConfigEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'userId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUserId(List<ReadingConfigEntity> objects) {
    return putAllByIndex(r'userId', objects);
  }

  List<Id> putAllByUserIdSync(List<ReadingConfigEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'userId', objects, saveLinks: saveLinks);
  }
}

extension ReadingConfigEntityQueryWhereSort
    on QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QWhere> {
  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ReadingConfigEntityQueryWhere
    on QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QWhereClause> {
  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterWhereClause>
      userIdEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterWhereClause>
      userIdNotEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [userId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [userId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ReadingConfigEntityQueryFilter on QueryBuilder<ReadingConfigEntity,
    ReadingConfigEntity, QFilterCondition> {
  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      currentStreakEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      currentStreakGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      currentStreakLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      currentStreakBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentStreak',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      dailyPagesGoalEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dailyPagesGoal',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      dailyPagesGoalGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dailyPagesGoal',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      dailyPagesGoalLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dailyPagesGoal',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      dailyPagesGoalBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dailyPagesGoal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      enableDailyReminderEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enableDailyReminder',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      enableNotificationsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enableNotifications',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      enableStreakReminderEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enableStreakReminder',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      isModuleActiveEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isModuleActive',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      lastReadingDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastReadingDate',
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      lastReadingDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastReadingDate',
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      lastReadingDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastReadingDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      lastReadingDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastReadingDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      lastReadingDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastReadingDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      lastReadingDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastReadingDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      longestStreakDaysEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'longestStreakDays',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      longestStreakDaysGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'longestStreakDays',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      longestStreakDaysLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'longestStreakDays',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      longestStreakDaysBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'longestStreakDays',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      longestStreakEndIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'longestStreakEnd',
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      longestStreakEndIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'longestStreakEnd',
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      longestStreakEndEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'longestStreakEnd',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      longestStreakEndGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'longestStreakEnd',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      longestStreakEndLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'longestStreakEnd',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      longestStreakEndBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'longestStreakEnd',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      longestStreakStartIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'longestStreakStart',
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      longestStreakStartIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'longestStreakStart',
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      longestStreakStartEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'longestStreakStart',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      longestStreakStartGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'longestStreakStart',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      longestStreakStartLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'longestStreakStart',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      longestStreakStartBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'longestStreakStart',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      reminderHourEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reminderHour',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      reminderHourGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reminderHour',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      reminderHourLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reminderHour',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      reminderHourBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reminderHour',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      reminderMinuteEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reminderMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      reminderMinuteGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reminderMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      reminderMinuteLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reminderMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      reminderMinuteBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reminderMinute',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      userIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      userIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      userIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      userIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      userIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      userIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      weeklyBooksGoalEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weeklyBooksGoal',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      weeklyBooksGoalGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weeklyBooksGoal',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      weeklyBooksGoalLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weeklyBooksGoal',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterFilterCondition>
      weeklyBooksGoalBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weeklyBooksGoal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ReadingConfigEntityQueryObject on QueryBuilder<ReadingConfigEntity,
    ReadingConfigEntity, QFilterCondition> {}

extension ReadingConfigEntityQueryLinks on QueryBuilder<ReadingConfigEntity,
    ReadingConfigEntity, QFilterCondition> {}

extension ReadingConfigEntityQuerySortBy
    on QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QSortBy> {
  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      sortByCurrentStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.asc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      sortByCurrentStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.desc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      sortByDailyPagesGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyPagesGoal', Sort.asc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      sortByDailyPagesGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyPagesGoal', Sort.desc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      sortByEnableDailyReminder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableDailyReminder', Sort.asc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      sortByEnableDailyReminderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableDailyReminder', Sort.desc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      sortByEnableNotifications() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableNotifications', Sort.asc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      sortByEnableNotificationsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableNotifications', Sort.desc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      sortByEnableStreakReminder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableStreakReminder', Sort.asc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      sortByEnableStreakReminderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableStreakReminder', Sort.desc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      sortByIsModuleActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isModuleActive', Sort.asc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      sortByIsModuleActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isModuleActive', Sort.desc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      sortByLastReadingDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadingDate', Sort.asc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      sortByLastReadingDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadingDate', Sort.desc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      sortByLongestStreakDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestStreakDays', Sort.asc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      sortByLongestStreakDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestStreakDays', Sort.desc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      sortByLongestStreakEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestStreakEnd', Sort.asc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      sortByLongestStreakEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestStreakEnd', Sort.desc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      sortByLongestStreakStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestStreakStart', Sort.asc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      sortByLongestStreakStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestStreakStart', Sort.desc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      sortByReminderHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderHour', Sort.asc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      sortByReminderHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderHour', Sort.desc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      sortByReminderMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderMinute', Sort.asc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      sortByReminderMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderMinute', Sort.desc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      sortByWeeklyBooksGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeklyBooksGoal', Sort.asc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      sortByWeeklyBooksGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeklyBooksGoal', Sort.desc);
    });
  }
}

extension ReadingConfigEntityQuerySortThenBy
    on QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QSortThenBy> {
  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      thenByCurrentStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.asc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      thenByCurrentStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.desc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      thenByDailyPagesGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyPagesGoal', Sort.asc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      thenByDailyPagesGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyPagesGoal', Sort.desc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      thenByEnableDailyReminder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableDailyReminder', Sort.asc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      thenByEnableDailyReminderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableDailyReminder', Sort.desc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      thenByEnableNotifications() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableNotifications', Sort.asc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      thenByEnableNotificationsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableNotifications', Sort.desc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      thenByEnableStreakReminder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableStreakReminder', Sort.asc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      thenByEnableStreakReminderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableStreakReminder', Sort.desc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      thenByIsModuleActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isModuleActive', Sort.asc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      thenByIsModuleActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isModuleActive', Sort.desc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      thenByLastReadingDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadingDate', Sort.asc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      thenByLastReadingDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadingDate', Sort.desc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      thenByLongestStreakDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestStreakDays', Sort.asc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      thenByLongestStreakDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestStreakDays', Sort.desc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      thenByLongestStreakEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestStreakEnd', Sort.asc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      thenByLongestStreakEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestStreakEnd', Sort.desc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      thenByLongestStreakStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestStreakStart', Sort.asc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      thenByLongestStreakStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestStreakStart', Sort.desc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      thenByReminderHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderHour', Sort.asc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      thenByReminderHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderHour', Sort.desc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      thenByReminderMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderMinute', Sort.asc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      thenByReminderMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderMinute', Sort.desc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      thenByWeeklyBooksGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeklyBooksGoal', Sort.asc);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QAfterSortBy>
      thenByWeeklyBooksGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeklyBooksGoal', Sort.desc);
    });
  }
}

extension ReadingConfigEntityQueryWhereDistinct
    on QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QDistinct> {
  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QDistinct>
      distinctByCurrentStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentStreak');
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QDistinct>
      distinctByDailyPagesGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dailyPagesGoal');
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QDistinct>
      distinctByEnableDailyReminder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enableDailyReminder');
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QDistinct>
      distinctByEnableNotifications() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enableNotifications');
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QDistinct>
      distinctByEnableStreakReminder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enableStreakReminder');
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QDistinct>
      distinctByIsModuleActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isModuleActive');
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QDistinct>
      distinctByLastReadingDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastReadingDate');
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QDistinct>
      distinctByLongestStreakDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'longestStreakDays');
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QDistinct>
      distinctByLongestStreakEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'longestStreakEnd');
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QDistinct>
      distinctByLongestStreakStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'longestStreakStart');
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QDistinct>
      distinctByReminderHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reminderHour');
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QDistinct>
      distinctByReminderMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reminderMinute');
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QDistinct>
      distinctByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QDistinct>
      distinctByWeeklyBooksGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weeklyBooksGoal');
    });
  }
}

extension ReadingConfigEntityQueryProperty
    on QueryBuilder<ReadingConfigEntity, ReadingConfigEntity, QQueryProperty> {
  QueryBuilder<ReadingConfigEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ReadingConfigEntity, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<ReadingConfigEntity, int, QQueryOperations>
      currentStreakProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentStreak');
    });
  }

  QueryBuilder<ReadingConfigEntity, int, QQueryOperations>
      dailyPagesGoalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dailyPagesGoal');
    });
  }

  QueryBuilder<ReadingConfigEntity, bool, QQueryOperations>
      enableDailyReminderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enableDailyReminder');
    });
  }

  QueryBuilder<ReadingConfigEntity, bool, QQueryOperations>
      enableNotificationsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enableNotifications');
    });
  }

  QueryBuilder<ReadingConfigEntity, bool, QQueryOperations>
      enableStreakReminderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enableStreakReminder');
    });
  }

  QueryBuilder<ReadingConfigEntity, bool, QQueryOperations>
      isModuleActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isModuleActive');
    });
  }

  QueryBuilder<ReadingConfigEntity, DateTime?, QQueryOperations>
      lastReadingDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastReadingDate');
    });
  }

  QueryBuilder<ReadingConfigEntity, int, QQueryOperations>
      longestStreakDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'longestStreakDays');
    });
  }

  QueryBuilder<ReadingConfigEntity, DateTime?, QQueryOperations>
      longestStreakEndProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'longestStreakEnd');
    });
  }

  QueryBuilder<ReadingConfigEntity, DateTime?, QQueryOperations>
      longestStreakStartProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'longestStreakStart');
    });
  }

  QueryBuilder<ReadingConfigEntity, int, QQueryOperations>
      reminderHourProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reminderHour');
    });
  }

  QueryBuilder<ReadingConfigEntity, int, QQueryOperations>
      reminderMinuteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reminderMinute');
    });
  }

  QueryBuilder<ReadingConfigEntity, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<ReadingConfigEntity, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }

  QueryBuilder<ReadingConfigEntity, int, QQueryOperations>
      weeklyBooksGoalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weeklyBooksGoal');
    });
  }
}
