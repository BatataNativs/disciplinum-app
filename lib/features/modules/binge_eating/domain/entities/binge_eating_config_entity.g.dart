// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'binge_eating_config_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBingeEatingConfigEntityCollection on Isar {
  IsarCollection<BingeEatingConfigEntity> get bingeEatingConfigEntitys =>
      this.collection();
}

const BingeEatingConfigEntitySchema = CollectionSchema(
  name: r'BingeEatingConfigEntity',
  id: 982033498122711142,
  properties: {
    r'appLockCooldownMinutes': PropertySchema(
      id: 0,
      name: r'appLockCooldownMinutes',
      type: IsarType.long,
    ),
    r'appLockMessage': PropertySchema(
      id: 1,
      name: r'appLockMessage',
      type: IsarType.string,
    ),
    r'appLockRequirePassword': PropertySchema(
      id: 2,
      name: r'appLockRequirePassword',
      type: IsarType.bool,
    ),
    r'blockReason': PropertySchema(
      id: 3,
      name: r'blockReason',
      type: IsarType.string,
    ),
    r'blockedUntil': PropertySchema(
      id: 4,
      name: r'blockedUntil',
      type: IsarType.dateTime,
    ),
    r'copingStrategies': PropertySchema(
      id: 5,
      name: r'copingStrategies',
      type: IsarType.stringList,
    ),
    r'createdAt': PropertySchema(
      id: 6,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'dailyLimitMinutes': PropertySchema(
      id: 7,
      name: r'dailyLimitMinutes',
      type: IsarType.long,
    ),
    r'enableAppLock': PropertySchema(
      id: 8,
      name: r'enableAppLock',
      type: IsarType.bool,
    ),
    r'enableNotifications': PropertySchema(
      id: 9,
      name: r'enableNotifications',
      type: IsarType.bool,
    ),
    r'isEnabled': PropertySchema(
      id: 10,
      name: r'isEnabled',
      type: IsarType.bool,
    ),
    r'monitoredApps': PropertySchema(
      id: 11,
      name: r'monitoredApps',
      type: IsarType.stringList,
    ),
    r'reminderHour': PropertySchema(
      id: 12,
      name: r'reminderHour',
      type: IsarType.long,
    ),
    r'reminderMinute': PropertySchema(
      id: 13,
      name: r'reminderMinute',
      type: IsarType.long,
    ),
    r'requirePassword': PropertySchema(
      id: 14,
      name: r'requirePassword',
      type: IsarType.bool,
    ),
    r'triggerFoods': PropertySchema(
      id: 15,
      name: r'triggerFoods',
      type: IsarType.stringList,
    ),
    r'updatedAt': PropertySchema(
      id: 16,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'userId': PropertySchema(
      id: 17,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _bingeEatingConfigEntityEstimateSize,
  serialize: _bingeEatingConfigEntitySerialize,
  deserialize: _bingeEatingConfigEntityDeserialize,
  deserializeProp: _bingeEatingConfigEntityDeserializeProp,
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
  getId: _bingeEatingConfigEntityGetId,
  getLinks: _bingeEatingConfigEntityGetLinks,
  attach: _bingeEatingConfigEntityAttach,
  version: '3.1.0+1',
);

int _bingeEatingConfigEntityEstimateSize(
  BingeEatingConfigEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.appLockMessage.length * 3;
  {
    final value = object.blockReason;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.copingStrategies.length * 3;
  {
    for (var i = 0; i < object.copingStrategies.length; i++) {
      final value = object.copingStrategies[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.monitoredApps.length * 3;
  {
    for (var i = 0; i < object.monitoredApps.length; i++) {
      final value = object.monitoredApps[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.triggerFoods.length * 3;
  {
    for (var i = 0; i < object.triggerFoods.length; i++) {
      final value = object.triggerFoods[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _bingeEatingConfigEntitySerialize(
  BingeEatingConfigEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.appLockCooldownMinutes);
  writer.writeString(offsets[1], object.appLockMessage);
  writer.writeBool(offsets[2], object.appLockRequirePassword);
  writer.writeString(offsets[3], object.blockReason);
  writer.writeDateTime(offsets[4], object.blockedUntil);
  writer.writeStringList(offsets[5], object.copingStrategies);
  writer.writeDateTime(offsets[6], object.createdAt);
  writer.writeLong(offsets[7], object.dailyLimitMinutes);
  writer.writeBool(offsets[8], object.enableAppLock);
  writer.writeBool(offsets[9], object.enableNotifications);
  writer.writeBool(offsets[10], object.isEnabled);
  writer.writeStringList(offsets[11], object.monitoredApps);
  writer.writeLong(offsets[12], object.reminderHour);
  writer.writeLong(offsets[13], object.reminderMinute);
  writer.writeBool(offsets[14], object.requirePassword);
  writer.writeStringList(offsets[15], object.triggerFoods);
  writer.writeDateTime(offsets[16], object.updatedAt);
  writer.writeString(offsets[17], object.userId);
}

BingeEatingConfigEntity _bingeEatingConfigEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BingeEatingConfigEntity(
    userId: reader.readString(offsets[17]),
  );
  object.appLockCooldownMinutes = reader.readLong(offsets[0]);
  object.appLockMessage = reader.readString(offsets[1]);
  object.appLockRequirePassword = reader.readBool(offsets[2]);
  object.blockReason = reader.readStringOrNull(offsets[3]);
  object.blockedUntil = reader.readDateTimeOrNull(offsets[4]);
  object.copingStrategies = reader.readStringList(offsets[5]) ?? [];
  object.createdAt = reader.readDateTime(offsets[6]);
  object.dailyLimitMinutes = reader.readLong(offsets[7]);
  object.enableAppLock = reader.readBool(offsets[8]);
  object.enableNotifications = reader.readBool(offsets[9]);
  object.id = id;
  object.isEnabled = reader.readBool(offsets[10]);
  object.monitoredApps = reader.readStringList(offsets[11]) ?? [];
  object.reminderHour = reader.readLong(offsets[12]);
  object.reminderMinute = reader.readLong(offsets[13]);
  object.requirePassword = reader.readBool(offsets[14]);
  object.triggerFoods = reader.readStringList(offsets[15]) ?? [];
  object.updatedAt = reader.readDateTime(offsets[16]);
  return object;
}

P _bingeEatingConfigEntityDeserializeProp<P>(
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
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readStringList(offset) ?? []) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readBool(offset)) as P;
    case 10:
      return (reader.readBool(offset)) as P;
    case 11:
      return (reader.readStringList(offset) ?? []) as P;
    case 12:
      return (reader.readLong(offset)) as P;
    case 13:
      return (reader.readLong(offset)) as P;
    case 14:
      return (reader.readBool(offset)) as P;
    case 15:
      return (reader.readStringList(offset) ?? []) as P;
    case 16:
      return (reader.readDateTime(offset)) as P;
    case 17:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _bingeEatingConfigEntityGetId(BingeEatingConfigEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _bingeEatingConfigEntityGetLinks(
    BingeEatingConfigEntity object) {
  return [];
}

void _bingeEatingConfigEntityAttach(
    IsarCollection<dynamic> col, Id id, BingeEatingConfigEntity object) {
  object.id = id;
}

extension BingeEatingConfigEntityByIndex
    on IsarCollection<BingeEatingConfigEntity> {
  Future<BingeEatingConfigEntity?> getByUserId(String userId) {
    return getByIndex(r'userId', [userId]);
  }

  BingeEatingConfigEntity? getByUserIdSync(String userId) {
    return getByIndexSync(r'userId', [userId]);
  }

  Future<bool> deleteByUserId(String userId) {
    return deleteByIndex(r'userId', [userId]);
  }

  bool deleteByUserIdSync(String userId) {
    return deleteByIndexSync(r'userId', [userId]);
  }

  Future<List<BingeEatingConfigEntity?>> getAllByUserId(
      List<String> userIdValues) {
    final values = userIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'userId', values);
  }

  List<BingeEatingConfigEntity?> getAllByUserIdSync(List<String> userIdValues) {
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

  Future<Id> putByUserId(BingeEatingConfigEntity object) {
    return putByIndex(r'userId', object);
  }

  Id putByUserIdSync(BingeEatingConfigEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'userId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUserId(List<BingeEatingConfigEntity> objects) {
    return putAllByIndex(r'userId', objects);
  }

  List<Id> putAllByUserIdSync(List<BingeEatingConfigEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'userId', objects, saveLinks: saveLinks);
  }
}

extension BingeEatingConfigEntityQueryWhereSort
    on QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QWhere> {
  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension BingeEatingConfigEntityQueryWhere on QueryBuilder<
    BingeEatingConfigEntity, BingeEatingConfigEntity, QWhereClause> {
  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
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

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
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

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterWhereClause> userIdEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
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

extension BingeEatingConfigEntityQueryFilter on QueryBuilder<
    BingeEatingConfigEntity, BingeEatingConfigEntity, QFilterCondition> {
  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> appLockCooldownMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'appLockCooldownMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> appLockCooldownMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'appLockCooldownMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> appLockCooldownMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'appLockCooldownMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> appLockCooldownMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'appLockCooldownMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> appLockMessageEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'appLockMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> appLockMessageGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'appLockMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> appLockMessageLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'appLockMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> appLockMessageBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'appLockMessage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> appLockMessageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'appLockMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> appLockMessageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'appLockMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
          QAfterFilterCondition>
      appLockMessageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'appLockMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
          QAfterFilterCondition>
      appLockMessageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'appLockMessage',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> appLockMessageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'appLockMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> appLockMessageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'appLockMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> appLockRequirePasswordEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'appLockRequirePassword',
        value: value,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> blockReasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'blockReason',
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> blockReasonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'blockReason',
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> blockReasonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'blockReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> blockReasonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'blockReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> blockReasonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'blockReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> blockReasonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'blockReason',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> blockReasonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'blockReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> blockReasonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'blockReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
          QAfterFilterCondition>
      blockReasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'blockReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
          QAfterFilterCondition>
      blockReasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'blockReason',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> blockReasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'blockReason',
        value: '',
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> blockReasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'blockReason',
        value: '',
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> blockedUntilIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'blockedUntil',
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> blockedUntilIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'blockedUntil',
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> blockedUntilEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'blockedUntil',
        value: value,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> blockedUntilGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'blockedUntil',
        value: value,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> blockedUntilLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'blockedUntil',
        value: value,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> blockedUntilBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'blockedUntil',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> copingStrategiesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'copingStrategies',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> copingStrategiesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'copingStrategies',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> copingStrategiesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'copingStrategies',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> copingStrategiesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'copingStrategies',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> copingStrategiesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'copingStrategies',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> copingStrategiesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'copingStrategies',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
          QAfterFilterCondition>
      copingStrategiesElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'copingStrategies',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
          QAfterFilterCondition>
      copingStrategiesElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'copingStrategies',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> copingStrategiesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'copingStrategies',
        value: '',
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> copingStrategiesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'copingStrategies',
        value: '',
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> copingStrategiesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'copingStrategies',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> copingStrategiesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'copingStrategies',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> copingStrategiesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'copingStrategies',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> copingStrategiesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'copingStrategies',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> copingStrategiesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'copingStrategies',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> copingStrategiesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'copingStrategies',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
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

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
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

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
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

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> dailyLimitMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dailyLimitMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> dailyLimitMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dailyLimitMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> dailyLimitMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dailyLimitMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> dailyLimitMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dailyLimitMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> enableAppLockEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enableAppLock',
        value: value,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> enableNotificationsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enableNotifications',
        value: value,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
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

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
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

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
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

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> isEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> monitoredAppsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'monitoredApps',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> monitoredAppsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'monitoredApps',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> monitoredAppsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'monitoredApps',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> monitoredAppsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'monitoredApps',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> monitoredAppsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'monitoredApps',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> monitoredAppsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'monitoredApps',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
          QAfterFilterCondition>
      monitoredAppsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'monitoredApps',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
          QAfterFilterCondition>
      monitoredAppsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'monitoredApps',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> monitoredAppsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'monitoredApps',
        value: '',
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> monitoredAppsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'monitoredApps',
        value: '',
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> monitoredAppsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'monitoredApps',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> monitoredAppsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'monitoredApps',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> monitoredAppsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'monitoredApps',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> monitoredAppsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'monitoredApps',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> monitoredAppsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'monitoredApps',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> monitoredAppsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'monitoredApps',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> reminderHourEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reminderHour',
        value: value,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> reminderHourGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reminderHour',
        value: value,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> reminderHourLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reminderHour',
        value: value,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> reminderHourBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reminderHour',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> reminderMinuteEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reminderMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> reminderMinuteGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reminderMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> reminderMinuteLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reminderMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> reminderMinuteBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reminderMinute',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> requirePasswordEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'requirePassword',
        value: value,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> triggerFoodsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'triggerFoods',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> triggerFoodsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'triggerFoods',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> triggerFoodsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'triggerFoods',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> triggerFoodsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'triggerFoods',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> triggerFoodsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'triggerFoods',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> triggerFoodsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'triggerFoods',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
          QAfterFilterCondition>
      triggerFoodsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'triggerFoods',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
          QAfterFilterCondition>
      triggerFoodsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'triggerFoods',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> triggerFoodsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'triggerFoods',
        value: '',
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> triggerFoodsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'triggerFoods',
        value: '',
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> triggerFoodsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'triggerFoods',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> triggerFoodsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'triggerFoods',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> triggerFoodsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'triggerFoods',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> triggerFoodsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'triggerFoods',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> triggerFoodsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'triggerFoods',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> triggerFoodsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'triggerFoods',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
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

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
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

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
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

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
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

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
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

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
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

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
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

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
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

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
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

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
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

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
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

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity,
      QAfterFilterCondition> userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension BingeEatingConfigEntityQueryObject on QueryBuilder<
    BingeEatingConfigEntity, BingeEatingConfigEntity, QFilterCondition> {}

extension BingeEatingConfigEntityQueryLinks on QueryBuilder<
    BingeEatingConfigEntity, BingeEatingConfigEntity, QFilterCondition> {}

extension BingeEatingConfigEntityQuerySortBy
    on QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QSortBy> {
  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      sortByAppLockCooldownMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appLockCooldownMinutes', Sort.asc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      sortByAppLockCooldownMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appLockCooldownMinutes', Sort.desc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      sortByAppLockMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appLockMessage', Sort.asc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      sortByAppLockMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appLockMessage', Sort.desc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      sortByAppLockRequirePassword() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appLockRequirePassword', Sort.asc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      sortByAppLockRequirePasswordDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appLockRequirePassword', Sort.desc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      sortByBlockReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockReason', Sort.asc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      sortByBlockReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockReason', Sort.desc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      sortByBlockedUntil() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockedUntil', Sort.asc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      sortByBlockedUntilDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockedUntil', Sort.desc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      sortByDailyLimitMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyLimitMinutes', Sort.asc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      sortByDailyLimitMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyLimitMinutes', Sort.desc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      sortByEnableAppLock() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableAppLock', Sort.asc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      sortByEnableAppLockDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableAppLock', Sort.desc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      sortByEnableNotifications() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableNotifications', Sort.asc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      sortByEnableNotificationsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableNotifications', Sort.desc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      sortByIsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEnabled', Sort.asc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      sortByIsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEnabled', Sort.desc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      sortByReminderHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderHour', Sort.asc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      sortByReminderHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderHour', Sort.desc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      sortByReminderMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderMinute', Sort.asc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      sortByReminderMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderMinute', Sort.desc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      sortByRequirePassword() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requirePassword', Sort.asc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      sortByRequirePasswordDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requirePassword', Sort.desc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension BingeEatingConfigEntityQuerySortThenBy on QueryBuilder<
    BingeEatingConfigEntity, BingeEatingConfigEntity, QSortThenBy> {
  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      thenByAppLockCooldownMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appLockCooldownMinutes', Sort.asc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      thenByAppLockCooldownMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appLockCooldownMinutes', Sort.desc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      thenByAppLockMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appLockMessage', Sort.asc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      thenByAppLockMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appLockMessage', Sort.desc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      thenByAppLockRequirePassword() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appLockRequirePassword', Sort.asc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      thenByAppLockRequirePasswordDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appLockRequirePassword', Sort.desc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      thenByBlockReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockReason', Sort.asc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      thenByBlockReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockReason', Sort.desc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      thenByBlockedUntil() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockedUntil', Sort.asc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      thenByBlockedUntilDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockedUntil', Sort.desc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      thenByDailyLimitMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyLimitMinutes', Sort.asc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      thenByDailyLimitMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyLimitMinutes', Sort.desc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      thenByEnableAppLock() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableAppLock', Sort.asc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      thenByEnableAppLockDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableAppLock', Sort.desc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      thenByEnableNotifications() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableNotifications', Sort.asc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      thenByEnableNotificationsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableNotifications', Sort.desc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      thenByIsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEnabled', Sort.asc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      thenByIsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEnabled', Sort.desc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      thenByReminderHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderHour', Sort.asc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      thenByReminderHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderHour', Sort.desc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      thenByReminderMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderMinute', Sort.asc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      thenByReminderMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderMinute', Sort.desc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      thenByRequirePassword() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requirePassword', Sort.asc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      thenByRequirePasswordDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requirePassword', Sort.desc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension BingeEatingConfigEntityQueryWhereDistinct on QueryBuilder<
    BingeEatingConfigEntity, BingeEatingConfigEntity, QDistinct> {
  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QDistinct>
      distinctByAppLockCooldownMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'appLockCooldownMinutes');
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QDistinct>
      distinctByAppLockMessage({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'appLockMessage',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QDistinct>
      distinctByAppLockRequirePassword() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'appLockRequirePassword');
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QDistinct>
      distinctByBlockReason({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'blockReason', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QDistinct>
      distinctByBlockedUntil() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'blockedUntil');
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QDistinct>
      distinctByCopingStrategies() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'copingStrategies');
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QDistinct>
      distinctByDailyLimitMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dailyLimitMinutes');
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QDistinct>
      distinctByEnableAppLock() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enableAppLock');
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QDistinct>
      distinctByEnableNotifications() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enableNotifications');
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QDistinct>
      distinctByIsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isEnabled');
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QDistinct>
      distinctByMonitoredApps() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'monitoredApps');
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QDistinct>
      distinctByReminderHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reminderHour');
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QDistinct>
      distinctByReminderMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reminderMinute');
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QDistinct>
      distinctByRequirePassword() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'requirePassword');
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QDistinct>
      distinctByTriggerFoods() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'triggerFoods');
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<BingeEatingConfigEntity, BingeEatingConfigEntity, QDistinct>
      distinctByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension BingeEatingConfigEntityQueryProperty on QueryBuilder<
    BingeEatingConfigEntity, BingeEatingConfigEntity, QQueryProperty> {
  QueryBuilder<BingeEatingConfigEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BingeEatingConfigEntity, int, QQueryOperations>
      appLockCooldownMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'appLockCooldownMinutes');
    });
  }

  QueryBuilder<BingeEatingConfigEntity, String, QQueryOperations>
      appLockMessageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'appLockMessage');
    });
  }

  QueryBuilder<BingeEatingConfigEntity, bool, QQueryOperations>
      appLockRequirePasswordProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'appLockRequirePassword');
    });
  }

  QueryBuilder<BingeEatingConfigEntity, String?, QQueryOperations>
      blockReasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'blockReason');
    });
  }

  QueryBuilder<BingeEatingConfigEntity, DateTime?, QQueryOperations>
      blockedUntilProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'blockedUntil');
    });
  }

  QueryBuilder<BingeEatingConfigEntity, List<String>, QQueryOperations>
      copingStrategiesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'copingStrategies');
    });
  }

  QueryBuilder<BingeEatingConfigEntity, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<BingeEatingConfigEntity, int, QQueryOperations>
      dailyLimitMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dailyLimitMinutes');
    });
  }

  QueryBuilder<BingeEatingConfigEntity, bool, QQueryOperations>
      enableAppLockProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enableAppLock');
    });
  }

  QueryBuilder<BingeEatingConfigEntity, bool, QQueryOperations>
      enableNotificationsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enableNotifications');
    });
  }

  QueryBuilder<BingeEatingConfigEntity, bool, QQueryOperations>
      isEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isEnabled');
    });
  }

  QueryBuilder<BingeEatingConfigEntity, List<String>, QQueryOperations>
      monitoredAppsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'monitoredApps');
    });
  }

  QueryBuilder<BingeEatingConfigEntity, int, QQueryOperations>
      reminderHourProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reminderHour');
    });
  }

  QueryBuilder<BingeEatingConfigEntity, int, QQueryOperations>
      reminderMinuteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reminderMinute');
    });
  }

  QueryBuilder<BingeEatingConfigEntity, bool, QQueryOperations>
      requirePasswordProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'requirePassword');
    });
  }

  QueryBuilder<BingeEatingConfigEntity, List<String>, QQueryOperations>
      triggerFoodsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'triggerFoods');
    });
  }

  QueryBuilder<BingeEatingConfigEntity, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<BingeEatingConfigEntity, String, QQueryOperations>
      userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}
