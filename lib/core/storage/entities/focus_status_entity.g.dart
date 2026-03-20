// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'focus_status_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFocusStatusEntityCollection on Isar {
  IsarCollection<FocusStatusEntity> get focusStatusEntitys => this.collection();
}

const FocusStatusEntitySchema = CollectionSchema(
  name: r'FocusStatusEntity',
  id: 6490486579915229919,
  properties: {
    r'earnedInsigniaNames': PropertySchema(
      id: 0,
      name: r'earnedInsigniaNames',
      type: IsarType.stringList,
    ),
    r'endHour': PropertySchema(
      id: 1,
      name: r'endHour',
      type: IsarType.long,
    ),
    r'endMinute': PropertySchema(
      id: 2,
      name: r'endMinute',
      type: IsarType.long,
    ),
    r'lastUpdated': PropertySchema(
      id: 3,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'respectedPeriods': PropertySchema(
      id: 4,
      name: r'respectedPeriods',
      type: IsarType.long,
    ),
    r'startHour': PropertySchema(
      id: 5,
      name: r'startHour',
      type: IsarType.long,
    ),
    r'startMinute': PropertySchema(
      id: 6,
      name: r'startMinute',
      type: IsarType.long,
    ),
    r'userId': PropertySchema(
      id: 7,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _focusStatusEntityEstimateSize,
  serialize: _focusStatusEntitySerialize,
  deserialize: _focusStatusEntityDeserialize,
  deserializeProp: _focusStatusEntityDeserializeProp,
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
  getId: _focusStatusEntityGetId,
  getLinks: _focusStatusEntityGetLinks,
  attach: _focusStatusEntityAttach,
  version: '3.1.0+1',
);

int _focusStatusEntityEstimateSize(
  FocusStatusEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.earnedInsigniaNames.length * 3;
  {
    for (var i = 0; i < object.earnedInsigniaNames.length; i++) {
      final value = object.earnedInsigniaNames[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _focusStatusEntitySerialize(
  FocusStatusEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeStringList(offsets[0], object.earnedInsigniaNames);
  writer.writeLong(offsets[1], object.endHour);
  writer.writeLong(offsets[2], object.endMinute);
  writer.writeDateTime(offsets[3], object.lastUpdated);
  writer.writeLong(offsets[4], object.respectedPeriods);
  writer.writeLong(offsets[5], object.startHour);
  writer.writeLong(offsets[6], object.startMinute);
  writer.writeString(offsets[7], object.userId);
}

FocusStatusEntity _focusStatusEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FocusStatusEntity();
  object.earnedInsigniaNames = reader.readStringList(offsets[0]) ?? [];
  object.endHour = reader.readLongOrNull(offsets[1]);
  object.endMinute = reader.readLongOrNull(offsets[2]);
  object.id = id;
  object.lastUpdated = reader.readDateTime(offsets[3]);
  object.respectedPeriods = reader.readLong(offsets[4]);
  object.startHour = reader.readLongOrNull(offsets[5]);
  object.startMinute = reader.readLongOrNull(offsets[6]);
  object.userId = reader.readString(offsets[7]);
  return object;
}

P _focusStatusEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringList(offset) ?? []) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _focusStatusEntityGetId(FocusStatusEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _focusStatusEntityGetLinks(
    FocusStatusEntity object) {
  return [];
}

void _focusStatusEntityAttach(
    IsarCollection<dynamic> col, Id id, FocusStatusEntity object) {
  object.id = id;
}

extension FocusStatusEntityByIndex on IsarCollection<FocusStatusEntity> {
  Future<FocusStatusEntity?> getByUserId(String userId) {
    return getByIndex(r'userId', [userId]);
  }

  FocusStatusEntity? getByUserIdSync(String userId) {
    return getByIndexSync(r'userId', [userId]);
  }

  Future<bool> deleteByUserId(String userId) {
    return deleteByIndex(r'userId', [userId]);
  }

  bool deleteByUserIdSync(String userId) {
    return deleteByIndexSync(r'userId', [userId]);
  }

  Future<List<FocusStatusEntity?>> getAllByUserId(List<String> userIdValues) {
    final values = userIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'userId', values);
  }

  List<FocusStatusEntity?> getAllByUserIdSync(List<String> userIdValues) {
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

  Future<Id> putByUserId(FocusStatusEntity object) {
    return putByIndex(r'userId', object);
  }

  Id putByUserIdSync(FocusStatusEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'userId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUserId(List<FocusStatusEntity> objects) {
    return putAllByIndex(r'userId', objects);
  }

  List<Id> putAllByUserIdSync(List<FocusStatusEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'userId', objects, saveLinks: saveLinks);
  }
}

extension FocusStatusEntityQueryWhereSort
    on QueryBuilder<FocusStatusEntity, FocusStatusEntity, QWhere> {
  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension FocusStatusEntityQueryWhere
    on QueryBuilder<FocusStatusEntity, FocusStatusEntity, QWhereClause> {
  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterWhereClause>
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

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterWhereClause>
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

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterWhereClause>
      userIdEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterWhereClause>
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

extension FocusStatusEntityQueryFilter
    on QueryBuilder<FocusStatusEntity, FocusStatusEntity, QFilterCondition> {
  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      earnedInsigniaNamesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'earnedInsigniaNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      earnedInsigniaNamesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'earnedInsigniaNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      earnedInsigniaNamesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'earnedInsigniaNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      earnedInsigniaNamesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'earnedInsigniaNames',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      earnedInsigniaNamesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'earnedInsigniaNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      earnedInsigniaNamesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'earnedInsigniaNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      earnedInsigniaNamesElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'earnedInsigniaNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      earnedInsigniaNamesElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'earnedInsigniaNames',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      earnedInsigniaNamesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'earnedInsigniaNames',
        value: '',
      ));
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      earnedInsigniaNamesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'earnedInsigniaNames',
        value: '',
      ));
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      earnedInsigniaNamesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedInsigniaNames',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      earnedInsigniaNamesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedInsigniaNames',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      earnedInsigniaNamesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedInsigniaNames',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      earnedInsigniaNamesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedInsigniaNames',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      earnedInsigniaNamesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedInsigniaNames',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      earnedInsigniaNamesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedInsigniaNames',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      endHourIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'endHour',
      ));
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      endHourIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'endHour',
      ));
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      endHourEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endHour',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      endHourGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endHour',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      endHourLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endHour',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      endHourBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endHour',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      endMinuteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'endMinute',
      ));
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      endMinuteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'endMinute',
      ));
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      endMinuteEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      endMinuteGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      endMinuteLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      endMinuteBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endMinute',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
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

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
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

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
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

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      lastUpdatedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
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

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
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

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
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

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      respectedPeriodsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'respectedPeriods',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      respectedPeriodsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'respectedPeriods',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      respectedPeriodsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'respectedPeriods',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      respectedPeriodsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'respectedPeriods',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      startHourIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'startHour',
      ));
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      startHourIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'startHour',
      ));
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      startHourEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startHour',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      startHourGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startHour',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      startHourLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startHour',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      startHourBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startHour',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      startMinuteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'startMinute',
      ));
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      startMinuteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'startMinute',
      ));
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      startMinuteEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      startMinuteGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      startMinuteLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      startMinuteBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startMinute',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
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

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
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

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
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

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
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

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
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

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
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

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterFilterCondition>
      userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension FocusStatusEntityQueryObject
    on QueryBuilder<FocusStatusEntity, FocusStatusEntity, QFilterCondition> {}

extension FocusStatusEntityQueryLinks
    on QueryBuilder<FocusStatusEntity, FocusStatusEntity, QFilterCondition> {}

extension FocusStatusEntityQuerySortBy
    on QueryBuilder<FocusStatusEntity, FocusStatusEntity, QSortBy> {
  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterSortBy>
      sortByEndHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endHour', Sort.asc);
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterSortBy>
      sortByEndHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endHour', Sort.desc);
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterSortBy>
      sortByEndMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endMinute', Sort.asc);
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterSortBy>
      sortByEndMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endMinute', Sort.desc);
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterSortBy>
      sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterSortBy>
      sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterSortBy>
      sortByRespectedPeriods() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'respectedPeriods', Sort.asc);
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterSortBy>
      sortByRespectedPeriodsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'respectedPeriods', Sort.desc);
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterSortBy>
      sortByStartHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startHour', Sort.asc);
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterSortBy>
      sortByStartHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startHour', Sort.desc);
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterSortBy>
      sortByStartMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startMinute', Sort.asc);
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterSortBy>
      sortByStartMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startMinute', Sort.desc);
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterSortBy>
      sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension FocusStatusEntityQuerySortThenBy
    on QueryBuilder<FocusStatusEntity, FocusStatusEntity, QSortThenBy> {
  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterSortBy>
      thenByEndHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endHour', Sort.asc);
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterSortBy>
      thenByEndHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endHour', Sort.desc);
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterSortBy>
      thenByEndMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endMinute', Sort.asc);
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterSortBy>
      thenByEndMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endMinute', Sort.desc);
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterSortBy>
      thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterSortBy>
      thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterSortBy>
      thenByRespectedPeriods() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'respectedPeriods', Sort.asc);
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterSortBy>
      thenByRespectedPeriodsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'respectedPeriods', Sort.desc);
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterSortBy>
      thenByStartHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startHour', Sort.asc);
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterSortBy>
      thenByStartHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startHour', Sort.desc);
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterSortBy>
      thenByStartMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startMinute', Sort.asc);
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterSortBy>
      thenByStartMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startMinute', Sort.desc);
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterSortBy>
      thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension FocusStatusEntityQueryWhereDistinct
    on QueryBuilder<FocusStatusEntity, FocusStatusEntity, QDistinct> {
  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QDistinct>
      distinctByEarnedInsigniaNames() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'earnedInsigniaNames');
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QDistinct>
      distinctByEndHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endHour');
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QDistinct>
      distinctByEndMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endMinute');
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QDistinct>
      distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QDistinct>
      distinctByRespectedPeriods() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'respectedPeriods');
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QDistinct>
      distinctByStartHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startHour');
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QDistinct>
      distinctByStartMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startMinute');
    });
  }

  QueryBuilder<FocusStatusEntity, FocusStatusEntity, QDistinct>
      distinctByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension FocusStatusEntityQueryProperty
    on QueryBuilder<FocusStatusEntity, FocusStatusEntity, QQueryProperty> {
  QueryBuilder<FocusStatusEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<FocusStatusEntity, List<String>, QQueryOperations>
      earnedInsigniaNamesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'earnedInsigniaNames');
    });
  }

  QueryBuilder<FocusStatusEntity, int?, QQueryOperations> endHourProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endHour');
    });
  }

  QueryBuilder<FocusStatusEntity, int?, QQueryOperations> endMinuteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endMinute');
    });
  }

  QueryBuilder<FocusStatusEntity, DateTime, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<FocusStatusEntity, int, QQueryOperations>
      respectedPeriodsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'respectedPeriods');
    });
  }

  QueryBuilder<FocusStatusEntity, int?, QQueryOperations> startHourProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startHour');
    });
  }

  QueryBuilder<FocusStatusEntity, int?, QQueryOperations>
      startMinuteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startMinute');
    });
  }

  QueryBuilder<FocusStatusEntity, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}
