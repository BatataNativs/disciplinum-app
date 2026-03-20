// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_checkin_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDailyCheckinCollection on Isar {
  IsarCollection<DailyCheckin> get dailyCheckins => this.collection();
}

const DailyCheckinSchema = CollectionSchema(
  name: r'DailyCheckin',
  id: -6411141256554944740,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'dateStr': PropertySchema(
      id: 1,
      name: r'dateStr',
      type: IsarType.string,
    ),
    r'nicheId': PropertySchema(
      id: 2,
      name: r'nicheId',
      type: IsarType.byte,
      enumMap: _DailyCheckinnicheIdEnumValueMap,
    )
  },
  estimateSize: _dailyCheckinEstimateSize,
  serialize: _dailyCheckinSerialize,
  deserialize: _dailyCheckinDeserialize,
  deserializeProp: _dailyCheckinDeserializeProp,
  idName: r'id',
  indexes: {
    r'nicheId_dateStr': IndexSchema(
      id: -8323858028981679640,
      name: r'nicheId_dateStr',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'nicheId',
          type: IndexType.value,
          caseSensitive: false,
        ),
        IndexPropertySchema(
          name: r'dateStr',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'dateStr': IndexSchema(
      id: -4653382495099137664,
      name: r'dateStr',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'dateStr',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _dailyCheckinGetId,
  getLinks: _dailyCheckinGetLinks,
  attach: _dailyCheckinAttach,
  version: '3.1.0+1',
);

int _dailyCheckinEstimateSize(
  DailyCheckin object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.dateStr.length * 3;
  return bytesCount;
}

void _dailyCheckinSerialize(
  DailyCheckin object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeString(offsets[1], object.dateStr);
  writer.writeByte(offsets[2], object.nicheId.index);
}

DailyCheckin _dailyCheckinDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DailyCheckin(
    dateStr: reader.readString(offsets[1]),
    nicheId:
        _DailyCheckinnicheIdValueEnumMap[reader.readByteOrNull(offsets[2])] ??
            NicheId.smoking,
  );
  object.createdAt = reader.readDateTime(offsets[0]);
  object.id = id;
  return object;
}

P _dailyCheckinDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (_DailyCheckinnicheIdValueEnumMap[reader.readByteOrNull(offset)] ??
          NicheId.smoking) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _DailyCheckinnicheIdEnumValueMap = {
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
const _DailyCheckinnicheIdValueEnumMap = {
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

Id _dailyCheckinGetId(DailyCheckin object) {
  return object.id ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _dailyCheckinGetLinks(DailyCheckin object) {
  return [];
}

void _dailyCheckinAttach(
    IsarCollection<dynamic> col, Id id, DailyCheckin object) {
  object.id = id;
}

extension DailyCheckinByIndex on IsarCollection<DailyCheckin> {
  Future<DailyCheckin?> getByNicheIdDateStr(NicheId nicheId, String dateStr) {
    return getByIndex(r'nicheId_dateStr', [nicheId, dateStr]);
  }

  DailyCheckin? getByNicheIdDateStrSync(NicheId nicheId, String dateStr) {
    return getByIndexSync(r'nicheId_dateStr', [nicheId, dateStr]);
  }

  Future<bool> deleteByNicheIdDateStr(NicheId nicheId, String dateStr) {
    return deleteByIndex(r'nicheId_dateStr', [nicheId, dateStr]);
  }

  bool deleteByNicheIdDateStrSync(NicheId nicheId, String dateStr) {
    return deleteByIndexSync(r'nicheId_dateStr', [nicheId, dateStr]);
  }

  Future<List<DailyCheckin?>> getAllByNicheIdDateStr(
      List<NicheId> nicheIdValues, List<String> dateStrValues) {
    final len = nicheIdValues.length;
    assert(dateStrValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([nicheIdValues[i], dateStrValues[i]]);
    }

    return getAllByIndex(r'nicheId_dateStr', values);
  }

  List<DailyCheckin?> getAllByNicheIdDateStrSync(
      List<NicheId> nicheIdValues, List<String> dateStrValues) {
    final len = nicheIdValues.length;
    assert(dateStrValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([nicheIdValues[i], dateStrValues[i]]);
    }

    return getAllByIndexSync(r'nicheId_dateStr', values);
  }

  Future<int> deleteAllByNicheIdDateStr(
      List<NicheId> nicheIdValues, List<String> dateStrValues) {
    final len = nicheIdValues.length;
    assert(dateStrValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([nicheIdValues[i], dateStrValues[i]]);
    }

    return deleteAllByIndex(r'nicheId_dateStr', values);
  }

  int deleteAllByNicheIdDateStrSync(
      List<NicheId> nicheIdValues, List<String> dateStrValues) {
    final len = nicheIdValues.length;
    assert(dateStrValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([nicheIdValues[i], dateStrValues[i]]);
    }

    return deleteAllByIndexSync(r'nicheId_dateStr', values);
  }

  Future<Id> putByNicheIdDateStr(DailyCheckin object) {
    return putByIndex(r'nicheId_dateStr', object);
  }

  Id putByNicheIdDateStrSync(DailyCheckin object, {bool saveLinks = true}) {
    return putByIndexSync(r'nicheId_dateStr', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByNicheIdDateStr(List<DailyCheckin> objects) {
    return putAllByIndex(r'nicheId_dateStr', objects);
  }

  List<Id> putAllByNicheIdDateStrSync(List<DailyCheckin> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'nicheId_dateStr', objects, saveLinks: saveLinks);
  }
}

extension DailyCheckinQueryWhereSort
    on QueryBuilder<DailyCheckin, DailyCheckin, QWhere> {
  QueryBuilder<DailyCheckin, DailyCheckin, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DailyCheckinQueryWhere
    on QueryBuilder<DailyCheckin, DailyCheckin, QWhereClause> {
  QueryBuilder<DailyCheckin, DailyCheckin, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DailyCheckin, DailyCheckin, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<DailyCheckin, DailyCheckin, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DailyCheckin, DailyCheckin, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DailyCheckin, DailyCheckin, QAfterWhereClause> idBetween(
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

  QueryBuilder<DailyCheckin, DailyCheckin, QAfterWhereClause>
      nicheIdEqualToAnyDateStr(NicheId nicheId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'nicheId_dateStr',
        value: [nicheId],
      ));
    });
  }

  QueryBuilder<DailyCheckin, DailyCheckin, QAfterWhereClause>
      nicheIdNotEqualToAnyDateStr(NicheId nicheId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nicheId_dateStr',
              lower: [],
              upper: [nicheId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nicheId_dateStr',
              lower: [nicheId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nicheId_dateStr',
              lower: [nicheId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nicheId_dateStr',
              lower: [],
              upper: [nicheId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<DailyCheckin, DailyCheckin, QAfterWhereClause>
      nicheIdGreaterThanAnyDateStr(
    NicheId nicheId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'nicheId_dateStr',
        lower: [nicheId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<DailyCheckin, DailyCheckin, QAfterWhereClause>
      nicheIdLessThanAnyDateStr(
    NicheId nicheId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'nicheId_dateStr',
        lower: [],
        upper: [nicheId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<DailyCheckin, DailyCheckin, QAfterWhereClause>
      nicheIdBetweenAnyDateStr(
    NicheId lowerNicheId,
    NicheId upperNicheId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'nicheId_dateStr',
        lower: [lowerNicheId],
        includeLower: includeLower,
        upper: [upperNicheId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyCheckin, DailyCheckin, QAfterWhereClause>
      nicheIdDateStrEqualTo(NicheId nicheId, String dateStr) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'nicheId_dateStr',
        value: [nicheId, dateStr],
      ));
    });
  }

  QueryBuilder<DailyCheckin, DailyCheckin, QAfterWhereClause>
      nicheIdEqualToDateStrNotEqualTo(NicheId nicheId, String dateStr) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nicheId_dateStr',
              lower: [nicheId],
              upper: [nicheId, dateStr],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nicheId_dateStr',
              lower: [nicheId, dateStr],
              includeLower: false,
              upper: [nicheId],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nicheId_dateStr',
              lower: [nicheId, dateStr],
              includeLower: false,
              upper: [nicheId],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nicheId_dateStr',
              lower: [nicheId],
              upper: [nicheId, dateStr],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<DailyCheckin, DailyCheckin, QAfterWhereClause> dateStrEqualTo(
      String dateStr) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'dateStr',
        value: [dateStr],
      ));
    });
  }

  QueryBuilder<DailyCheckin, DailyCheckin, QAfterWhereClause> dateStrNotEqualTo(
      String dateStr) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dateStr',
              lower: [],
              upper: [dateStr],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dateStr',
              lower: [dateStr],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dateStr',
              lower: [dateStr],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dateStr',
              lower: [],
              upper: [dateStr],
              includeUpper: false,
            ));
      }
    });
  }
}

extension DailyCheckinQueryFilter
    on QueryBuilder<DailyCheckin, DailyCheckin, QFilterCondition> {
  QueryBuilder<DailyCheckin, DailyCheckin, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyCheckin, DailyCheckin, QAfterFilterCondition>
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

  QueryBuilder<DailyCheckin, DailyCheckin, QAfterFilterCondition>
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

  QueryBuilder<DailyCheckin, DailyCheckin, QAfterFilterCondition>
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

  QueryBuilder<DailyCheckin, DailyCheckin, QAfterFilterCondition>
      dateStrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateStr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyCheckin, DailyCheckin, QAfterFilterCondition>
      dateStrGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dateStr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyCheckin, DailyCheckin, QAfterFilterCondition>
      dateStrLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dateStr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyCheckin, DailyCheckin, QAfterFilterCondition>
      dateStrBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dateStr',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyCheckin, DailyCheckin, QAfterFilterCondition>
      dateStrStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dateStr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyCheckin, DailyCheckin, QAfterFilterCondition>
      dateStrEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dateStr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyCheckin, DailyCheckin, QAfterFilterCondition>
      dateStrContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dateStr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyCheckin, DailyCheckin, QAfterFilterCondition>
      dateStrMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dateStr',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyCheckin, DailyCheckin, QAfterFilterCondition>
      dateStrIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateStr',
        value: '',
      ));
    });
  }

  QueryBuilder<DailyCheckin, DailyCheckin, QAfterFilterCondition>
      dateStrIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dateStr',
        value: '',
      ));
    });
  }

  QueryBuilder<DailyCheckin, DailyCheckin, QAfterFilterCondition> idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<DailyCheckin, DailyCheckin, QAfterFilterCondition>
      idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<DailyCheckin, DailyCheckin, QAfterFilterCondition> idEqualTo(
      Id? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyCheckin, DailyCheckin, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<DailyCheckin, DailyCheckin, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<DailyCheckin, DailyCheckin, QAfterFilterCondition> idBetween(
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

  QueryBuilder<DailyCheckin, DailyCheckin, QAfterFilterCondition>
      nicheIdEqualTo(NicheId value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nicheId',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyCheckin, DailyCheckin, QAfterFilterCondition>
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

  QueryBuilder<DailyCheckin, DailyCheckin, QAfterFilterCondition>
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

  QueryBuilder<DailyCheckin, DailyCheckin, QAfterFilterCondition>
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
}

extension DailyCheckinQueryObject
    on QueryBuilder<DailyCheckin, DailyCheckin, QFilterCondition> {}

extension DailyCheckinQueryLinks
    on QueryBuilder<DailyCheckin, DailyCheckin, QFilterCondition> {}

extension DailyCheckinQuerySortBy
    on QueryBuilder<DailyCheckin, DailyCheckin, QSortBy> {
  QueryBuilder<DailyCheckin, DailyCheckin, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckin, DailyCheckin, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckin, DailyCheckin, QAfterSortBy> sortByDateStr() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateStr', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckin, DailyCheckin, QAfterSortBy> sortByDateStrDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateStr', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckin, DailyCheckin, QAfterSortBy> sortByNicheId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nicheId', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckin, DailyCheckin, QAfterSortBy> sortByNicheIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nicheId', Sort.desc);
    });
  }
}

extension DailyCheckinQuerySortThenBy
    on QueryBuilder<DailyCheckin, DailyCheckin, QSortThenBy> {
  QueryBuilder<DailyCheckin, DailyCheckin, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckin, DailyCheckin, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckin, DailyCheckin, QAfterSortBy> thenByDateStr() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateStr', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckin, DailyCheckin, QAfterSortBy> thenByDateStrDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateStr', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckin, DailyCheckin, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckin, DailyCheckin, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckin, DailyCheckin, QAfterSortBy> thenByNicheId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nicheId', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckin, DailyCheckin, QAfterSortBy> thenByNicheIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nicheId', Sort.desc);
    });
  }
}

extension DailyCheckinQueryWhereDistinct
    on QueryBuilder<DailyCheckin, DailyCheckin, QDistinct> {
  QueryBuilder<DailyCheckin, DailyCheckin, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<DailyCheckin, DailyCheckin, QDistinct> distinctByDateStr(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateStr', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyCheckin, DailyCheckin, QDistinct> distinctByNicheId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nicheId');
    });
  }
}

extension DailyCheckinQueryProperty
    on QueryBuilder<DailyCheckin, DailyCheckin, QQueryProperty> {
  QueryBuilder<DailyCheckin, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DailyCheckin, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<DailyCheckin, String, QQueryOperations> dateStrProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateStr');
    });
  }

  QueryBuilder<DailyCheckin, NicheId, QQueryOperations> nicheIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nicheId');
    });
  }
}
