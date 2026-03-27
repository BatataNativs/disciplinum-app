// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'money_saving_gamification_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMoneySavingGamificationEntityCollection on Isar {
  IsarCollection<MoneySavingGamificationEntity>
      get moneySavingGamificationEntitys => this.collection();
}

const MoneySavingGamificationEntitySchema = CollectionSchema(
  name: r'MoneySavingGamificationEntity',
  id: -5848814811992811775,
  properties: {
    r'bestStreak': PropertySchema(
      id: 0,
      name: r'bestStreak',
      type: IsarType.long,
    ),
    r'consecutiveDays': PropertySchema(
      id: 1,
      name: r'consecutiveDays',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'disciplinumCount': PropertySchema(
      id: 3,
      name: r'disciplinumCount',
      type: IsarType.long,
    ),
    r'earnedInsignias': PropertySchema(
      id: 4,
      name: r'earnedInsignias',
      type: IsarType.string,
    ),
    r'earnedMedalhas': PropertySchema(
      id: 5,
      name: r'earnedMedalhas',
      type: IsarType.string,
    ),
    r'isActive': PropertySchema(
      id: 6,
      name: r'isActive',
      type: IsarType.bool,
    ),
    r'lastSavingDate': PropertySchema(
      id: 7,
      name: r'lastSavingDate',
      type: IsarType.dateTime,
    ),
    r'lastUpdated': PropertySchema(
      id: 8,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'startDate': PropertySchema(
      id: 9,
      name: r'startDate',
      type: IsarType.dateTime,
    ),
    r'totalSavedAmount': PropertySchema(
      id: 10,
      name: r'totalSavedAmount',
      type: IsarType.double,
    ),
    r'userId': PropertySchema(
      id: 11,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _moneySavingGamificationEntityEstimateSize,
  serialize: _moneySavingGamificationEntitySerialize,
  deserialize: _moneySavingGamificationEntityDeserialize,
  deserializeProp: _moneySavingGamificationEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'userId': IndexSchema(
      id: -2005826577402374815,
      name: r'userId',
      unique: false,
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
  getId: _moneySavingGamificationEntityGetId,
  getLinks: _moneySavingGamificationEntityGetLinks,
  attach: _moneySavingGamificationEntityAttach,
  version: '3.1.0+1',
);

int _moneySavingGamificationEntityEstimateSize(
  MoneySavingGamificationEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.earnedInsignias.length * 3;
  bytesCount += 3 + object.earnedMedalhas.length * 3;
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _moneySavingGamificationEntitySerialize(
  MoneySavingGamificationEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.bestStreak);
  writer.writeLong(offsets[1], object.consecutiveDays);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeLong(offsets[3], object.disciplinumCount);
  writer.writeString(offsets[4], object.earnedInsignias);
  writer.writeString(offsets[5], object.earnedMedalhas);
  writer.writeBool(offsets[6], object.isActive);
  writer.writeDateTime(offsets[7], object.lastSavingDate);
  writer.writeDateTime(offsets[8], object.lastUpdated);
  writer.writeDateTime(offsets[9], object.startDate);
  writer.writeDouble(offsets[10], object.totalSavedAmount);
  writer.writeString(offsets[11], object.userId);
}

MoneySavingGamificationEntity _moneySavingGamificationEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MoneySavingGamificationEntity(
    bestStreak: reader.readLongOrNull(offsets[0]) ?? 0,
    consecutiveDays: reader.readLongOrNull(offsets[1]) ?? 0,
    disciplinumCount: reader.readLongOrNull(offsets[3]) ?? 0,
    earnedInsignias: reader.readStringOrNull(offsets[4]) ?? '[]',
    earnedMedalhas: reader.readStringOrNull(offsets[5]) ?? '[]',
    isActive: reader.readBoolOrNull(offsets[6]) ?? false,
    lastSavingDate: reader.readDateTimeOrNull(offsets[7]),
    lastUpdated: reader.readDateTime(offsets[8]),
    startDate: reader.readDateTimeOrNull(offsets[9]),
    totalSavedAmount: reader.readDoubleOrNull(offsets[10]) ?? 0.0,
    userId: reader.readString(offsets[11]),
  );
  object.createdAt = reader.readDateTime(offsets[2]);
  object.id = id;
  return object;
}

P _moneySavingGamificationEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 1:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 4:
      return (reader.readStringOrNull(offset) ?? '[]') as P;
    case 5:
      return (reader.readStringOrNull(offset) ?? '[]') as P;
    case 6:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    case 9:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 10:
      return (reader.readDoubleOrNull(offset) ?? 0.0) as P;
    case 11:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _moneySavingGamificationEntityGetId(MoneySavingGamificationEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _moneySavingGamificationEntityGetLinks(
    MoneySavingGamificationEntity object) {
  return [];
}

void _moneySavingGamificationEntityAttach(
    IsarCollection<dynamic> col, Id id, MoneySavingGamificationEntity object) {
  object.id = id;
}

extension MoneySavingGamificationEntityQueryWhereSort on QueryBuilder<
    MoneySavingGamificationEntity, MoneySavingGamificationEntity, QWhere> {
  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MoneySavingGamificationEntityQueryWhere on QueryBuilder<
    MoneySavingGamificationEntity,
    MoneySavingGamificationEntity,
    QWhereClause> {
  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
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

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
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

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterWhereClause> userIdEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
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

extension MoneySavingGamificationEntityQueryFilter on QueryBuilder<
    MoneySavingGamificationEntity,
    MoneySavingGamificationEntity,
    QFilterCondition> {
  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterFilterCondition> bestStreakEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bestStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
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

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
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

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
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

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterFilterCondition> consecutiveDaysEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'consecutiveDays',
        value: value,
      ));
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterFilterCondition> consecutiveDaysGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'consecutiveDays',
        value: value,
      ));
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterFilterCondition> consecutiveDaysLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'consecutiveDays',
        value: value,
      ));
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterFilterCondition> consecutiveDaysBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'consecutiveDays',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
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

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
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

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
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

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterFilterCondition> disciplinumCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'disciplinumCount',
        value: value,
      ));
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
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

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
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

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
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

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
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

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
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

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
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

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
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

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
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

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
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

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
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

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
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

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterFilterCondition> earnedInsigniasIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'earnedInsignias',
        value: '',
      ));
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterFilterCondition> earnedInsigniasIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'earnedInsignias',
        value: '',
      ));
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
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

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
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

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
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

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
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

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
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

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
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

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
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

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
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

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterFilterCondition> earnedMedalhasIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'earnedMedalhas',
        value: '',
      ));
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterFilterCondition> earnedMedalhasIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'earnedMedalhas',
        value: '',
      ));
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
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

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
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

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
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

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterFilterCondition> isActiveEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isActive',
        value: value,
      ));
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterFilterCondition> lastSavingDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastSavingDate',
      ));
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterFilterCondition> lastSavingDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastSavingDate',
      ));
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterFilterCondition> lastSavingDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSavingDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterFilterCondition> lastSavingDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastSavingDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterFilterCondition> lastSavingDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastSavingDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterFilterCondition> lastSavingDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastSavingDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterFilterCondition> lastUpdatedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterFilterCondition> lastUpdatedGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterFilterCondition> lastUpdatedLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterFilterCondition> lastUpdatedBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastUpdated',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterFilterCondition> startDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'startDate',
      ));
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterFilterCondition> startDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'startDate',
      ));
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterFilterCondition> startDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
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

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
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

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
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

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterFilterCondition> totalSavedAmountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalSavedAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterFilterCondition> totalSavedAmountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalSavedAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterFilterCondition> totalSavedAmountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalSavedAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterFilterCondition> totalSavedAmountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalSavedAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
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

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
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

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
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

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
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

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
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

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
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

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
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

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
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

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterFilterCondition> userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterFilterCondition> userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension MoneySavingGamificationEntityQueryObject on QueryBuilder<
    MoneySavingGamificationEntity,
    MoneySavingGamificationEntity,
    QFilterCondition> {}

extension MoneySavingGamificationEntityQueryLinks on QueryBuilder<
    MoneySavingGamificationEntity,
    MoneySavingGamificationEntity,
    QFilterCondition> {}

extension MoneySavingGamificationEntityQuerySortBy on QueryBuilder<
    MoneySavingGamificationEntity, MoneySavingGamificationEntity, QSortBy> {
  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> sortByBestStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bestStreak', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> sortByBestStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bestStreak', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> sortByConsecutiveDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consecutiveDays', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> sortByConsecutiveDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consecutiveDays', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> sortByDisciplinumCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disciplinumCount', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> sortByDisciplinumCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disciplinumCount', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> sortByEarnedInsignias() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earnedInsignias', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> sortByEarnedInsigniasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earnedInsignias', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> sortByEarnedMedalhas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earnedMedalhas', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> sortByEarnedMedalhasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earnedMedalhas', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> sortByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> sortByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> sortByLastSavingDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSavingDate', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> sortByLastSavingDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSavingDate', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> sortByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> sortByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> sortByTotalSavedAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSavedAmount', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> sortByTotalSavedAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSavedAmount', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension MoneySavingGamificationEntityQuerySortThenBy on QueryBuilder<
    MoneySavingGamificationEntity, MoneySavingGamificationEntity, QSortThenBy> {
  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> thenByBestStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bestStreak', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> thenByBestStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bestStreak', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> thenByConsecutiveDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consecutiveDays', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> thenByConsecutiveDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consecutiveDays', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> thenByDisciplinumCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disciplinumCount', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> thenByDisciplinumCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disciplinumCount', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> thenByEarnedInsignias() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earnedInsignias', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> thenByEarnedInsigniasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earnedInsignias', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> thenByEarnedMedalhas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earnedMedalhas', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> thenByEarnedMedalhasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earnedMedalhas', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> thenByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> thenByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> thenByLastSavingDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSavingDate', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> thenByLastSavingDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSavingDate', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> thenByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> thenByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> thenByTotalSavedAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSavedAmount', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> thenByTotalSavedAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSavedAmount', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QAfterSortBy> thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension MoneySavingGamificationEntityQueryWhereDistinct on QueryBuilder<
    MoneySavingGamificationEntity, MoneySavingGamificationEntity, QDistinct> {
  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QDistinct> distinctByBestStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bestStreak');
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QDistinct> distinctByConsecutiveDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'consecutiveDays');
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QDistinct> distinctByDisciplinumCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'disciplinumCount');
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QDistinct> distinctByEarnedInsignias({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'earnedInsignias',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QDistinct> distinctByEarnedMedalhas({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'earnedMedalhas',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QDistinct> distinctByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isActive');
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QDistinct> distinctByLastSavingDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSavingDate');
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QDistinct> distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QDistinct> distinctByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startDate');
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QDistinct> distinctByTotalSavedAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalSavedAmount');
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, MoneySavingGamificationEntity,
      QDistinct> distinctByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension MoneySavingGamificationEntityQueryProperty on QueryBuilder<
    MoneySavingGamificationEntity,
    MoneySavingGamificationEntity,
    QQueryProperty> {
  QueryBuilder<MoneySavingGamificationEntity, int, QQueryOperations>
      idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, int, QQueryOperations>
      bestStreakProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bestStreak');
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, int, QQueryOperations>
      consecutiveDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'consecutiveDays');
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, int, QQueryOperations>
      disciplinumCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'disciplinumCount');
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, String, QQueryOperations>
      earnedInsigniasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'earnedInsignias');
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, String, QQueryOperations>
      earnedMedalhasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'earnedMedalhas');
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, bool, QQueryOperations>
      isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isActive');
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, DateTime?, QQueryOperations>
      lastSavingDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSavingDate');
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, DateTime, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, DateTime?, QQueryOperations>
      startDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startDate');
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, double, QQueryOperations>
      totalSavedAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalSavedAmount');
    });
  }

  QueryBuilder<MoneySavingGamificationEntity, String, QQueryOperations>
      userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}
