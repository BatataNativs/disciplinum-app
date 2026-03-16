// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detection_session_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDetectionSessionCollection on Isar {
  IsarCollection<DetectionSession> get detectionSessions => this.collection();
}

const DetectionSessionSchema = CollectionSchema(
  name: r'DetectionSession',
  id: -5225469591625843384,
  properties: {
    r'calculatedRemainingSeconds': PropertySchema(
      id: 0,
      name: r'calculatedRemainingSeconds',
      type: IsarType.long,
    ),
    r'duration': PropertySchema(
      id: 1,
      name: r'duration',
      type: IsarType.long,
    ),
    r'isActive': PropertySchema(
      id: 2,
      name: r'isActive',
      type: IsarType.bool,
    ),
    r'isExpired': PropertySchema(
      id: 3,
      name: r'isExpired',
      type: IsarType.bool,
    ),
    r'lastUpdated': PropertySchema(
      id: 4,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'nicheId': PropertySchema(
      id: 5,
      name: r'nicheId',
      type: IsarType.byte,
      enumMap: _DetectionSessionnicheIdEnumValueMap,
    ),
    r'packageName': PropertySchema(
      id: 6,
      name: r'packageName',
      type: IsarType.string,
    ),
    r'remainingSeconds': PropertySchema(
      id: 7,
      name: r'remainingSeconds',
      type: IsarType.long,
    ),
    r'startTime': PropertySchema(
      id: 8,
      name: r'startTime',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _detectionSessionEstimateSize,
  serialize: _detectionSessionSerialize,
  deserialize: _detectionSessionDeserialize,
  deserializeProp: _detectionSessionDeserializeProp,
  idName: r'id',
  indexes: {
    r'packageName': IndexSchema(
      id: -3211024755902609907,
      name: r'packageName',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'packageName',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'startTime': IndexSchema(
      id: -3870335341264752872,
      name: r'startTime',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'startTime',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'isActive': IndexSchema(
      id: 8092228061260947457,
      name: r'isActive',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isActive',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'nicheId': IndexSchema(
      id: 4346940864654638376,
      name: r'nicheId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'nicheId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _detectionSessionGetId,
  getLinks: _detectionSessionGetLinks,
  attach: _detectionSessionAttach,
  version: '3.1.0+1',
);

int _detectionSessionEstimateSize(
  DetectionSession object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.packageName.length * 3;
  return bytesCount;
}

void _detectionSessionSerialize(
  DetectionSession object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.calculatedRemainingSeconds);
  writer.writeLong(offsets[1], object.duration);
  writer.writeBool(offsets[2], object.isActive);
  writer.writeBool(offsets[3], object.isExpired);
  writer.writeDateTime(offsets[4], object.lastUpdated);
  writer.writeByte(offsets[5], object.nicheId.index);
  writer.writeString(offsets[6], object.packageName);
  writer.writeLong(offsets[7], object.remainingSeconds);
  writer.writeDateTime(offsets[8], object.startTime);
}

DetectionSession _detectionSessionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DetectionSession(
    duration: reader.readLong(offsets[1]),
    isActive: reader.readBool(offsets[2]),
    nicheId: _DetectionSessionnicheIdValueEnumMap[
            reader.readByteOrNull(offsets[5])] ??
        NicheId.smoking,
    packageName: reader.readString(offsets[6]),
    remainingSeconds: reader.readLong(offsets[7]),
    startTime: reader.readDateTime(offsets[8]),
  );
  object.id = id;
  object.lastUpdated = reader.readDateTime(offsets[4]);
  return object;
}

P _detectionSessionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (_DetectionSessionnicheIdValueEnumMap[
              reader.readByteOrNull(offset)] ??
          NicheId.smoking) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _DetectionSessionnicheIdEnumValueMap = {
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
const _DetectionSessionnicheIdValueEnumMap = {
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

Id _detectionSessionGetId(DetectionSession object) {
  return object.id ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _detectionSessionGetLinks(DetectionSession object) {
  return [];
}

void _detectionSessionAttach(
    IsarCollection<dynamic> col, Id id, DetectionSession object) {
  object.id = id;
}

extension DetectionSessionQueryWhereSort
    on QueryBuilder<DetectionSession, DetectionSession, QWhere> {
  QueryBuilder<DetectionSession, DetectionSession, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterWhere> anyStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'startTime'),
      );
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterWhere> anyIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isActive'),
      );
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterWhere> anyNicheId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'nicheId'),
      );
    });
  }
}

extension DetectionSessionQueryWhere
    on QueryBuilder<DetectionSession, DetectionSession, QWhereClause> {
  QueryBuilder<DetectionSession, DetectionSession, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterWhereClause>
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

  QueryBuilder<DetectionSession, DetectionSession, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterWhereClause> idBetween(
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

  QueryBuilder<DetectionSession, DetectionSession, QAfterWhereClause>
      packageNameEqualTo(String packageName) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'packageName',
        value: [packageName],
      ));
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterWhereClause>
      packageNameNotEqualTo(String packageName) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'packageName',
              lower: [],
              upper: [packageName],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'packageName',
              lower: [packageName],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'packageName',
              lower: [packageName],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'packageName',
              lower: [],
              upper: [packageName],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterWhereClause>
      startTimeEqualTo(DateTime startTime) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'startTime',
        value: [startTime],
      ));
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterWhereClause>
      startTimeNotEqualTo(DateTime startTime) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startTime',
              lower: [],
              upper: [startTime],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startTime',
              lower: [startTime],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startTime',
              lower: [startTime],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startTime',
              lower: [],
              upper: [startTime],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterWhereClause>
      startTimeGreaterThan(
    DateTime startTime, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'startTime',
        lower: [startTime],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterWhereClause>
      startTimeLessThan(
    DateTime startTime, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'startTime',
        lower: [],
        upper: [startTime],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterWhereClause>
      startTimeBetween(
    DateTime lowerStartTime,
    DateTime upperStartTime, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'startTime',
        lower: [lowerStartTime],
        includeLower: includeLower,
        upper: [upperStartTime],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterWhereClause>
      isActiveEqualTo(bool isActive) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isActive',
        value: [isActive],
      ));
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterWhereClause>
      isActiveNotEqualTo(bool isActive) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isActive',
              lower: [],
              upper: [isActive],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isActive',
              lower: [isActive],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isActive',
              lower: [isActive],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isActive',
              lower: [],
              upper: [isActive],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterWhereClause>
      nicheIdEqualTo(NicheId nicheId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'nicheId',
        value: [nicheId],
      ));
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterWhereClause>
      nicheIdNotEqualTo(NicheId nicheId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nicheId',
              lower: [],
              upper: [nicheId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nicheId',
              lower: [nicheId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nicheId',
              lower: [nicheId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nicheId',
              lower: [],
              upper: [nicheId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterWhereClause>
      nicheIdGreaterThan(
    NicheId nicheId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'nicheId',
        lower: [nicheId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterWhereClause>
      nicheIdLessThan(
    NicheId nicheId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'nicheId',
        lower: [],
        upper: [nicheId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterWhereClause>
      nicheIdBetween(
    NicheId lowerNicheId,
    NicheId upperNicheId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'nicheId',
        lower: [lowerNicheId],
        includeLower: includeLower,
        upper: [upperNicheId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DetectionSessionQueryFilter
    on QueryBuilder<DetectionSession, DetectionSession, QFilterCondition> {
  QueryBuilder<DetectionSession, DetectionSession, QAfterFilterCondition>
      calculatedRemainingSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'calculatedRemainingSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterFilterCondition>
      calculatedRemainingSecondsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'calculatedRemainingSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterFilterCondition>
      calculatedRemainingSecondsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'calculatedRemainingSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterFilterCondition>
      calculatedRemainingSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'calculatedRemainingSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterFilterCondition>
      durationEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'duration',
        value: value,
      ));
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterFilterCondition>
      durationGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'duration',
        value: value,
      ));
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterFilterCondition>
      durationLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'duration',
        value: value,
      ));
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterFilterCondition>
      durationBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'duration',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterFilterCondition>
      idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterFilterCondition>
      idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterFilterCondition>
      idEqualTo(Id? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterFilterCondition>
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

  QueryBuilder<DetectionSession, DetectionSession, QAfterFilterCondition>
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

  QueryBuilder<DetectionSession, DetectionSession, QAfterFilterCondition>
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

  QueryBuilder<DetectionSession, DetectionSession, QAfterFilterCondition>
      isActiveEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isActive',
        value: value,
      ));
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterFilterCondition>
      isExpiredEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isExpired',
        value: value,
      ));
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterFilterCondition>
      lastUpdatedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterFilterCondition>
      lastUpdatedGreaterThan(
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

  QueryBuilder<DetectionSession, DetectionSession, QAfterFilterCondition>
      lastUpdatedLessThan(
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

  QueryBuilder<DetectionSession, DetectionSession, QAfterFilterCondition>
      lastUpdatedBetween(
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

  QueryBuilder<DetectionSession, DetectionSession, QAfterFilterCondition>
      nicheIdEqualTo(NicheId value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nicheId',
        value: value,
      ));
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterFilterCondition>
      nicheIdGreaterThan(
    NicheId value, {
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

  QueryBuilder<DetectionSession, DetectionSession, QAfterFilterCondition>
      nicheIdLessThan(
    NicheId value, {
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

  QueryBuilder<DetectionSession, DetectionSession, QAfterFilterCondition>
      nicheIdBetween(
    NicheId lower,
    NicheId upper, {
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

  QueryBuilder<DetectionSession, DetectionSession, QAfterFilterCondition>
      packageNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'packageName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterFilterCondition>
      packageNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'packageName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterFilterCondition>
      packageNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'packageName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterFilterCondition>
      packageNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'packageName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterFilterCondition>
      packageNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'packageName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterFilterCondition>
      packageNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'packageName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterFilterCondition>
      packageNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'packageName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterFilterCondition>
      packageNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'packageName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterFilterCondition>
      packageNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'packageName',
        value: '',
      ));
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterFilterCondition>
      packageNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'packageName',
        value: '',
      ));
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterFilterCondition>
      remainingSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'remainingSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterFilterCondition>
      remainingSecondsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'remainingSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterFilterCondition>
      remainingSecondsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'remainingSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterFilterCondition>
      remainingSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'remainingSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterFilterCondition>
      startTimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startTime',
        value: value,
      ));
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterFilterCondition>
      startTimeGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startTime',
        value: value,
      ));
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterFilterCondition>
      startTimeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startTime',
        value: value,
      ));
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterFilterCondition>
      startTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DetectionSessionQueryObject
    on QueryBuilder<DetectionSession, DetectionSession, QFilterCondition> {}

extension DetectionSessionQueryLinks
    on QueryBuilder<DetectionSession, DetectionSession, QFilterCondition> {}

extension DetectionSessionQuerySortBy
    on QueryBuilder<DetectionSession, DetectionSession, QSortBy> {
  QueryBuilder<DetectionSession, DetectionSession, QAfterSortBy>
      sortByCalculatedRemainingSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calculatedRemainingSeconds', Sort.asc);
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterSortBy>
      sortByCalculatedRemainingSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calculatedRemainingSeconds', Sort.desc);
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterSortBy>
      sortByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.asc);
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterSortBy>
      sortByDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.desc);
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterSortBy>
      sortByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterSortBy>
      sortByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterSortBy>
      sortByIsExpired() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isExpired', Sort.asc);
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterSortBy>
      sortByIsExpiredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isExpired', Sort.desc);
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterSortBy>
      sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterSortBy>
      sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterSortBy>
      sortByNicheId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nicheId', Sort.asc);
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterSortBy>
      sortByNicheIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nicheId', Sort.desc);
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterSortBy>
      sortByPackageName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packageName', Sort.asc);
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterSortBy>
      sortByPackageNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packageName', Sort.desc);
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterSortBy>
      sortByRemainingSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remainingSeconds', Sort.asc);
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterSortBy>
      sortByRemainingSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remainingSeconds', Sort.desc);
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterSortBy>
      sortByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.asc);
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterSortBy>
      sortByStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.desc);
    });
  }
}

extension DetectionSessionQuerySortThenBy
    on QueryBuilder<DetectionSession, DetectionSession, QSortThenBy> {
  QueryBuilder<DetectionSession, DetectionSession, QAfterSortBy>
      thenByCalculatedRemainingSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calculatedRemainingSeconds', Sort.asc);
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterSortBy>
      thenByCalculatedRemainingSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calculatedRemainingSeconds', Sort.desc);
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterSortBy>
      thenByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.asc);
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterSortBy>
      thenByDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.desc);
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterSortBy>
      thenByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterSortBy>
      thenByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterSortBy>
      thenByIsExpired() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isExpired', Sort.asc);
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterSortBy>
      thenByIsExpiredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isExpired', Sort.desc);
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterSortBy>
      thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterSortBy>
      thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterSortBy>
      thenByNicheId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nicheId', Sort.asc);
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterSortBy>
      thenByNicheIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nicheId', Sort.desc);
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterSortBy>
      thenByPackageName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packageName', Sort.asc);
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterSortBy>
      thenByPackageNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packageName', Sort.desc);
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterSortBy>
      thenByRemainingSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remainingSeconds', Sort.asc);
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterSortBy>
      thenByRemainingSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remainingSeconds', Sort.desc);
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterSortBy>
      thenByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.asc);
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QAfterSortBy>
      thenByStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.desc);
    });
  }
}

extension DetectionSessionQueryWhereDistinct
    on QueryBuilder<DetectionSession, DetectionSession, QDistinct> {
  QueryBuilder<DetectionSession, DetectionSession, QDistinct>
      distinctByCalculatedRemainingSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'calculatedRemainingSeconds');
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QDistinct>
      distinctByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'duration');
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QDistinct>
      distinctByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isActive');
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QDistinct>
      distinctByIsExpired() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isExpired');
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QDistinct>
      distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QDistinct>
      distinctByNicheId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nicheId');
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QDistinct>
      distinctByPackageName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'packageName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QDistinct>
      distinctByRemainingSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'remainingSeconds');
    });
  }

  QueryBuilder<DetectionSession, DetectionSession, QDistinct>
      distinctByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startTime');
    });
  }
}

extension DetectionSessionQueryProperty
    on QueryBuilder<DetectionSession, DetectionSession, QQueryProperty> {
  QueryBuilder<DetectionSession, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DetectionSession, int, QQueryOperations>
      calculatedRemainingSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'calculatedRemainingSeconds');
    });
  }

  QueryBuilder<DetectionSession, int, QQueryOperations> durationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'duration');
    });
  }

  QueryBuilder<DetectionSession, bool, QQueryOperations> isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isActive');
    });
  }

  QueryBuilder<DetectionSession, bool, QQueryOperations> isExpiredProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isExpired');
    });
  }

  QueryBuilder<DetectionSession, DateTime, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<DetectionSession, NicheId, QQueryOperations> nicheIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nicheId');
    });
  }

  QueryBuilder<DetectionSession, String, QQueryOperations>
      packageNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'packageName');
    });
  }

  QueryBuilder<DetectionSession, int, QQueryOperations>
      remainingSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'remainingSeconds');
    });
  }

  QueryBuilder<DetectionSession, DateTime, QQueryOperations>
      startTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startTime');
    });
  }
}
