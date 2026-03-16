// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monitoring_state_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMonitoringStateCollection on Isar {
  IsarCollection<MonitoringState> get monitoringStates => this.collection();
}

const MonitoringStateSchema = CollectionSchema(
  name: r'MonitoringState',
  id: 497767931457432119,
  properties: {
    r'activeNicheId': PropertySchema(
      id: 0,
      name: r'activeNicheId',
      type: IsarType.byte,
      enumMap: _MonitoringStateactiveNicheIdEnumValueMap,
    ),
    r'isMonitoringActive': PropertySchema(
      id: 1,
      name: r'isMonitoringActive',
      type: IsarType.bool,
    ),
    r'isStale': PropertySchema(
      id: 2,
      name: r'isStale',
      type: IsarType.bool,
    ),
    r'lastHeartbeat': PropertySchema(
      id: 3,
      name: r'lastHeartbeat',
      type: IsarType.dateTime,
    ),
    r'lastViolationTime': PropertySchema(
      id: 4,
      name: r'lastViolationTime',
      type: IsarType.dateTime,
    ),
    r'monitoredApps': PropertySchema(
      id: 5,
      name: r'monitoredApps',
      type: IsarType.stringList,
    ),
    r'monitoringStartTime': PropertySchema(
      id: 6,
      name: r'monitoringStartTime',
      type: IsarType.dateTime,
    ),
    r'violationCount': PropertySchema(
      id: 7,
      name: r'violationCount',
      type: IsarType.long,
    )
  },
  estimateSize: _monitoringStateEstimateSize,
  serialize: _monitoringStateSerialize,
  deserialize: _monitoringStateDeserialize,
  deserializeProp: _monitoringStateDeserializeProp,
  idName: r'id',
  indexes: {
    r'activeNicheId': IndexSchema(
      id: 3982573554326231931,
      name: r'activeNicheId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'activeNicheId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'isMonitoringActive': IndexSchema(
      id: -1141587199569236876,
      name: r'isMonitoringActive',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isMonitoringActive',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _monitoringStateGetId,
  getLinks: _monitoringStateGetLinks,
  attach: _monitoringStateAttach,
  version: '3.1.0+1',
);

int _monitoringStateEstimateSize(
  MonitoringState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.monitoredApps.length * 3;
  {
    for (var i = 0; i < object.monitoredApps.length; i++) {
      final value = object.monitoredApps[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _monitoringStateSerialize(
  MonitoringState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeByte(offsets[0], object.activeNicheId.index);
  writer.writeBool(offsets[1], object.isMonitoringActive);
  writer.writeBool(offsets[2], object.isStale);
  writer.writeDateTime(offsets[3], object.lastHeartbeat);
  writer.writeDateTime(offsets[4], object.lastViolationTime);
  writer.writeStringList(offsets[5], object.monitoredApps);
  writer.writeDateTime(offsets[6], object.monitoringStartTime);
  writer.writeLong(offsets[7], object.violationCount);
}

MonitoringState _monitoringStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MonitoringState(
    activeNicheId: _MonitoringStateactiveNicheIdValueEnumMap[
            reader.readByteOrNull(offsets[0])] ??
        NicheId.smoking,
    isMonitoringActive: reader.readBoolOrNull(offsets[1]) ?? false,
    lastHeartbeat: reader.readDateTime(offsets[3]),
    lastViolationTime: reader.readDateTimeOrNull(offsets[4]),
    monitoredApps: reader.readStringList(offsets[5]) ?? const [],
    monitoringStartTime: reader.readDateTimeOrNull(offsets[6]),
    violationCount: reader.readLongOrNull(offsets[7]) ?? 0,
  );
  object.id = id;
  return object;
}

P _monitoringStateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (_MonitoringStateactiveNicheIdValueEnumMap[
              reader.readByteOrNull(offset)] ??
          NicheId.smoking) as P;
    case 1:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readStringList(offset) ?? const []) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _MonitoringStateactiveNicheIdEnumValueMap = {
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
const _MonitoringStateactiveNicheIdValueEnumMap = {
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

Id _monitoringStateGetId(MonitoringState object) {
  return object.id ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _monitoringStateGetLinks(MonitoringState object) {
  return [];
}

void _monitoringStateAttach(
    IsarCollection<dynamic> col, Id id, MonitoringState object) {
  object.id = id;
}

extension MonitoringStateQueryWhereSort
    on QueryBuilder<MonitoringState, MonitoringState, QWhere> {
  QueryBuilder<MonitoringState, MonitoringState, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterWhere>
      anyActiveNicheId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'activeNicheId'),
      );
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterWhere>
      anyIsMonitoringActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isMonitoringActive'),
      );
    });
  }
}

extension MonitoringStateQueryWhere
    on QueryBuilder<MonitoringState, MonitoringState, QWhereClause> {
  QueryBuilder<MonitoringState, MonitoringState, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterWhereClause>
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

  QueryBuilder<MonitoringState, MonitoringState, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterWhereClause> idBetween(
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

  QueryBuilder<MonitoringState, MonitoringState, QAfterWhereClause>
      activeNicheIdEqualTo(NicheId activeNicheId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'activeNicheId',
        value: [activeNicheId],
      ));
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterWhereClause>
      activeNicheIdNotEqualTo(NicheId activeNicheId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'activeNicheId',
              lower: [],
              upper: [activeNicheId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'activeNicheId',
              lower: [activeNicheId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'activeNicheId',
              lower: [activeNicheId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'activeNicheId',
              lower: [],
              upper: [activeNicheId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterWhereClause>
      activeNicheIdGreaterThan(
    NicheId activeNicheId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'activeNicheId',
        lower: [activeNicheId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterWhereClause>
      activeNicheIdLessThan(
    NicheId activeNicheId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'activeNicheId',
        lower: [],
        upper: [activeNicheId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterWhereClause>
      activeNicheIdBetween(
    NicheId lowerActiveNicheId,
    NicheId upperActiveNicheId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'activeNicheId',
        lower: [lowerActiveNicheId],
        includeLower: includeLower,
        upper: [upperActiveNicheId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterWhereClause>
      isMonitoringActiveEqualTo(bool isMonitoringActive) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isMonitoringActive',
        value: [isMonitoringActive],
      ));
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterWhereClause>
      isMonitoringActiveNotEqualTo(bool isMonitoringActive) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isMonitoringActive',
              lower: [],
              upper: [isMonitoringActive],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isMonitoringActive',
              lower: [isMonitoringActive],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isMonitoringActive',
              lower: [isMonitoringActive],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isMonitoringActive',
              lower: [],
              upper: [isMonitoringActive],
              includeUpper: false,
            ));
      }
    });
  }
}

extension MonitoringStateQueryFilter
    on QueryBuilder<MonitoringState, MonitoringState, QFilterCondition> {
  QueryBuilder<MonitoringState, MonitoringState, QAfterFilterCondition>
      activeNicheIdEqualTo(NicheId value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activeNicheId',
        value: value,
      ));
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterFilterCondition>
      activeNicheIdGreaterThan(
    NicheId value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activeNicheId',
        value: value,
      ));
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterFilterCondition>
      activeNicheIdLessThan(
    NicheId value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activeNicheId',
        value: value,
      ));
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterFilterCondition>
      activeNicheIdBetween(
    NicheId lower,
    NicheId upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activeNicheId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterFilterCondition>
      idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterFilterCondition>
      idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterFilterCondition>
      idEqualTo(Id? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterFilterCondition>
      idGreaterThan(
    Id? value, {
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

  QueryBuilder<MonitoringState, MonitoringState, QAfterFilterCondition>
      idLessThan(
    Id? value, {
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

  QueryBuilder<MonitoringState, MonitoringState, QAfterFilterCondition>
      idBetween(
    Id? lower,
    Id? upper, {
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

  QueryBuilder<MonitoringState, MonitoringState, QAfterFilterCondition>
      isMonitoringActiveEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isMonitoringActive',
        value: value,
      ));
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterFilterCondition>
      isStaleEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isStale',
        value: value,
      ));
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterFilterCondition>
      lastHeartbeatEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastHeartbeat',
        value: value,
      ));
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterFilterCondition>
      lastHeartbeatGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastHeartbeat',
        value: value,
      ));
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterFilterCondition>
      lastHeartbeatLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastHeartbeat',
        value: value,
      ));
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterFilterCondition>
      lastHeartbeatBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastHeartbeat',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterFilterCondition>
      lastViolationTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastViolationTime',
      ));
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterFilterCondition>
      lastViolationTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastViolationTime',
      ));
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterFilterCondition>
      lastViolationTimeEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastViolationTime',
        value: value,
      ));
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterFilterCondition>
      lastViolationTimeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastViolationTime',
        value: value,
      ));
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterFilterCondition>
      lastViolationTimeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastViolationTime',
        value: value,
      ));
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterFilterCondition>
      lastViolationTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastViolationTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterFilterCondition>
      monitoredAppsElementEqualTo(
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

  QueryBuilder<MonitoringState, MonitoringState, QAfterFilterCondition>
      monitoredAppsElementGreaterThan(
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

  QueryBuilder<MonitoringState, MonitoringState, QAfterFilterCondition>
      monitoredAppsElementLessThan(
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

  QueryBuilder<MonitoringState, MonitoringState, QAfterFilterCondition>
      monitoredAppsElementBetween(
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

  QueryBuilder<MonitoringState, MonitoringState, QAfterFilterCondition>
      monitoredAppsElementStartsWith(
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

  QueryBuilder<MonitoringState, MonitoringState, QAfterFilterCondition>
      monitoredAppsElementEndsWith(
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

  QueryBuilder<MonitoringState, MonitoringState, QAfterFilterCondition>
      monitoredAppsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'monitoredApps',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterFilterCondition>
      monitoredAppsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'monitoredApps',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterFilterCondition>
      monitoredAppsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'monitoredApps',
        value: '',
      ));
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterFilterCondition>
      monitoredAppsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'monitoredApps',
        value: '',
      ));
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterFilterCondition>
      monitoredAppsLengthEqualTo(int length) {
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

  QueryBuilder<MonitoringState, MonitoringState, QAfterFilterCondition>
      monitoredAppsIsEmpty() {
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

  QueryBuilder<MonitoringState, MonitoringState, QAfterFilterCondition>
      monitoredAppsIsNotEmpty() {
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

  QueryBuilder<MonitoringState, MonitoringState, QAfterFilterCondition>
      monitoredAppsLengthLessThan(
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

  QueryBuilder<MonitoringState, MonitoringState, QAfterFilterCondition>
      monitoredAppsLengthGreaterThan(
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

  QueryBuilder<MonitoringState, MonitoringState, QAfterFilterCondition>
      monitoredAppsLengthBetween(
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

  QueryBuilder<MonitoringState, MonitoringState, QAfterFilterCondition>
      monitoringStartTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'monitoringStartTime',
      ));
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterFilterCondition>
      monitoringStartTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'monitoringStartTime',
      ));
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterFilterCondition>
      monitoringStartTimeEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'monitoringStartTime',
        value: value,
      ));
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterFilterCondition>
      monitoringStartTimeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'monitoringStartTime',
        value: value,
      ));
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterFilterCondition>
      monitoringStartTimeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'monitoringStartTime',
        value: value,
      ));
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterFilterCondition>
      monitoringStartTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'monitoringStartTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterFilterCondition>
      violationCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'violationCount',
        value: value,
      ));
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterFilterCondition>
      violationCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'violationCount',
        value: value,
      ));
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterFilterCondition>
      violationCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'violationCount',
        value: value,
      ));
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterFilterCondition>
      violationCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'violationCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension MonitoringStateQueryObject
    on QueryBuilder<MonitoringState, MonitoringState, QFilterCondition> {}

extension MonitoringStateQueryLinks
    on QueryBuilder<MonitoringState, MonitoringState, QFilterCondition> {}

extension MonitoringStateQuerySortBy
    on QueryBuilder<MonitoringState, MonitoringState, QSortBy> {
  QueryBuilder<MonitoringState, MonitoringState, QAfterSortBy>
      sortByActiveNicheId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeNicheId', Sort.asc);
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterSortBy>
      sortByActiveNicheIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeNicheId', Sort.desc);
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterSortBy>
      sortByIsMonitoringActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMonitoringActive', Sort.asc);
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterSortBy>
      sortByIsMonitoringActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMonitoringActive', Sort.desc);
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterSortBy> sortByIsStale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isStale', Sort.asc);
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterSortBy>
      sortByIsStaleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isStale', Sort.desc);
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterSortBy>
      sortByLastHeartbeat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastHeartbeat', Sort.asc);
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterSortBy>
      sortByLastHeartbeatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastHeartbeat', Sort.desc);
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterSortBy>
      sortByLastViolationTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastViolationTime', Sort.asc);
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterSortBy>
      sortByLastViolationTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastViolationTime', Sort.desc);
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterSortBy>
      sortByMonitoringStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monitoringStartTime', Sort.asc);
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterSortBy>
      sortByMonitoringStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monitoringStartTime', Sort.desc);
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterSortBy>
      sortByViolationCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'violationCount', Sort.asc);
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterSortBy>
      sortByViolationCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'violationCount', Sort.desc);
    });
  }
}

extension MonitoringStateQuerySortThenBy
    on QueryBuilder<MonitoringState, MonitoringState, QSortThenBy> {
  QueryBuilder<MonitoringState, MonitoringState, QAfterSortBy>
      thenByActiveNicheId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeNicheId', Sort.asc);
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterSortBy>
      thenByActiveNicheIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeNicheId', Sort.desc);
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterSortBy>
      thenByIsMonitoringActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMonitoringActive', Sort.asc);
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterSortBy>
      thenByIsMonitoringActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMonitoringActive', Sort.desc);
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterSortBy> thenByIsStale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isStale', Sort.asc);
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterSortBy>
      thenByIsStaleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isStale', Sort.desc);
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterSortBy>
      thenByLastHeartbeat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastHeartbeat', Sort.asc);
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterSortBy>
      thenByLastHeartbeatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastHeartbeat', Sort.desc);
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterSortBy>
      thenByLastViolationTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastViolationTime', Sort.asc);
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterSortBy>
      thenByLastViolationTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastViolationTime', Sort.desc);
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterSortBy>
      thenByMonitoringStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monitoringStartTime', Sort.asc);
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterSortBy>
      thenByMonitoringStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monitoringStartTime', Sort.desc);
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterSortBy>
      thenByViolationCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'violationCount', Sort.asc);
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QAfterSortBy>
      thenByViolationCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'violationCount', Sort.desc);
    });
  }
}

extension MonitoringStateQueryWhereDistinct
    on QueryBuilder<MonitoringState, MonitoringState, QDistinct> {
  QueryBuilder<MonitoringState, MonitoringState, QDistinct>
      distinctByActiveNicheId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activeNicheId');
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QDistinct>
      distinctByIsMonitoringActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isMonitoringActive');
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QDistinct>
      distinctByIsStale() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isStale');
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QDistinct>
      distinctByLastHeartbeat() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastHeartbeat');
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QDistinct>
      distinctByLastViolationTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastViolationTime');
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QDistinct>
      distinctByMonitoredApps() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'monitoredApps');
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QDistinct>
      distinctByMonitoringStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'monitoringStartTime');
    });
  }

  QueryBuilder<MonitoringState, MonitoringState, QDistinct>
      distinctByViolationCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'violationCount');
    });
  }
}

extension MonitoringStateQueryProperty
    on QueryBuilder<MonitoringState, MonitoringState, QQueryProperty> {
  QueryBuilder<MonitoringState, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MonitoringState, NicheId, QQueryOperations>
      activeNicheIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activeNicheId');
    });
  }

  QueryBuilder<MonitoringState, bool, QQueryOperations>
      isMonitoringActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isMonitoringActive');
    });
  }

  QueryBuilder<MonitoringState, bool, QQueryOperations> isStaleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isStale');
    });
  }

  QueryBuilder<MonitoringState, DateTime, QQueryOperations>
      lastHeartbeatProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastHeartbeat');
    });
  }

  QueryBuilder<MonitoringState, DateTime?, QQueryOperations>
      lastViolationTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastViolationTime');
    });
  }

  QueryBuilder<MonitoringState, List<String>, QQueryOperations>
      monitoredAppsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'monitoredApps');
    });
  }

  QueryBuilder<MonitoringState, DateTime?, QQueryOperations>
      monitoringStartTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'monitoringStartTime');
    });
  }

  QueryBuilder<MonitoringState, int, QQueryOperations>
      violationCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'violationCount');
    });
  }
}
