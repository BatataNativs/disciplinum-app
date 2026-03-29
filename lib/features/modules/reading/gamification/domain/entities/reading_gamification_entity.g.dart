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
    r'consecutiveDays': PropertySchema(
      id: 0,
      name: r'consecutiveDays',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'earnedInsignias': PropertySchema(
      id: 2,
      name: r'earnedInsignias',
      type: IsarType.string,
    ),
    r'earnedInsigniasList': PropertySchema(
      id: 3,
      name: r'earnedInsigniasList',
      type: IsarType.stringList,
    ),
    r'earnedMedalhas': PropertySchema(
      id: 4,
      name: r'earnedMedalhas',
      type: IsarType.string,
    ),
    r'earnedMedalhasList': PropertySchema(
      id: 5,
      name: r'earnedMedalhasList',
      type: IsarType.stringList,
    ),
    r'lastReadingDate': PropertySchema(
      id: 6,
      name: r'lastReadingDate',
      type: IsarType.dateTime,
    ),
    r'startDate': PropertySchema(
      id: 7,
      name: r'startDate',
      type: IsarType.dateTime,
    ),
    r'updatedAt': PropertySchema(
      id: 8,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _readingGamificationEntityEstimateSize,
  serialize: _readingGamificationEntitySerialize,
  deserialize: _readingGamificationEntityDeserialize,
  deserializeProp: _readingGamificationEntityDeserializeProp,
  idName: r'id',
  indexes: {},
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
  bytesCount += 3 + object.earnedInsignias.length * 3;
  bytesCount += 3 + object.earnedInsigniasList.length * 3;
  {
    for (var i = 0; i < object.earnedInsigniasList.length; i++) {
      final value = object.earnedInsigniasList[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.earnedMedalhas.length * 3;
  bytesCount += 3 + object.earnedMedalhasList.length * 3;
  {
    for (var i = 0; i < object.earnedMedalhasList.length; i++) {
      final value = object.earnedMedalhasList[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _readingGamificationEntitySerialize(
  ReadingGamificationEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.consecutiveDays);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.earnedInsignias);
  writer.writeStringList(offsets[3], object.earnedInsigniasList);
  writer.writeString(offsets[4], object.earnedMedalhas);
  writer.writeStringList(offsets[5], object.earnedMedalhasList);
  writer.writeDateTime(offsets[6], object.lastReadingDate);
  writer.writeDateTime(offsets[7], object.startDate);
  writer.writeDateTime(offsets[8], object.updatedAt);
}

ReadingGamificationEntity _readingGamificationEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ReadingGamificationEntity();
  object.consecutiveDays = reader.readLong(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.earnedInsignias = reader.readString(offsets[2]);
  object.earnedInsigniasList = reader.readStringList(offsets[3]) ?? [];
  object.earnedMedalhas = reader.readString(offsets[4]);
  object.earnedMedalhasList = reader.readStringList(offsets[5]) ?? [];
  object.id = id;
  object.lastReadingDate = reader.readDateTimeOrNull(offsets[6]);
  object.startDate = reader.readDateTimeOrNull(offsets[7]);
  object.updatedAt = reader.readDateTime(offsets[8]);
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
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readStringList(offset) ?? []) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readStringList(offset) ?? []) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
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
}

extension ReadingGamificationEntityQueryFilter on QueryBuilder<
    ReadingGamificationEntity, ReadingGamificationEntity, QFilterCondition> {
  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> consecutiveDaysEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'consecutiveDays',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> consecutiveDaysGreaterThan(
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

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> consecutiveDaysLessThan(
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

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> consecutiveDaysBetween(
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
      QAfterFilterCondition> earnedInsigniasEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'earnedInsignias',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> earnedInsigniasGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'earnedInsignias',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> earnedInsigniasLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'earnedInsignias',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> earnedInsigniasBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'earnedInsignias',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> earnedInsigniasStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'earnedInsignias',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> earnedInsigniasEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'earnedInsignias',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
          QAfterFilterCondition>
      earnedInsigniasContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'earnedInsignias',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
          QAfterFilterCondition>
      earnedInsigniasMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'earnedInsignias',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> earnedInsigniasIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'earnedInsignias',
        value: '',
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> earnedInsigniasIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'earnedInsignias',
        value: '',
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> earnedInsigniasListElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'earnedInsigniasList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> earnedInsigniasListElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'earnedInsigniasList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> earnedInsigniasListElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'earnedInsigniasList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> earnedInsigniasListElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'earnedInsigniasList',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> earnedInsigniasListElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'earnedInsigniasList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> earnedInsigniasListElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'earnedInsigniasList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
          QAfterFilterCondition>
      earnedInsigniasListElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'earnedInsigniasList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
          QAfterFilterCondition>
      earnedInsigniasListElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'earnedInsigniasList',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> earnedInsigniasListElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'earnedInsigniasList',
        value: '',
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> earnedInsigniasListElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'earnedInsigniasList',
        value: '',
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> earnedInsigniasListLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedInsigniasList',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> earnedInsigniasListIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedInsigniasList',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> earnedInsigniasListIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedInsigniasList',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> earnedInsigniasListLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedInsigniasList',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> earnedInsigniasListLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedInsigniasList',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> earnedInsigniasListLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedInsigniasList',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> earnedMedalhasEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'earnedMedalhas',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> earnedMedalhasGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'earnedMedalhas',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> earnedMedalhasLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'earnedMedalhas',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> earnedMedalhasBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'earnedMedalhas',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> earnedMedalhasStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'earnedMedalhas',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> earnedMedalhasEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'earnedMedalhas',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
          QAfterFilterCondition>
      earnedMedalhasContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'earnedMedalhas',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
          QAfterFilterCondition>
      earnedMedalhasMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'earnedMedalhas',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> earnedMedalhasIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'earnedMedalhas',
        value: '',
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> earnedMedalhasIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'earnedMedalhas',
        value: '',
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> earnedMedalhasListElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'earnedMedalhasList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> earnedMedalhasListElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'earnedMedalhasList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> earnedMedalhasListElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'earnedMedalhasList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> earnedMedalhasListElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'earnedMedalhasList',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> earnedMedalhasListElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'earnedMedalhasList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> earnedMedalhasListElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'earnedMedalhasList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
          QAfterFilterCondition>
      earnedMedalhasListElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'earnedMedalhasList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
          QAfterFilterCondition>
      earnedMedalhasListElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'earnedMedalhasList',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> earnedMedalhasListElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'earnedMedalhasList',
        value: '',
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> earnedMedalhasListElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'earnedMedalhasList',
        value: '',
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> earnedMedalhasListLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedMedalhasList',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> earnedMedalhasListIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedMedalhasList',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> earnedMedalhasListIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedMedalhasList',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> earnedMedalhasListLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedMedalhasList',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> earnedMedalhasListLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedMedalhasList',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> earnedMedalhasListLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedMedalhasList',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
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
      QAfterFilterCondition> startDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'startDate',
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> startDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'startDate',
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> startDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> startDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> startDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterFilterCondition> startDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
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
}

extension ReadingGamificationEntityQueryObject on QueryBuilder<
    ReadingGamificationEntity, ReadingGamificationEntity, QFilterCondition> {}

extension ReadingGamificationEntityQueryLinks on QueryBuilder<
    ReadingGamificationEntity, ReadingGamificationEntity, QFilterCondition> {}

extension ReadingGamificationEntityQuerySortBy on QueryBuilder<
    ReadingGamificationEntity, ReadingGamificationEntity, QSortBy> {
  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> sortByConsecutiveDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consecutiveDays', Sort.asc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> sortByConsecutiveDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consecutiveDays', Sort.desc);
    });
  }

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
      QAfterSortBy> sortByEarnedInsignias() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earnedInsignias', Sort.asc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> sortByEarnedInsigniasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earnedInsignias', Sort.desc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> sortByEarnedMedalhas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earnedMedalhas', Sort.asc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> sortByEarnedMedalhasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earnedMedalhas', Sort.desc);
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
      QAfterSortBy> sortByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> sortByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
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
}

extension ReadingGamificationEntityQuerySortThenBy on QueryBuilder<
    ReadingGamificationEntity, ReadingGamificationEntity, QSortThenBy> {
  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> thenByConsecutiveDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consecutiveDays', Sort.asc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> thenByConsecutiveDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consecutiveDays', Sort.desc);
    });
  }

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
      QAfterSortBy> thenByEarnedInsignias() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earnedInsignias', Sort.asc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> thenByEarnedInsigniasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earnedInsignias', Sort.desc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> thenByEarnedMedalhas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earnedMedalhas', Sort.asc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> thenByEarnedMedalhasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earnedMedalhas', Sort.desc);
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
      QAfterSortBy> thenByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity,
      QAfterSortBy> thenByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
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
}

extension ReadingGamificationEntityQueryWhereDistinct on QueryBuilder<
    ReadingGamificationEntity, ReadingGamificationEntity, QDistinct> {
  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity, QDistinct>
      distinctByConsecutiveDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'consecutiveDays');
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity, QDistinct>
      distinctByEarnedInsignias({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'earnedInsignias',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity, QDistinct>
      distinctByEarnedInsigniasList() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'earnedInsigniasList');
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity, QDistinct>
      distinctByEarnedMedalhas({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'earnedMedalhas',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity, QDistinct>
      distinctByEarnedMedalhasList() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'earnedMedalhasList');
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity, QDistinct>
      distinctByLastReadingDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastReadingDate');
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity, QDistinct>
      distinctByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startDate');
    });
  }

  QueryBuilder<ReadingGamificationEntity, ReadingGamificationEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
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

  QueryBuilder<ReadingGamificationEntity, int, QQueryOperations>
      consecutiveDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'consecutiveDays');
    });
  }

  QueryBuilder<ReadingGamificationEntity, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<ReadingGamificationEntity, String, QQueryOperations>
      earnedInsigniasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'earnedInsignias');
    });
  }

  QueryBuilder<ReadingGamificationEntity, List<String>, QQueryOperations>
      earnedInsigniasListProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'earnedInsigniasList');
    });
  }

  QueryBuilder<ReadingGamificationEntity, String, QQueryOperations>
      earnedMedalhasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'earnedMedalhas');
    });
  }

  QueryBuilder<ReadingGamificationEntity, List<String>, QQueryOperations>
      earnedMedalhasListProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'earnedMedalhasList');
    });
  }

  QueryBuilder<ReadingGamificationEntity, DateTime?, QQueryOperations>
      lastReadingDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastReadingDate');
    });
  }

  QueryBuilder<ReadingGamificationEntity, DateTime?, QQueryOperations>
      startDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startDate');
    });
  }

  QueryBuilder<ReadingGamificationEntity, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
