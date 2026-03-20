// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gamification_progress.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetGamificationProgressCollection on Isar {
  IsarCollection<GamificationProgress> get gamificationProgress =>
      this.collection();
}

const GamificationProgressSchema = CollectionSchema(
  name: r'GamificationProgress',
  id: 6055610741288592906,
  properties: {
    r'additionalData': PropertySchema(
      id: 0,
      name: r'additionalData',
      type: IsarType.string,
    ),
    r'bestStreak': PropertySchema(
      id: 1,
      name: r'bestStreak',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'currentMedal': PropertySchema(
      id: 3,
      name: r'currentMedal',
      type: IsarType.string,
    ),
    r'currentStreak': PropertySchema(
      id: 4,
      name: r'currentStreak',
      type: IsarType.long,
    ),
    r'hashCode': PropertySchema(
      id: 5,
      name: r'hashCode',
      type: IsarType.long,
    ),
    r'isNewDay': PropertySchema(
      id: 6,
      name: r'isNewDay',
      type: IsarType.bool,
    ),
    r'isStreakBroken': PropertySchema(
      id: 7,
      name: r'isStreakBroken',
      type: IsarType.bool,
    ),
    r'lastActivityDate': PropertySchema(
      id: 8,
      name: r'lastActivityDate',
      type: IsarType.dateTime,
    ),
    r'niche': PropertySchema(
      id: 9,
      name: r'niche',
      type: IsarType.byte,
      enumMap: _GamificationProgressnicheEnumValueMap,
    ),
    r'nicheId': PropertySchema(
      id: 10,
      name: r'nicheId',
      type: IsarType.long,
    ),
    r'unlockedAchievements': PropertySchema(
      id: 11,
      name: r'unlockedAchievements',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 12,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'userId': PropertySchema(
      id: 13,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _gamificationProgressEstimateSize,
  serialize: _gamificationProgressSerialize,
  deserialize: _gamificationProgressDeserialize,
  deserializeProp: _gamificationProgressDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _gamificationProgressGetId,
  getLinks: _gamificationProgressGetLinks,
  attach: _gamificationProgressAttach,
  version: '3.1.0+1',
);

int _gamificationProgressEstimateSize(
  GamificationProgress object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.additionalData;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.currentMedal;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.unlockedAchievements;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _gamificationProgressSerialize(
  GamificationProgress object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.additionalData);
  writer.writeLong(offsets[1], object.bestStreak);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeString(offsets[3], object.currentMedal);
  writer.writeLong(offsets[4], object.currentStreak);
  writer.writeLong(offsets[5], object.hashCode);
  writer.writeBool(offsets[6], object.isNewDay);
  writer.writeBool(offsets[7], object.isStreakBroken);
  writer.writeDateTime(offsets[8], object.lastActivityDate);
  writer.writeByte(offsets[9], object.niche.index);
  writer.writeLong(offsets[10], object.nicheId);
  writer.writeString(offsets[11], object.unlockedAchievements);
  writer.writeDateTime(offsets[12], object.updatedAt);
  writer.writeString(offsets[13], object.userId);
}

GamificationProgress _gamificationProgressDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = GamificationProgress(
    additionalData: reader.readStringOrNull(offsets[0]),
    bestStreak: reader.readLong(offsets[1]),
    createdAt: reader.readDateTime(offsets[2]),
    currentMedal: reader.readStringOrNull(offsets[3]),
    currentStreak: reader.readLong(offsets[4]),
    lastActivityDate: reader.readDateTime(offsets[8]),
    nicheId: reader.readLong(offsets[10]),
    unlockedAchievements: reader.readStringOrNull(offsets[11]),
    updatedAt: reader.readDateTime(offsets[12]),
    userId: reader.readString(offsets[13]),
  );
  object.id = id;
  return object;
}

P _gamificationProgressDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    case 9:
      return (_GamificationProgressnicheValueEnumMap[
              reader.readByteOrNull(offset)] ??
          NicheId.smoking) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readDateTime(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _GamificationProgressnicheEnumValueMap = {
  'smoking': 0,
  'bingeEating': 1,
  'diet': 2,
  'spending': 3,
  'focus': 4,
  'adultContent': 5,
  'moneySavingChallenge': 6,
  'procrastination': 7,
  'reading': 8,
};
const _GamificationProgressnicheValueEnumMap = {
  0: NicheId.smoking,
  1: NicheId.bingeEating,
  2: NicheId.diet,
  3: NicheId.spending,
  4: NicheId.focus,
  5: NicheId.adultContent,
  6: NicheId.moneySavingChallenge,
  7: NicheId.procrastination,
  8: NicheId.reading,
};

Id _gamificationProgressGetId(GamificationProgress object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _gamificationProgressGetLinks(
    GamificationProgress object) {
  return [];
}

void _gamificationProgressAttach(
    IsarCollection<dynamic> col, Id id, GamificationProgress object) {
  object.id = id;
}

extension GamificationProgressQueryWhereSort
    on QueryBuilder<GamificationProgress, GamificationProgress, QWhere> {
  QueryBuilder<GamificationProgress, GamificationProgress, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension GamificationProgressQueryWhere
    on QueryBuilder<GamificationProgress, GamificationProgress, QWhereClause> {
  QueryBuilder<GamificationProgress, GamificationProgress, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterWhereClause>
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

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterWhereClause>
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
}

extension GamificationProgressQueryFilter on QueryBuilder<GamificationProgress,
    GamificationProgress, QFilterCondition> {
  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> additionalDataIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'additionalData',
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> additionalDataIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'additionalData',
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> additionalDataEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'additionalData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> additionalDataGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'additionalData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> additionalDataLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'additionalData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> additionalDataBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'additionalData',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> additionalDataStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'additionalData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> additionalDataEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'additionalData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
          QAfterFilterCondition>
      additionalDataContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'additionalData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
          QAfterFilterCondition>
      additionalDataMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'additionalData',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> additionalDataIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'additionalData',
        value: '',
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> additionalDataIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'additionalData',
        value: '',
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> bestStreakEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bestStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> bestStreakGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bestStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> bestStreakLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bestStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> bestStreakBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bestStreak',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
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

  QueryBuilder<GamificationProgress, GamificationProgress,
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

  QueryBuilder<GamificationProgress, GamificationProgress,
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

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> currentMedalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'currentMedal',
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> currentMedalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'currentMedal',
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> currentMedalEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentMedal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> currentMedalGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentMedal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> currentMedalLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentMedal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> currentMedalBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentMedal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> currentMedalStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'currentMedal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> currentMedalEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'currentMedal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
          QAfterFilterCondition>
      currentMedalContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'currentMedal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
          QAfterFilterCondition>
      currentMedalMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'currentMedal',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> currentMedalIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentMedal',
        value: '',
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> currentMedalIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'currentMedal',
        value: '',
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> currentStreakEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> currentStreakGreaterThan(
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

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> currentStreakLessThan(
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

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> currentStreakBetween(
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

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> hashCodeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> hashCodeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> hashCodeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> hashCodeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hashCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
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

  QueryBuilder<GamificationProgress, GamificationProgress,
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

  QueryBuilder<GamificationProgress, GamificationProgress,
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

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> isNewDayEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isNewDay',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> isStreakBrokenEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isStreakBroken',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> lastActivityDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastActivityDate',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> lastActivityDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastActivityDate',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> lastActivityDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastActivityDate',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> lastActivityDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastActivityDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> nicheEqualTo(NicheId value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'niche',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> nicheGreaterThan(
    NicheId value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'niche',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> nicheLessThan(
    NicheId value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'niche',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> nicheBetween(
    NicheId lower,
    NicheId upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'niche',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> nicheIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nicheId',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> nicheIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nicheId',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> nicheIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nicheId',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> nicheIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nicheId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> unlockedAchievementsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'unlockedAchievements',
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> unlockedAchievementsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'unlockedAchievements',
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> unlockedAchievementsEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unlockedAchievements',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> unlockedAchievementsGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unlockedAchievements',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> unlockedAchievementsLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unlockedAchievements',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> unlockedAchievementsBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unlockedAchievements',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> unlockedAchievementsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'unlockedAchievements',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> unlockedAchievementsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'unlockedAchievements',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
          QAfterFilterCondition>
      unlockedAchievementsContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'unlockedAchievements',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
          QAfterFilterCondition>
      unlockedAchievementsMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'unlockedAchievements',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> unlockedAchievementsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unlockedAchievements',
        value: '',
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> unlockedAchievementsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'unlockedAchievements',
        value: '',
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
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

  QueryBuilder<GamificationProgress, GamificationProgress,
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

  QueryBuilder<GamificationProgress, GamificationProgress,
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

  QueryBuilder<GamificationProgress, GamificationProgress,
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

  QueryBuilder<GamificationProgress, GamificationProgress,
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

  QueryBuilder<GamificationProgress, GamificationProgress,
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

  QueryBuilder<GamificationProgress, GamificationProgress,
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

  QueryBuilder<GamificationProgress, GamificationProgress,
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

  QueryBuilder<GamificationProgress, GamificationProgress,
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

  QueryBuilder<GamificationProgress, GamificationProgress,
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

  QueryBuilder<GamificationProgress, GamificationProgress,
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

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress,
      QAfterFilterCondition> userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension GamificationProgressQueryObject on QueryBuilder<GamificationProgress,
    GamificationProgress, QFilterCondition> {}

extension GamificationProgressQueryLinks on QueryBuilder<GamificationProgress,
    GamificationProgress, QFilterCondition> {}

extension GamificationProgressQuerySortBy
    on QueryBuilder<GamificationProgress, GamificationProgress, QSortBy> {
  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      sortByAdditionalData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'additionalData', Sort.asc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      sortByAdditionalDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'additionalData', Sort.desc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      sortByBestStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bestStreak', Sort.asc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      sortByBestStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bestStreak', Sort.desc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      sortByCurrentMedal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentMedal', Sort.asc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      sortByCurrentMedalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentMedal', Sort.desc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      sortByCurrentStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.asc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      sortByCurrentStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.desc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      sortByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      sortByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      sortByIsNewDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNewDay', Sort.asc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      sortByIsNewDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNewDay', Sort.desc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      sortByIsStreakBroken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isStreakBroken', Sort.asc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      sortByIsStreakBrokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isStreakBroken', Sort.desc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      sortByLastActivityDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastActivityDate', Sort.asc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      sortByLastActivityDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastActivityDate', Sort.desc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      sortByNiche() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'niche', Sort.asc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      sortByNicheDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'niche', Sort.desc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      sortByNicheId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nicheId', Sort.asc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      sortByNicheIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nicheId', Sort.desc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      sortByUnlockedAchievements() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockedAchievements', Sort.asc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      sortByUnlockedAchievementsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockedAchievements', Sort.desc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension GamificationProgressQuerySortThenBy
    on QueryBuilder<GamificationProgress, GamificationProgress, QSortThenBy> {
  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      thenByAdditionalData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'additionalData', Sort.asc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      thenByAdditionalDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'additionalData', Sort.desc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      thenByBestStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bestStreak', Sort.asc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      thenByBestStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bestStreak', Sort.desc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      thenByCurrentMedal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentMedal', Sort.asc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      thenByCurrentMedalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentMedal', Sort.desc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      thenByCurrentStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.asc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      thenByCurrentStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.desc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      thenByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      thenByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      thenByIsNewDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNewDay', Sort.asc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      thenByIsNewDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNewDay', Sort.desc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      thenByIsStreakBroken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isStreakBroken', Sort.asc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      thenByIsStreakBrokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isStreakBroken', Sort.desc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      thenByLastActivityDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastActivityDate', Sort.asc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      thenByLastActivityDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastActivityDate', Sort.desc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      thenByNiche() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'niche', Sort.asc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      thenByNicheDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'niche', Sort.desc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      thenByNicheId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nicheId', Sort.asc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      thenByNicheIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nicheId', Sort.desc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      thenByUnlockedAchievements() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockedAchievements', Sort.asc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      thenByUnlockedAchievementsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockedAchievements', Sort.desc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension GamificationProgressQueryWhereDistinct
    on QueryBuilder<GamificationProgress, GamificationProgress, QDistinct> {
  QueryBuilder<GamificationProgress, GamificationProgress, QDistinct>
      distinctByAdditionalData({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'additionalData',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QDistinct>
      distinctByBestStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bestStreak');
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QDistinct>
      distinctByCurrentMedal({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentMedal', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QDistinct>
      distinctByCurrentStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentStreak');
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QDistinct>
      distinctByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hashCode');
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QDistinct>
      distinctByIsNewDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isNewDay');
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QDistinct>
      distinctByIsStreakBroken() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isStreakBroken');
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QDistinct>
      distinctByLastActivityDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastActivityDate');
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QDistinct>
      distinctByNiche() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'niche');
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QDistinct>
      distinctByNicheId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nicheId');
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QDistinct>
      distinctByUnlockedAchievements({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unlockedAchievements',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<GamificationProgress, GamificationProgress, QDistinct>
      distinctByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension GamificationProgressQueryProperty on QueryBuilder<
    GamificationProgress, GamificationProgress, QQueryProperty> {
  QueryBuilder<GamificationProgress, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<GamificationProgress, String?, QQueryOperations>
      additionalDataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'additionalData');
    });
  }

  QueryBuilder<GamificationProgress, int, QQueryOperations>
      bestStreakProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bestStreak');
    });
  }

  QueryBuilder<GamificationProgress, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<GamificationProgress, String?, QQueryOperations>
      currentMedalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentMedal');
    });
  }

  QueryBuilder<GamificationProgress, int, QQueryOperations>
      currentStreakProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentStreak');
    });
  }

  QueryBuilder<GamificationProgress, int, QQueryOperations> hashCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hashCode');
    });
  }

  QueryBuilder<GamificationProgress, bool, QQueryOperations>
      isNewDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isNewDay');
    });
  }

  QueryBuilder<GamificationProgress, bool, QQueryOperations>
      isStreakBrokenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isStreakBroken');
    });
  }

  QueryBuilder<GamificationProgress, DateTime, QQueryOperations>
      lastActivityDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastActivityDate');
    });
  }

  QueryBuilder<GamificationProgress, NicheId, QQueryOperations>
      nicheProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'niche');
    });
  }

  QueryBuilder<GamificationProgress, int, QQueryOperations> nicheIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nicheId');
    });
  }

  QueryBuilder<GamificationProgress, String?, QQueryOperations>
      unlockedAchievementsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unlockedAchievements');
    });
  }

  QueryBuilder<GamificationProgress, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<GamificationProgress, String, QQueryOperations>
      userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}
