// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_module_state.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUserModuleStateCollection on Isar {
  IsarCollection<UserModuleState> get userModuleStates => this.collection();
}

const UserModuleStateSchema = CollectionSchema(
  name: r'UserModuleState',
  id: -5613929950737411987,
  properties: {
    r'additionalData': PropertySchema(
      id: 0,
      name: r'additionalData',
      type: IsarType.string,
    ),
    r'consecutiveDays': PropertySchema(
      id: 1,
      name: r'consecutiveDays',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'focusPeriodsRespected': PropertySchema(
      id: 3,
      name: r'focusPeriodsRespected',
      type: IsarType.long,
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
    r'lastAccessDate': PropertySchema(
      id: 6,
      name: r'lastAccessDate',
      type: IsarType.dateTime,
    ),
    r'maxMedal': PropertySchema(
      id: 7,
      name: r'maxMedal',
      type: IsarType.string,
    ),
    r'niche': PropertySchema(
      id: 8,
      name: r'niche',
      type: IsarType.byte,
      enumMap: _UserModuleStatenicheEnumValueMap,
    ),
    r'nicheId': PropertySchema(
      id: 9,
      name: r'nicheId',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 10,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'userId': PropertySchema(
      id: 11,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _userModuleStateEstimateSize,
  serialize: _userModuleStateSerialize,
  deserialize: _userModuleStateDeserialize,
  deserializeProp: _userModuleStateDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _userModuleStateGetId,
  getLinks: _userModuleStateGetLinks,
  attach: _userModuleStateAttach,
  version: '3.1.0+1',
);

int _userModuleStateEstimateSize(
  UserModuleState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.additionalData;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.maxMedal;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _userModuleStateSerialize(
  UserModuleState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.additionalData);
  writer.writeLong(offsets[1], object.consecutiveDays);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeLong(offsets[3], object.focusPeriodsRespected);
  writer.writeLong(offsets[4], object.hashCode);
  writer.writeBool(offsets[5], object.isActive);
  writer.writeDateTime(offsets[6], object.lastAccessDate);
  writer.writeString(offsets[7], object.maxMedal);
  writer.writeByte(offsets[8], object.niche.index);
  writer.writeLong(offsets[9], object.nicheId);
  writer.writeDateTime(offsets[10], object.updatedAt);
  writer.writeString(offsets[11], object.userId);
}

UserModuleState _userModuleStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserModuleState(
    additionalData: reader.readStringOrNull(offsets[0]),
    consecutiveDays: reader.readLong(offsets[1]),
    createdAt: reader.readDateTime(offsets[2]),
    focusPeriodsRespected: reader.readLongOrNull(offsets[3]) ?? 0,
    isActive: reader.readBool(offsets[5]),
    lastAccessDate: reader.readDateTime(offsets[6]),
    maxMedal: reader.readStringOrNull(offsets[7]),
    nicheId: reader.readLong(offsets[9]),
    updatedAt: reader.readDateTime(offsets[10]),
    userId: reader.readString(offsets[11]),
  );
  object.id = id;
  return object;
}

P _userModuleStateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (_UserModuleStatenicheValueEnumMap[
              reader.readByteOrNull(offset)] ??
          NicheId.smoking) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readDateTime(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _UserModuleStatenicheEnumValueMap = {
  'smoking': 0,
  'bingeEating': 1,
  'diet': 2,
  'spending': 3,
  'focus': 4,
  'adultContent': 5,
  'moneySavingChallenge': 6,
  'procrastination': 7,
  'reading': 8,
};
const _UserModuleStatenicheValueEnumMap = {
  0: NicheId.smoking,
  1: NicheId.bingeEating,
  2: NicheId.diet,
  3: NicheId.spending,
  4: NicheId.focus,
  5: NicheId.adultContent,
  6: NicheId.moneySavingChallenge,
  7: NicheId.procrastination,
  8: NicheId.reading,
};

Id _userModuleStateGetId(UserModuleState object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _userModuleStateGetLinks(UserModuleState object) {
  return [];
}

void _userModuleStateAttach(
    IsarCollection<dynamic> col, Id id, UserModuleState object) {
  object.id = id;
}

extension UserModuleStateQueryWhereSort
    on QueryBuilder<UserModuleState, UserModuleState, QWhere> {
  QueryBuilder<UserModuleState, UserModuleState, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UserModuleStateQueryWhere
    on QueryBuilder<UserModuleState, UserModuleState, QWhereClause> {
  QueryBuilder<UserModuleState, UserModuleState, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterWhereClause>
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

  QueryBuilder<UserModuleState, UserModuleState, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterWhereClause> idBetween(
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

extension UserModuleStateQueryFilter
    on QueryBuilder<UserModuleState, UserModuleState, QFilterCondition> {
  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      additionalDataIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'additionalData',
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      additionalDataIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'additionalData',
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      additionalDataEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'additionalData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      additionalDataGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'additionalData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      additionalDataLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'additionalData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      additionalDataBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'additionalData',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      additionalDataStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'additionalData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      additionalDataEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'additionalData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      additionalDataContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'additionalData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      additionalDataMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'additionalData',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      additionalDataIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'additionalData',
        value: '',
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      additionalDataIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'additionalData',
        value: '',
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      consecutiveDaysEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'consecutiveDays',
        value: value,
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      consecutiveDaysGreaterThan(
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

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      consecutiveDaysLessThan(
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

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      consecutiveDaysBetween(
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

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
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

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
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

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
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

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      focusPeriodsRespectedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'focusPeriodsRespected',
        value: value,
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      focusPeriodsRespectedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'focusPeriodsRespected',
        value: value,
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      focusPeriodsRespectedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'focusPeriodsRespected',
        value: value,
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      focusPeriodsRespectedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'focusPeriodsRespected',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      hashCodeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      hashCodeGreaterThan(
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

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      hashCodeLessThan(
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

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      hashCodeBetween(
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

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
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

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
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

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
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

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      isActiveEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isActive',
        value: value,
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      lastAccessDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastAccessDate',
        value: value,
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      lastAccessDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastAccessDate',
        value: value,
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      lastAccessDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastAccessDate',
        value: value,
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      lastAccessDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastAccessDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      maxMedalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'maxMedal',
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      maxMedalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'maxMedal',
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      maxMedalEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maxMedal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      maxMedalGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maxMedal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      maxMedalLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maxMedal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      maxMedalBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maxMedal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      maxMedalStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'maxMedal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      maxMedalEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'maxMedal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      maxMedalContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'maxMedal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      maxMedalMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'maxMedal',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      maxMedalIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maxMedal',
        value: '',
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      maxMedalIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'maxMedal',
        value: '',
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      nicheEqualTo(NicheId value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'niche',
        value: value,
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      nicheGreaterThan(
    NicheId value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'niche',
        value: value,
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      nicheLessThan(
    NicheId value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'niche',
        value: value,
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      nicheBetween(
    NicheId lower,
    NicheId upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'niche',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      nicheIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nicheId',
        value: value,
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      nicheIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nicheId',
        value: value,
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      nicheIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nicheId',
        value: value,
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      nicheIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nicheId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
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

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
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

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
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

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
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

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
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

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
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

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
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

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
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

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
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

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterFilterCondition>
      userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension UserModuleStateQueryObject
    on QueryBuilder<UserModuleState, UserModuleState, QFilterCondition> {}

extension UserModuleStateQueryLinks
    on QueryBuilder<UserModuleState, UserModuleState, QFilterCondition> {}

extension UserModuleStateQuerySortBy
    on QueryBuilder<UserModuleState, UserModuleState, QSortBy> {
  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy>
      sortByAdditionalData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'additionalData', Sort.asc);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy>
      sortByAdditionalDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'additionalData', Sort.desc);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy>
      sortByConsecutiveDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consecutiveDays', Sort.asc);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy>
      sortByConsecutiveDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consecutiveDays', Sort.desc);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy>
      sortByFocusPeriodsRespected() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'focusPeriodsRespected', Sort.asc);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy>
      sortByFocusPeriodsRespectedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'focusPeriodsRespected', Sort.desc);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy>
      sortByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy>
      sortByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy>
      sortByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy>
      sortByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy>
      sortByLastAccessDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAccessDate', Sort.asc);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy>
      sortByLastAccessDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAccessDate', Sort.desc);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy>
      sortByMaxMedal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxMedal', Sort.asc);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy>
      sortByMaxMedalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxMedal', Sort.desc);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy> sortByNiche() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'niche', Sort.asc);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy>
      sortByNicheDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'niche', Sort.desc);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy> sortByNicheId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nicheId', Sort.asc);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy>
      sortByNicheIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nicheId', Sort.desc);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension UserModuleStateQuerySortThenBy
    on QueryBuilder<UserModuleState, UserModuleState, QSortThenBy> {
  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy>
      thenByAdditionalData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'additionalData', Sort.asc);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy>
      thenByAdditionalDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'additionalData', Sort.desc);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy>
      thenByConsecutiveDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consecutiveDays', Sort.asc);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy>
      thenByConsecutiveDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consecutiveDays', Sort.desc);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy>
      thenByFocusPeriodsRespected() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'focusPeriodsRespected', Sort.asc);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy>
      thenByFocusPeriodsRespectedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'focusPeriodsRespected', Sort.desc);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy>
      thenByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy>
      thenByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy>
      thenByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy>
      thenByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy>
      thenByLastAccessDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAccessDate', Sort.asc);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy>
      thenByLastAccessDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAccessDate', Sort.desc);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy>
      thenByMaxMedal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxMedal', Sort.asc);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy>
      thenByMaxMedalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxMedal', Sort.desc);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy> thenByNiche() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'niche', Sort.asc);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy>
      thenByNicheDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'niche', Sort.desc);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy> thenByNicheId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nicheId', Sort.asc);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy>
      thenByNicheIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nicheId', Sort.desc);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension UserModuleStateQueryWhereDistinct
    on QueryBuilder<UserModuleState, UserModuleState, QDistinct> {
  QueryBuilder<UserModuleState, UserModuleState, QDistinct>
      distinctByAdditionalData({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'additionalData',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QDistinct>
      distinctByConsecutiveDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'consecutiveDays');
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QDistinct>
      distinctByFocusPeriodsRespected() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'focusPeriodsRespected');
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QDistinct>
      distinctByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hashCode');
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QDistinct>
      distinctByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isActive');
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QDistinct>
      distinctByLastAccessDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastAccessDate');
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QDistinct> distinctByMaxMedal(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxMedal', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QDistinct> distinctByNiche() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'niche');
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QDistinct>
      distinctByNicheId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nicheId');
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<UserModuleState, UserModuleState, QDistinct> distinctByUserId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension UserModuleStateQueryProperty
    on QueryBuilder<UserModuleState, UserModuleState, QQueryProperty> {
  QueryBuilder<UserModuleState, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UserModuleState, String?, QQueryOperations>
      additionalDataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'additionalData');
    });
  }

  QueryBuilder<UserModuleState, int, QQueryOperations>
      consecutiveDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'consecutiveDays');
    });
  }

  QueryBuilder<UserModuleState, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<UserModuleState, int, QQueryOperations>
      focusPeriodsRespectedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'focusPeriodsRespected');
    });
  }

  QueryBuilder<UserModuleState, int, QQueryOperations> hashCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hashCode');
    });
  }

  QueryBuilder<UserModuleState, bool, QQueryOperations> isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isActive');
    });
  }

  QueryBuilder<UserModuleState, DateTime, QQueryOperations>
      lastAccessDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastAccessDate');
    });
  }

  QueryBuilder<UserModuleState, String?, QQueryOperations> maxMedalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxMedal');
    });
  }

  QueryBuilder<UserModuleState, NicheId, QQueryOperations> nicheProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'niche');
    });
  }

  QueryBuilder<UserModuleState, int, QQueryOperations> nicheIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nicheId');
    });
  }

  QueryBuilder<UserModuleState, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<UserModuleState, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}
