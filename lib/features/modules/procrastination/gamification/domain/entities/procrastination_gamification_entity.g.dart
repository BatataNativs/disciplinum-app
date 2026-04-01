// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'procrastination_gamification_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetProcrastinationGamificationEntityCollection on Isar {
  IsarCollection<ProcrastinationGamificationEntity>
      get procrastinationGamificationEntitys => this.collection();
}

const ProcrastinationGamificationEntitySchema = CollectionSchema(
  name: r'ProcrastinationGamificationEntity',
  id: 3634494299903065,
  properties: {
    r'consecutiveDays': PropertySchema(
      id: 0,
      name: r'consecutiveDays',
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
    r'isActive': PropertySchema(
      id: 4,
      name: r'isActive',
      type: IsarType.bool,
    ),
    r'lastUpdated': PropertySchema(
      id: 5,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'userId': PropertySchema(
      id: 6,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _procrastinationGamificationEntityEstimateSize,
  serialize: _procrastinationGamificationEntitySerialize,
  deserialize: _procrastinationGamificationEntityDeserialize,
  deserializeProp: _procrastinationGamificationEntityDeserializeProp,
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
  getId: _procrastinationGamificationEntityGetId,
  getLinks: _procrastinationGamificationEntityGetLinks,
  attach: _procrastinationGamificationEntityAttach,
  version: '3.1.0+1',
);

int _procrastinationGamificationEntityEstimateSize(
  ProcrastinationGamificationEntity object,
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

void _procrastinationGamificationEntitySerialize(
  ProcrastinationGamificationEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.consecutiveDays);
  writer.writeLong(offsets[1], object.disciplinumCount);
  writer.writeStringList(offsets[2], object.earnedInsignias);
  writer.writeStringList(offsets[3], object.earnedMedalhas);
  writer.writeBool(offsets[4], object.isActive);
  writer.writeDateTime(offsets[5], object.lastUpdated);
  writer.writeString(offsets[6], object.userId);
}

ProcrastinationGamificationEntity _procrastinationGamificationEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ProcrastinationGamificationEntity(
    consecutiveDays: reader.readLongOrNull(offsets[0]) ?? 0,
    disciplinumCount: reader.readLongOrNull(offsets[1]) ?? 0,
    earnedInsignias: reader.readStringList(offsets[2]) ?? const [],
    earnedMedalhas: reader.readStringList(offsets[3]) ?? const [],
    isActive: reader.readBoolOrNull(offsets[4]) ?? true,
    lastUpdated: reader.readDateTime(offsets[5]),
    userId: reader.readString(offsets[6]),
  );
  return object;
}

P _procrastinationGamificationEntityDeserializeProp<P>(
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
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _procrastinationGamificationEntityGetId(
    ProcrastinationGamificationEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _procrastinationGamificationEntityGetLinks(
    ProcrastinationGamificationEntity object) {
  return [];
}

void _procrastinationGamificationEntityAttach(IsarCollection<dynamic> col,
    Id id, ProcrastinationGamificationEntity object) {}

extension ProcrastinationGamificationEntityQueryWhereSort on QueryBuilder<
    ProcrastinationGamificationEntity,
    ProcrastinationGamificationEntity,
    QWhere> {
  QueryBuilder<ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ProcrastinationGamificationEntityQueryWhere on QueryBuilder<
    ProcrastinationGamificationEntity,
    ProcrastinationGamificationEntity,
    QWhereClause> {
  QueryBuilder<ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
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

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity, QAfterWhereClause> idBetween(
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

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
      QAfterWhereClause> userIdEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
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

extension ProcrastinationGamificationEntityQueryFilter on QueryBuilder<
    ProcrastinationGamificationEntity,
    ProcrastinationGamificationEntity,
    QFilterCondition> {
  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
      QAfterFilterCondition> consecutiveDaysEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'consecutiveDays',
        value: value,
      ));
    });
  }

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
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

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
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

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
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

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
      QAfterFilterCondition> disciplinumCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'disciplinumCount',
        value: value,
      ));
    });
  }

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
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

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
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

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
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

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
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

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
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

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
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

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
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

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
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

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
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

  QueryBuilder<ProcrastinationGamificationEntity,
          ProcrastinationGamificationEntity, QAfterFilterCondition>
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

  QueryBuilder<ProcrastinationGamificationEntity,
          ProcrastinationGamificationEntity, QAfterFilterCondition>
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

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
      QAfterFilterCondition> earnedInsigniasElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'earnedInsignias',
        value: '',
      ));
    });
  }

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
      QAfterFilterCondition> earnedInsigniasElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'earnedInsignias',
        value: '',
      ));
    });
  }

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
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

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
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

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
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

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
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

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
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

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
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

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
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

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
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

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
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

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
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

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
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

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
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

  QueryBuilder<ProcrastinationGamificationEntity,
          ProcrastinationGamificationEntity, QAfterFilterCondition>
      earnedMedalhasElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'earnedMedalhas',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcrastinationGamificationEntity,
          ProcrastinationGamificationEntity, QAfterFilterCondition>
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

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
      QAfterFilterCondition> earnedMedalhasElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'earnedMedalhas',
        value: '',
      ));
    });
  }

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
      QAfterFilterCondition> earnedMedalhasElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'earnedMedalhas',
        value: '',
      ));
    });
  }

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
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

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
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

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
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

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
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

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
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

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
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

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity, QAfterFilterCondition> idBetween(
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

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
      QAfterFilterCondition> isActiveEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isActive',
        value: value,
      ));
    });
  }

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
      QAfterFilterCondition> lastUpdatedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
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

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
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

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
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

  QueryBuilder<ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity, QAfterFilterCondition> userIdEqualTo(
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

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
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

  QueryBuilder<ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity, QAfterFilterCondition> userIdLessThan(
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

  QueryBuilder<ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity, QAfterFilterCondition> userIdBetween(
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

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
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

  QueryBuilder<ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity, QAfterFilterCondition> userIdEndsWith(
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

  QueryBuilder<ProcrastinationGamificationEntity,
          ProcrastinationGamificationEntity, QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcrastinationGamificationEntity,
          ProcrastinationGamificationEntity, QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
      QAfterFilterCondition> userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
      QAfterFilterCondition> userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension ProcrastinationGamificationEntityQueryObject on QueryBuilder<
    ProcrastinationGamificationEntity,
    ProcrastinationGamificationEntity,
    QFilterCondition> {}

extension ProcrastinationGamificationEntityQueryLinks on QueryBuilder<
    ProcrastinationGamificationEntity,
    ProcrastinationGamificationEntity,
    QFilterCondition> {}

extension ProcrastinationGamificationEntityQuerySortBy on QueryBuilder<
    ProcrastinationGamificationEntity,
    ProcrastinationGamificationEntity,
    QSortBy> {
  QueryBuilder<ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity, QAfterSortBy> sortByConsecutiveDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consecutiveDays', Sort.asc);
    });
  }

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
      QAfterSortBy> sortByConsecutiveDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consecutiveDays', Sort.desc);
    });
  }

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
      QAfterSortBy> sortByDisciplinumCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disciplinumCount', Sort.asc);
    });
  }

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
      QAfterSortBy> sortByDisciplinumCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disciplinumCount', Sort.desc);
    });
  }

  QueryBuilder<ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity, QAfterSortBy> sortByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity, QAfterSortBy> sortByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity, QAfterSortBy> sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity, QAfterSortBy> sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity, QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity, QAfterSortBy> sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension ProcrastinationGamificationEntityQuerySortThenBy on QueryBuilder<
    ProcrastinationGamificationEntity,
    ProcrastinationGamificationEntity,
    QSortThenBy> {
  QueryBuilder<ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity, QAfterSortBy> thenByConsecutiveDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consecutiveDays', Sort.asc);
    });
  }

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
      QAfterSortBy> thenByConsecutiveDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consecutiveDays', Sort.desc);
    });
  }

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
      QAfterSortBy> thenByDisciplinumCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disciplinumCount', Sort.asc);
    });
  }

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
      QAfterSortBy> thenByDisciplinumCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disciplinumCount', Sort.desc);
    });
  }

  QueryBuilder<ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity, QAfterSortBy> thenByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity, QAfterSortBy> thenByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity, QAfterSortBy> thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity, QAfterSortBy> thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity, QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity, QAfterSortBy> thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension ProcrastinationGamificationEntityQueryWhereDistinct on QueryBuilder<
    ProcrastinationGamificationEntity,
    ProcrastinationGamificationEntity,
    QDistinct> {
  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
      QDistinct> distinctByConsecutiveDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'consecutiveDays');
    });
  }

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
      QDistinct> distinctByDisciplinumCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'disciplinumCount');
    });
  }

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
      QDistinct> distinctByEarnedInsignias() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'earnedInsignias');
    });
  }

  QueryBuilder<ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity, QDistinct> distinctByEarnedMedalhas() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'earnedMedalhas');
    });
  }

  QueryBuilder<ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity, QDistinct> distinctByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isActive');
    });
  }

  QueryBuilder<ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity, QDistinct> distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<
      ProcrastinationGamificationEntity,
      ProcrastinationGamificationEntity,
      QDistinct> distinctByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension ProcrastinationGamificationEntityQueryProperty on QueryBuilder<
    ProcrastinationGamificationEntity,
    ProcrastinationGamificationEntity,
    QQueryProperty> {
  QueryBuilder<ProcrastinationGamificationEntity, int, QQueryOperations>
      idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ProcrastinationGamificationEntity, int, QQueryOperations>
      consecutiveDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'consecutiveDays');
    });
  }

  QueryBuilder<ProcrastinationGamificationEntity, int, QQueryOperations>
      disciplinumCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'disciplinumCount');
    });
  }

  QueryBuilder<ProcrastinationGamificationEntity, List<String>,
      QQueryOperations> earnedInsigniasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'earnedInsignias');
    });
  }

  QueryBuilder<ProcrastinationGamificationEntity, List<String>,
      QQueryOperations> earnedMedalhasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'earnedMedalhas');
    });
  }

  QueryBuilder<ProcrastinationGamificationEntity, bool, QQueryOperations>
      isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isActive');
    });
  }

  QueryBuilder<ProcrastinationGamificationEntity, DateTime, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<ProcrastinationGamificationEntity, String, QQueryOperations>
      userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}
