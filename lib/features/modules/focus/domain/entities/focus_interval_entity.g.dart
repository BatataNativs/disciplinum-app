// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'focus_interval_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFocusIntervalEntityCollection on Isar {
  IsarCollection<FocusIntervalEntity> get focusIntervalEntitys =>
      this.collection();
}

const FocusIntervalEntitySchema = CollectionSchema(
  name: r'FocusIntervalEntity',
  id: -6969834926278765261,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
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
    r'nicheId': PropertySchema(
      id: 3,
      name: r'nicheId',
      type: IsarType.long,
    ),
    r'startHour': PropertySchema(
      id: 4,
      name: r'startHour',
      type: IsarType.long,
    ),
    r'startMinute': PropertySchema(
      id: 5,
      name: r'startMinute',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 6,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _focusIntervalEntityEstimateSize,
  serialize: _focusIntervalEntitySerialize,
  deserialize: _focusIntervalEntityDeserialize,
  deserializeProp: _focusIntervalEntityDeserializeProp,
  idName: r'id',
  indexes: {
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
  getId: _focusIntervalEntityGetId,
  getLinks: _focusIntervalEntityGetLinks,
  attach: _focusIntervalEntityAttach,
  version: '3.1.0+1',
);

int _focusIntervalEntityEstimateSize(
  FocusIntervalEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _focusIntervalEntitySerialize(
  FocusIntervalEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeLong(offsets[1], object.endHour);
  writer.writeLong(offsets[2], object.endMinute);
  writer.writeLong(offsets[3], object.nicheId);
  writer.writeLong(offsets[4], object.startHour);
  writer.writeLong(offsets[5], object.startMinute);
  writer.writeDateTime(offsets[6], object.updatedAt);
}

FocusIntervalEntity _focusIntervalEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FocusIntervalEntity(
    endHour: reader.readLong(offsets[1]),
    endMinute: reader.readLong(offsets[2]),
    nicheId: reader.readLong(offsets[3]),
    startHour: reader.readLong(offsets[4]),
    startMinute: reader.readLong(offsets[5]),
  );
  object.createdAt = reader.readDateTime(offsets[0]);
  object.id = id;
  object.updatedAt = reader.readDateTime(offsets[6]);
  return object;
}

P _focusIntervalEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _focusIntervalEntityGetId(FocusIntervalEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _focusIntervalEntityGetLinks(
    FocusIntervalEntity object) {
  return [];
}

void _focusIntervalEntityAttach(
    IsarCollection<dynamic> col, Id id, FocusIntervalEntity object) {
  object.id = id;
}

extension FocusIntervalEntityQueryWhereSort
    on QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QWhere> {
  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterWhere>
      anyNicheId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'nicheId'),
      );
    });
  }
}

extension FocusIntervalEntityQueryWhere
    on QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QWhereClause> {
  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterWhereClause>
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

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterWhereClause>
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

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterWhereClause>
      nicheIdEqualTo(int nicheId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'nicheId',
        value: [nicheId],
      ));
    });
  }

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterWhereClause>
      nicheIdNotEqualTo(int nicheId) {
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

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterWhereClause>
      nicheIdGreaterThan(
    int nicheId, {
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

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterWhereClause>
      nicheIdLessThan(
    int nicheId, {
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

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterWhereClause>
      nicheIdBetween(
    int lowerNicheId,
    int upperNicheId, {
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

extension FocusIntervalEntityQueryFilter on QueryBuilder<FocusIntervalEntity,
    FocusIntervalEntity, QFilterCondition> {
  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterFilterCondition>
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

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterFilterCondition>
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

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterFilterCondition>
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

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterFilterCondition>
      endHourEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endHour',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterFilterCondition>
      endHourGreaterThan(
    int value, {
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

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterFilterCondition>
      endHourLessThan(
    int value, {
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

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterFilterCondition>
      endHourBetween(
    int lower,
    int upper, {
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

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterFilterCondition>
      endMinuteEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterFilterCondition>
      endMinuteGreaterThan(
    int value, {
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

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterFilterCondition>
      endMinuteLessThan(
    int value, {
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

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterFilterCondition>
      endMinuteBetween(
    int lower,
    int upper, {
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

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterFilterCondition>
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

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterFilterCondition>
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

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterFilterCondition>
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

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterFilterCondition>
      nicheIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nicheId',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterFilterCondition>
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

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterFilterCondition>
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

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterFilterCondition>
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

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterFilterCondition>
      startHourEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startHour',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterFilterCondition>
      startHourGreaterThan(
    int value, {
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

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterFilterCondition>
      startHourLessThan(
    int value, {
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

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterFilterCondition>
      startHourBetween(
    int lower,
    int upper, {
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

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterFilterCondition>
      startMinuteEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterFilterCondition>
      startMinuteGreaterThan(
    int value, {
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

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterFilterCondition>
      startMinuteLessThan(
    int value, {
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

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterFilterCondition>
      startMinuteBetween(
    int lower,
    int upper, {
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

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterFilterCondition>
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

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterFilterCondition>
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

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterFilterCondition>
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

extension FocusIntervalEntityQueryObject on QueryBuilder<FocusIntervalEntity,
    FocusIntervalEntity, QFilterCondition> {}

extension FocusIntervalEntityQueryLinks on QueryBuilder<FocusIntervalEntity,
    FocusIntervalEntity, QFilterCondition> {}

extension FocusIntervalEntityQuerySortBy
    on QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QSortBy> {
  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterSortBy>
      sortByEndHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endHour', Sort.asc);
    });
  }

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterSortBy>
      sortByEndHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endHour', Sort.desc);
    });
  }

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterSortBy>
      sortByEndMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endMinute', Sort.asc);
    });
  }

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterSortBy>
      sortByEndMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endMinute', Sort.desc);
    });
  }

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterSortBy>
      sortByNicheId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nicheId', Sort.asc);
    });
  }

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterSortBy>
      sortByNicheIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nicheId', Sort.desc);
    });
  }

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterSortBy>
      sortByStartHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startHour', Sort.asc);
    });
  }

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterSortBy>
      sortByStartHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startHour', Sort.desc);
    });
  }

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterSortBy>
      sortByStartMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startMinute', Sort.asc);
    });
  }

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterSortBy>
      sortByStartMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startMinute', Sort.desc);
    });
  }

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension FocusIntervalEntityQuerySortThenBy
    on QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QSortThenBy> {
  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterSortBy>
      thenByEndHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endHour', Sort.asc);
    });
  }

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterSortBy>
      thenByEndHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endHour', Sort.desc);
    });
  }

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterSortBy>
      thenByEndMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endMinute', Sort.asc);
    });
  }

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterSortBy>
      thenByEndMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endMinute', Sort.desc);
    });
  }

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterSortBy>
      thenByNicheId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nicheId', Sort.asc);
    });
  }

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterSortBy>
      thenByNicheIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nicheId', Sort.desc);
    });
  }

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterSortBy>
      thenByStartHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startHour', Sort.asc);
    });
  }

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterSortBy>
      thenByStartHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startHour', Sort.desc);
    });
  }

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterSortBy>
      thenByStartMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startMinute', Sort.asc);
    });
  }

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterSortBy>
      thenByStartMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startMinute', Sort.desc);
    });
  }

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension FocusIntervalEntityQueryWhereDistinct
    on QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QDistinct> {
  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QDistinct>
      distinctByEndHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endHour');
    });
  }

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QDistinct>
      distinctByEndMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endMinute');
    });
  }

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QDistinct>
      distinctByNicheId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nicheId');
    });
  }

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QDistinct>
      distinctByStartHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startHour');
    });
  }

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QDistinct>
      distinctByStartMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startMinute');
    });
  }

  QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension FocusIntervalEntityQueryProperty
    on QueryBuilder<FocusIntervalEntity, FocusIntervalEntity, QQueryProperty> {
  QueryBuilder<FocusIntervalEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<FocusIntervalEntity, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<FocusIntervalEntity, int, QQueryOperations> endHourProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endHour');
    });
  }

  QueryBuilder<FocusIntervalEntity, int, QQueryOperations> endMinuteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endMinute');
    });
  }

  QueryBuilder<FocusIntervalEntity, int, QQueryOperations> nicheIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nicheId');
    });
  }

  QueryBuilder<FocusIntervalEntity, int, QQueryOperations> startHourProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startHour');
    });
  }

  QueryBuilder<FocusIntervalEntity, int, QQueryOperations>
      startMinuteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startMinute');
    });
  }

  QueryBuilder<FocusIntervalEntity, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
