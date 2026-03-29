// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_gamification_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetReadingGamificationEntityCollection on Isar {
  IsarCollection<ReadingGamificationEntity> get readingGamificationEntitys =>
      this.collection();
}

const ReadingGamificationEntitySchema = CollectionSchema(
  name: r'ReadingGamificationEntity',
  id: 1613384822400216726,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'currentStreak': PropertySchema(
      id: 1,
      name: r'currentStreak',
      type: IsarType.long,
    ),
    r'lastAchievementDate': PropertySchema(
      id: 2,
      name: r'lastAchievementDate',
      type: IsarType.dateTime,
    ),
    r'lastReadingDate': PropertySchema(
      id: 3,
      name: r'lastReadingDate',
      type: IsarType.dateTime,
    ),
    r'longestStreakDays': PropertySchema(
      id: 4,
      name: r'longestStreakDays',
      type: IsarType.long,
    ),
    r'longestStreakEnd': PropertySchema(
      id: 5,
      name: r'longestStreakEnd',
      type: IsarType.dateTime,
    ),
    r'longestStreakStart': PropertySchema(
      id: 6,
      name: r'longestStreakStart',
      type: IsarType.dateTime,
    ),
    r'totalBooksRead': PropertySchema(
      id: 7,
      name: r'totalBooksRead',
      type: IsarType.long,
    ),
    r'totalPagesRead': PropertySchema(
      id: 8,
      name: r'totalPagesRead',
      type: IsarType.long,
    ),
    r'totalReadingDays': PropertySchema(
      id: 9,
      name: r'totalReadingDays',
      type: IsarType.long,
    ),
    r'unlockedAchievements': PropertySchema(
      id: 10,
      name: r'unlockedAchievements',
      type: IsarType.stringList,
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
  estimateSize: _readingGamificationEntityEstimateSize,
  serialize: _readingGamificationEntitySerialize,
  deserialize: _readingGamificationEntityDeserialize,
  deserializeProp: _readingGamificationEntityDeserializeProp,
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
  getId: _readingGamificationEntityGetId,
  getLinks: _readingGamificationEntityGetLinks,
  attach: _readingGamificationEntityAttach,
  version: '3.1.0+1',
);

int _readingGamificationEntityEstimateSize(
  ReadingGamificationEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.unlockedAchievements.length * 3;
  {
    for (var i = 0; i < object.unlockedAchievements.length; i++) {
      final value = object.unlockedAchievements[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _readingGamificationEntitySerialize(
  ReadingGamificationEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeLong(offsets[1], object.currentStreak);
  writer.writeDateTime(offsets[2], object.lastAchievementDate);
  writer.writeDateTime(offsets[3], object.lastReadingDate);
  writer.writeLong(offsets[4], object.longestStreakDays);
  writer.writeDateTime(offsets[5], object.longestStreakEnd);
  writer.writeDateTime(offsets[6], object.longestStreakStart);
  writer.writeLong(offsets[7], object.totalBooksRead);
  writer.writeLong(offsets[8], object.totalPagesRead);
  writer.writeLong(offsets[9], object.totalReadingDays);
  writer.writeStringList(offsets[10], object.unlockedAchievements);
  writer.writeDateTime(offsets[11], object.updatedAt);
  writer.writeString(offsets[12], object.userId);
}

ReadingGamificationEntity _readingGamificationEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ReadingGamificationEntity(
    userId: reader.readString(offsets[12]),
  );
  object.createdAt = reader.readDateTime(offsets[0]);
  object.currentStreak = reader.readLong(offsets[1]);
  object.id = id;
  object.lastAchievementDate = reader.readDateTimeOrNull(offsets[2]);
  object.lastReadingDate = reader.readDateTimeOrNull(offsets[3]);
  object.longestStreakDays = reader.readLong(offsets[4]);
  object.longestStreakEnd = reader.readDateTimeOrNull(offsets[5]);
  object.longestStreakStart = reader.readDateTimeOrNull(offsets[6]);
  object.totalBooksRead = reader.readLong(offsets[7]);
  object.totalPagesRead = reader.readLong(offsets[8]);
  object.totalReadingDays = reader.readLong(offsets[9]);
  object.unlockedAchievements = reader.readStringList(offsets[10]) ?? [];
  object.updatedAt = reader.readDateTime(offsets[11]);
  return object;
}

P _readingGamificationEntityDeserializeProp<P>(
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
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readStringList(offset) ?? []) as P;
    case 11:
      return (reader.readDateTime(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _readingGamificationEntityGetId(ReadingGamificationEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _readingGamificationEntityGetLinks(
    ReadingGamificationEntity object) {
  return [];
}

void _readingGamificationEntityAttach(
    IsarCollection<dynamic> col, Id id, ReadingGamificationEntity object) {
  object.id = id;
}

extension ReadingGamificationEntityByIndex
    on IsarCollection<ReadingGamificationEntity> {
  Future<ReadingGamificationEntity?> getByUserId(String userId) {
    return getByIndex(r'userId', [userId]);
  }

  ReadingGamificationEntity? getByUserIdSync(String userId) {
    return getByIndexSync(r'userId', [userId]);
  }

  Future<bool> deleteByUserId(String userId) {
    return deleteByIndex(r'userId', [userId]);
  }

  bool deleteByUserIdSync(String userId) {
    return deleteByIndexSync(r'userId', [userId]);
  }

  Future<List<ReadingGamificationEntity?>> getAllByUserId(
      List<String> userIdValues) {
    final values = userIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'userId', values);
  }

  List<ReadingGamificationEntity?> getAllByUserIdSync(
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

  Future<Id> putByUserId(ReadingGamificationEntity object) {
    return putByIndex(r'userId', object);
  }

  Id putByUserIdSync(ReadingGamificationEntity object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'userId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUserId(List<ReadingGamificationEntity> objects) {
    return putAllByIndex(r'userId', objects);
  }

  List<Id> putAllByUserIdSync(List<ReadingGamificationEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'userId', objects, saveLinks: saveLinks);
  }
}

extension ReadingGamificationEntityQueryWhereSort on QueryBuilder<
    ReadingGamificationEntity, ReadingGamificationEntity, QWhere> {
  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ReadingGamificationEntityQueryWhere on QueryBuilder<
    ReadingGamificationEntity, ReadingGamificationEntity, QWhereClause> {
  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
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

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
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

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterWhereClause> userIdEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
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

extension ReadingGamificationEntityQueryFilter on QueryBuilder<
    ReadingGamificationEntity, ReadingGamificationEntity, QFilterCondition> {
  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
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

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
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

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
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

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> currentStreakEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> currentStreakGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> currentStreakLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> currentStreakBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentStreak',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
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

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
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

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
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

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> lastAchievementDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastAchievementDate',
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> lastAchievementDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastAchievementDate',
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> lastAchievementDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastAchievementDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> lastAchievementDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastAchievementDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> lastAchievementDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastAchievementDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> lastAchievementDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastAchievementDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> lastReadingDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastReadingDate',
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> lastReadingDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastReadingDate',
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> lastReadingDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastReadingDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> lastReadingDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastReadingDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> lastReadingDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastReadingDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> lastReadingDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastReadingDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> longestStreakDaysEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'longestStreakDays',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> longestStreakDaysGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'longestStreakDays',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> longestStreakDaysLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'longestStreakDays',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> longestStreakDaysBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'longestStreakDays',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> longestStreakEndIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'longestStreakEnd',
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> longestStreakEndIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'longestStreakEnd',
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> longestStreakEndEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'longestStreakEnd',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> longestStreakEndGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'longestStreakEnd',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> longestStreakEndLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'longestStreakEnd',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> longestStreakEndBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'longestStreakEnd',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> longestStreakStartIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'longestStreakStart',
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> longestStreakStartIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'longestStreakStart',
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> longestStreakStartEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'longestStreakStart',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> longestStreakStartGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'longestStreakStart',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> longestStreakStartLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'longestStreakStart',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> longestStreakStartBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'longestStreakStart',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> totalBooksReadEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalBooksRead',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> totalBooksReadGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalBooksRead',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> totalBooksReadLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalBooksRead',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> totalBooksReadBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalBooksRead',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> totalPagesReadEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalPagesRead',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> totalPagesReadGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalPagesRead',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> totalPagesReadLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalPagesRead',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> totalPagesReadBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalPagesRead',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> totalReadingDaysEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalReadingDays',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> totalReadingDaysGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalReadingDays',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> totalReadingDaysLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalReadingDays',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> totalReadingDaysBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalReadingDays',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> unlockedAchievementsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unlockedAchievements',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> unlockedAchievementsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unlockedAchievements',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> unlockedAchievementsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unlockedAchievements',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> unlockedAchievementsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unlockedAchievements',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> unlockedAchievementsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'unlockedAchievements',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> unlockedAchievementsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'unlockedAchievements',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
          QAfterFilterCondition>
      unlockedAchievementsElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'unlockedAchievements',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
          QAfterFilterCondition>
      unlockedAchievementsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'unlockedAchievements',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> unlockedAchievementsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unlockedAchievements',
        value: '',
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> unlockedAchievementsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'unlockedAchievements',
        value: '',
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> unlockedAchievementsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'unlockedAchievements',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> unlockedAchievementsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'unlockedAchievements',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> unlockedAchievementsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'unlockedAchievements',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> unlockedAchievementsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'unlockedAchievements',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> unlockedAchievementsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'unlockedAchievements',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> unlockedAchievementsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'unlockedAchievements',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
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

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
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

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
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

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
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

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
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

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
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

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
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

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
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

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
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

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
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

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
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

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension ReadingGamificationEntityQueryObject on QueryBuilder<
    ReadingGamificationEntity, ReadingGamificationEntity, QFilterCondition> {}

extension ReadingGamificationEntityQueryLinks on QueryBuilder<
    ReadingGamificationEntity, ReadingGamificationEntity, QFilterCondition> {}

extension ReadingGamificationEntityQuerySortBy on QueryBuilder<
    ReadingGamificationEntity, ReadingGamificationEntity, QSortBy> {
  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> sortByCurrentStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.asc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> sortByCurrentStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.desc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> sortByLastAchievementDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAchievementDate', Sort.asc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> sortByLastAchievementDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAchievementDate', Sort.desc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> sortByLastReadingDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadingDate', Sort.asc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> sortByLastReadingDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadingDate', Sort.desc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> sortByLongestStreakDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestStreakDays', Sort.asc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> sortByLongestStreakDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestStreakDays', Sort.desc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> sortByLongestStreakEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestStreakEnd', Sort.asc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> sortByLongestStreakEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestStreakEnd', Sort.desc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> sortByLongestStreakStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestStreakStart', Sort.asc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> sortByLongestStreakStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestStreakStart', Sort.desc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> sortByTotalBooksRead() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalBooksRead', Sort.asc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> sortByTotalBooksReadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalBooksRead', Sort.desc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> sortByTotalPagesRead() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPagesRead', Sort.asc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> sortByTotalPagesReadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPagesRead', Sort.desc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> sortByTotalReadingDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalReadingDays', Sort.asc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> sortByTotalReadingDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalReadingDays', Sort.desc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension ReadingGamificationEntityQuerySortThenBy on QueryBuilder<
    ReadingGamificationEntity, ReadingGamificationEntity, QSortThenBy> {
  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> thenByCurrentStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.asc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> thenByCurrentStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.desc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> thenByLastAchievementDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAchievementDate', Sort.asc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> thenByLastAchievementDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAchievementDate', Sort.desc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> thenByLastReadingDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadingDate', Sort.asc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> thenByLastReadingDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadingDate', Sort.desc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> thenByLongestStreakDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestStreakDays', Sort.asc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> thenByLongestStreakDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestStreakDays', Sort.desc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> thenByLongestStreakEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestStreakEnd', Sort.asc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> thenByLongestStreakEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestStreakEnd', Sort.desc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> thenByLongestStreakStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestStreakStart', Sort.asc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> thenByLongestStreakStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestStreakStart', Sort.desc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> thenByTotalBooksRead() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalBooksRead', Sort.asc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> thenByTotalBooksReadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalBooksRead', Sort.desc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> thenByTotalPagesRead() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPagesRead', Sort.asc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> thenByTotalPagesReadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPagesRead', Sort.desc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> thenByTotalReadingDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalReadingDays', Sort.asc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> thenByTotalReadingDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalReadingDays', Sort.desc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension ReadingGamificationEntityQueryWhereDistinct on QueryBuilder<
    ReadingGamificationEntity, ReadingGamificationEntity, QDistinct> {
  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity, QDistinct>
      distinctByCurrentStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentStreak');
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity, QDistinct>
      distinctByLastAchievementDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastAchievementDate');
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity, QDistinct>
      distinctByLastReadingDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastReadingDate');
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity, QDistinct>
      distinctByLongestStreakDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'longestStreakDays');
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity, QDistinct>
      distinctByLongestStreakEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'longestStreakEnd');
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity, QDistinct>
      distinctByLongestStreakStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'longestStreakStart');
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity, QDistinct>
      distinctByTotalBooksRead() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalBooksRead');
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity, QDistinct>
      distinctByTotalPagesRead() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalPagesRead');
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity, QDistinct>
      distinctByTotalReadingDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalReadingDays');
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity, QDistinct>
      distinctByUnlockedAchievements() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unlockedAchievements');
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity, QDistinct>
      distinctByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension ReadingGamificationEntityQueryProperty on QueryBuilder<
    ReadingGamificationEntity, ReadingGamificationEntity, QQueryProperty> {
  QueryBuilder<ReadingGamificationEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ReadingGamificationEntity, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<ReadingGamificationEntity, int, QQueryOperations>
      currentStreakProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentStreak');
    });
  }

  QueryBuilder<ReadingGamificationEntity, DateTime?, QQueryOperations>
      lastAchievementDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastAchievementDate');
    });
  }

  QueryBuilder<ReadingGamificationEntity, DateTime?, QQueryOperations>
      lastReadingDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastReadingDate');
    });
  }

  QueryBuilder<ReadingGamificationEntity, int, QQueryOperations>
      longestStreakDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'longestStreakDays');
    });
  }

  QueryBuilder<ReadingGamificationEntity, DateTime?, QQueryOperations>
      longestStreakEndProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'longestStreakEnd');
    });
  }

  QueryBuilder<ReadingGamificationEntity, DateTime?, QQueryOperations>
      longestStreakStartProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'longestStreakStart');
    });
  }

  QueryBuilder<ReadingGamificationEntity, int, QQueryOperations>
      totalBooksReadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalBooksRead');
    });
  }

  QueryBuilder<ReadingGamificationEntity, int, QQueryOperations>
      totalPagesReadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalPagesRead');
    });
  }

  QueryBuilder<ReadingGamificationEntity, int, QQueryOperations>
      totalReadingDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalReadingDays');
    });
  }

  QueryBuilder<ReadingGamificationEntity, List<String>, QQueryOperations>
      unlockedAchievementsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unlockedAchievements');
    });
  }

  QueryBuilder<ReadingGamificationEntity, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<ReadingGamificationEntity, String, QQueryOperations>
      userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}
