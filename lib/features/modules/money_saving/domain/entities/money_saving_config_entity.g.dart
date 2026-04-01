// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'money_saving_config_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMoneySavingConfigEntityCollection on Isar {
  IsarCollection<MoneySavingConfigEntity> get moneySavingConfigEntitys =>
      this.collection();
}

const MoneySavingConfigEntitySchema = CollectionSchema(
  name: r'MoneySavingConfigEntity',
  id: 8112858222803264062,
  properties: {
    r'activeChallengeId': PropertySchema(
      id: 0,
      name: r'activeChallengeId',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'isModuleActive': PropertySchema(
      id: 2,
      name: r'isModuleActive',
      type: IsarType.bool,
    ),
    r'updatedAt': PropertySchema(
      id: 3,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'userId': PropertySchema(
      id: 4,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _moneySavingConfigEntityEstimateSize,
  serialize: _moneySavingConfigEntitySerialize,
  deserialize: _moneySavingConfigEntityDeserialize,
  deserializeProp: _moneySavingConfigEntityDeserializeProp,
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
  getId: _moneySavingConfigEntityGetId,
  getLinks: _moneySavingConfigEntityGetLinks,
  attach: _moneySavingConfigEntityAttach,
  version: '3.1.0+1',
);

int _moneySavingConfigEntityEstimateSize(
  MoneySavingConfigEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.activeChallengeId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _moneySavingConfigEntitySerialize(
  MoneySavingConfigEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.activeChallengeId);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeBool(offsets[2], object.isModuleActive);
  writer.writeDateTime(offsets[3], object.updatedAt);
  writer.writeString(offsets[4], object.userId);
}

MoneySavingConfigEntity _moneySavingConfigEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MoneySavingConfigEntity(
    activeChallengeId: reader.readStringOrNull(offsets[0]),
    isModuleActive: reader.readBoolOrNull(offsets[2]) ?? false,
    userId: reader.readString(offsets[4]),
  );
  object.createdAt = reader.readDateTime(offsets[1]);
  object.id = id;
  object.updatedAt = reader.readDateTime(offsets[3]);
  return object;
}

P _moneySavingConfigEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _moneySavingConfigEntityGetId(MoneySavingConfigEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _moneySavingConfigEntityGetLinks(
    MoneySavingConfigEntity object) {
  return [];
}

void _moneySavingConfigEntityAttach(
    IsarCollection<dynamic> col, Id id, MoneySavingConfigEntity object) {
  object.id = id;
}

extension MoneySavingConfigEntityByIndex
    on IsarCollection<MoneySavingConfigEntity> {
  Future<MoneySavingConfigEntity?> getByUserId(String userId) {
    return getByIndex(r'userId', [userId]);
  }

  MoneySavingConfigEntity? getByUserIdSync(String userId) {
    return getByIndexSync(r'userId', [userId]);
  }

  Future<bool> deleteByUserId(String userId) {
    return deleteByIndex(r'userId', [userId]);
  }

  bool deleteByUserIdSync(String userId) {
    return deleteByIndexSync(r'userId', [userId]);
  }

  Future<List<MoneySavingConfigEntity?>> getAllByUserId(
      List<String> userIdValues) {
    final values = userIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'userId', values);
  }

  List<MoneySavingConfigEntity?> getAllByUserIdSync(List<String> userIdValues) {
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

  Future<Id> putByUserId(MoneySavingConfigEntity object) {
    return putByIndex(r'userId', object);
  }

  Id putByUserIdSync(MoneySavingConfigEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'userId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUserId(List<MoneySavingConfigEntity> objects) {
    return putAllByIndex(r'userId', objects);
  }

  List<Id> putAllByUserIdSync(List<MoneySavingConfigEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'userId', objects, saveLinks: saveLinks);
  }
}

extension MoneySavingConfigEntityQueryWhereSort
    on QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity, QWhere> {
  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MoneySavingConfigEntityQueryWhere on QueryBuilder<
    MoneySavingConfigEntity, MoneySavingConfigEntity, QWhereClause> {
  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity,
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

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity,
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

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity,
      QAfterWhereClause> userIdEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity,
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

extension MoneySavingConfigEntityQueryFilter on QueryBuilder<
    MoneySavingConfigEntity, MoneySavingConfigEntity, QFilterCondition> {
  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity,
      QAfterFilterCondition> activeChallengeIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'activeChallengeId',
      ));
    });
  }

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity,
      QAfterFilterCondition> activeChallengeIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'activeChallengeId',
      ));
    });
  }

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity,
      QAfterFilterCondition> activeChallengeIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activeChallengeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity,
      QAfterFilterCondition> activeChallengeIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activeChallengeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity,
      QAfterFilterCondition> activeChallengeIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activeChallengeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity,
      QAfterFilterCondition> activeChallengeIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activeChallengeId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity,
      QAfterFilterCondition> activeChallengeIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'activeChallengeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity,
      QAfterFilterCondition> activeChallengeIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'activeChallengeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity,
          QAfterFilterCondition>
      activeChallengeIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'activeChallengeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity,
          QAfterFilterCondition>
      activeChallengeIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'activeChallengeId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity,
      QAfterFilterCondition> activeChallengeIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activeChallengeId',
        value: '',
      ));
    });
  }

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity,
      QAfterFilterCondition> activeChallengeIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'activeChallengeId',
        value: '',
      ));
    });
  }

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity,
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

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity,
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

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity,
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

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity,
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

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity,
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

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity,
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

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity,
      QAfterFilterCondition> isModuleActiveEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isModuleActive',
        value: value,
      ));
    });
  }

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity,
      QAfterFilterCondition> updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity,
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

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity,
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

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity,
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

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity,
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

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity,
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

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity,
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

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity,
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

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity,
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

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity,
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

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity,
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

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity,
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

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity,
      QAfterFilterCondition> userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity,
      QAfterFilterCondition> userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension MoneySavingConfigEntityQueryObject on QueryBuilder<
    MoneySavingConfigEntity, MoneySavingConfigEntity, QFilterCondition> {}

extension MoneySavingConfigEntityQueryLinks on QueryBuilder<
    MoneySavingConfigEntity, MoneySavingConfigEntity, QFilterCondition> {}

extension MoneySavingConfigEntityQuerySortBy
    on QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity, QSortBy> {
  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity, QAfterSortBy>
      sortByActiveChallengeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeChallengeId', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity, QAfterSortBy>
      sortByActiveChallengeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeChallengeId', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity, QAfterSortBy>
      sortByIsModuleActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isModuleActive', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity, QAfterSortBy>
      sortByIsModuleActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isModuleActive', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity, QAfterSortBy>
      sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension MoneySavingConfigEntityQuerySortThenBy on QueryBuilder<
    MoneySavingConfigEntity, MoneySavingConfigEntity, QSortThenBy> {
  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity, QAfterSortBy>
      thenByActiveChallengeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeChallengeId', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity, QAfterSortBy>
      thenByActiveChallengeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeChallengeId', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity, QAfterSortBy>
      thenByIsModuleActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isModuleActive', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity, QAfterSortBy>
      thenByIsModuleActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isModuleActive', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity, QAfterSortBy>
      thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension MoneySavingConfigEntityQueryWhereDistinct on QueryBuilder<
    MoneySavingConfigEntity, MoneySavingConfigEntity, QDistinct> {
  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity, QDistinct>
      distinctByActiveChallengeId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activeChallengeId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity, QDistinct>
      distinctByIsModuleActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isModuleActive');
    });
  }

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<MoneySavingConfigEntity, MoneySavingConfigEntity, QDistinct>
      distinctByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension MoneySavingConfigEntityQueryProperty on QueryBuilder<
    MoneySavingConfigEntity, MoneySavingConfigEntity, QQueryProperty> {
  QueryBuilder<MoneySavingConfigEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MoneySavingConfigEntity, String?, QQueryOperations>
      activeChallengeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activeChallengeId');
    });
  }

  QueryBuilder<MoneySavingConfigEntity, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<MoneySavingConfigEntity, bool, QQueryOperations>
      isModuleActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isModuleActive');
    });
  }

  QueryBuilder<MoneySavingConfigEntity, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<MoneySavingConfigEntity, String, QQueryOperations>
      userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}
