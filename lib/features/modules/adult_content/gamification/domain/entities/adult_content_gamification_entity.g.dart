// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adult_content_gamification_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAdultContentGamificationEntityCollection on Isar {
  IsarCollection<AdultContentGamificationEntity>
      get adultContentGamificationEntitys => this.collection();
}

const AdultContentGamificationEntitySchema = CollectionSchema(
  name: r'AdultContentGamificationEntity',
  id: -2703871913733835940,
  properties: {
    r'consecutiveDays': PropertySchema(
      id: 0,
      name: r'consecutiveDays',
      type: IsarType.long,
    ),
    r'disciplinumCount': PropertySchema(
      id: 1,
      name: r'disciplinumCount',
      type: IsarType.long,
    ),
    r'earnedInsignias': PropertySchema(
      id: 2,
      name: r'earnedInsignias',
      type: IsarType.stringList,
    ),
    r'earnedMedalhas': PropertySchema(
      id: 3,
      name: r'earnedMedalhas',
      type: IsarType.stringList,
    ),
    r'isActive': PropertySchema(
      id: 4,
      name: r'isActive',
      type: IsarType.bool,
    ),
    r'lastUpdated': PropertySchema(
      id: 5,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'userId': PropertySchema(
      id: 6,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _adultContentGamificationEntityEstimateSize,
  serialize: _adultContentGamificationEntitySerialize,
  deserialize: _adultContentGamificationEntityDeserialize,
  deserializeProp: _adultContentGamificationEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'userId': IndexSchema(
      id: -2005826577402374815,
      name: r'userId',
      unique: false,
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
  getId: _adultContentGamificationEntityGetId,
  getLinks: _adultContentGamificationEntityGetLinks,
  attach: _adultContentGamificationEntityAttach,
  version: '3.1.0+1',
);

int _adultContentGamificationEntityEstimateSize(
  AdultContentGamificationEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.earnedInsignias.length * 3;
  {
    for (var i = 0; i < object.earnedInsignias.length; i++) {
      final value = object.earnedInsignias[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.earnedMedalhas.length * 3;
  {
    for (var i = 0; i < object.earnedMedalhas.length; i++) {
      final value = object.earnedMedalhas[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _adultContentGamificationEntitySerialize(
  AdultContentGamificationEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.consecutiveDays);
  writer.writeLong(offsets[1], object.disciplinumCount);
  writer.writeStringList(offsets[2], object.earnedInsignias);
  writer.writeStringList(offsets[3], object.earnedMedalhas);
  writer.writeBool(offsets[4], object.isActive);
  writer.writeDateTime(offsets[5], object.lastUpdated);
  writer.writeString(offsets[6], object.userId);
}

AdultContentGamificationEntity _adultContentGamificationEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AdultContentGamificationEntity(
    consecutiveDays: reader.readLongOrNull(offsets[0]) ?? 0,
    disciplinumCount: reader.readLongOrNull(offsets[1]) ?? 0,
    earnedInsignias: reader.readStringList(offsets[2]) ?? const [],
    earnedMedalhas: reader.readStringList(offsets[3]) ?? const [],
    isActive: reader.readBoolOrNull(offsets[4]) ?? true,
    lastUpdated: reader.readDateTime(offsets[5]),
    userId: reader.readString(offsets[6]),
  );
  return object;
}

P _adultContentGamificationEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 1:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 2:
      return (reader.readStringList(offset) ?? const []) as P;
    case 3:
      return (reader.readStringList(offset) ?? const []) as P;
    case 4:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _adultContentGamificationEntityGetId(AdultContentGamificationEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _adultContentGamificationEntityGetLinks(
    AdultContentGamificationEntity object) {
  return [];
}

void _adultContentGamificationEntityAttach(IsarCollection<dynamic> col, Id id,
    AdultContentGamificationEntity object) {}

extension AdultContentGamificationEntityQueryWhereSort on QueryBuilder<
    AdultContentGamificationEntity, AdultContentGamificationEntity, QWhere> {
  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AdultContentGamificationEntityQueryWhere on QueryBuilder<
    AdultContentGamificationEntity,
    AdultContentGamificationEntity,
    QWhereClause> {
  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
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

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
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

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterWhereClause> userIdEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
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

extension AdultContentGamificationEntityQueryFilter on QueryBuilder<
    AdultContentGamificationEntity,
    AdultContentGamificationEntity,
    QFilterCondition> {
  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterFilterCondition> consecutiveDaysEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'consecutiveDays',
        value: value,
      ));
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
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

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
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

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
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

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterFilterCondition> disciplinumCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'disciplinumCount',
        value: value,
      ));
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterFilterCondition> disciplinumCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'disciplinumCount',
        value: value,
      ));
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterFilterCondition> disciplinumCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'disciplinumCount',
        value: value,
      ));
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterFilterCondition> disciplinumCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'disciplinumCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterFilterCondition> earnedInsigniasElementEqualTo(
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

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterFilterCondition> earnedInsigniasElementGreaterThan(
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

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterFilterCondition> earnedInsigniasElementLessThan(
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

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterFilterCondition> earnedInsigniasElementBetween(
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

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterFilterCondition> earnedInsigniasElementStartsWith(
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

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterFilterCondition> earnedInsigniasElementEndsWith(
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

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
          QAfterFilterCondition>
      earnedInsigniasElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'earnedInsignias',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
          QAfterFilterCondition>
      earnedInsigniasElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'earnedInsignias',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterFilterCondition> earnedInsigniasElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'earnedInsignias',
        value: '',
      ));
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterFilterCondition> earnedInsigniasElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'earnedInsignias',
        value: '',
      ));
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterFilterCondition> earnedInsigniasLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedInsignias',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterFilterCondition> earnedInsigniasIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedInsignias',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterFilterCondition> earnedInsigniasIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedInsignias',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterFilterCondition> earnedInsigniasLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedInsignias',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterFilterCondition> earnedInsigniasLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedInsignias',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterFilterCondition> earnedInsigniasLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedInsignias',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterFilterCondition> earnedMedalhasElementEqualTo(
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

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterFilterCondition> earnedMedalhasElementGreaterThan(
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

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterFilterCondition> earnedMedalhasElementLessThan(
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

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterFilterCondition> earnedMedalhasElementBetween(
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

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterFilterCondition> earnedMedalhasElementStartsWith(
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

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterFilterCondition> earnedMedalhasElementEndsWith(
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

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
          QAfterFilterCondition>
      earnedMedalhasElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'earnedMedalhas',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
          QAfterFilterCondition>
      earnedMedalhasElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'earnedMedalhas',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterFilterCondition> earnedMedalhasElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'earnedMedalhas',
        value: '',
      ));
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterFilterCondition> earnedMedalhasElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'earnedMedalhas',
        value: '',
      ));
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterFilterCondition> earnedMedalhasLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedMedalhas',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterFilterCondition> earnedMedalhasIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedMedalhas',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterFilterCondition> earnedMedalhasIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedMedalhas',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterFilterCondition> earnedMedalhasLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedMedalhas',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterFilterCondition> earnedMedalhasLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedMedalhas',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterFilterCondition> earnedMedalhasLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'earnedMedalhas',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
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

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
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

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
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

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterFilterCondition> isActiveEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isActive',
        value: value,
      ));
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterFilterCondition> lastUpdatedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterFilterCondition> lastUpdatedGreaterThan(
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

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterFilterCondition> lastUpdatedLessThan(
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

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterFilterCondition> lastUpdatedBetween(
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

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
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

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
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

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
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

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
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

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
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

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
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

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
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

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
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

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterFilterCondition> userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterFilterCondition> userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension AdultContentGamificationEntityQueryObject on QueryBuilder<
    AdultContentGamificationEntity,
    AdultContentGamificationEntity,
    QFilterCondition> {}

extension AdultContentGamificationEntityQueryLinks on QueryBuilder<
    AdultContentGamificationEntity,
    AdultContentGamificationEntity,
    QFilterCondition> {}

extension AdultContentGamificationEntityQuerySortBy on QueryBuilder<
    AdultContentGamificationEntity, AdultContentGamificationEntity, QSortBy> {
  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterSortBy> sortByConsecutiveDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consecutiveDays', Sort.asc);
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterSortBy> sortByConsecutiveDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consecutiveDays', Sort.desc);
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterSortBy> sortByDisciplinumCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disciplinumCount', Sort.asc);
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterSortBy> sortByDisciplinumCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disciplinumCount', Sort.desc);
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterSortBy> sortByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterSortBy> sortByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterSortBy> sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterSortBy> sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterSortBy> sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension AdultContentGamificationEntityQuerySortThenBy on QueryBuilder<
    AdultContentGamificationEntity,
    AdultContentGamificationEntity,
    QSortThenBy> {
  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterSortBy> thenByConsecutiveDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consecutiveDays', Sort.asc);
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterSortBy> thenByConsecutiveDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consecutiveDays', Sort.desc);
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterSortBy> thenByDisciplinumCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disciplinumCount', Sort.asc);
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterSortBy> thenByDisciplinumCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disciplinumCount', Sort.desc);
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterSortBy> thenByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterSortBy> thenByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterSortBy> thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterSortBy> thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QAfterSortBy> thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension AdultContentGamificationEntityQueryWhereDistinct on QueryBuilder<
    AdultContentGamificationEntity, AdultContentGamificationEntity, QDistinct> {
  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QDistinct> distinctByConsecutiveDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'consecutiveDays');
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QDistinct> distinctByDisciplinumCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'disciplinumCount');
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QDistinct> distinctByEarnedInsignias() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'earnedInsignias');
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QDistinct> distinctByEarnedMedalhas() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'earnedMedalhas');
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QDistinct> distinctByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isActive');
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QDistinct> distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<AdultContentGamificationEntity, AdultContentGamificationEntity,
      QDistinct> distinctByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension AdultContentGamificationEntityQueryProperty on QueryBuilder<
    AdultContentGamificationEntity,
    AdultContentGamificationEntity,
    QQueryProperty> {
  QueryBuilder<AdultContentGamificationEntity, int, QQueryOperations>
      idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AdultContentGamificationEntity, int, QQueryOperations>
      consecutiveDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'consecutiveDays');
    });
  }

  QueryBuilder<AdultContentGamificationEntity, int, QQueryOperations>
      disciplinumCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'disciplinumCount');
    });
  }

  QueryBuilder<AdultContentGamificationEntity, List<String>, QQueryOperations>
      earnedInsigniasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'earnedInsignias');
    });
  }

  QueryBuilder<AdultContentGamificationEntity, List<String>, QQueryOperations>
      earnedMedalhasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'earnedMedalhas');
    });
  }

  QueryBuilder<AdultContentGamificationEntity, bool, QQueryOperations>
      isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isActive');
    });
  }

  QueryBuilder<AdultContentGamificationEntity, DateTime, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<AdultContentGamificationEntity, String, QQueryOperations>
      userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}
