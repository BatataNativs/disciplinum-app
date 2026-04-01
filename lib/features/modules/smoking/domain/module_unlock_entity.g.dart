// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'module_unlock_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetModuleUnlockEntityCollection on Isar {
  IsarCollection<ModuleUnlockEntity> get moduleUnlockEntitys =>
      this.collection();
}

const ModuleUnlockEntitySchema = CollectionSchema(
  name: r'ModuleUnlockEntity',
  id: -3450260150605970115,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'isUnlocked': PropertySchema(
      id: 1,
      name: r'isUnlocked',
      type: IsarType.bool,
    ),
    r'moduleId': PropertySchema(
      id: 2,
      name: r'moduleId',
      type: IsarType.string,
    ),
    r'unlockMethod': PropertySchema(
      id: 3,
      name: r'unlockMethod',
      type: IsarType.string,
    ),
    r'unlockType': PropertySchema(
      id: 4,
      name: r'unlockType',
      type: IsarType.string,
    ),
    r'unlockedAt': PropertySchema(
      id: 5,
      name: r'unlockedAt',
      type: IsarType.dateTime,
    ),
    r'updatedAt': PropertySchema(
      id: 6,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _moduleUnlockEntityEstimateSize,
  serialize: _moduleUnlockEntitySerialize,
  deserialize: _moduleUnlockEntityDeserialize,
  deserializeProp: _moduleUnlockEntityDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _moduleUnlockEntityGetId,
  getLinks: _moduleUnlockEntityGetLinks,
  attach: _moduleUnlockEntityAttach,
  version: '3.1.0+1',
);

int _moduleUnlockEntityEstimateSize(
  ModuleUnlockEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.moduleId.length * 3;
  {
    final value = object.unlockMethod;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.unlockType.length * 3;
  return bytesCount;
}

void _moduleUnlockEntitySerialize(
  ModuleUnlockEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeBool(offsets[1], object.isUnlocked);
  writer.writeString(offsets[2], object.moduleId);
  writer.writeString(offsets[3], object.unlockMethod);
  writer.writeString(offsets[4], object.unlockType);
  writer.writeDateTime(offsets[5], object.unlockedAt);
  writer.writeDateTime(offsets[6], object.updatedAt);
}

ModuleUnlockEntity _moduleUnlockEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ModuleUnlockEntity(
    isUnlocked: reader.readBoolOrNull(offsets[1]) ?? false,
    moduleId: reader.readString(offsets[2]),
    unlockMethod: reader.readStringOrNull(offsets[3]),
    unlockType: reader.readString(offsets[4]),
    unlockedAt: reader.readDateTimeOrNull(offsets[5]),
  );
  object.createdAt = reader.readDateTime(offsets[0]);
  object.id = id;
  object.updatedAt = reader.readDateTime(offsets[6]);
  return object;
}

P _moduleUnlockEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _moduleUnlockEntityGetId(ModuleUnlockEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _moduleUnlockEntityGetLinks(
    ModuleUnlockEntity object) {
  return [];
}

void _moduleUnlockEntityAttach(
    IsarCollection<dynamic> col, Id id, ModuleUnlockEntity object) {
  object.id = id;
}

extension ModuleUnlockEntityQueryWhereSort
    on QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QWhere> {
  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ModuleUnlockEntityQueryWhere
    on QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QWhereClause> {
  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterWhereClause>
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

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterWhereClause>
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
}

extension ModuleUnlockEntityQueryFilter
    on QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QFilterCondition> {
  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
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

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
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

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
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

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
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

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
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

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
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

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
      isUnlockedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isUnlocked',
        value: value,
      ));
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
      moduleIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'moduleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
      moduleIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'moduleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
      moduleIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'moduleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
      moduleIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'moduleId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
      moduleIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'moduleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
      moduleIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'moduleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
      moduleIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'moduleId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
      moduleIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'moduleId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
      moduleIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'moduleId',
        value: '',
      ));
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
      moduleIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'moduleId',
        value: '',
      ));
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
      unlockMethodIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'unlockMethod',
      ));
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
      unlockMethodIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'unlockMethod',
      ));
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
      unlockMethodEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unlockMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
      unlockMethodGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unlockMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
      unlockMethodLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unlockMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
      unlockMethodBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unlockMethod',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
      unlockMethodStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'unlockMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
      unlockMethodEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'unlockMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
      unlockMethodContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'unlockMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
      unlockMethodMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'unlockMethod',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
      unlockMethodIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unlockMethod',
        value: '',
      ));
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
      unlockMethodIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'unlockMethod',
        value: '',
      ));
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
      unlockTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unlockType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
      unlockTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unlockType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
      unlockTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unlockType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
      unlockTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unlockType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
      unlockTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'unlockType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
      unlockTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'unlockType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
      unlockTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'unlockType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
      unlockTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'unlockType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
      unlockTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unlockType',
        value: '',
      ));
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
      unlockTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'unlockType',
        value: '',
      ));
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
      unlockedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'unlockedAt',
      ));
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
      unlockedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'unlockedAt',
      ));
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
      unlockedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unlockedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
      unlockedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unlockedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
      unlockedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unlockedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
      unlockedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unlockedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
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

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
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

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterFilterCondition>
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
}

extension ModuleUnlockEntityQueryObject
    on QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QFilterCondition> {}

extension ModuleUnlockEntityQueryLinks
    on QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QFilterCondition> {}

extension ModuleUnlockEntityQuerySortBy
    on QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QSortBy> {
  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterSortBy>
      sortByIsUnlocked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isUnlocked', Sort.asc);
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterSortBy>
      sortByIsUnlockedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isUnlocked', Sort.desc);
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterSortBy>
      sortByModuleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moduleId', Sort.asc);
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterSortBy>
      sortByModuleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moduleId', Sort.desc);
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterSortBy>
      sortByUnlockMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockMethod', Sort.asc);
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterSortBy>
      sortByUnlockMethodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockMethod', Sort.desc);
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterSortBy>
      sortByUnlockType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockType', Sort.asc);
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterSortBy>
      sortByUnlockTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockType', Sort.desc);
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterSortBy>
      sortByUnlockedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockedAt', Sort.asc);
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterSortBy>
      sortByUnlockedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockedAt', Sort.desc);
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension ModuleUnlockEntityQuerySortThenBy
    on QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QSortThenBy> {
  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterSortBy>
      thenByIsUnlocked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isUnlocked', Sort.asc);
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterSortBy>
      thenByIsUnlockedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isUnlocked', Sort.desc);
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterSortBy>
      thenByModuleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moduleId', Sort.asc);
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterSortBy>
      thenByModuleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moduleId', Sort.desc);
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterSortBy>
      thenByUnlockMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockMethod', Sort.asc);
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterSortBy>
      thenByUnlockMethodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockMethod', Sort.desc);
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterSortBy>
      thenByUnlockType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockType', Sort.asc);
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterSortBy>
      thenByUnlockTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockType', Sort.desc);
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterSortBy>
      thenByUnlockedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockedAt', Sort.asc);
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterSortBy>
      thenByUnlockedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockedAt', Sort.desc);
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension ModuleUnlockEntityQueryWhereDistinct
    on QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QDistinct> {
  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QDistinct>
      distinctByIsUnlocked() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isUnlocked');
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QDistinct>
      distinctByModuleId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'moduleId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QDistinct>
      distinctByUnlockMethod({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unlockMethod', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QDistinct>
      distinctByUnlockType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unlockType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QDistinct>
      distinctByUnlockedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unlockedAt');
    });
  }

  QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension ModuleUnlockEntityQueryProperty
    on QueryBuilder<ModuleUnlockEntity, ModuleUnlockEntity, QQueryProperty> {
  QueryBuilder<ModuleUnlockEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ModuleUnlockEntity, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<ModuleUnlockEntity, bool, QQueryOperations>
      isUnlockedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isUnlocked');
    });
  }

  QueryBuilder<ModuleUnlockEntity, String, QQueryOperations>
      moduleIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'moduleId');
    });
  }

  QueryBuilder<ModuleUnlockEntity, String?, QQueryOperations>
      unlockMethodProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unlockMethod');
    });
  }

  QueryBuilder<ModuleUnlockEntity, String, QQueryOperations>
      unlockTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unlockType');
    });
  }

  QueryBuilder<ModuleUnlockEntity, DateTime?, QQueryOperations>
      unlockedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unlockedAt');
    });
  }

  QueryBuilder<ModuleUnlockEntity, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
