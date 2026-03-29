// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adult_content_config_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAdultContentConfigEntityCollection on Isar {
  IsarCollection<AdultContentConfigEntity> get adultContentConfigEntitys =>
      this.collection();
}

const AdultContentConfigEntitySchema = CollectionSchema(
  name: r'AdultContentConfigEntity',
  id: -7775751516946011271,
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
    r'createdAt': PropertySchema(
      id: 5,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'dailyLimitMinutes': PropertySchema(
      id: 6,
      name: r'dailyLimitMinutes',
      type: IsarType.long,
    ),
    r'enableAppLock': PropertySchema(
      id: 7,
      name: r'enableAppLock',
      type: IsarType.bool,
    ),
    r'isEnabled': PropertySchema(
      id: 8,
      name: r'isEnabled',
      type: IsarType.bool,
    ),
    r'monitoredApps': PropertySchema(
      id: 9,
      name: r'monitoredApps',
      type: IsarType.stringList,
    ),
    r'requirePassword': PropertySchema(
      id: 10,
      name: r'requirePassword',
      type: IsarType.bool,
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
  estimateSize: _adultContentConfigEntityEstimateSize,
  serialize: _adultContentConfigEntitySerialize,
  deserialize: _adultContentConfigEntityDeserialize,
  deserializeProp: _adultContentConfigEntityDeserializeProp,
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
  getId: _adultContentConfigEntityGetId,
  getLinks: _adultContentConfigEntityGetLinks,
  attach: _adultContentConfigEntityAttach,
  version: '3.1.0+1',
);

int _adultContentConfigEntityEstimateSize(
  AdultContentConfigEntity object,
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
  bytesCount += 3 + object.monitoredApps.length * 3;
  {
    for (var i = 0; i < object.monitoredApps.length; i++) {
      final value = object.monitoredApps[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _adultContentConfigEntitySerialize(
  AdultContentConfigEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.appLockCooldownMinutes);
  writer.writeString(offsets[1], object.appLockMessage);
  writer.writeBool(offsets[2], object.appLockRequirePassword);
  writer.writeString(offsets[3], object.blockReason);
  writer.writeDateTime(offsets[4], object.blockedUntil);
  writer.writeDateTime(offsets[5], object.createdAt);
  writer.writeLong(offsets[6], object.dailyLimitMinutes);
  writer.writeBool(offsets[7], object.enableAppLock);
  writer.writeBool(offsets[8], object.isEnabled);
  writer.writeStringList(offsets[9], object.monitoredApps);
  writer.writeBool(offsets[10], object.requirePassword);
  writer.writeDateTime(offsets[11], object.updatedAt);
  writer.writeString(offsets[12], object.userId);
}

AdultContentConfigEntity _adultContentConfigEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AdultContentConfigEntity(
    userId: reader.readString(offsets[12]),
  );
  object.appLockCooldownMinutes = reader.readLong(offsets[0]);
  object.appLockMessage = reader.readString(offsets[1]);
  object.appLockRequirePassword = reader.readBool(offsets[2]);
  object.blockReason = reader.readStringOrNull(offsets[3]);
  object.blockedUntil = reader.readDateTimeOrNull(offsets[4]);
  object.createdAt = reader.readDateTime(offsets[5]);
  object.dailyLimitMinutes = reader.readLong(offsets[6]);
  object.enableAppLock = reader.readBool(offsets[7]);
  object.id = id;
  object.isEnabled = reader.readBool(offsets[8]);
  object.monitoredApps = reader.readStringList(offsets[9]) ?? [];
  object.requirePassword = reader.readBool(offsets[10]);
  object.updatedAt = reader.readDateTime(offsets[11]);
  return object;
}

P _adultContentConfigEntityDeserializeProp<P>(
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
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readStringList(offset) ?? []) as P;
    case 10:
      return (reader.readBool(offset)) as P;
    case 11:
      return (reader.readDateTime(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _adultContentConfigEntityGetId(AdultContentConfigEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _adultContentConfigEntityGetLinks(
    AdultContentConfigEntity object) {
  return [];
}

void _adultContentConfigEntityAttach(
    IsarCollection<dynamic> col, Id id, AdultContentConfigEntity object) {
  object.id = id;
}

extension AdultContentConfigEntityByIndex
    on IsarCollection<AdultContentConfigEntity> {
  Future<AdultContentConfigEntity?> getByUserId(String userId) {
    return getByIndex(r'userId', [userId]);
  }

  AdultContentConfigEntity? getByUserIdSync(String userId) {
    return getByIndexSync(r'userId', [userId]);
  }

  Future<bool> deleteByUserId(String userId) {
    return deleteByIndex(r'userId', [userId]);
  }

  bool deleteByUserIdSync(String userId) {
    return deleteByIndexSync(r'userId', [userId]);
  }

  Future<List<AdultContentConfigEntity?>> getAllByUserId(
      List<String> userIdValues) {
    final values = userIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'userId', values);
  }

  List<AdultContentConfigEntity?> getAllByUserIdSync(
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

  Future<Id> putByUserId(AdultContentConfigEntity object) {
    return putByIndex(r'userId', object);
  }

  Id putByUserIdSync(AdultContentConfigEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'userId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUserId(List<AdultContentConfigEntity> objects) {
    return putAllByIndex(r'userId', objects);
  }

  List<Id> putAllByUserIdSync(List<AdultContentConfigEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'userId', objects, saveLinks: saveLinks);
  }
}

extension AdultContentConfigEntityQueryWhereSort on QueryBuilder<
    AdultContentConfigEntity, AdultContentConfigEntity, QWhere> {
  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AdultContentConfigEntityQueryWhere on QueryBuilder<
    AdultContentConfigEntity, AdultContentConfigEntity, QWhereClause> {
  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
      QAfterWhereClause> userIdEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

extension AdultContentConfigEntityQueryFilter on QueryBuilder<
    AdultContentConfigEntity, AdultContentConfigEntity, QFilterCondition> {
  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
      QAfterFilterCondition> appLockCooldownMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'appLockCooldownMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
      QAfterFilterCondition> appLockMessageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'appLockMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
      QAfterFilterCondition> appLockMessageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'appLockMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
      QAfterFilterCondition> appLockRequirePasswordEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'appLockRequirePassword',
        value: value,
      ));
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
      QAfterFilterCondition> blockReasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'blockReason',
      ));
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
      QAfterFilterCondition> blockReasonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'blockReason',
      ));
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
      QAfterFilterCondition> blockReasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'blockReason',
        value: '',
      ));
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
      QAfterFilterCondition> blockReasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'blockReason',
        value: '',
      ));
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
      QAfterFilterCondition> blockedUntilIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'blockedUntil',
      ));
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
      QAfterFilterCondition> blockedUntilIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'blockedUntil',
      ));
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
      QAfterFilterCondition> blockedUntilEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'blockedUntil',
        value: value,
      ));
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
      QAfterFilterCondition> dailyLimitMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dailyLimitMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
      QAfterFilterCondition> enableAppLockEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enableAppLock',
        value: value,
      ));
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
      QAfterFilterCondition> isEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
      QAfterFilterCondition> monitoredAppsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'monitoredApps',
        value: '',
      ));
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
      QAfterFilterCondition> monitoredAppsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'monitoredApps',
        value: '',
      ));
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
      QAfterFilterCondition> requirePasswordEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'requirePassword',
        value: value,
      ));
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
      QAfterFilterCondition> updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
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

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
      QAfterFilterCondition> userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity,
      QAfterFilterCondition> userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension AdultContentConfigEntityQueryObject on QueryBuilder<
    AdultContentConfigEntity, AdultContentConfigEntity, QFilterCondition> {}

extension AdultContentConfigEntityQueryLinks on QueryBuilder<
    AdultContentConfigEntity, AdultContentConfigEntity, QFilterCondition> {}

extension AdultContentConfigEntityQuerySortBy on QueryBuilder<
    AdultContentConfigEntity, AdultContentConfigEntity, QSortBy> {
  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      sortByAppLockCooldownMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appLockCooldownMinutes', Sort.asc);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      sortByAppLockCooldownMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appLockCooldownMinutes', Sort.desc);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      sortByAppLockMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appLockMessage', Sort.asc);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      sortByAppLockMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appLockMessage', Sort.desc);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      sortByAppLockRequirePassword() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appLockRequirePassword', Sort.asc);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      sortByAppLockRequirePasswordDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appLockRequirePassword', Sort.desc);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      sortByBlockReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockReason', Sort.asc);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      sortByBlockReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockReason', Sort.desc);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      sortByBlockedUntil() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockedUntil', Sort.asc);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      sortByBlockedUntilDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockedUntil', Sort.desc);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      sortByDailyLimitMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyLimitMinutes', Sort.asc);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      sortByDailyLimitMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyLimitMinutes', Sort.desc);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      sortByEnableAppLock() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableAppLock', Sort.asc);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      sortByEnableAppLockDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableAppLock', Sort.desc);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      sortByIsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEnabled', Sort.asc);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      sortByIsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEnabled', Sort.desc);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      sortByRequirePassword() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requirePassword', Sort.asc);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      sortByRequirePasswordDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requirePassword', Sort.desc);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension AdultContentConfigEntityQuerySortThenBy on QueryBuilder<
    AdultContentConfigEntity, AdultContentConfigEntity, QSortThenBy> {
  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      thenByAppLockCooldownMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appLockCooldownMinutes', Sort.asc);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      thenByAppLockCooldownMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appLockCooldownMinutes', Sort.desc);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      thenByAppLockMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appLockMessage', Sort.asc);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      thenByAppLockMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appLockMessage', Sort.desc);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      thenByAppLockRequirePassword() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appLockRequirePassword', Sort.asc);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      thenByAppLockRequirePasswordDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appLockRequirePassword', Sort.desc);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      thenByBlockReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockReason', Sort.asc);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      thenByBlockReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockReason', Sort.desc);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      thenByBlockedUntil() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockedUntil', Sort.asc);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      thenByBlockedUntilDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockedUntil', Sort.desc);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      thenByDailyLimitMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyLimitMinutes', Sort.asc);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      thenByDailyLimitMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyLimitMinutes', Sort.desc);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      thenByEnableAppLock() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableAppLock', Sort.asc);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      thenByEnableAppLockDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enableAppLock', Sort.desc);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      thenByIsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEnabled', Sort.asc);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      thenByIsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEnabled', Sort.desc);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      thenByRequirePassword() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requirePassword', Sort.asc);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      thenByRequirePasswordDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requirePassword', Sort.desc);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension AdultContentConfigEntityQueryWhereDistinct on QueryBuilder<
    AdultContentConfigEntity, AdultContentConfigEntity, QDistinct> {
  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QDistinct>
      distinctByAppLockCooldownMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'appLockCooldownMinutes');
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QDistinct>
      distinctByAppLockMessage({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'appLockMessage',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QDistinct>
      distinctByAppLockRequirePassword() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'appLockRequirePassword');
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QDistinct>
      distinctByBlockReason({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'blockReason', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QDistinct>
      distinctByBlockedUntil() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'blockedUntil');
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QDistinct>
      distinctByDailyLimitMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dailyLimitMinutes');
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QDistinct>
      distinctByEnableAppLock() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enableAppLock');
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QDistinct>
      distinctByIsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isEnabled');
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QDistinct>
      distinctByMonitoredApps() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'monitoredApps');
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QDistinct>
      distinctByRequirePassword() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'requirePassword');
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<AdultContentConfigEntity, AdultContentConfigEntity, QDistinct>
      distinctByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension AdultContentConfigEntityQueryProperty on QueryBuilder<
    AdultContentConfigEntity, AdultContentConfigEntity, QQueryProperty> {
  QueryBuilder<AdultContentConfigEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AdultContentConfigEntity, int, QQueryOperations>
      appLockCooldownMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'appLockCooldownMinutes');
    });
  }

  QueryBuilder<AdultContentConfigEntity, String, QQueryOperations>
      appLockMessageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'appLockMessage');
    });
  }

  QueryBuilder<AdultContentConfigEntity, bool, QQueryOperations>
      appLockRequirePasswordProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'appLockRequirePassword');
    });
  }

  QueryBuilder<AdultContentConfigEntity, String?, QQueryOperations>
      blockReasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'blockReason');
    });
  }

  QueryBuilder<AdultContentConfigEntity, DateTime?, QQueryOperations>
      blockedUntilProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'blockedUntil');
    });
  }

  QueryBuilder<AdultContentConfigEntity, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<AdultContentConfigEntity, int, QQueryOperations>
      dailyLimitMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dailyLimitMinutes');
    });
  }

  QueryBuilder<AdultContentConfigEntity, bool, QQueryOperations>
      enableAppLockProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enableAppLock');
    });
  }

  QueryBuilder<AdultContentConfigEntity, bool, QQueryOperations>
      isEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isEnabled');
    });
  }

  QueryBuilder<AdultContentConfigEntity, List<String>, QQueryOperations>
      monitoredAppsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'monitoredApps');
    });
  }

  QueryBuilder<AdultContentConfigEntity, bool, QQueryOperations>
      requirePasswordProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'requirePassword');
    });
  }

  QueryBuilder<AdultContentConfigEntity, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<AdultContentConfigEntity, String, QQueryOperations>
      userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}
