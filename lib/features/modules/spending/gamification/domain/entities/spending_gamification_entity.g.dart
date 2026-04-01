// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spending_gamification_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSpendingGamificationEntityCollection on Isar {
  IsarCollection<SpendingGamificationEntity> get spendingGamificationEntitys =>
      this.collection();
}

const SpendingGamificationEntitySchema = CollectionSchema(
  name: r'SpendingGamificationEntity',
  id: 1885435756214491301,
  properties: {
    r'consecutiveMonths': PropertySchema(
      id: 0,
      name: r'consecutiveMonths',
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
  estimateSize: _spendingGamificationEntityEstimateSize,
  serialize: _spendingGamificationEntitySerialize,
  deserialize: _spendingGamificationEntityDeserialize,
  deserializeProp: _spendingGamificationEntityDeserializeProp,
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
  getId: _spendingGamificationEntityGetId,
  getLinks: _spendingGamificationEntityGetLinks,
  attach: _spendingGamificationEntityAttach,
  version: '3.1.0+1',
);

int _spendingGamificationEntityEstimateSize(
  SpendingGamificationEntity object,
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

void _spendingGamificationEntitySerialize(
  SpendingGamificationEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.consecutiveMonths);
  writer.writeLong(offsets[1], object.disciplinumCount);
  writer.writeStringList(offsets[2], object.earnedInsignias);
  writer.writeStringList(offsets[3], object.earnedMedalhas);
  writer.writeBool(offsets[4], object.isActive);
  writer.writeDateTime(offsets[5], object.lastUpdated);
  writer.writeString(offsets[6], object.userId);
}

SpendingGamificationEntity _spendingGamificationEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SpendingGamificationEntity(
    consecutiveMonths: reader.readLongOrNull(offsets[0]) ?? 0,
    disciplinumCount: reader.readLongOrNull(offsets[1]) ?? 0,
    earnedInsignias: reader.readStringList(offsets[2]) ?? const [],
    earnedMedalhas: reader.readStringList(offsets[3]) ?? const [],
    isActive: reader.readBoolOrNull(offsets[4]) ?? true,
    lastUpdated: reader.readDateTime(offsets[5]),
    userId: reader.readString(offsets[6]),
  );
  object.id = id;
  return object;
}

P _spendingGamificationEntityDeserializeProp<P>(
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

Id _spendingGamificationEntityGetId(SpendingGamificationEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _spendingGamificationEntityGetLinks(
    SpendingGamificationEntity object) {
  return [];
}

void _spendingGamificationEntityAttach(
    IsarCollection<dynamic> col, Id id, SpendingGamificationEntity object) {
  object.id = id;
}

extension SpendingGamificationEntityByIndex
    on IsarCollection<SpendingGamificationEntity> {
  Future<SpendingGamificationEntity?> getByUserId(String userId) {
    return getByIndex(r'userId', [userId]);
  }

  SpendingGamificationEntity? getByUserIdSync(String userId) {
    return getByIndexSync(r'userId', [userId]);
  }

  Future<bool> deleteByUserId(String userId) {
    return deleteByIndex(r'userId', [userId]);
  }

  bool deleteByUserIdSync(String userId) {
    return deleteByIndexSync(r'userId', [userId]);
  }

  Future<List<SpendingGamificationEntity?>> getAllByUserId(
      List<String> userIdValues) {
    final values = userIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'userId', values);
  }

  List<SpendingGamificationEntity?> getAllByUserIdSync(
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

  Future<Id> putByUserId(SpendingGamificationEntity object) {
    return putByIndex(r'userId', object);
  }

  Id putByUserIdSync(SpendingGamificationEntity object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'userId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUserId(List<SpendingGamificationEntity> objects) {
    return putAllByIndex(r'userId', objects);
  }

  List<Id> putAllByUserIdSync(List<SpendingGamificationEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'userId', objects, saveLinks: saveLinks);
  }
}

extension SpendingGamificationEntityQueryWhereSort on QueryBuilder<
    SpendingGamificationEntity, SpendingGamificationEntity, QWhere> {
  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
      QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SpendingGamificationEntityQueryWhere on QueryBuilder<
    SpendingGamificationEntity, SpendingGamificationEntity, QWhereClause> {
  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
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

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
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

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
      QAfterWhereClause> userIdEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
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

extension SpendingGamificationEntityQueryFilter on QueryBuilder<
    SpendingGamificationEntity, SpendingGamificationEntity, QFilterCondition> {
  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
      QAfterFilterCondition> consecutiveMonthsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'consecutiveMonths',
        value: value,
      ));
    });
  }

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
      QAfterFilterCondition> consecutiveMonthsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'consecutiveMonths',
        value: value,
      ));
    });
  }

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
      QAfterFilterCondition> consecutiveMonthsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'consecutiveMonths',
        value: value,
      ));
    });
  }

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
      QAfterFilterCondition> consecutiveMonthsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'consecutiveMonths',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
      QAfterFilterCondition> disciplinumCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'disciplinumCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
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

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
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

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
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

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
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

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
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

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
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

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
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

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
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

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
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

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
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

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
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

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
      QAfterFilterCondition> earnedInsigniasElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'earnedInsignias',
        value: '',
      ));
    });
  }

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
      QAfterFilterCondition> earnedInsigniasElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'earnedInsignias',
        value: '',
      ));
    });
  }

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
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

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
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

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
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

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
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

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
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

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
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

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
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

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
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

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
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

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
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

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
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

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
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

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
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

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
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

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
      QAfterFilterCondition> earnedMedalhasElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'earnedMedalhas',
        value: '',
      ));
    });
  }

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
      QAfterFilterCondition> earnedMedalhasElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'earnedMedalhas',
        value: '',
      ));
    });
  }

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
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

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
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

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
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

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
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

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
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

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
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

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
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

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
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

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
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

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
      QAfterFilterCondition> isActiveEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isActive',
        value: value,
      ));
    });
  }

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
      QAfterFilterCondition> lastUpdatedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
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

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
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

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
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

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
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

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
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

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
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

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
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

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
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

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
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

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
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

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
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

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
      QAfterFilterCondition> userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
      QAfterFilterCondition> userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension SpendingGamificationEntityQueryObject on QueryBuilder<
    SpendingGamificationEntity, SpendingGamificationEntity, QFilterCondition> {}

extension SpendingGamificationEntityQueryLinks on QueryBuilder<
    SpendingGamificationEntity, SpendingGamificationEntity, QFilterCondition> {}

extension SpendingGamificationEntityQuerySortBy on QueryBuilder<
    SpendingGamificationEntity, SpendingGamificationEntity, QSortBy> {
  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
      QAfterSortBy> sortByConsecutiveMonths() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consecutiveMonths', Sort.asc);
    });
  }

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
      QAfterSortBy> sortByConsecutiveMonthsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consecutiveMonths', Sort.desc);
    });
  }

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
      QAfterSortBy> sortByDisciplinumCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disciplinumCount', Sort.asc);
    });
  }

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
      QAfterSortBy> sortByDisciplinumCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disciplinumCount', Sort.desc);
    });
  }

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
      QAfterSortBy> sortByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
      QAfterSortBy> sortByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
      QAfterSortBy> sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
      QAfterSortBy> sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
      QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
      QAfterSortBy> sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension SpendingGamificationEntityQuerySortThenBy on QueryBuilder<
    SpendingGamificationEntity, SpendingGamificationEntity, QSortThenBy> {
  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
      QAfterSortBy> thenByConsecutiveMonths() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consecutiveMonths', Sort.asc);
    });
  }

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
      QAfterSortBy> thenByConsecutiveMonthsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consecutiveMonths', Sort.desc);
    });
  }

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
      QAfterSortBy> thenByDisciplinumCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disciplinumCount', Sort.asc);
    });
  }

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
      QAfterSortBy> thenByDisciplinumCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disciplinumCount', Sort.desc);
    });
  }

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
      QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
      QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
      QAfterSortBy> thenByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
      QAfterSortBy> thenByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
      QAfterSortBy> thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
      QAfterSortBy> thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
      QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
      QAfterSortBy> thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension SpendingGamificationEntityQueryWhereDistinct on QueryBuilder<
    SpendingGamificationEntity, SpendingGamificationEntity, QDistinct> {
  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
      QDistinct> distinctByConsecutiveMonths() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'consecutiveMonths');
    });
  }

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
      QDistinct> distinctByDisciplinumCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'disciplinumCount');
    });
  }

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
      QDistinct> distinctByEarnedInsignias() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'earnedInsignias');
    });
  }

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
      QDistinct> distinctByEarnedMedalhas() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'earnedMedalhas');
    });
  }

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
      QDistinct> distinctByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isActive');
    });
  }

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
      QDistinct> distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<SpendingGamificationEntity, SpendingGamificationEntity,
      QDistinct> distinctByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension SpendingGamificationEntityQueryProperty on QueryBuilder<
    SpendingGamificationEntity, SpendingGamificationEntity, QQueryProperty> {
  QueryBuilder<SpendingGamificationEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SpendingGamificationEntity, int, QQueryOperations>
      consecutiveMonthsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'consecutiveMonths');
    });
  }

  QueryBuilder<SpendingGamificationEntity, int, QQueryOperations>
      disciplinumCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'disciplinumCount');
    });
  }

  QueryBuilder<SpendingGamificationEntity, List<String>, QQueryOperations>
      earnedInsigniasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'earnedInsignias');
    });
  }

  QueryBuilder<SpendingGamificationEntity, List<String>, QQueryOperations>
      earnedMedalhasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'earnedMedalhas');
    });
  }

  QueryBuilder<SpendingGamificationEntity, bool, QQueryOperations>
      isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isActive');
    });
  }

  QueryBuilder<SpendingGamificationEntity, DateTime, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<SpendingGamificationEntity, String, QQueryOperations>
      userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}
