// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'binge_eating_gamification_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBingeEatingGamificationEntityCollection on Isar {
  IsarCollection<BingeEatingGamificationEntity>
      get bingeEatingGamificationEntitys => this.collection();
}

const BingeEatingGamificationEntitySchema = CollectionSchema(
  name: r'BingeEatingGamificationEntity',
  id: 7998667181858413489,
  properties: {
    r'consecutivePositiveDays': PropertySchema(
      id: 0,
      name: r'consecutivePositiveDays',
      type: IsarType.long,
    ),
    r'disciplinumCount': PropertySchema(
      id: 1,
      name: r'disciplinumCount',
      type: IsarType.long,
    ),
    r'earnedInsignias': PropertySchema(
      id: 2,
      name: r'earnedInsignias',
      type: IsarType.stringList,
    ),
    r'earnedMedalhas': PropertySchema(
      id: 3,
      name: r'earnedMedalhas',
      type: IsarType.stringList,
    ),
    r'hashCode': PropertySchema(
      id: 4,
      name: r'hashCode',
      type: IsarType.long,
    ),
    r'isActive': PropertySchema(
      id: 5,
      name: r'isActive',
      type: IsarType.bool,
    ),
    r'isStale': PropertySchema(
      id: 6,
      name: r'isStale',
      type: IsarType.bool,
    ),
    r'lastUpdated': PropertySchema(
      id: 7,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'userId': PropertySchema(
      id: 8,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _bingeEatingGamificationEntityEstimateSize,
  serialize: _bingeEatingGamificationEntitySerialize,
  deserialize: _bingeEatingGamificationEntityDeserialize,
  deserializeProp: _bingeEatingGamificationEntityDeserializeProp,
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
  getId: _bingeEatingGamificationEntityGetId,
  getLinks: _bingeEatingGamificationEntityGetLinks,
  attach: _bingeEatingGamificationEntityAttach,
  version: '3.1.0+1',
);

int _bingeEatingGamificationEntityEstimateSize(
  BingeEatingGamificationEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.earnedInsignias.length * 3;
  {
    for (var i = 0; i < object.earnedInsignias.length; i++) {
      final value = object.earnedInsignias[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.earnedMedalhas.length * 3;
  {
    for (var i = 0; i < object.earnedMedalhas.length; i++) {
      final value = object.earnedMedalhas[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _bingeEatingGamificationEntitySerialize(
  BingeEatingGamificationEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.consecutivePositiveDays);
  writer.writeLong(offsets[1], object.disciplinumCount);
  writer.writeStringList(offsets[2], object.earnedInsignias);
  writer.writeStringList(offsets[3], object.earnedMedalhas);
  writer.writeLong(offsets[4], object.hashCode);
  writer.writeBool(offsets[5], object.isActive);
  writer.writeBool(offsets[6], object.isStale);
  writer.writeDateTime(offsets[7], object.lastUpdated);
  writer.writeString(offsets[8], object.userId);
}

BingeEatingGamificationEntity _bingeEatingGamificationEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BingeEatingGamificationEntity(
    consecutivePositiveDays: reader.readLongOrNull(offsets[0]) ?? 0,
    disciplinumCount: reader.readLongOrNull(offsets[1]) ?? 0,
    earnedInsignias: reader.readStringList(offsets[2]) ?? const [],
    earnedMedalhas: reader.readStringList(offsets[3]) ?? const [],
    isActive: reader.readBoolOrNull(offsets[5]) ?? true,
    lastUpdated: reader.readDateTime(offsets[7]),
    userId: reader.readString(offsets[8]),
  );
  return object;
}

P _bingeEatingGamificationEntityDeserializeProp<P>(
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
      return (reader.readStringList(offset) ?? const []) as P;
    case 3:
      return (reader.readStringList(offset) ?? const []) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _bingeEatingGamificationEntityGetId(BingeEatingGamificationEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _bingeEatingGamificationEntityGetLinks(
    BingeEatingGamificationEntity object) {
  return [];
}

void _bingeEatingGamificationEntityAttach(
    IsarCollection<dynamic> col, Id id, BingeEatingGamificationEntity object) {}

extension BingeEatingGamificationEntityQueryWhereSort on QueryBuilder<
    BingeEatingGamificationEntity, BingeEatingGamificationEntity, QWhere> {
  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension BingeEatingGamificationEntityQueryWhere on QueryBuilder<
    BingeEatingGamificationEntity,
    BingeEatingGamificationEntity,
    QWhereClause> {
  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
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

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
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

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterWhereClause> userIdEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
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

extension BingeEatingGamificationEntityQueryFilter on QueryBuilder<
    BingeEatingGamificationEntity,
    BingeEatingGamificationEntity,
    QFilterCondition> {
  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterFilterCondition> consecutivePositiveDaysEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'consecutivePositiveDays',
        value: value,
      ));
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
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

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
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

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
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

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterFilterCondition> disciplinumCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'disciplinumCount',
        value: value,
      ));
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
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

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
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

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
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

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterFilterCondition> earnedInsigniasElementEqualTo(
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

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterFilterCondition> earnedInsigniasElementGreaterThan(
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

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterFilterCondition> earnedInsigniasElementLessThan(
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

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterFilterCondition> earnedInsigniasElementBetween(
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

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterFilterCondition> earnedInsigniasElementStartsWith(
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

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterFilterCondition> earnedInsigniasElementEndsWith(
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

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
          QAfterFilterCondition>
      earnedInsigniasElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'earnedInsignias',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
          QAfterFilterCondition>
      earnedInsigniasElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'earnedInsignias',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterFilterCondition> earnedInsigniasElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'earnedInsignias',
        value: '',
      ));
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterFilterCondition> earnedInsigniasElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'earnedInsignias',
        value: '',
      ));
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterFilterCondition> earnedInsigniasLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedInsignias',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterFilterCondition> earnedInsigniasIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedInsignias',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterFilterCondition> earnedInsigniasIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedInsignias',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterFilterCondition> earnedInsigniasLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedInsignias',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterFilterCondition> earnedInsigniasLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedInsignias',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterFilterCondition> earnedInsigniasLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedInsignias',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterFilterCondition> earnedMedalhasElementEqualTo(
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

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterFilterCondition> earnedMedalhasElementGreaterThan(
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

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterFilterCondition> earnedMedalhasElementLessThan(
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

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterFilterCondition> earnedMedalhasElementBetween(
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

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterFilterCondition> earnedMedalhasElementStartsWith(
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

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterFilterCondition> earnedMedalhasElementEndsWith(
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

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
          QAfterFilterCondition>
      earnedMedalhasElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'earnedMedalhas',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
          QAfterFilterCondition>
      earnedMedalhasElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'earnedMedalhas',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterFilterCondition> earnedMedalhasElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'earnedMedalhas',
        value: '',
      ));
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterFilterCondition> earnedMedalhasElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'earnedMedalhas',
        value: '',
      ));
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterFilterCondition> earnedMedalhasLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedMedalhas',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterFilterCondition> earnedMedalhasIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedMedalhas',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterFilterCondition> earnedMedalhasIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedMedalhas',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterFilterCondition> earnedMedalhasLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedMedalhas',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterFilterCondition> earnedMedalhasLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedMedalhas',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterFilterCondition> earnedMedalhasLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedMedalhas',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterFilterCondition> hashCodeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
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

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
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

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
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

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
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

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
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

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
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

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterFilterCondition> isActiveEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isActive',
        value: value,
      ));
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterFilterCondition> isStaleEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isStale',
        value: value,
      ));
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterFilterCondition> lastUpdatedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
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

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
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

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
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

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
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

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
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

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
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

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
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

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
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

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
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

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
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

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
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

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterFilterCondition> userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterFilterCondition> userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension BingeEatingGamificationEntityQueryObject on QueryBuilder<
    BingeEatingGamificationEntity,
    BingeEatingGamificationEntity,
    QFilterCondition> {}

extension BingeEatingGamificationEntityQueryLinks on QueryBuilder<
    BingeEatingGamificationEntity,
    BingeEatingGamificationEntity,
    QFilterCondition> {}

extension BingeEatingGamificationEntityQuerySortBy on QueryBuilder<
    BingeEatingGamificationEntity, BingeEatingGamificationEntity, QSortBy> {
  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterSortBy> sortByConsecutivePositiveDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consecutivePositiveDays', Sort.asc);
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterSortBy> sortByConsecutivePositiveDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consecutivePositiveDays', Sort.desc);
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterSortBy> sortByDisciplinumCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disciplinumCount', Sort.asc);
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterSortBy> sortByDisciplinumCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disciplinumCount', Sort.desc);
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterSortBy> sortByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterSortBy> sortByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterSortBy> sortByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterSortBy> sortByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterSortBy> sortByIsStale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isStale', Sort.asc);
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterSortBy> sortByIsStaleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isStale', Sort.desc);
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterSortBy> sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterSortBy> sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterSortBy> sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension BingeEatingGamificationEntityQuerySortThenBy on QueryBuilder<
    BingeEatingGamificationEntity, BingeEatingGamificationEntity, QSortThenBy> {
  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterSortBy> thenByConsecutivePositiveDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consecutivePositiveDays', Sort.asc);
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterSortBy> thenByConsecutivePositiveDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consecutivePositiveDays', Sort.desc);
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterSortBy> thenByDisciplinumCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disciplinumCount', Sort.asc);
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterSortBy> thenByDisciplinumCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disciplinumCount', Sort.desc);
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterSortBy> thenByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterSortBy> thenByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterSortBy> thenByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterSortBy> thenByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterSortBy> thenByIsStale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isStale', Sort.asc);
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterSortBy> thenByIsStaleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isStale', Sort.desc);
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterSortBy> thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterSortBy> thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QAfterSortBy> thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension BingeEatingGamificationEntityQueryWhereDistinct on QueryBuilder<
    BingeEatingGamificationEntity, BingeEatingGamificationEntity, QDistinct> {
  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QDistinct> distinctByConsecutivePositiveDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'consecutivePositiveDays');
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QDistinct> distinctByDisciplinumCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'disciplinumCount');
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QDistinct> distinctByEarnedInsignias() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'earnedInsignias');
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QDistinct> distinctByEarnedMedalhas() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'earnedMedalhas');
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QDistinct> distinctByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hashCode');
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QDistinct> distinctByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isActive');
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QDistinct> distinctByIsStale() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isStale');
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QDistinct> distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, BingeEatingGamificationEntity,
      QDistinct> distinctByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension BingeEatingGamificationEntityQueryProperty on QueryBuilder<
    BingeEatingGamificationEntity,
    BingeEatingGamificationEntity,
    QQueryProperty> {
  QueryBuilder<BingeEatingGamificationEntity, int, QQueryOperations>
      idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, int, QQueryOperations>
      consecutivePositiveDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'consecutivePositiveDays');
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, int, QQueryOperations>
      disciplinumCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'disciplinumCount');
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, List<String>, QQueryOperations>
      earnedInsigniasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'earnedInsignias');
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, List<String>, QQueryOperations>
      earnedMedalhasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'earnedMedalhas');
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, int, QQueryOperations>
      hashCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hashCode');
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, bool, QQueryOperations>
      isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isActive');
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, bool, QQueryOperations>
      isStaleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isStale');
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, DateTime, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<BingeEatingGamificationEntity, String, QQueryOperations>
      userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}
