// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'iap_entitlement.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIapEntitlementCollection on Isar {
  IsarCollection<IapEntitlement> get iapEntitlements => this.collection();
}

const IapEntitlementSchema = CollectionSchema(
  name: r'IapEntitlement',
  id: -2435884170834850202,
  properties: {
    r'daysRemaining': PropertySchema(
      id: 0,
      name: r'daysRemaining',
      type: IsarType.long,
    ),
    r'expirationDate': PropertySchema(
      id: 1,
      name: r'expirationDate',
      type: IsarType.dateTime,
    ),
    r'isExpired': PropertySchema(
      id: 2,
      name: r'isExpired',
      type: IsarType.bool,
    ),
    r'isPermanent': PropertySchema(
      id: 3,
      name: r'isPermanent',
      type: IsarType.bool,
    ),
    r'isPurchased': PropertySchema(
      id: 4,
      name: r'isPurchased',
      type: IsarType.bool,
    ),
    r'isValid': PropertySchema(
      id: 5,
      name: r'isValid',
      type: IsarType.bool,
    ),
    r'isVerified': PropertySchema(
      id: 6,
      name: r'isVerified',
      type: IsarType.bool,
    ),
    r'productId': PropertySchema(
      id: 7,
      name: r'productId',
      type: IsarType.string,
    ),
    r'purchaseDate': PropertySchema(
      id: 8,
      name: r'purchaseDate',
      type: IsarType.dateTime,
    ),
    r'verificationToken': PropertySchema(
      id: 9,
      name: r'verificationToken',
      type: IsarType.string,
    )
  },
  estimateSize: _iapEntitlementEstimateSize,
  serialize: _iapEntitlementSerialize,
  deserialize: _iapEntitlementDeserialize,
  deserializeProp: _iapEntitlementDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _iapEntitlementGetId,
  getLinks: _iapEntitlementGetLinks,
  attach: _iapEntitlementAttach,
  version: '3.1.0+1',
);

int _iapEntitlementEstimateSize(
  IapEntitlement object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.productId.length * 3;
  {
    final value = object.verificationToken;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _iapEntitlementSerialize(
  IapEntitlement object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.daysRemaining);
  writer.writeDateTime(offsets[1], object.expirationDate);
  writer.writeBool(offsets[2], object.isExpired);
  writer.writeBool(offsets[3], object.isPermanent);
  writer.writeBool(offsets[4], object.isPurchased);
  writer.writeBool(offsets[5], object.isValid);
  writer.writeBool(offsets[6], object.isVerified);
  writer.writeString(offsets[7], object.productId);
  writer.writeDateTime(offsets[8], object.purchaseDate);
  writer.writeString(offsets[9], object.verificationToken);
}

IapEntitlement _iapEntitlementDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IapEntitlement(
    expirationDate: reader.readDateTimeOrNull(offsets[1]),
    isPurchased: reader.readBool(offsets[4]),
    isVerified: reader.readBoolOrNull(offsets[6]) ?? false,
    productId: reader.readString(offsets[7]),
    purchaseDate: reader.readDateTime(offsets[8]),
    verificationToken: reader.readStringOrNull(offsets[9]),
  );
  object.id = id;
  return object;
}

P _iapEntitlementDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _iapEntitlementGetId(IapEntitlement object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _iapEntitlementGetLinks(IapEntitlement object) {
  return [];
}

void _iapEntitlementAttach(
    IsarCollection<dynamic> col, Id id, IapEntitlement object) {
  object.id = id;
}

extension IapEntitlementQueryWhereSort
    on QueryBuilder<IapEntitlement, IapEntitlement, QWhere> {
  QueryBuilder<IapEntitlement, IapEntitlement, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IapEntitlementQueryWhere
    on QueryBuilder<IapEntitlement, IapEntitlement, QWhereClause> {
  QueryBuilder<IapEntitlement, IapEntitlement, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterWhereClause> idBetween(
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

extension IapEntitlementQueryFilter
    on QueryBuilder<IapEntitlement, IapEntitlement, QFilterCondition> {
  QueryBuilder<IapEntitlement, IapEntitlement, QAfterFilterCondition>
      daysRemainingIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'daysRemaining',
      ));
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterFilterCondition>
      daysRemainingIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'daysRemaining',
      ));
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterFilterCondition>
      daysRemainingEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'daysRemaining',
        value: value,
      ));
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterFilterCondition>
      daysRemainingGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'daysRemaining',
        value: value,
      ));
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterFilterCondition>
      daysRemainingLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'daysRemaining',
        value: value,
      ));
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterFilterCondition>
      daysRemainingBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'daysRemaining',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterFilterCondition>
      expirationDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'expirationDate',
      ));
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterFilterCondition>
      expirationDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'expirationDate',
      ));
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterFilterCondition>
      expirationDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expirationDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterFilterCondition>
      expirationDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'expirationDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterFilterCondition>
      expirationDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'expirationDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterFilterCondition>
      expirationDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'expirationDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterFilterCondition>
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

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterFilterCondition>
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

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterFilterCondition> idBetween(
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

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterFilterCondition>
      isExpiredEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isExpired',
        value: value,
      ));
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterFilterCondition>
      isPermanentEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPermanent',
        value: value,
      ));
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterFilterCondition>
      isPurchasedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPurchased',
        value: value,
      ));
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterFilterCondition>
      isValidEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isValid',
        value: value,
      ));
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterFilterCondition>
      isVerifiedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isVerified',
        value: value,
      ));
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterFilterCondition>
      productIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterFilterCondition>
      productIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'productId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterFilterCondition>
      productIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'productId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterFilterCondition>
      productIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'productId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterFilterCondition>
      productIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'productId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterFilterCondition>
      productIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'productId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterFilterCondition>
      productIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'productId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterFilterCondition>
      productIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'productId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterFilterCondition>
      productIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productId',
        value: '',
      ));
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterFilterCondition>
      productIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'productId',
        value: '',
      ));
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterFilterCondition>
      purchaseDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'purchaseDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterFilterCondition>
      purchaseDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'purchaseDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterFilterCondition>
      purchaseDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'purchaseDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterFilterCondition>
      purchaseDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'purchaseDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterFilterCondition>
      verificationTokenIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'verificationToken',
      ));
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterFilterCondition>
      verificationTokenIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'verificationToken',
      ));
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterFilterCondition>
      verificationTokenEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'verificationToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterFilterCondition>
      verificationTokenGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'verificationToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterFilterCondition>
      verificationTokenLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'verificationToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterFilterCondition>
      verificationTokenBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'verificationToken',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterFilterCondition>
      verificationTokenStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'verificationToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterFilterCondition>
      verificationTokenEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'verificationToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterFilterCondition>
      verificationTokenContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'verificationToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterFilterCondition>
      verificationTokenMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'verificationToken',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterFilterCondition>
      verificationTokenIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'verificationToken',
        value: '',
      ));
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterFilterCondition>
      verificationTokenIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'verificationToken',
        value: '',
      ));
    });
  }
}

extension IapEntitlementQueryObject
    on QueryBuilder<IapEntitlement, IapEntitlement, QFilterCondition> {}

extension IapEntitlementQueryLinks
    on QueryBuilder<IapEntitlement, IapEntitlement, QFilterCondition> {}

extension IapEntitlementQuerySortBy
    on QueryBuilder<IapEntitlement, IapEntitlement, QSortBy> {
  QueryBuilder<IapEntitlement, IapEntitlement, QAfterSortBy>
      sortByDaysRemaining() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'daysRemaining', Sort.asc);
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterSortBy>
      sortByDaysRemainingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'daysRemaining', Sort.desc);
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterSortBy>
      sortByExpirationDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expirationDate', Sort.asc);
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterSortBy>
      sortByExpirationDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expirationDate', Sort.desc);
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterSortBy> sortByIsExpired() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isExpired', Sort.asc);
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterSortBy>
      sortByIsExpiredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isExpired', Sort.desc);
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterSortBy>
      sortByIsPermanent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPermanent', Sort.asc);
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterSortBy>
      sortByIsPermanentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPermanent', Sort.desc);
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterSortBy>
      sortByIsPurchased() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPurchased', Sort.asc);
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterSortBy>
      sortByIsPurchasedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPurchased', Sort.desc);
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterSortBy> sortByIsValid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isValid', Sort.asc);
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterSortBy>
      sortByIsValidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isValid', Sort.desc);
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterSortBy>
      sortByIsVerified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isVerified', Sort.asc);
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterSortBy>
      sortByIsVerifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isVerified', Sort.desc);
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterSortBy> sortByProductId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productId', Sort.asc);
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterSortBy>
      sortByProductIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productId', Sort.desc);
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterSortBy>
      sortByPurchaseDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchaseDate', Sort.asc);
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterSortBy>
      sortByPurchaseDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchaseDate', Sort.desc);
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterSortBy>
      sortByVerificationToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificationToken', Sort.asc);
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterSortBy>
      sortByVerificationTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificationToken', Sort.desc);
    });
  }
}

extension IapEntitlementQuerySortThenBy
    on QueryBuilder<IapEntitlement, IapEntitlement, QSortThenBy> {
  QueryBuilder<IapEntitlement, IapEntitlement, QAfterSortBy>
      thenByDaysRemaining() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'daysRemaining', Sort.asc);
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterSortBy>
      thenByDaysRemainingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'daysRemaining', Sort.desc);
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterSortBy>
      thenByExpirationDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expirationDate', Sort.asc);
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterSortBy>
      thenByExpirationDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expirationDate', Sort.desc);
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterSortBy> thenByIsExpired() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isExpired', Sort.asc);
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterSortBy>
      thenByIsExpiredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isExpired', Sort.desc);
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterSortBy>
      thenByIsPermanent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPermanent', Sort.asc);
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterSortBy>
      thenByIsPermanentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPermanent', Sort.desc);
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterSortBy>
      thenByIsPurchased() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPurchased', Sort.asc);
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterSortBy>
      thenByIsPurchasedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPurchased', Sort.desc);
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterSortBy> thenByIsValid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isValid', Sort.asc);
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterSortBy>
      thenByIsValidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isValid', Sort.desc);
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterSortBy>
      thenByIsVerified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isVerified', Sort.asc);
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterSortBy>
      thenByIsVerifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isVerified', Sort.desc);
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterSortBy> thenByProductId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productId', Sort.asc);
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterSortBy>
      thenByProductIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productId', Sort.desc);
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterSortBy>
      thenByPurchaseDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchaseDate', Sort.asc);
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterSortBy>
      thenByPurchaseDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchaseDate', Sort.desc);
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterSortBy>
      thenByVerificationToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificationToken', Sort.asc);
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QAfterSortBy>
      thenByVerificationTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificationToken', Sort.desc);
    });
  }
}

extension IapEntitlementQueryWhereDistinct
    on QueryBuilder<IapEntitlement, IapEntitlement, QDistinct> {
  QueryBuilder<IapEntitlement, IapEntitlement, QDistinct>
      distinctByDaysRemaining() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'daysRemaining');
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QDistinct>
      distinctByExpirationDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expirationDate');
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QDistinct>
      distinctByIsExpired() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isExpired');
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QDistinct>
      distinctByIsPermanent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPermanent');
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QDistinct>
      distinctByIsPurchased() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPurchased');
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QDistinct> distinctByIsValid() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isValid');
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QDistinct>
      distinctByIsVerified() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isVerified');
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QDistinct> distinctByProductId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'productId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QDistinct>
      distinctByPurchaseDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'purchaseDate');
    });
  }

  QueryBuilder<IapEntitlement, IapEntitlement, QDistinct>
      distinctByVerificationToken({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'verificationToken',
          caseSensitive: caseSensitive);
    });
  }
}

extension IapEntitlementQueryProperty
    on QueryBuilder<IapEntitlement, IapEntitlement, QQueryProperty> {
  QueryBuilder<IapEntitlement, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IapEntitlement, int?, QQueryOperations> daysRemainingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'daysRemaining');
    });
  }

  QueryBuilder<IapEntitlement, DateTime?, QQueryOperations>
      expirationDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expirationDate');
    });
  }

  QueryBuilder<IapEntitlement, bool, QQueryOperations> isExpiredProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isExpired');
    });
  }

  QueryBuilder<IapEntitlement, bool, QQueryOperations> isPermanentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPermanent');
    });
  }

  QueryBuilder<IapEntitlement, bool, QQueryOperations> isPurchasedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPurchased');
    });
  }

  QueryBuilder<IapEntitlement, bool, QQueryOperations> isValidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isValid');
    });
  }

  QueryBuilder<IapEntitlement, bool, QQueryOperations> isVerifiedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isVerified');
    });
  }

  QueryBuilder<IapEntitlement, String, QQueryOperations> productIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'productId');
    });
  }

  QueryBuilder<IapEntitlement, DateTime, QQueryOperations>
      purchaseDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'purchaseDate');
    });
  }

  QueryBuilder<IapEntitlement, String?, QQueryOperations>
      verificationTokenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'verificationToken');
    });
  }
}
