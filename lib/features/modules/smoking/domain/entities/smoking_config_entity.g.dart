// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'smoking_config_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSmokingConfigEntityCollection on Isar {
  IsarCollection<SmokingConfigEntity> get smokingConfigEntitys =>
      this.collection();
}

const SmokingConfigEntitySchema = CollectionSchema(
  name: r'SmokingConfigEntity',
  id: 8402262883332487631,
  properties: {
    r'cigarettesPerPack': PropertySchema(
      id: 0,
      name: r'cigarettesPerPack',
      type: IsarType.long,
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
    r'dailyCigarettes': PropertySchema(
      id: 3,
      name: r'dailyCigarettes',
      type: IsarType.long,
    ),
    r'isModuleActive': PropertySchema(
      id: 4,
      name: r'isModuleActive',
      type: IsarType.bool,
    ),
    r'lastCurrency': PropertySchema(
      id: 5,
      name: r'lastCurrency',
      type: IsarType.string,
    ),
    r'lastEndDate': PropertySchema(
      id: 6,
      name: r'lastEndDate',
      type: IsarType.dateTime,
    ),
    r'lastPackPrice': PropertySchema(
      id: 7,
      name: r'lastPackPrice',
      type: IsarType.double,
    ),
    r'lastPacksPerDay': PropertySchema(
      id: 8,
      name: r'lastPacksPerDay',
      type: IsarType.double,
    ),
    r'lastQuitDate': PropertySchema(
      id: 9,
      name: r'lastQuitDate',
      type: IsarType.dateTime,
    ),
    r'lastSavedTotal': PropertySchema(
      id: 10,
      name: r'lastSavedTotal',
      type: IsarType.double,
    ),
    r'pricePerPack': PropertySchema(
      id: 11,
      name: r'pricePerPack',
      type: IsarType.double,
    ),
    r'quitDate': PropertySchema(
      id: 12,
      name: r'quitDate',
      type: IsarType.dateTime,
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
  estimateSize: _smokingConfigEntityEstimateSize,
  serialize: _smokingConfigEntitySerialize,
  deserialize: _smokingConfigEntityDeserialize,
  deserializeProp: _smokingConfigEntityDeserializeProp,
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
  getId: _smokingConfigEntityGetId,
  getLinks: _smokingConfigEntityGetLinks,
  attach: _smokingConfigEntityAttach,
  version: '3.1.0+1',
);

int _smokingConfigEntityEstimateSize(
  SmokingConfigEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.currency.length * 3;
  {
    final value = object.lastCurrency;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _smokingConfigEntitySerialize(
  SmokingConfigEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.cigarettesPerPack);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.currency);
  writer.writeLong(offsets[3], object.dailyCigarettes);
  writer.writeBool(offsets[4], object.isModuleActive);
  writer.writeString(offsets[5], object.lastCurrency);
  writer.writeDateTime(offsets[6], object.lastEndDate);
  writer.writeDouble(offsets[7], object.lastPackPrice);
  writer.writeDouble(offsets[8], object.lastPacksPerDay);
  writer.writeDateTime(offsets[9], object.lastQuitDate);
  writer.writeDouble(offsets[10], object.lastSavedTotal);
  writer.writeDouble(offsets[11], object.pricePerPack);
  writer.writeDateTime(offsets[12], object.quitDate);
  writer.writeDateTime(offsets[13], object.updatedAt);
  writer.writeString(offsets[14], object.userId);
}

SmokingConfigEntity _smokingConfigEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SmokingConfigEntity(
    cigarettesPerPack: reader.readLongOrNull(offsets[0]) ?? 20,
    currency: reader.readStringOrNull(offsets[2]) ?? 'R\$',
    dailyCigarettes: reader.readLongOrNull(offsets[3]) ?? 0,
    isModuleActive: reader.readBoolOrNull(offsets[4]) ?? false,
    lastCurrency: reader.readStringOrNull(offsets[5]),
    lastEndDate: reader.readDateTimeOrNull(offsets[6]),
    lastPackPrice: reader.readDoubleOrNull(offsets[7]),
    lastPacksPerDay: reader.readDoubleOrNull(offsets[8]),
    lastQuitDate: reader.readDateTimeOrNull(offsets[9]),
    lastSavedTotal: reader.readDoubleOrNull(offsets[10]),
    pricePerPack: reader.readDoubleOrNull(offsets[11]) ?? 0.0,
    quitDate: reader.readDateTimeOrNull(offsets[12]),
    userId: reader.readString(offsets[14]),
  );
  object.createdAt = reader.readDateTime(offsets[1]);
  object.id = id;
  object.updatedAt = reader.readDateTime(offsets[13]);
  return object;
}

P _smokingConfigEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset) ?? 20) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset) ?? 'R\$') as P;
    case 3:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 4:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readDoubleOrNull(offset)) as P;
    case 8:
      return (reader.readDoubleOrNull(offset)) as P;
    case 9:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 10:
      return (reader.readDoubleOrNull(offset)) as P;
    case 11:
      return (reader.readDoubleOrNull(offset) ?? 0.0) as P;
    case 12:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 13:
      return (reader.readDateTime(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _smokingConfigEntityGetId(SmokingConfigEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _smokingConfigEntityGetLinks(
    SmokingConfigEntity object) {
  return [];
}

void _smokingConfigEntityAttach(
    IsarCollection<dynamic> col, Id id, SmokingConfigEntity object) {
  object.id = id;
}

extension SmokingConfigEntityByIndex on IsarCollection<SmokingConfigEntity> {
  Future<SmokingConfigEntity?> getByUserId(String userId) {
    return getByIndex(r'userId', [userId]);
  }

  SmokingConfigEntity? getByUserIdSync(String userId) {
    return getByIndexSync(r'userId', [userId]);
  }

  Future<bool> deleteByUserId(String userId) {
    return deleteByIndex(r'userId', [userId]);
  }

  bool deleteByUserIdSync(String userId) {
    return deleteByIndexSync(r'userId', [userId]);
  }

  Future<List<SmokingConfigEntity?>> getAllByUserId(List<String> userIdValues) {
    final values = userIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'userId', values);
  }

  List<SmokingConfigEntity?> getAllByUserIdSync(List<String> userIdValues) {
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

  Future<Id> putByUserId(SmokingConfigEntity object) {
    return putByIndex(r'userId', object);
  }

  Id putByUserIdSync(SmokingConfigEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'userId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUserId(List<SmokingConfigEntity> objects) {
    return putAllByIndex(r'userId', objects);
  }

  List<Id> putAllByUserIdSync(List<SmokingConfigEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'userId', objects, saveLinks: saveLinks);
  }
}

extension SmokingConfigEntityQueryWhereSort
    on QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QWhere> {
  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SmokingConfigEntityQueryWhere
    on QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QWhereClause> {
  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterWhereClause>
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

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterWhereClause>
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

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterWhereClause>
      userIdEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterWhereClause>
      userIdNotEqualTo(String userId) {
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

extension SmokingConfigEntityQueryFilter on QueryBuilder<SmokingConfigEntity,
    SmokingConfigEntity, QFilterCondition> {
  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      cigarettesPerPackEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cigarettesPerPack',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      cigarettesPerPackGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cigarettesPerPack',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      cigarettesPerPackLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cigarettesPerPack',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      cigarettesPerPackBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cigarettesPerPack',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      createdAtGreaterThan(
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

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      createdAtLessThan(
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

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      createdAtBetween(
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

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      currencyEqualTo(
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

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      currencyGreaterThan(
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

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      currencyLessThan(
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

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      currencyBetween(
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

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      currencyStartsWith(
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

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      currencyEndsWith(
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

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      currencyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'currency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      currencyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'currency',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      currencyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      currencyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      dailyCigarettesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dailyCigarettes',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      dailyCigarettesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dailyCigarettes',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      dailyCigarettesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dailyCigarettes',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      dailyCigarettesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dailyCigarettes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      isModuleActiveEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isModuleActive',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      lastCurrencyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastCurrency',
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      lastCurrencyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastCurrency',
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      lastCurrencyEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastCurrency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      lastCurrencyGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastCurrency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      lastCurrencyLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastCurrency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      lastCurrencyBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastCurrency',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      lastCurrencyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastCurrency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      lastCurrencyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastCurrency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      lastCurrencyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastCurrency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      lastCurrencyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastCurrency',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      lastCurrencyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastCurrency',
        value: '',
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      lastCurrencyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastCurrency',
        value: '',
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      lastEndDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastEndDate',
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      lastEndDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastEndDate',
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      lastEndDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastEndDate',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      lastEndDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastEndDate',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      lastEndDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastEndDate',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      lastEndDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastEndDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      lastPackPriceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastPackPrice',
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      lastPackPriceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastPackPrice',
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      lastPackPriceEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastPackPrice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      lastPackPriceGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastPackPrice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      lastPackPriceLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastPackPrice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      lastPackPriceBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastPackPrice',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      lastPacksPerDayIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastPacksPerDay',
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      lastPacksPerDayIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastPacksPerDay',
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      lastPacksPerDayEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastPacksPerDay',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      lastPacksPerDayGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastPacksPerDay',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      lastPacksPerDayLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastPacksPerDay',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      lastPacksPerDayBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastPacksPerDay',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      lastQuitDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastQuitDate',
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      lastQuitDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastQuitDate',
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      lastQuitDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastQuitDate',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      lastQuitDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastQuitDate',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      lastQuitDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastQuitDate',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      lastQuitDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastQuitDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      lastSavedTotalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastSavedTotal',
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      lastSavedTotalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastSavedTotal',
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      lastSavedTotalEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSavedTotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      lastSavedTotalGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastSavedTotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      lastSavedTotalLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastSavedTotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      lastSavedTotalBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastSavedTotal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      pricePerPackEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pricePerPack',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      pricePerPackGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pricePerPack',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      pricePerPackLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pricePerPack',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      pricePerPackBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pricePerPack',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      quitDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'quitDate',
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      quitDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'quitDate',
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      quitDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quitDate',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      quitDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'quitDate',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      quitDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'quitDate',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      quitDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'quitDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      updatedAtGreaterThan(
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

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      updatedAtLessThan(
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

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      updatedAtBetween(
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

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      userIdEqualTo(
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

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      userIdGreaterThan(
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

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      userIdLessThan(
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

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      userIdBetween(
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

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      userIdStartsWith(
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

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      userIdEndsWith(
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

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterFilterCondition>
      userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension SmokingConfigEntityQueryObject on QueryBuilder<SmokingConfigEntity,
    SmokingConfigEntity, QFilterCondition> {}

extension SmokingConfigEntityQueryLinks on QueryBuilder<SmokingConfigEntity,
    SmokingConfigEntity, QFilterCondition> {}

extension SmokingConfigEntityQuerySortBy
    on QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QSortBy> {
  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      sortByCigarettesPerPack() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cigarettesPerPack', Sort.asc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      sortByCigarettesPerPackDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cigarettesPerPack', Sort.desc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      sortByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      sortByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      sortByDailyCigarettes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyCigarettes', Sort.asc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      sortByDailyCigarettesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyCigarettes', Sort.desc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      sortByIsModuleActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isModuleActive', Sort.asc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      sortByIsModuleActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isModuleActive', Sort.desc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      sortByLastCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCurrency', Sort.asc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      sortByLastCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCurrency', Sort.desc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      sortByLastEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastEndDate', Sort.asc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      sortByLastEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastEndDate', Sort.desc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      sortByLastPackPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPackPrice', Sort.asc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      sortByLastPackPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPackPrice', Sort.desc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      sortByLastPacksPerDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPacksPerDay', Sort.asc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      sortByLastPacksPerDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPacksPerDay', Sort.desc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      sortByLastQuitDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastQuitDate', Sort.asc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      sortByLastQuitDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastQuitDate', Sort.desc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      sortByLastSavedTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSavedTotal', Sort.asc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      sortByLastSavedTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSavedTotal', Sort.desc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      sortByPricePerPack() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pricePerPack', Sort.asc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      sortByPricePerPackDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pricePerPack', Sort.desc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      sortByQuitDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quitDate', Sort.asc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      sortByQuitDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quitDate', Sort.desc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension SmokingConfigEntityQuerySortThenBy
    on QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QSortThenBy> {
  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      thenByCigarettesPerPack() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cigarettesPerPack', Sort.asc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      thenByCigarettesPerPackDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cigarettesPerPack', Sort.desc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      thenByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      thenByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      thenByDailyCigarettes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyCigarettes', Sort.asc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      thenByDailyCigarettesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyCigarettes', Sort.desc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      thenByIsModuleActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isModuleActive', Sort.asc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      thenByIsModuleActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isModuleActive', Sort.desc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      thenByLastCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCurrency', Sort.asc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      thenByLastCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCurrency', Sort.desc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      thenByLastEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastEndDate', Sort.asc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      thenByLastEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastEndDate', Sort.desc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      thenByLastPackPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPackPrice', Sort.asc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      thenByLastPackPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPackPrice', Sort.desc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      thenByLastPacksPerDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPacksPerDay', Sort.asc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      thenByLastPacksPerDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPacksPerDay', Sort.desc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      thenByLastQuitDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastQuitDate', Sort.asc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      thenByLastQuitDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastQuitDate', Sort.desc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      thenByLastSavedTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSavedTotal', Sort.asc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      thenByLastSavedTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSavedTotal', Sort.desc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      thenByPricePerPack() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pricePerPack', Sort.asc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      thenByPricePerPackDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pricePerPack', Sort.desc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      thenByQuitDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quitDate', Sort.asc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      thenByQuitDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quitDate', Sort.desc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension SmokingConfigEntityQueryWhereDistinct
    on QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QDistinct> {
  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QDistinct>
      distinctByCigarettesPerPack() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cigarettesPerPack');
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QDistinct>
      distinctByCurrency({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currency', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QDistinct>
      distinctByDailyCigarettes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dailyCigarettes');
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QDistinct>
      distinctByIsModuleActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isModuleActive');
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QDistinct>
      distinctByLastCurrency({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastCurrency', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QDistinct>
      distinctByLastEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastEndDate');
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QDistinct>
      distinctByLastPackPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPackPrice');
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QDistinct>
      distinctByLastPacksPerDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPacksPerDay');
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QDistinct>
      distinctByLastQuitDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastQuitDate');
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QDistinct>
      distinctByLastSavedTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSavedTotal');
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QDistinct>
      distinctByPricePerPack() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pricePerPack');
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QDistinct>
      distinctByQuitDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quitDate');
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QDistinct>
      distinctByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension SmokingConfigEntityQueryProperty
    on QueryBuilder<SmokingConfigEntity, SmokingConfigEntity, QQueryProperty> {
  QueryBuilder<SmokingConfigEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SmokingConfigEntity, int, QQueryOperations>
      cigarettesPerPackProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cigarettesPerPack');
    });
  }

  QueryBuilder<SmokingConfigEntity, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<SmokingConfigEntity, String, QQueryOperations>
      currencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currency');
    });
  }

  QueryBuilder<SmokingConfigEntity, int, QQueryOperations>
      dailyCigarettesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dailyCigarettes');
    });
  }

  QueryBuilder<SmokingConfigEntity, bool, QQueryOperations>
      isModuleActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isModuleActive');
    });
  }

  QueryBuilder<SmokingConfigEntity, String?, QQueryOperations>
      lastCurrencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastCurrency');
    });
  }

  QueryBuilder<SmokingConfigEntity, DateTime?, QQueryOperations>
      lastEndDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastEndDate');
    });
  }

  QueryBuilder<SmokingConfigEntity, double?, QQueryOperations>
      lastPackPriceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPackPrice');
    });
  }

  QueryBuilder<SmokingConfigEntity, double?, QQueryOperations>
      lastPacksPerDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPacksPerDay');
    });
  }

  QueryBuilder<SmokingConfigEntity, DateTime?, QQueryOperations>
      lastQuitDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastQuitDate');
    });
  }

  QueryBuilder<SmokingConfigEntity, double?, QQueryOperations>
      lastSavedTotalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSavedTotal');
    });
  }

  QueryBuilder<SmokingConfigEntity, double, QQueryOperations>
      pricePerPackProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pricePerPack');
    });
  }

  QueryBuilder<SmokingConfigEntity, DateTime?, QQueryOperations>
      quitDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quitDate');
    });
  }

  QueryBuilder<SmokingConfigEntity, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<SmokingConfigEntity, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}
