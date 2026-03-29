// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'money_saving_challenge_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMoneySavingChallengeEntityCollection on Isar {
  IsarCollection<MoneySavingChallengeEntity> get moneySavingChallengeEntitys =>
      this.collection();
}

const MoneySavingChallengeEntitySchema = CollectionSchema(
  name: r'MoneySavingChallengeEntity',
  id: -6877806387528227592,
  properties: {
    r'challengeId': PropertySchema(
      id: 0,
      name: r'challengeId',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'currency': PropertySchema(
      id: 2,
      name: r'currency',
      type: IsarType.string,
    ),
    r'gridSize': PropertySchema(
      id: 3,
      name: r'gridSize',
      type: IsarType.long,
    ),
    r'isActive': PropertySchema(
      id: 4,
      name: r'isActive',
      type: IsarType.bool,
    ),
    r'maxValue': PropertySchema(
      id: 5,
      name: r'maxValue',
      type: IsarType.double,
    ),
    r'minValue': PropertySchema(
      id: 6,
      name: r'minValue',
      type: IsarType.double,
    ),
    r'periodType': PropertySchema(
      id: 7,
      name: r'periodType',
      type: IsarType.string,
    ),
    r'periodValue': PropertySchema(
      id: 8,
      name: r'periodValue',
      type: IsarType.long,
    ),
    r'targetAmount': PropertySchema(
      id: 9,
      name: r'targetAmount',
      type: IsarType.double,
    ),
    r'title': PropertySchema(
      id: 10,
      name: r'title',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 11,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'userId': PropertySchema(
      id: 12,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _moneySavingChallengeEntityEstimateSize,
  serialize: _moneySavingChallengeEntitySerialize,
  deserialize: _moneySavingChallengeEntityDeserialize,
  deserializeProp: _moneySavingChallengeEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'challengeId': IndexSchema(
      id: 4483557487511118379,
      name: r'challengeId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'challengeId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _moneySavingChallengeEntityGetId,
  getLinks: _moneySavingChallengeEntityGetLinks,
  attach: _moneySavingChallengeEntityAttach,
  version: '3.1.0+1',
);

int _moneySavingChallengeEntityEstimateSize(
  MoneySavingChallengeEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.challengeId.length * 3;
  bytesCount += 3 + object.currency.length * 3;
  bytesCount += 3 + object.periodType.length * 3;
  bytesCount += 3 + object.title.length * 3;
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _moneySavingChallengeEntitySerialize(
  MoneySavingChallengeEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.challengeId);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.currency);
  writer.writeLong(offsets[3], object.gridSize);
  writer.writeBool(offsets[4], object.isActive);
  writer.writeDouble(offsets[5], object.maxValue);
  writer.writeDouble(offsets[6], object.minValue);
  writer.writeString(offsets[7], object.periodType);
  writer.writeLong(offsets[8], object.periodValue);
  writer.writeDouble(offsets[9], object.targetAmount);
  writer.writeString(offsets[10], object.title);
  writer.writeDateTime(offsets[11], object.updatedAt);
  writer.writeString(offsets[12], object.userId);
}

MoneySavingChallengeEntity _moneySavingChallengeEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MoneySavingChallengeEntity(
    challengeId: reader.readString(offsets[0]),
    gridSize: reader.readLong(offsets[3]),
    maxValue: reader.readDouble(offsets[5]),
    minValue: reader.readDouble(offsets[6]),
    periodType: reader.readString(offsets[7]),
    periodValue: reader.readLong(offsets[8]),
    targetAmount: reader.readDouble(offsets[9]),
    title: reader.readString(offsets[10]),
    userId: reader.readString(offsets[12]),
  );
  object.createdAt = reader.readDateTime(offsets[1]);
  object.currency = reader.readString(offsets[2]);
  object.id = id;
  object.isActive = reader.readBool(offsets[4]);
  object.updatedAt = reader.readDateTime(offsets[11]);
  return object;
}

P _moneySavingChallengeEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readDouble(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readDouble(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readDateTime(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _moneySavingChallengeEntityGetId(MoneySavingChallengeEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _moneySavingChallengeEntityGetLinks(
    MoneySavingChallengeEntity object) {
  return [];
}

void _moneySavingChallengeEntityAttach(
    IsarCollection<dynamic> col, Id id, MoneySavingChallengeEntity object) {
  object.id = id;
}

extension MoneySavingChallengeEntityByIndex
    on IsarCollection<MoneySavingChallengeEntity> {
  Future<MoneySavingChallengeEntity?> getByChallengeId(String challengeId) {
    return getByIndex(r'challengeId', [challengeId]);
  }

  MoneySavingChallengeEntity? getByChallengeIdSync(String challengeId) {
    return getByIndexSync(r'challengeId', [challengeId]);
  }

  Future<bool> deleteByChallengeId(String challengeId) {
    return deleteByIndex(r'challengeId', [challengeId]);
  }

  bool deleteByChallengeIdSync(String challengeId) {
    return deleteByIndexSync(r'challengeId', [challengeId]);
  }

  Future<List<MoneySavingChallengeEntity?>> getAllByChallengeId(
      List<String> challengeIdValues) {
    final values = challengeIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'challengeId', values);
  }

  List<MoneySavingChallengeEntity?> getAllByChallengeIdSync(
      List<String> challengeIdValues) {
    final values = challengeIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'challengeId', values);
  }

  Future<int> deleteAllByChallengeId(List<String> challengeIdValues) {
    final values = challengeIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'challengeId', values);
  }

  int deleteAllByChallengeIdSync(List<String> challengeIdValues) {
    final values = challengeIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'challengeId', values);
  }

  Future<Id> putByChallengeId(MoneySavingChallengeEntity object) {
    return putByIndex(r'challengeId', object);
  }

  Id putByChallengeIdSync(MoneySavingChallengeEntity object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'challengeId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByChallengeId(
      List<MoneySavingChallengeEntity> objects) {
    return putAllByIndex(r'challengeId', objects);
  }

  List<Id> putAllByChallengeIdSync(List<MoneySavingChallengeEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'challengeId', objects, saveLinks: saveLinks);
  }
}

extension MoneySavingChallengeEntityQueryWhereSort on QueryBuilder<
    MoneySavingChallengeEntity, MoneySavingChallengeEntity, QWhere> {
  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MoneySavingChallengeEntityQueryWhere on QueryBuilder<
    MoneySavingChallengeEntity, MoneySavingChallengeEntity, QWhereClause> {
  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
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

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
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

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterWhereClause> challengeIdEqualTo(String challengeId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'challengeId',
        value: [challengeId],
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterWhereClause> challengeIdNotEqualTo(String challengeId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'challengeId',
              lower: [],
              upper: [challengeId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'challengeId',
              lower: [challengeId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'challengeId',
              lower: [challengeId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'challengeId',
              lower: [],
              upper: [challengeId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension MoneySavingChallengeEntityQueryFilter on QueryBuilder<
    MoneySavingChallengeEntity, MoneySavingChallengeEntity, QFilterCondition> {
  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> challengeIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'challengeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> challengeIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'challengeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> challengeIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'challengeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> challengeIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'challengeId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> challengeIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'challengeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> challengeIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'challengeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
          QAfterFilterCondition>
      challengeIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'challengeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
          QAfterFilterCondition>
      challengeIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'challengeId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> challengeIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'challengeId',
        value: '',
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> challengeIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'challengeId',
        value: '',
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
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

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
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

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
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

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> currencyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> currencyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> currencyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> currencyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currency',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> currencyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'currency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> currencyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'currency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
          QAfterFilterCondition>
      currencyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'currency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
          QAfterFilterCondition>
      currencyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'currency',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> currencyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> currencyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> gridSizeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gridSize',
        value: value,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> gridSizeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'gridSize',
        value: value,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> gridSizeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'gridSize',
        value: value,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> gridSizeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'gridSize',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
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

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
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

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
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

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> isActiveEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isActive',
        value: value,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> maxValueEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maxValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> maxValueGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maxValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> maxValueLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maxValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> maxValueBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maxValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> minValueEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'minValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> minValueGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'minValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> minValueLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'minValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> minValueBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'minValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> periodTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'periodType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> periodTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'periodType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> periodTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'periodType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> periodTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'periodType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> periodTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'periodType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> periodTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'periodType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
          QAfterFilterCondition>
      periodTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'periodType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
          QAfterFilterCondition>
      periodTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'periodType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> periodTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'periodType',
        value: '',
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> periodTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'periodType',
        value: '',
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> periodValueEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'periodValue',
        value: value,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> periodValueGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'periodValue',
        value: value,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> periodValueLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'periodValue',
        value: value,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> periodValueBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'periodValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> targetAmountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> targetAmountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> targetAmountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> targetAmountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
          QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
          QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
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

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
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

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
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

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
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

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
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

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
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

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
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

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
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

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
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

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
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

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
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

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterFilterCondition> userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension MoneySavingChallengeEntityQueryObject on QueryBuilder<
    MoneySavingChallengeEntity, MoneySavingChallengeEntity, QFilterCondition> {}

extension MoneySavingChallengeEntityQueryLinks on QueryBuilder<
    MoneySavingChallengeEntity, MoneySavingChallengeEntity, QFilterCondition> {}

extension MoneySavingChallengeEntityQuerySortBy on QueryBuilder<
    MoneySavingChallengeEntity, MoneySavingChallengeEntity, QSortBy> {
  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> sortByChallengeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'challengeId', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> sortByChallengeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'challengeId', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> sortByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> sortByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> sortByGridSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gridSize', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> sortByGridSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gridSize', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> sortByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> sortByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> sortByMaxValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxValue', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> sortByMaxValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxValue', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> sortByMinValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minValue', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> sortByMinValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minValue', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> sortByPeriodType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodType', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> sortByPeriodTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodType', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> sortByPeriodValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodValue', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> sortByPeriodValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodValue', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> sortByTargetAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetAmount', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> sortByTargetAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetAmount', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension MoneySavingChallengeEntityQuerySortThenBy on QueryBuilder<
    MoneySavingChallengeEntity, MoneySavingChallengeEntity, QSortThenBy> {
  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> thenByChallengeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'challengeId', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> thenByChallengeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'challengeId', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> thenByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> thenByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> thenByGridSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gridSize', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> thenByGridSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gridSize', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> thenByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> thenByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> thenByMaxValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxValue', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> thenByMaxValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxValue', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> thenByMinValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minValue', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> thenByMinValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minValue', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> thenByPeriodType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodType', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> thenByPeriodTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodType', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> thenByPeriodValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodValue', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> thenByPeriodValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodValue', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> thenByTargetAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetAmount', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> thenByTargetAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetAmount', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QAfterSortBy> thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension MoneySavingChallengeEntityQueryWhereDistinct on QueryBuilder<
    MoneySavingChallengeEntity, MoneySavingChallengeEntity, QDistinct> {
  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QDistinct> distinctByChallengeId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'challengeId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QDistinct> distinctByCurrency({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currency', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QDistinct> distinctByGridSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gridSize');
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QDistinct> distinctByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isActive');
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QDistinct> distinctByMaxValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxValue');
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QDistinct> distinctByMinValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'minValue');
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QDistinct> distinctByPeriodType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'periodType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QDistinct> distinctByPeriodValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'periodValue');
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QDistinct> distinctByTargetAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetAmount');
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QDistinct> distinctByTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, MoneySavingChallengeEntity,
      QDistinct> distinctByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension MoneySavingChallengeEntityQueryProperty on QueryBuilder<
    MoneySavingChallengeEntity, MoneySavingChallengeEntity, QQueryProperty> {
  QueryBuilder<MoneySavingChallengeEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, String, QQueryOperations>
      challengeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'challengeId');
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, String, QQueryOperations>
      currencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currency');
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, int, QQueryOperations>
      gridSizeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gridSize');
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, bool, QQueryOperations>
      isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isActive');
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, double, QQueryOperations>
      maxValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxValue');
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, double, QQueryOperations>
      minValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'minValue');
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, String, QQueryOperations>
      periodTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'periodType');
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, int, QQueryOperations>
      periodValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'periodValue');
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, double, QQueryOperations>
      targetAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetAmount');
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, String, QQueryOperations>
      titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<MoneySavingChallengeEntity, String, QQueryOperations>
      userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMoneySavingGridCellEntityCollection on Isar {
  IsarCollection<MoneySavingGridCellEntity> get moneySavingGridCellEntitys =>
      this.collection();
}

const MoneySavingGridCellEntitySchema = CollectionSchema(
  name: r'MoneySavingGridCellEntity',
  id: 1329764332145410620,
  properties: {
    r'cellIndex': PropertySchema(
      id: 0,
      name: r'cellIndex',
      type: IsarType.long,
    ),
    r'challengeId': PropertySchema(
      id: 1,
      name: r'challengeId',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'isMarked': PropertySchema(
      id: 3,
      name: r'isMarked',
      type: IsarType.bool,
    ),
    r'markedAt': PropertySchema(
      id: 4,
      name: r'markedAt',
      type: IsarType.dateTime,
    ),
    r'updatedAt': PropertySchema(
      id: 5,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'value': PropertySchema(
      id: 6,
      name: r'value',
      type: IsarType.double,
    )
  },
  estimateSize: _moneySavingGridCellEntityEstimateSize,
  serialize: _moneySavingGridCellEntitySerialize,
  deserialize: _moneySavingGridCellEntityDeserialize,
  deserializeProp: _moneySavingGridCellEntityDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _moneySavingGridCellEntityGetId,
  getLinks: _moneySavingGridCellEntityGetLinks,
  attach: _moneySavingGridCellEntityAttach,
  version: '3.1.0+1',
);

int _moneySavingGridCellEntityEstimateSize(
  MoneySavingGridCellEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.challengeId.length * 3;
  return bytesCount;
}

void _moneySavingGridCellEntitySerialize(
  MoneySavingGridCellEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.cellIndex);
  writer.writeString(offsets[1], object.challengeId);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeBool(offsets[3], object.isMarked);
  writer.writeDateTime(offsets[4], object.markedAt);
  writer.writeDateTime(offsets[5], object.updatedAt);
  writer.writeDouble(offsets[6], object.value);
}

MoneySavingGridCellEntity _moneySavingGridCellEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MoneySavingGridCellEntity(
    cellIndex: reader.readLong(offsets[0]),
    challengeId: reader.readString(offsets[1]),
    value: reader.readDouble(offsets[6]),
  );
  object.createdAt = reader.readDateTime(offsets[2]);
  object.id = id;
  object.isMarked = reader.readBool(offsets[3]);
  object.markedAt = reader.readDateTimeOrNull(offsets[4]);
  object.updatedAt = reader.readDateTime(offsets[5]);
  return object;
}

P _moneySavingGridCellEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _moneySavingGridCellEntityGetId(MoneySavingGridCellEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _moneySavingGridCellEntityGetLinks(
    MoneySavingGridCellEntity object) {
  return [];
}

void _moneySavingGridCellEntityAttach(
    IsarCollection<dynamic> col, Id id, MoneySavingGridCellEntity object) {
  object.id = id;
}

extension MoneySavingGridCellEntityQueryWhereSort on QueryBuilder<
    MoneySavingGridCellEntity, MoneySavingGridCellEntity, QWhere> {
  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MoneySavingGridCellEntityQueryWhere on QueryBuilder<
    MoneySavingGridCellEntity, MoneySavingGridCellEntity, QWhereClause> {
  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
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

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
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

extension MoneySavingGridCellEntityQueryFilter on QueryBuilder<
    MoneySavingGridCellEntity, MoneySavingGridCellEntity, QFilterCondition> {
  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterFilterCondition> cellIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cellIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterFilterCondition> cellIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cellIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterFilterCondition> cellIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cellIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterFilterCondition> cellIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cellIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterFilterCondition> challengeIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'challengeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterFilterCondition> challengeIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'challengeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterFilterCondition> challengeIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'challengeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterFilterCondition> challengeIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'challengeId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterFilterCondition> challengeIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'challengeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterFilterCondition> challengeIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'challengeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
          QAfterFilterCondition>
      challengeIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'challengeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
          QAfterFilterCondition>
      challengeIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'challengeId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterFilterCondition> challengeIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'challengeId',
        value: '',
      ));
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterFilterCondition> challengeIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'challengeId',
        value: '',
      ));
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
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

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
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

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
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

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
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

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
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

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
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

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterFilterCondition> isMarkedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isMarked',
        value: value,
      ));
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterFilterCondition> markedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'markedAt',
      ));
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterFilterCondition> markedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'markedAt',
      ));
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterFilterCondition> markedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'markedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterFilterCondition> markedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'markedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterFilterCondition> markedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'markedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterFilterCondition> markedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'markedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterFilterCondition> updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
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

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
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

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
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

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterFilterCondition> valueEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'value',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterFilterCondition> valueGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'value',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterFilterCondition> valueLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'value',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterFilterCondition> valueBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'value',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension MoneySavingGridCellEntityQueryObject on QueryBuilder<
    MoneySavingGridCellEntity, MoneySavingGridCellEntity, QFilterCondition> {}

extension MoneySavingGridCellEntityQueryLinks on QueryBuilder<
    MoneySavingGridCellEntity, MoneySavingGridCellEntity, QFilterCondition> {}

extension MoneySavingGridCellEntityQuerySortBy on QueryBuilder<
    MoneySavingGridCellEntity, MoneySavingGridCellEntity, QSortBy> {
  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterSortBy> sortByCellIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cellIndex', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterSortBy> sortByCellIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cellIndex', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterSortBy> sortByChallengeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'challengeId', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterSortBy> sortByChallengeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'challengeId', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterSortBy> sortByIsMarked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMarked', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterSortBy> sortByIsMarkedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMarked', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterSortBy> sortByMarkedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'markedAt', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterSortBy> sortByMarkedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'markedAt', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterSortBy> sortByValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'value', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterSortBy> sortByValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'value', Sort.desc);
    });
  }
}

extension MoneySavingGridCellEntityQuerySortThenBy on QueryBuilder<
    MoneySavingGridCellEntity, MoneySavingGridCellEntity, QSortThenBy> {
  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterSortBy> thenByCellIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cellIndex', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterSortBy> thenByCellIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cellIndex', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterSortBy> thenByChallengeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'challengeId', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterSortBy> thenByChallengeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'challengeId', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterSortBy> thenByIsMarked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMarked', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterSortBy> thenByIsMarkedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMarked', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterSortBy> thenByMarkedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'markedAt', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterSortBy> thenByMarkedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'markedAt', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterSortBy> thenByValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'value', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity,
      QAfterSortBy> thenByValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'value', Sort.desc);
    });
  }
}

extension MoneySavingGridCellEntityQueryWhereDistinct on QueryBuilder<
    MoneySavingGridCellEntity, MoneySavingGridCellEntity, QDistinct> {
  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity, QDistinct>
      distinctByCellIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cellIndex');
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity, QDistinct>
      distinctByChallengeId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'challengeId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity, QDistinct>
      distinctByIsMarked() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isMarked');
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity, QDistinct>
      distinctByMarkedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'markedAt');
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, MoneySavingGridCellEntity, QDistinct>
      distinctByValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'value');
    });
  }
}

extension MoneySavingGridCellEntityQueryProperty on QueryBuilder<
    MoneySavingGridCellEntity, MoneySavingGridCellEntity, QQueryProperty> {
  QueryBuilder<MoneySavingGridCellEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, int, QQueryOperations>
      cellIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cellIndex');
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, String, QQueryOperations>
      challengeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'challengeId');
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, bool, QQueryOperations>
      isMarkedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isMarked');
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, DateTime?, QQueryOperations>
      markedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'markedAt');
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<MoneySavingGridCellEntity, double, QQueryOperations>
      valueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'value');
    });
  }
}
