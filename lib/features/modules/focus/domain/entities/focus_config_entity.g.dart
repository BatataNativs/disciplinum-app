// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'focus_config_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFocusConfigEntityCollection on Isar {
  IsarCollection<FocusConfigEntity> get focusConfigEntitys => this.collection();
}

const FocusConfigEntitySchema = CollectionSchema(
  name: r'FocusConfigEntity',
  id: 7169910328729912355,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'dailyGoalMinutes': PropertySchema(
      id: 1,
      name: r'dailyGoalMinutes',
      type: IsarType.long,
    ),
    r'enableNotifications': PropertySchema(
      id: 2,
      name: r'enableNotifications',
      type: IsarType.bool,
    ),
    r'isEnabled': PropertySchema(
      id: 3,
      name: r'isEnabled',
      type: IsarType.bool,
    ),
    r'lastFocusDate': PropertySchema(
      id: 4,
      name: r'lastFocusDate',
      type: IsarType.dateTime,
    ),
    r'longestFocusSession': PropertySchema(
      id: 5,
      name: r'longestFocusSession',
      type: IsarType.long,
    ),
    r'reminderHour': PropertySchema(
      id: 6,
      name: r'reminderHour',
      type: IsarType.long,
    ),
    r'reminderMinute': PropertySchema(
      id: 7,
      name: r'reminderMinute',
      type: IsarType.long,
    ),
    r'streakDays': PropertySchema(
      id: 8,
      name: r'streakDays',
      type: IsarType.long,
    ),
    r'totalFocusMinutes': PropertySchema(
      id: 9,
      name: r'totalFocusMinutes',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 10,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'userId': PropertySchema(
      id: 11,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _focusConfigEntityEstimateSize,
  serialize: _focusConfigEntitySerialize,
  deserialize: _focusConfigEntityDeserialize,
  deserializeProp: _focusConfigEntityDeserializeProp,
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
  getId: _focusConfigEntityGetId,
  getLinks: _focusConfigEntityGetLinks,
  attach: _focusConfigEntityAttach,
  version: '3.1.0+1',
);

int _focusConfigEntityEstimateSize(
  FocusConfigEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _focusConfigEntitySerialize(
  FocusConfigEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeLong(offsets[1], object.dailyGoalMinutes);
  writer.writeBool(offsets[2], object.enableNotifications);
  writer.writeBool(offsets[3], object.isEnabled);
  writer.writeDateTime(offsets[4], object.lastFocusDate);
  writer.writeLong(offsets[5], object.longestFocusSession);
  writer.writeLong(offsets[6], object.reminderHour);
  writer.writeLong(offsets[7], object.reminderMinute);
  writer.writeLong(offsets[8], object.streakDays);
  writer.writeLong(offsets[9], object.totalFocusMinutes);
  writer.writeDateTime(offsets[10], object.updatedAt);
  writer.writeString(offsets[11], object.userId);
}

FocusConfigEntity _focusConfigEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FocusConfigEntity(
    userId: reader.readString(offsets[11]),
  );
  object.createdAt = reader.readDateTime(offsets[0]);
  object.dailyGoalMinutes = reader.readLong(offsets[1]);
  object.enableNotifications = reader.readBool(offsets[2]);
  object.id = id;
  object.isEnabled = reader.readBool(offsets[3]);
  object.lastFocusDate = reader.readDateTimeOrNull(offsets[4]);
  object.longestFocusSession = reader.readLong(offsets[5]);
  object.reminderHour = reader.readLong(offsets[6]);
  object.reminderMinute = reader.readLong(offsets[7]);
  object.streakDays = reader.readLong(offsets[8]);
  object.totalFocusMinutes = reader.readLong(offsets[9]);
  object.updatedAt = reader.readDateTime(offsets[10]);
  return object;
}

P _focusConfigEntityDeserializeProp<P>(
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
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readDateTime(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _focusConfigEntityGetId(FocusConfigEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _focusConfigEntityGetLinks(
    FocusConfigEntity object) {
  return [];
}

void _focusConfigEntityAttach(
    IsarCollection<dynamic> col, Id id, FocusConfigEntity object) {
  object.id = id;
}

extension FocusConfigEntityByIndex on IsarCollection<FocusConfigEntity> {
  Future<FocusConfigEntity?> getByUserId(String userId) {
    return getByIndex(r'userId', [userId]);
  }

  FocusConfigEntity? getByUserIdSync(String userId) {
    return getByIndexSync(r'userId', [userId]);
  }

  Future<bool> deleteByUserId(String userId) {
    return deleteByIndex(r'userId', [userId]);
  }

  bool deleteByUserIdSync(String userId) {
    return deleteByIndexSync(r'userId', [userId]);
  }

  Future<List<FocusConfigEntity?>> getAllByUserId(List<String> userIdValues) {
    final values = userIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'userId', values);
  }

  List<FocusConfigEntity?> getAllByUserIdSync(List<String> userIdValues) {
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

  Future<Id> putByUserId(FocusConfigEntity object) {
    return putByIndex(r'userId', object);
  }

  Id putByUserIdSync(FocusConfigEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'userId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUserId(List<FocusConfigEntity> objects) {
    return putAllByIndex(r'userId', objects);
  }

  List<Id> putAllByUserIdSync(List<FocusConfigEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'userId', objects, saveLinks: saveLinks);
  }
}

extension FocusConfigEntityQueryWhereSort
    on QueryBuilder<FocusConfigEntity, FocusConfigEntity, QWhere> {
  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension FocusConfigEntityQueryWhere
    on QueryBuilder<FocusConfigEntity, FocusConfigEntity, QWhereClause> {
  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterWhereClause>
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

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterWhereClause>
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

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterWhereClause>
      userIdEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterWhereClause>
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

extension FocusConfigEntityQueryFilter
    on QueryBuilder<FocusConfigEntity, FocusConfigEntity, QFilterCondition> {
  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
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

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
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

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
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

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
      dailyGoalMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dailyGoalMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
      dailyGoalMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dailyGoalMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
      dailyGoalMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dailyGoalMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
      dailyGoalMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dailyGoalMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
      enableNotificationsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enableNotifications',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
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

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
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

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
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

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
      isEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
      lastFocusDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastFocusDate',
      ));
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
      lastFocusDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastFocusDate',
      ));
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
      lastFocusDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastFocusDate',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
      lastFocusDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastFocusDate',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
      lastFocusDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastFocusDate',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
      lastFocusDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastFocusDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
      longestFocusSessionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'longestFocusSession',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
      longestFocusSessionGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'longestFocusSession',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
      longestFocusSessionLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'longestFocusSession',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
      longestFocusSessionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'longestFocusSession',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
      reminderHourEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reminderHour',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
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

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
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

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
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

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
      reminderMinuteEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reminderMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
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

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
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

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
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

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
      streakDaysEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'streakDays',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
      streakDaysGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'streakDays',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
      streakDaysLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'streakDays',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
      streakDaysBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'streakDays',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
      totalFocusMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalFocusMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
      totalFocusMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalFocusMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
      totalFocusMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalFocusMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
      totalFocusMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalFocusMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
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

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
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

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
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

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
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

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
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

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
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

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
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

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
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

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
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

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
      userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterFilterCondition>
      userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension FocusConfigEntityQueryObject
    on QueryBuilder<FocusConfigEntity, FocusConfigEntity, QFilterCondition> {}

extension FocusConfigEntityQueryLinks
    on QueryBuilder<FocusConfigEntity, FocusConfigEntity, QFilterCondition> {}

extension FocusConfigEntityQuerySortBy
    on QueryBuilder<FocusConfigEntity, FocusConfigEntity, QSortBy> {
  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy>
      sortByDailyGoalMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyGoalMinutes', Sort.asc);
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy>
      sortByDailyGoalMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyGoalMinutes', Sort.desc);
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy>
      sortByEnableNotifications() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableNotifications', Sort.asc);
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy>
      sortByEnableNotificationsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableNotifications', Sort.desc);
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy>
      sortByIsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEnabled', Sort.asc);
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy>
      sortByIsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEnabled', Sort.desc);
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy>
      sortByLastFocusDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFocusDate', Sort.asc);
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy>
      sortByLastFocusDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFocusDate', Sort.desc);
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy>
      sortByLongestFocusSession() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestFocusSession', Sort.asc);
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy>
      sortByLongestFocusSessionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestFocusSession', Sort.desc);
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy>
      sortByReminderHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderHour', Sort.asc);
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy>
      sortByReminderHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderHour', Sort.desc);
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy>
      sortByReminderMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderMinute', Sort.asc);
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy>
      sortByReminderMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderMinute', Sort.desc);
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy>
      sortByStreakDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streakDays', Sort.asc);
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy>
      sortByStreakDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streakDays', Sort.desc);
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy>
      sortByTotalFocusMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalFocusMinutes', Sort.asc);
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy>
      sortByTotalFocusMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalFocusMinutes', Sort.desc);
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy>
      sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension FocusConfigEntityQuerySortThenBy
    on QueryBuilder<FocusConfigEntity, FocusConfigEntity, QSortThenBy> {
  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy>
      thenByDailyGoalMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyGoalMinutes', Sort.asc);
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy>
      thenByDailyGoalMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyGoalMinutes', Sort.desc);
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy>
      thenByEnableNotifications() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableNotifications', Sort.asc);
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy>
      thenByEnableNotificationsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableNotifications', Sort.desc);
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy>
      thenByIsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEnabled', Sort.asc);
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy>
      thenByIsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEnabled', Sort.desc);
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy>
      thenByLastFocusDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFocusDate', Sort.asc);
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy>
      thenByLastFocusDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFocusDate', Sort.desc);
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy>
      thenByLongestFocusSession() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestFocusSession', Sort.asc);
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy>
      thenByLongestFocusSessionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestFocusSession', Sort.desc);
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy>
      thenByReminderHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderHour', Sort.asc);
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy>
      thenByReminderHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderHour', Sort.desc);
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy>
      thenByReminderMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderMinute', Sort.asc);
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy>
      thenByReminderMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderMinute', Sort.desc);
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy>
      thenByStreakDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streakDays', Sort.asc);
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy>
      thenByStreakDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streakDays', Sort.desc);
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy>
      thenByTotalFocusMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalFocusMinutes', Sort.asc);
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy>
      thenByTotalFocusMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalFocusMinutes', Sort.desc);
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy>
      thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension FocusConfigEntityQueryWhereDistinct
    on QueryBuilder<FocusConfigEntity, FocusConfigEntity, QDistinct> {
  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QDistinct>
      distinctByDailyGoalMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dailyGoalMinutes');
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QDistinct>
      distinctByEnableNotifications() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enableNotifications');
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QDistinct>
      distinctByIsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isEnabled');
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QDistinct>
      distinctByLastFocusDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastFocusDate');
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QDistinct>
      distinctByLongestFocusSession() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'longestFocusSession');
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QDistinct>
      distinctByReminderHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reminderHour');
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QDistinct>
      distinctByReminderMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reminderMinute');
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QDistinct>
      distinctByStreakDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'streakDays');
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QDistinct>
      distinctByTotalFocusMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalFocusMinutes');
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<FocusConfigEntity, FocusConfigEntity, QDistinct>
      distinctByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension FocusConfigEntityQueryProperty
    on QueryBuilder<FocusConfigEntity, FocusConfigEntity, QQueryProperty> {
  QueryBuilder<FocusConfigEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<FocusConfigEntity, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<FocusConfigEntity, int, QQueryOperations>
      dailyGoalMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dailyGoalMinutes');
    });
  }

  QueryBuilder<FocusConfigEntity, bool, QQueryOperations>
      enableNotificationsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enableNotifications');
    });
  }

  QueryBuilder<FocusConfigEntity, bool, QQueryOperations> isEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isEnabled');
    });
  }

  QueryBuilder<FocusConfigEntity, DateTime?, QQueryOperations>
      lastFocusDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastFocusDate');
    });
  }

  QueryBuilder<FocusConfigEntity, int, QQueryOperations>
      longestFocusSessionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'longestFocusSession');
    });
  }

  QueryBuilder<FocusConfigEntity, int, QQueryOperations>
      reminderHourProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reminderHour');
    });
  }

  QueryBuilder<FocusConfigEntity, int, QQueryOperations>
      reminderMinuteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reminderMinute');
    });
  }

  QueryBuilder<FocusConfigEntity, int, QQueryOperations> streakDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'streakDays');
    });
  }

  QueryBuilder<FocusConfigEntity, int, QQueryOperations>
      totalFocusMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalFocusMinutes');
    });
  }

  QueryBuilder<FocusConfigEntity, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<FocusConfigEntity, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}
