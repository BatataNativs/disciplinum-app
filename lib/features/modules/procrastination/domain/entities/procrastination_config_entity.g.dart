// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'procrastination_config_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetProcrastinationConfigEntityCollection on Isar {
  IsarCollection<ProcrastinationConfigEntity>
      get procrastinationConfigEntitys => this.collection();
}

const ProcrastinationConfigEntitySchema = CollectionSchema(
  name: r'ProcrastinationConfigEntity',
  id: 3721019986176023336,
  properties: {
    r'blockDurationMinutes': PropertySchema(
      id: 0,
      name: r'blockDurationMinutes',
      type: IsarType.long,
    ),
    r'blockedApps': PropertySchema(
      id: 1,
      name: r'blockedApps',
      type: IsarType.stringList,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'dailyFocusMinutes': PropertySchema(
      id: 3,
      name: r'dailyFocusMinutes',
      type: IsarType.long,
    ),
    r'enableAppBlocking': PropertySchema(
      id: 4,
      name: r'enableAppBlocking',
      type: IsarType.bool,
    ),
    r'enableNotifications': PropertySchema(
      id: 5,
      name: r'enableNotifications',
      type: IsarType.bool,
    ),
    r'isEnabled': PropertySchema(
      id: 6,
      name: r'isEnabled',
      type: IsarType.bool,
    ),
    r'lastFocusDate': PropertySchema(
      id: 7,
      name: r'lastFocusDate',
      type: IsarType.dateTime,
    ),
    r'longestFocusSession': PropertySchema(
      id: 8,
      name: r'longestFocusSession',
      type: IsarType.long,
    ),
    r'reminderHour': PropertySchema(
      id: 9,
      name: r'reminderHour',
      type: IsarType.long,
    ),
    r'reminderMinute': PropertySchema(
      id: 10,
      name: r'reminderMinute',
      type: IsarType.long,
    ),
    r'streakDays': PropertySchema(
      id: 11,
      name: r'streakDays',
      type: IsarType.long,
    ),
    r'totalFocusMinutes': PropertySchema(
      id: 12,
      name: r'totalFocusMinutes',
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
    )
  },
  estimateSize: _procrastinationConfigEntityEstimateSize,
  serialize: _procrastinationConfigEntitySerialize,
  deserialize: _procrastinationConfigEntityDeserialize,
  deserializeProp: _procrastinationConfigEntityDeserializeProp,
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
  getId: _procrastinationConfigEntityGetId,
  getLinks: _procrastinationConfigEntityGetLinks,
  attach: _procrastinationConfigEntityAttach,
  version: '3.1.0+1',
);

int _procrastinationConfigEntityEstimateSize(
  ProcrastinationConfigEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.blockedApps.length * 3;
  {
    for (var i = 0; i < object.blockedApps.length; i++) {
      final value = object.blockedApps[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _procrastinationConfigEntitySerialize(
  ProcrastinationConfigEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.blockDurationMinutes);
  writer.writeStringList(offsets[1], object.blockedApps);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeLong(offsets[3], object.dailyFocusMinutes);
  writer.writeBool(offsets[4], object.enableAppBlocking);
  writer.writeBool(offsets[5], object.enableNotifications);
  writer.writeBool(offsets[6], object.isEnabled);
  writer.writeDateTime(offsets[7], object.lastFocusDate);
  writer.writeLong(offsets[8], object.longestFocusSession);
  writer.writeLong(offsets[9], object.reminderHour);
  writer.writeLong(offsets[10], object.reminderMinute);
  writer.writeLong(offsets[11], object.streakDays);
  writer.writeLong(offsets[12], object.totalFocusMinutes);
  writer.writeDateTime(offsets[13], object.updatedAt);
  writer.writeString(offsets[14], object.userId);
}

ProcrastinationConfigEntity _procrastinationConfigEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ProcrastinationConfigEntity(
    userId: reader.readString(offsets[14]),
  );
  object.blockDurationMinutes = reader.readLong(offsets[0]);
  object.blockedApps = reader.readStringList(offsets[1]) ?? [];
  object.createdAt = reader.readDateTime(offsets[2]);
  object.dailyFocusMinutes = reader.readLong(offsets[3]);
  object.enableAppBlocking = reader.readBool(offsets[4]);
  object.enableNotifications = reader.readBool(offsets[5]);
  object.id = id;
  object.isEnabled = reader.readBool(offsets[6]);
  object.lastFocusDate = reader.readDateTimeOrNull(offsets[7]);
  object.longestFocusSession = reader.readLong(offsets[8]);
  object.reminderHour = reader.readLong(offsets[9]);
  object.reminderMinute = reader.readLong(offsets[10]);
  object.streakDays = reader.readLong(offsets[11]);
  object.totalFocusMinutes = reader.readLong(offsets[12]);
  object.updatedAt = reader.readDateTime(offsets[13]);
  return object;
}

P _procrastinationConfigEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readStringList(offset) ?? []) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (reader.readLong(offset)) as P;
    case 13:
      return (reader.readDateTime(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _procrastinationConfigEntityGetId(ProcrastinationConfigEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _procrastinationConfigEntityGetLinks(
    ProcrastinationConfigEntity object) {
  return [];
}

void _procrastinationConfigEntityAttach(
    IsarCollection<dynamic> col, Id id, ProcrastinationConfigEntity object) {
  object.id = id;
}

extension ProcrastinationConfigEntityByIndex
    on IsarCollection<ProcrastinationConfigEntity> {
  Future<ProcrastinationConfigEntity?> getByUserId(String userId) {
    return getByIndex(r'userId', [userId]);
  }

  ProcrastinationConfigEntity? getByUserIdSync(String userId) {
    return getByIndexSync(r'userId', [userId]);
  }

  Future<bool> deleteByUserId(String userId) {
    return deleteByIndex(r'userId', [userId]);
  }

  bool deleteByUserIdSync(String userId) {
    return deleteByIndexSync(r'userId', [userId]);
  }

  Future<List<ProcrastinationConfigEntity?>> getAllByUserId(
      List<String> userIdValues) {
    final values = userIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'userId', values);
  }

  List<ProcrastinationConfigEntity?> getAllByUserIdSync(
      List<String> userIdValues) {
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

  Future<Id> putByUserId(ProcrastinationConfigEntity object) {
    return putByIndex(r'userId', object);
  }

  Id putByUserIdSync(ProcrastinationConfigEntity object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'userId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUserId(List<ProcrastinationConfigEntity> objects) {
    return putAllByIndex(r'userId', objects);
  }

  List<Id> putAllByUserIdSync(List<ProcrastinationConfigEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'userId', objects, saveLinks: saveLinks);
  }
}

extension ProcrastinationConfigEntityQueryWhereSort on QueryBuilder<
    ProcrastinationConfigEntity, ProcrastinationConfigEntity, QWhere> {
  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ProcrastinationConfigEntityQueryWhere on QueryBuilder<
    ProcrastinationConfigEntity, ProcrastinationConfigEntity, QWhereClause> {
  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterWhereClause> idBetween(
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

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterWhereClause> userIdEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterWhereClause> userIdNotEqualTo(String userId) {
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

extension ProcrastinationConfigEntityQueryFilter on QueryBuilder<
    ProcrastinationConfigEntity,
    ProcrastinationConfigEntity,
    QFilterCondition> {
  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> blockDurationMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'blockDurationMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> blockDurationMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'blockDurationMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> blockDurationMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'blockDurationMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> blockDurationMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'blockDurationMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> blockedAppsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'blockedApps',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> blockedAppsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'blockedApps',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> blockedAppsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'blockedApps',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> blockedAppsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'blockedApps',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> blockedAppsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'blockedApps',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> blockedAppsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'blockedApps',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
          QAfterFilterCondition>
      blockedAppsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'blockedApps',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
          QAfterFilterCondition>
      blockedAppsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'blockedApps',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> blockedAppsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'blockedApps',
        value: '',
      ));
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> blockedAppsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'blockedApps',
        value: '',
      ));
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> blockedAppsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'blockedApps',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> blockedAppsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'blockedApps',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> blockedAppsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'blockedApps',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> blockedAppsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'blockedApps',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> blockedAppsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'blockedApps',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> blockedAppsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'blockedApps',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> createdAtGreaterThan(
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

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> dailyFocusMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dailyFocusMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> dailyFocusMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dailyFocusMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> dailyFocusMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dailyFocusMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> dailyFocusMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dailyFocusMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> enableAppBlockingEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enableAppBlocking',
        value: value,
      ));
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> enableNotificationsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enableNotifications',
        value: value,
      ));
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> isEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> lastFocusDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastFocusDate',
      ));
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> lastFocusDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastFocusDate',
      ));
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> lastFocusDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastFocusDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> lastFocusDateGreaterThan(
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

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> lastFocusDateLessThan(
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

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> lastFocusDateBetween(
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

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> longestFocusSessionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'longestFocusSession',
        value: value,
      ));
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> longestFocusSessionGreaterThan(
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

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> longestFocusSessionLessThan(
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

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> longestFocusSessionBetween(
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

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> reminderHourEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reminderHour',
        value: value,
      ));
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> reminderHourGreaterThan(
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

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> reminderHourLessThan(
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

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> reminderHourBetween(
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

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> reminderMinuteEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reminderMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> reminderMinuteGreaterThan(
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

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> reminderMinuteLessThan(
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

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> reminderMinuteBetween(
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

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> streakDaysEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'streakDays',
        value: value,
      ));
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> streakDaysGreaterThan(
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

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> streakDaysLessThan(
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

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> streakDaysBetween(
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

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> totalFocusMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalFocusMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> totalFocusMinutesGreaterThan(
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

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> totalFocusMinutesLessThan(
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

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> totalFocusMinutesBetween(
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

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> updatedAtGreaterThan(
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

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> updatedAtLessThan(
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

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> updatedAtBetween(
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

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> userIdEqualTo(
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

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> userIdGreaterThan(
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

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> userIdLessThan(
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

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> userIdBetween(
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

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> userIdStartsWith(
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

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> userIdEndsWith(
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

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
          QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
          QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterFilterCondition> userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension ProcrastinationConfigEntityQueryObject on QueryBuilder<
    ProcrastinationConfigEntity,
    ProcrastinationConfigEntity,
    QFilterCondition> {}

extension ProcrastinationConfigEntityQueryLinks on QueryBuilder<
    ProcrastinationConfigEntity,
    ProcrastinationConfigEntity,
    QFilterCondition> {}

extension ProcrastinationConfigEntityQuerySortBy on QueryBuilder<
    ProcrastinationConfigEntity, ProcrastinationConfigEntity, QSortBy> {
  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> sortByBlockDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockDurationMinutes', Sort.asc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> sortByBlockDurationMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockDurationMinutes', Sort.desc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> sortByDailyFocusMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyFocusMinutes', Sort.asc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> sortByDailyFocusMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyFocusMinutes', Sort.desc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> sortByEnableAppBlocking() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableAppBlocking', Sort.asc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> sortByEnableAppBlockingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableAppBlocking', Sort.desc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> sortByEnableNotifications() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableNotifications', Sort.asc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> sortByEnableNotificationsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableNotifications', Sort.desc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> sortByIsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEnabled', Sort.asc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> sortByIsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEnabled', Sort.desc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> sortByLastFocusDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFocusDate', Sort.asc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> sortByLastFocusDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFocusDate', Sort.desc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> sortByLongestFocusSession() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestFocusSession', Sort.asc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> sortByLongestFocusSessionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestFocusSession', Sort.desc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> sortByReminderHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderHour', Sort.asc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> sortByReminderHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderHour', Sort.desc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> sortByReminderMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderMinute', Sort.asc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> sortByReminderMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderMinute', Sort.desc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> sortByStreakDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streakDays', Sort.asc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> sortByStreakDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streakDays', Sort.desc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> sortByTotalFocusMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalFocusMinutes', Sort.asc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> sortByTotalFocusMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalFocusMinutes', Sort.desc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension ProcrastinationConfigEntityQuerySortThenBy on QueryBuilder<
    ProcrastinationConfigEntity, ProcrastinationConfigEntity, QSortThenBy> {
  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> thenByBlockDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockDurationMinutes', Sort.asc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> thenByBlockDurationMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockDurationMinutes', Sort.desc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> thenByDailyFocusMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyFocusMinutes', Sort.asc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> thenByDailyFocusMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyFocusMinutes', Sort.desc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> thenByEnableAppBlocking() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableAppBlocking', Sort.asc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> thenByEnableAppBlockingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableAppBlocking', Sort.desc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> thenByEnableNotifications() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableNotifications', Sort.asc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> thenByEnableNotificationsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableNotifications', Sort.desc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> thenByIsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEnabled', Sort.asc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> thenByIsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEnabled', Sort.desc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> thenByLastFocusDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFocusDate', Sort.asc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> thenByLastFocusDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFocusDate', Sort.desc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> thenByLongestFocusSession() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestFocusSession', Sort.asc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> thenByLongestFocusSessionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestFocusSession', Sort.desc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> thenByReminderHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderHour', Sort.asc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> thenByReminderHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderHour', Sort.desc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> thenByReminderMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderMinute', Sort.asc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> thenByReminderMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderMinute', Sort.desc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> thenByStreakDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streakDays', Sort.asc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> thenByStreakDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streakDays', Sort.desc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> thenByTotalFocusMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalFocusMinutes', Sort.asc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> thenByTotalFocusMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalFocusMinutes', Sort.desc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QAfterSortBy> thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension ProcrastinationConfigEntityQueryWhereDistinct on QueryBuilder<
    ProcrastinationConfigEntity, ProcrastinationConfigEntity, QDistinct> {
  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QDistinct> distinctByBlockDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'blockDurationMinutes');
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QDistinct> distinctByBlockedApps() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'blockedApps');
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QDistinct> distinctByDailyFocusMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dailyFocusMinutes');
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QDistinct> distinctByEnableAppBlocking() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enableAppBlocking');
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QDistinct> distinctByEnableNotifications() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enableNotifications');
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QDistinct> distinctByIsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isEnabled');
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QDistinct> distinctByLastFocusDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastFocusDate');
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QDistinct> distinctByLongestFocusSession() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'longestFocusSession');
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QDistinct> distinctByReminderHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reminderHour');
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QDistinct> distinctByReminderMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reminderMinute');
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QDistinct> distinctByStreakDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'streakDays');
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QDistinct> distinctByTotalFocusMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalFocusMinutes');
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, ProcrastinationConfigEntity,
      QDistinct> distinctByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension ProcrastinationConfigEntityQueryProperty on QueryBuilder<
    ProcrastinationConfigEntity, ProcrastinationConfigEntity, QQueryProperty> {
  QueryBuilder<ProcrastinationConfigEntity, int, QQueryOperations>
      idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, int, QQueryOperations>
      blockDurationMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'blockDurationMinutes');
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, List<String>, QQueryOperations>
      blockedAppsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'blockedApps');
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, int, QQueryOperations>
      dailyFocusMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dailyFocusMinutes');
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, bool, QQueryOperations>
      enableAppBlockingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enableAppBlocking');
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, bool, QQueryOperations>
      enableNotificationsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enableNotifications');
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, bool, QQueryOperations>
      isEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isEnabled');
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, DateTime?, QQueryOperations>
      lastFocusDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastFocusDate');
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, int, QQueryOperations>
      longestFocusSessionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'longestFocusSession');
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, int, QQueryOperations>
      reminderHourProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reminderHour');
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, int, QQueryOperations>
      reminderMinuteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reminderMinute');
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, int, QQueryOperations>
      streakDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'streakDays');
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, int, QQueryOperations>
      totalFocusMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalFocusMinutes');
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<ProcrastinationConfigEntity, String, QQueryOperations>
      userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}
