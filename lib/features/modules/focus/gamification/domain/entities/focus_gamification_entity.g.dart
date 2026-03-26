// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'focus_gamification_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFocusGamificationEntityCollection on Isar {
  IsarCollection<FocusGamificationEntity> get focusGamificationEntitys =>
      this.collection();
}

const FocusGamificationEntitySchema = CollectionSchema(
  name: r'FocusGamificationEntity',
  id: -8605190470453892549,
  properties: {
    r'blockedApps': PropertySchema(
      id: 0,
      name: r'blockedApps',
      type: IsarType.string,
    ),
    r'blockedAppsList': PropertySchema(
      id: 1,
      name: r'blockedAppsList',
      type: IsarType.stringList,
    ),
    r'completedSessions': PropertySchema(
      id: 2,
      name: r'completedSessions',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 3,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'currentStreakDays': PropertySchema(
      id: 4,
      name: r'currentStreakDays',
      type: IsarType.long,
    ),
    r'disciplinumCount': PropertySchema(
      id: 5,
      name: r'disciplinumCount',
      type: IsarType.long,
    ),
    r'earnedInsignias': PropertySchema(
      id: 6,
      name: r'earnedInsignias',
      type: IsarType.string,
    ),
    r'earnedInsigniasList': PropertySchema(
      id: 7,
      name: r'earnedInsigniasList',
      type: IsarType.stringList,
    ),
    r'earnedMedalhas': PropertySchema(
      id: 8,
      name: r'earnedMedalhas',
      type: IsarType.string,
    ),
    r'earnedMedalhasList': PropertySchema(
      id: 9,
      name: r'earnedMedalhasList',
      type: IsarType.stringList,
    ),
    r'lastFocusSession': PropertySchema(
      id: 10,
      name: r'lastFocusSession',
      type: IsarType.dateTime,
    ),
    r'maxStreakDays': PropertySchema(
      id: 11,
      name: r'maxStreakDays',
      type: IsarType.long,
    ),
    r'startDate': PropertySchema(
      id: 12,
      name: r'startDate',
      type: IsarType.dateTime,
    ),
    r'totalFocusMinutes': PropertySchema(
      id: 13,
      name: r'totalFocusMinutes',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 14,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _focusGamificationEntityEstimateSize,
  serialize: _focusGamificationEntitySerialize,
  deserialize: _focusGamificationEntityDeserialize,
  deserializeProp: _focusGamificationEntityDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _focusGamificationEntityGetId,
  getLinks: _focusGamificationEntityGetLinks,
  attach: _focusGamificationEntityAttach,
  version: '3.1.0+1',
);

int _focusGamificationEntityEstimateSize(
  FocusGamificationEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.blockedApps.length * 3;
  bytesCount += 3 + object.blockedAppsList.length * 3;
  {
    for (var i = 0; i < object.blockedAppsList.length; i++) {
      final value = object.blockedAppsList[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.earnedInsignias.length * 3;
  bytesCount += 3 + object.earnedInsigniasList.length * 3;
  {
    for (var i = 0; i < object.earnedInsigniasList.length; i++) {
      final value = object.earnedInsigniasList[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.earnedMedalhas.length * 3;
  bytesCount += 3 + object.earnedMedalhasList.length * 3;
  {
    for (var i = 0; i < object.earnedMedalhasList.length; i++) {
      final value = object.earnedMedalhasList[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _focusGamificationEntitySerialize(
  FocusGamificationEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.blockedApps);
  writer.writeStringList(offsets[1], object.blockedAppsList);
  writer.writeLong(offsets[2], object.completedSessions);
  writer.writeDateTime(offsets[3], object.createdAt);
  writer.writeLong(offsets[4], object.currentStreakDays);
  writer.writeLong(offsets[5], object.disciplinumCount);
  writer.writeString(offsets[6], object.earnedInsignias);
  writer.writeStringList(offsets[7], object.earnedInsigniasList);
  writer.writeString(offsets[8], object.earnedMedalhas);
  writer.writeStringList(offsets[9], object.earnedMedalhasList);
  writer.writeDateTime(offsets[10], object.lastFocusSession);
  writer.writeLong(offsets[11], object.maxStreakDays);
  writer.writeDateTime(offsets[12], object.startDate);
  writer.writeLong(offsets[13], object.totalFocusMinutes);
  writer.writeDateTime(offsets[14], object.updatedAt);
}

FocusGamificationEntity _focusGamificationEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FocusGamificationEntity();
  object.blockedApps = reader.readString(offsets[0]);
  object.blockedAppsList = reader.readStringList(offsets[1]) ?? [];
  object.completedSessions = reader.readLong(offsets[2]);
  object.createdAt = reader.readDateTime(offsets[3]);
  object.currentStreakDays = reader.readLong(offsets[4]);
  object.disciplinumCount = reader.readLong(offsets[5]);
  object.earnedInsignias = reader.readString(offsets[6]);
  object.earnedInsigniasList = reader.readStringList(offsets[7]) ?? [];
  object.earnedMedalhas = reader.readString(offsets[8]);
  object.earnedMedalhasList = reader.readStringList(offsets[9]) ?? [];
  object.id = id;
  object.lastFocusSession = reader.readDateTimeOrNull(offsets[10]);
  object.maxStreakDays = reader.readLong(offsets[11]);
  object.startDate = reader.readDateTimeOrNull(offsets[12]);
  object.totalFocusMinutes = reader.readLong(offsets[13]);
  object.updatedAt = reader.readDateTime(offsets[14]);
  return object;
}

P _focusGamificationEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readStringList(offset) ?? []) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readStringList(offset) ?? []) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readStringList(offset) ?? []) as P;
    case 10:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 13:
      return (reader.readLong(offset)) as P;
    case 14:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _focusGamificationEntityGetId(FocusGamificationEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _focusGamificationEntityGetLinks(
    FocusGamificationEntity object) {
  return [];
}

void _focusGamificationEntityAttach(
    IsarCollection<dynamic> col, Id id, FocusGamificationEntity object) {
  object.id = id;
}

extension FocusGamificationEntityQueryWhereSort
    on QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QWhere> {
  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension FocusGamificationEntityQueryWhere on QueryBuilder<
    FocusGamificationEntity, FocusGamificationEntity, QWhereClause> {
  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
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

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
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
}

extension FocusGamificationEntityQueryFilter on QueryBuilder<
    FocusGamificationEntity, FocusGamificationEntity, QFilterCondition> {
  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> blockedAppsEqualTo(
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

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> blockedAppsGreaterThan(
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

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> blockedAppsLessThan(
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

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> blockedAppsBetween(
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

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> blockedAppsStartsWith(
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

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> blockedAppsEndsWith(
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

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
          QAfterFilterCondition>
      blockedAppsContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'blockedApps',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
          QAfterFilterCondition>
      blockedAppsMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'blockedApps',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> blockedAppsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'blockedApps',
        value: '',
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> blockedAppsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'blockedApps',
        value: '',
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> blockedAppsListElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'blockedAppsList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> blockedAppsListElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'blockedAppsList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> blockedAppsListElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'blockedAppsList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> blockedAppsListElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'blockedAppsList',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> blockedAppsListElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'blockedAppsList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> blockedAppsListElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'blockedAppsList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
          QAfterFilterCondition>
      blockedAppsListElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'blockedAppsList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
          QAfterFilterCondition>
      blockedAppsListElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'blockedAppsList',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> blockedAppsListElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'blockedAppsList',
        value: '',
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> blockedAppsListElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'blockedAppsList',
        value: '',
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> blockedAppsListLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'blockedAppsList',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> blockedAppsListIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'blockedAppsList',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> blockedAppsListIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'blockedAppsList',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> blockedAppsListLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'blockedAppsList',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> blockedAppsListLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'blockedAppsList',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> blockedAppsListLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'blockedAppsList',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> completedSessionsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completedSessions',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> completedSessionsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'completedSessions',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> completedSessionsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'completedSessions',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> completedSessionsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'completedSessions',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
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

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
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

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
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

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> currentStreakDaysEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentStreakDays',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> currentStreakDaysGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentStreakDays',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> currentStreakDaysLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentStreakDays',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> currentStreakDaysBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentStreakDays',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> disciplinumCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'disciplinumCount',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> disciplinumCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'disciplinumCount',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> disciplinumCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'disciplinumCount',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> disciplinumCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'disciplinumCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> earnedInsigniasEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'earnedInsignias',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> earnedInsigniasGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'earnedInsignias',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> earnedInsigniasLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'earnedInsignias',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> earnedInsigniasBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'earnedInsignias',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> earnedInsigniasStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'earnedInsignias',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> earnedInsigniasEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'earnedInsignias',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
          QAfterFilterCondition>
      earnedInsigniasContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'earnedInsignias',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
          QAfterFilterCondition>
      earnedInsigniasMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'earnedInsignias',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> earnedInsigniasIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'earnedInsignias',
        value: '',
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> earnedInsigniasIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'earnedInsignias',
        value: '',
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> earnedInsigniasListElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'earnedInsigniasList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> earnedInsigniasListElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'earnedInsigniasList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> earnedInsigniasListElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'earnedInsigniasList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> earnedInsigniasListElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'earnedInsigniasList',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> earnedInsigniasListElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'earnedInsigniasList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> earnedInsigniasListElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'earnedInsigniasList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
          QAfterFilterCondition>
      earnedInsigniasListElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'earnedInsigniasList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
          QAfterFilterCondition>
      earnedInsigniasListElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'earnedInsigniasList',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> earnedInsigniasListElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'earnedInsigniasList',
        value: '',
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> earnedInsigniasListElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'earnedInsigniasList',
        value: '',
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> earnedInsigniasListLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedInsigniasList',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> earnedInsigniasListIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedInsigniasList',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> earnedInsigniasListIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedInsigniasList',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> earnedInsigniasListLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedInsigniasList',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> earnedInsigniasListLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedInsigniasList',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> earnedInsigniasListLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedInsigniasList',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> earnedMedalhasEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'earnedMedalhas',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> earnedMedalhasGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'earnedMedalhas',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> earnedMedalhasLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'earnedMedalhas',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> earnedMedalhasBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'earnedMedalhas',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> earnedMedalhasStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'earnedMedalhas',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> earnedMedalhasEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'earnedMedalhas',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
          QAfterFilterCondition>
      earnedMedalhasContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'earnedMedalhas',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
          QAfterFilterCondition>
      earnedMedalhasMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'earnedMedalhas',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> earnedMedalhasIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'earnedMedalhas',
        value: '',
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> earnedMedalhasIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'earnedMedalhas',
        value: '',
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> earnedMedalhasListElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'earnedMedalhasList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> earnedMedalhasListElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'earnedMedalhasList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> earnedMedalhasListElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'earnedMedalhasList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> earnedMedalhasListElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'earnedMedalhasList',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> earnedMedalhasListElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'earnedMedalhasList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> earnedMedalhasListElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'earnedMedalhasList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
          QAfterFilterCondition>
      earnedMedalhasListElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'earnedMedalhasList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
          QAfterFilterCondition>
      earnedMedalhasListElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'earnedMedalhasList',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> earnedMedalhasListElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'earnedMedalhasList',
        value: '',
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> earnedMedalhasListElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'earnedMedalhasList',
        value: '',
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> earnedMedalhasListLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedMedalhasList',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> earnedMedalhasListIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedMedalhasList',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> earnedMedalhasListIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedMedalhasList',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> earnedMedalhasListLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedMedalhasList',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> earnedMedalhasListLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedMedalhasList',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> earnedMedalhasListLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedMedalhasList',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
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

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
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

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
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

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> lastFocusSessionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastFocusSession',
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> lastFocusSessionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastFocusSession',
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> lastFocusSessionEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastFocusSession',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> lastFocusSessionGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastFocusSession',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> lastFocusSessionLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastFocusSession',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> lastFocusSessionBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastFocusSession',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> maxStreakDaysEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maxStreakDays',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> maxStreakDaysGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maxStreakDays',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> maxStreakDaysLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maxStreakDays',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> maxStreakDaysBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maxStreakDays',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> startDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'startDate',
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> startDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'startDate',
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> startDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> startDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> startDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> startDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> totalFocusMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalFocusMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
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

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
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

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
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

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
      QAfterFilterCondition> updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
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

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
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

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity,
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
}

extension FocusGamificationEntityQueryObject on QueryBuilder<
    FocusGamificationEntity, FocusGamificationEntity, QFilterCondition> {}

extension FocusGamificationEntityQueryLinks on QueryBuilder<
    FocusGamificationEntity, FocusGamificationEntity, QFilterCondition> {}

extension FocusGamificationEntityQuerySortBy
    on QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QSortBy> {
  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      sortByBlockedApps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockedApps', Sort.asc);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      sortByBlockedAppsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockedApps', Sort.desc);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      sortByCompletedSessions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedSessions', Sort.asc);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      sortByCompletedSessionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedSessions', Sort.desc);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      sortByCurrentStreakDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreakDays', Sort.asc);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      sortByCurrentStreakDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreakDays', Sort.desc);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      sortByDisciplinumCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disciplinumCount', Sort.asc);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      sortByDisciplinumCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disciplinumCount', Sort.desc);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      sortByEarnedInsignias() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earnedInsignias', Sort.asc);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      sortByEarnedInsigniasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earnedInsignias', Sort.desc);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      sortByEarnedMedalhas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earnedMedalhas', Sort.asc);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      sortByEarnedMedalhasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earnedMedalhas', Sort.desc);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      sortByLastFocusSession() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFocusSession', Sort.asc);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      sortByLastFocusSessionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFocusSession', Sort.desc);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      sortByMaxStreakDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxStreakDays', Sort.asc);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      sortByMaxStreakDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxStreakDays', Sort.desc);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      sortByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      sortByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      sortByTotalFocusMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalFocusMinutes', Sort.asc);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      sortByTotalFocusMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalFocusMinutes', Sort.desc);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension FocusGamificationEntityQuerySortThenBy on QueryBuilder<
    FocusGamificationEntity, FocusGamificationEntity, QSortThenBy> {
  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      thenByBlockedApps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockedApps', Sort.asc);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      thenByBlockedAppsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockedApps', Sort.desc);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      thenByCompletedSessions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedSessions', Sort.asc);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      thenByCompletedSessionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedSessions', Sort.desc);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      thenByCurrentStreakDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreakDays', Sort.asc);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      thenByCurrentStreakDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreakDays', Sort.desc);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      thenByDisciplinumCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disciplinumCount', Sort.asc);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      thenByDisciplinumCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disciplinumCount', Sort.desc);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      thenByEarnedInsignias() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earnedInsignias', Sort.asc);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      thenByEarnedInsigniasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earnedInsignias', Sort.desc);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      thenByEarnedMedalhas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earnedMedalhas', Sort.asc);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      thenByEarnedMedalhasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earnedMedalhas', Sort.desc);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      thenByLastFocusSession() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFocusSession', Sort.asc);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      thenByLastFocusSessionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFocusSession', Sort.desc);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      thenByMaxStreakDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxStreakDays', Sort.asc);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      thenByMaxStreakDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxStreakDays', Sort.desc);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      thenByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      thenByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      thenByTotalFocusMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalFocusMinutes', Sort.asc);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      thenByTotalFocusMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalFocusMinutes', Sort.desc);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension FocusGamificationEntityQueryWhereDistinct on QueryBuilder<
    FocusGamificationEntity, FocusGamificationEntity, QDistinct> {
  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QDistinct>
      distinctByBlockedApps({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'blockedApps', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QDistinct>
      distinctByBlockedAppsList() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'blockedAppsList');
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QDistinct>
      distinctByCompletedSessions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedSessions');
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QDistinct>
      distinctByCurrentStreakDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentStreakDays');
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QDistinct>
      distinctByDisciplinumCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'disciplinumCount');
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QDistinct>
      distinctByEarnedInsignias({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'earnedInsignias',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QDistinct>
      distinctByEarnedInsigniasList() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'earnedInsigniasList');
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QDistinct>
      distinctByEarnedMedalhas({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'earnedMedalhas',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QDistinct>
      distinctByEarnedMedalhasList() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'earnedMedalhasList');
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QDistinct>
      distinctByLastFocusSession() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastFocusSession');
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QDistinct>
      distinctByMaxStreakDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxStreakDays');
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QDistinct>
      distinctByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startDate');
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QDistinct>
      distinctByTotalFocusMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalFocusMinutes');
    });
  }

  QueryBuilder<FocusGamificationEntity, FocusGamificationEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension FocusGamificationEntityQueryProperty on QueryBuilder<
    FocusGamificationEntity, FocusGamificationEntity, QQueryProperty> {
  QueryBuilder<FocusGamificationEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<FocusGamificationEntity, String, QQueryOperations>
      blockedAppsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'blockedApps');
    });
  }

  QueryBuilder<FocusGamificationEntity, List<String>, QQueryOperations>
      blockedAppsListProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'blockedAppsList');
    });
  }

  QueryBuilder<FocusGamificationEntity, int, QQueryOperations>
      completedSessionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedSessions');
    });
  }

  QueryBuilder<FocusGamificationEntity, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<FocusGamificationEntity, int, QQueryOperations>
      currentStreakDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentStreakDays');
    });
  }

  QueryBuilder<FocusGamificationEntity, int, QQueryOperations>
      disciplinumCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'disciplinumCount');
    });
  }

  QueryBuilder<FocusGamificationEntity, String, QQueryOperations>
      earnedInsigniasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'earnedInsignias');
    });
  }

  QueryBuilder<FocusGamificationEntity, List<String>, QQueryOperations>
      earnedInsigniasListProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'earnedInsigniasList');
    });
  }

  QueryBuilder<FocusGamificationEntity, String, QQueryOperations>
      earnedMedalhasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'earnedMedalhas');
    });
  }

  QueryBuilder<FocusGamificationEntity, List<String>, QQueryOperations>
      earnedMedalhasListProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'earnedMedalhasList');
    });
  }

  QueryBuilder<FocusGamificationEntity, DateTime?, QQueryOperations>
      lastFocusSessionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastFocusSession');
    });
  }

  QueryBuilder<FocusGamificationEntity, int, QQueryOperations>
      maxStreakDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxStreakDays');
    });
  }

  QueryBuilder<FocusGamificationEntity, DateTime?, QQueryOperations>
      startDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startDate');
    });
  }

  QueryBuilder<FocusGamificationEntity, int, QQueryOperations>
      totalFocusMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalFocusMinutes');
    });
  }

  QueryBuilder<FocusGamificationEntity, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
