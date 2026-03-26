// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'smoking_gamification_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSmokingGamificationEntityCollection on Isar {
  IsarCollection<SmokingGamificationEntity> get smokingGamificationEntitys =>
      this.collection();
}

const SmokingGamificationEntitySchema = CollectionSchema(
  name: r'SmokingGamificationEntity',
  id: 2962251724919287570,
  properties: {
    r'consecutivePositiveDays': PropertySchema(
      id: 0,
      name: r'consecutivePositiveDays',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'dailyCost': PropertySchema(
      id: 2,
      name: r'dailyCost',
      type: IsarType.double,
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
    r'earnedInsigniasList': PropertySchema(
      id: 5,
      name: r'earnedInsigniasList',
      type: IsarType.stringList,
    ),
    r'earnedMedalhas': PropertySchema(
      id: 6,
      name: r'earnedMedalhas',
      type: IsarType.string,
    ),
    r'earnedMedalhasList': PropertySchema(
      id: 7,
      name: r'earnedMedalhasList',
      type: IsarType.stringList,
    ),
    r'hasSignificantStreak': PropertySchema(
      id: 8,
      name: r'hasSignificantStreak',
      type: IsarType.bool,
    ),
    r'isInStreak': PropertySchema(
      id: 9,
      name: r'isInStreak',
      type: IsarType.bool,
    ),
    r'lastPositiveCheckIn': PropertySchema(
      id: 10,
      name: r'lastPositiveCheckIn',
      type: IsarType.dateTime,
    ),
    r'packCost': PropertySchema(
      id: 11,
      name: r'packCost',
      type: IsarType.double,
    ),
    r'startDate': PropertySchema(
      id: 12,
      name: r'startDate',
      type: IsarType.dateTime,
    ),
    r'updatedAt': PropertySchema(
      id: 13,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _smokingGamificationEntityEstimateSize,
  serialize: _smokingGamificationEntitySerialize,
  deserialize: _smokingGamificationEntityDeserialize,
  deserializeProp: _smokingGamificationEntityDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _smokingGamificationEntityGetId,
  getLinks: _smokingGamificationEntityGetLinks,
  attach: _smokingGamificationEntityAttach,
  version: '3.1.0+1',
);

int _smokingGamificationEntityEstimateSize(
  SmokingGamificationEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
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

void _smokingGamificationEntitySerialize(
  SmokingGamificationEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.consecutivePositiveDays);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeDouble(offsets[2], object.dailyCost);
  writer.writeLong(offsets[3], object.disciplinumCount);
  writer.writeString(offsets[4], object.earnedInsignias);
  writer.writeStringList(offsets[5], object.earnedInsigniasList);
  writer.writeString(offsets[6], object.earnedMedalhas);
  writer.writeStringList(offsets[7], object.earnedMedalhasList);
  writer.writeBool(offsets[8], object.hasSignificantStreak);
  writer.writeBool(offsets[9], object.isInStreak);
  writer.writeDateTime(offsets[10], object.lastPositiveCheckIn);
  writer.writeDouble(offsets[11], object.packCost);
  writer.writeDateTime(offsets[12], object.startDate);
  writer.writeDateTime(offsets[13], object.updatedAt);
}

SmokingGamificationEntity _smokingGamificationEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SmokingGamificationEntity();
  object.consecutivePositiveDays = reader.readLong(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.dailyCost = reader.readDouble(offsets[2]);
  object.disciplinumCount = reader.readLong(offsets[3]);
  object.earnedInsignias = reader.readString(offsets[4]);
  object.earnedInsigniasList = reader.readStringList(offsets[5]) ?? [];
  object.earnedMedalhas = reader.readString(offsets[6]);
  object.earnedMedalhasList = reader.readStringList(offsets[7]) ?? [];
  object.id = id;
  object.lastPositiveCheckIn = reader.readDateTimeOrNull(offsets[10]);
  object.packCost = reader.readDouble(offsets[11]);
  object.startDate = reader.readDateTimeOrNull(offsets[12]);
  object.updatedAt = reader.readDateTime(offsets[13]);
  return object;
}

P _smokingGamificationEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readStringList(offset) ?? []) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readStringList(offset) ?? []) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readBool(offset)) as P;
    case 10:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 11:
      return (reader.readDouble(offset)) as P;
    case 12:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 13:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _smokingGamificationEntityGetId(SmokingGamificationEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _smokingGamificationEntityGetLinks(
    SmokingGamificationEntity object) {
  return [];
}

void _smokingGamificationEntityAttach(
    IsarCollection<dynamic> col, Id id, SmokingGamificationEntity object) {
  object.id = id;
}

extension SmokingGamificationEntityQueryWhereSort on QueryBuilder<
    SmokingGamificationEntity, SmokingGamificationEntity, QWhere> {
  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SmokingGamificationEntityQueryWhere on QueryBuilder<
    SmokingGamificationEntity, SmokingGamificationEntity, QWhereClause> {
  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

extension SmokingGamificationEntityQueryFilter on QueryBuilder<
    SmokingGamificationEntity, SmokingGamificationEntity, QFilterCondition> {
  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterFilterCondition> consecutivePositiveDaysEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'consecutivePositiveDays',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterFilterCondition> consecutivePositiveDaysGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'consecutivePositiveDays',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterFilterCondition> consecutivePositiveDaysLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'consecutivePositiveDays',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterFilterCondition> consecutivePositiveDaysBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'consecutivePositiveDays',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterFilterCondition> dailyCostEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dailyCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterFilterCondition> dailyCostGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dailyCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterFilterCondition> dailyCostLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dailyCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterFilterCondition> dailyCostBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dailyCost',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterFilterCondition> disciplinumCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'disciplinumCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterFilterCondition> earnedInsigniasIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'earnedInsignias',
        value: '',
      ));
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterFilterCondition> earnedInsigniasIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'earnedInsignias',
        value: '',
      ));
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterFilterCondition> earnedInsigniasListElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'earnedInsigniasList',
        value: '',
      ));
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterFilterCondition> earnedInsigniasListElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'earnedInsigniasList',
        value: '',
      ));
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterFilterCondition> earnedMedalhasIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'earnedMedalhas',
        value: '',
      ));
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterFilterCondition> earnedMedalhasIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'earnedMedalhas',
        value: '',
      ));
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterFilterCondition> earnedMedalhasListElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'earnedMedalhasList',
        value: '',
      ));
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterFilterCondition> earnedMedalhasListElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'earnedMedalhasList',
        value: '',
      ));
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterFilterCondition> hasSignificantStreakEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hasSignificantStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterFilterCondition> isInStreakEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isInStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterFilterCondition> lastPositiveCheckInIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastPositiveCheckIn',
      ));
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterFilterCondition> lastPositiveCheckInIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastPositiveCheckIn',
      ));
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterFilterCondition> lastPositiveCheckInEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastPositiveCheckIn',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterFilterCondition> lastPositiveCheckInGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastPositiveCheckIn',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterFilterCondition> lastPositiveCheckInLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastPositiveCheckIn',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterFilterCondition> lastPositiveCheckInBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastPositiveCheckIn',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterFilterCondition> packCostEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'packCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterFilterCondition> packCostGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'packCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterFilterCondition> packCostLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'packCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterFilterCondition> packCostBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'packCost',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterFilterCondition> startDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'startDate',
      ));
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterFilterCondition> startDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'startDate',
      ));
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterFilterCondition> startDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterFilterCondition> updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
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

extension SmokingGamificationEntityQueryObject on QueryBuilder<
    SmokingGamificationEntity, SmokingGamificationEntity, QFilterCondition> {}

extension SmokingGamificationEntityQueryLinks on QueryBuilder<
    SmokingGamificationEntity, SmokingGamificationEntity, QFilterCondition> {}

extension SmokingGamificationEntityQuerySortBy on QueryBuilder<
    SmokingGamificationEntity, SmokingGamificationEntity, QSortBy> {
  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> sortByConsecutivePositiveDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consecutivePositiveDays', Sort.asc);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> sortByConsecutivePositiveDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consecutivePositiveDays', Sort.desc);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> sortByDailyCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyCost', Sort.asc);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> sortByDailyCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyCost', Sort.desc);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> sortByDisciplinumCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disciplinumCount', Sort.asc);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> sortByDisciplinumCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disciplinumCount', Sort.desc);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> sortByEarnedInsignias() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earnedInsignias', Sort.asc);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> sortByEarnedInsigniasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earnedInsignias', Sort.desc);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> sortByEarnedMedalhas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earnedMedalhas', Sort.asc);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> sortByEarnedMedalhasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earnedMedalhas', Sort.desc);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> sortByHasSignificantStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasSignificantStreak', Sort.asc);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> sortByHasSignificantStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasSignificantStreak', Sort.desc);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> sortByIsInStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isInStreak', Sort.asc);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> sortByIsInStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isInStreak', Sort.desc);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> sortByLastPositiveCheckIn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPositiveCheckIn', Sort.asc);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> sortByLastPositiveCheckInDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPositiveCheckIn', Sort.desc);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> sortByPackCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packCost', Sort.asc);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> sortByPackCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packCost', Sort.desc);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> sortByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> sortByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension SmokingGamificationEntityQuerySortThenBy on QueryBuilder<
    SmokingGamificationEntity, SmokingGamificationEntity, QSortThenBy> {
  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> thenByConsecutivePositiveDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consecutivePositiveDays', Sort.asc);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> thenByConsecutivePositiveDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consecutivePositiveDays', Sort.desc);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> thenByDailyCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyCost', Sort.asc);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> thenByDailyCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyCost', Sort.desc);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> thenByDisciplinumCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disciplinumCount', Sort.asc);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> thenByDisciplinumCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disciplinumCount', Sort.desc);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> thenByEarnedInsignias() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earnedInsignias', Sort.asc);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> thenByEarnedInsigniasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earnedInsignias', Sort.desc);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> thenByEarnedMedalhas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earnedMedalhas', Sort.asc);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> thenByEarnedMedalhasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earnedMedalhas', Sort.desc);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> thenByHasSignificantStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasSignificantStreak', Sort.asc);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> thenByHasSignificantStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasSignificantStreak', Sort.desc);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> thenByIsInStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isInStreak', Sort.asc);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> thenByIsInStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isInStreak', Sort.desc);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> thenByLastPositiveCheckIn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPositiveCheckIn', Sort.asc);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> thenByLastPositiveCheckInDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPositiveCheckIn', Sort.desc);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> thenByPackCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packCost', Sort.asc);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> thenByPackCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packCost', Sort.desc);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> thenByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> thenByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity,
      QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension SmokingGamificationEntityQueryWhereDistinct on QueryBuilder<
    SmokingGamificationEntity, SmokingGamificationEntity, QDistinct> {
  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity, QDistinct>
      distinctByConsecutivePositiveDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'consecutivePositiveDays');
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity, QDistinct>
      distinctByDailyCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dailyCost');
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity, QDistinct>
      distinctByDisciplinumCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'disciplinumCount');
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity, QDistinct>
      distinctByEarnedInsignias({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'earnedInsignias',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity, QDistinct>
      distinctByEarnedInsigniasList() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'earnedInsigniasList');
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity, QDistinct>
      distinctByEarnedMedalhas({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'earnedMedalhas',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity, QDistinct>
      distinctByEarnedMedalhasList() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'earnedMedalhasList');
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity, QDistinct>
      distinctByHasSignificantStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasSignificantStreak');
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity, QDistinct>
      distinctByIsInStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isInStreak');
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity, QDistinct>
      distinctByLastPositiveCheckIn() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPositiveCheckIn');
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity, QDistinct>
      distinctByPackCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'packCost');
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity, QDistinct>
      distinctByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startDate');
    });
  }

  QueryBuilder<SmokingGamificationEntity, SmokingGamificationEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension SmokingGamificationEntityQueryProperty on QueryBuilder<
    SmokingGamificationEntity, SmokingGamificationEntity, QQueryProperty> {
  QueryBuilder<SmokingGamificationEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SmokingGamificationEntity, int, QQueryOperations>
      consecutivePositiveDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'consecutivePositiveDays');
    });
  }

  QueryBuilder<SmokingGamificationEntity, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<SmokingGamificationEntity, double, QQueryOperations>
      dailyCostProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dailyCost');
    });
  }

  QueryBuilder<SmokingGamificationEntity, int, QQueryOperations>
      disciplinumCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'disciplinumCount');
    });
  }

  QueryBuilder<SmokingGamificationEntity, String, QQueryOperations>
      earnedInsigniasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'earnedInsignias');
    });
  }

  QueryBuilder<SmokingGamificationEntity, List<String>, QQueryOperations>
      earnedInsigniasListProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'earnedInsigniasList');
    });
  }

  QueryBuilder<SmokingGamificationEntity, String, QQueryOperations>
      earnedMedalhasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'earnedMedalhas');
    });
  }

  QueryBuilder<SmokingGamificationEntity, List<String>, QQueryOperations>
      earnedMedalhasListProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'earnedMedalhasList');
    });
  }

  QueryBuilder<SmokingGamificationEntity, bool, QQueryOperations>
      hasSignificantStreakProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasSignificantStreak');
    });
  }

  QueryBuilder<SmokingGamificationEntity, bool, QQueryOperations>
      isInStreakProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isInStreak');
    });
  }

  QueryBuilder<SmokingGamificationEntity, DateTime?, QQueryOperations>
      lastPositiveCheckInProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPositiveCheckIn');
    });
  }

  QueryBuilder<SmokingGamificationEntity, double, QQueryOperations>
      packCostProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'packCost');
    });
  }

  QueryBuilder<SmokingGamificationEntity, DateTime?, QQueryOperations>
      startDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startDate');
    });
  }

  QueryBuilder<SmokingGamificationEntity, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
