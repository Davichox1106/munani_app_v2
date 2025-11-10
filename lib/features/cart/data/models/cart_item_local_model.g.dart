// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item_local_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCartItemLocalModelCollection on Isar {
  IsarCollection<CartItemLocalModel> get cartItemLocalModels =>
      this.collection();
}

const CartItemLocalModelSchema = CollectionSchema(
  name: r'CartItemLocalModel',
  id: -1263616705203058402,
  properties: {
    r'availableQuantity': PropertySchema(
      id: 0,
      name: r'availableQuantity',
      type: IsarType.long,
    ),
    r'cartId': PropertySchema(
      id: 1,
      name: r'cartId',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'imageUrls': PropertySchema(
      id: 3,
      name: r'imageUrls',
      type: IsarType.stringList,
    ),
    r'inventoryId': PropertySchema(
      id: 4,
      name: r'inventoryId',
      type: IsarType.string,
    ),
    r'productName': PropertySchema(
      id: 5,
      name: r'productName',
      type: IsarType.string,
    ),
    r'productVariantId': PropertySchema(
      id: 6,
      name: r'productVariantId',
      type: IsarType.string,
    ),
    r'quantity': PropertySchema(
      id: 7,
      name: r'quantity',
      type: IsarType.long,
    ),
    r'subtotal': PropertySchema(
      id: 8,
      name: r'subtotal',
      type: IsarType.double,
    ),
    r'unitPrice': PropertySchema(
      id: 9,
      name: r'unitPrice',
      type: IsarType.double,
    ),
    r'updatedAt': PropertySchema(
      id: 10,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'uuid': PropertySchema(
      id: 11,
      name: r'uuid',
      type: IsarType.string,
    ),
    r'variantName': PropertySchema(
      id: 12,
      name: r'variantName',
      type: IsarType.string,
    )
  },
  estimateSize: _cartItemLocalModelEstimateSize,
  serialize: _cartItemLocalModelSerialize,
  deserialize: _cartItemLocalModelDeserialize,
  deserializeProp: _cartItemLocalModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'uuid': IndexSchema(
      id: 2134397340427724972,
      name: r'uuid',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'uuid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'cartId': IndexSchema(
      id: 5525719335954350174,
      name: r'cartId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'cartId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'inventoryId': IndexSchema(
      id: 5580507021079049209,
      name: r'inventoryId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'inventoryId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _cartItemLocalModelGetId,
  getLinks: _cartItemLocalModelGetLinks,
  attach: _cartItemLocalModelAttach,
  version: '3.1.0+1',
);

int _cartItemLocalModelEstimateSize(
  CartItemLocalModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.cartId.length * 3;
  bytesCount += 3 + object.imageUrls.length * 3;
  {
    for (var i = 0; i < object.imageUrls.length; i++) {
      final value = object.imageUrls[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.inventoryId.length * 3;
  {
    final value = object.productName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.productVariantId.length * 3;
  bytesCount += 3 + object.uuid.length * 3;
  {
    final value = object.variantName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _cartItemLocalModelSerialize(
  CartItemLocalModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.availableQuantity);
  writer.writeString(offsets[1], object.cartId);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeStringList(offsets[3], object.imageUrls);
  writer.writeString(offsets[4], object.inventoryId);
  writer.writeString(offsets[5], object.productName);
  writer.writeString(offsets[6], object.productVariantId);
  writer.writeLong(offsets[7], object.quantity);
  writer.writeDouble(offsets[8], object.subtotal);
  writer.writeDouble(offsets[9], object.unitPrice);
  writer.writeDateTime(offsets[10], object.updatedAt);
  writer.writeString(offsets[11], object.uuid);
  writer.writeString(offsets[12], object.variantName);
}

CartItemLocalModel _cartItemLocalModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CartItemLocalModel();
  object.availableQuantity = reader.readLong(offsets[0]);
  object.cartId = reader.readString(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.id = id;
  object.imageUrls = reader.readStringList(offsets[3]) ?? [];
  object.inventoryId = reader.readString(offsets[4]);
  object.productName = reader.readStringOrNull(offsets[5]);
  object.productVariantId = reader.readString(offsets[6]);
  object.quantity = reader.readLong(offsets[7]);
  object.subtotal = reader.readDouble(offsets[8]);
  object.unitPrice = reader.readDouble(offsets[9]);
  object.updatedAt = reader.readDateTime(offsets[10]);
  object.uuid = reader.readString(offsets[11]);
  object.variantName = reader.readStringOrNull(offsets[12]);
  return object;
}

P _cartItemLocalModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readStringList(offset) ?? []) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readDouble(offset)) as P;
    case 9:
      return (reader.readDouble(offset)) as P;
    case 10:
      return (reader.readDateTime(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _cartItemLocalModelGetId(CartItemLocalModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _cartItemLocalModelGetLinks(
    CartItemLocalModel object) {
  return [];
}

void _cartItemLocalModelAttach(
    IsarCollection<dynamic> col, Id id, CartItemLocalModel object) {
  object.id = id;
}

extension CartItemLocalModelByIndex on IsarCollection<CartItemLocalModel> {
  Future<CartItemLocalModel?> getByUuid(String uuid) {
    return getByIndex(r'uuid', [uuid]);
  }

  CartItemLocalModel? getByUuidSync(String uuid) {
    return getByIndexSync(r'uuid', [uuid]);
  }

  Future<bool> deleteByUuid(String uuid) {
    return deleteByIndex(r'uuid', [uuid]);
  }

  bool deleteByUuidSync(String uuid) {
    return deleteByIndexSync(r'uuid', [uuid]);
  }

  Future<List<CartItemLocalModel?>> getAllByUuid(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uuid', values);
  }

  List<CartItemLocalModel?> getAllByUuidSync(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'uuid', values);
  }

  Future<int> deleteAllByUuid(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'uuid', values);
  }

  int deleteAllByUuidSync(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'uuid', values);
  }

  Future<Id> putByUuid(CartItemLocalModel object) {
    return putByIndex(r'uuid', object);
  }

  Id putByUuidSync(CartItemLocalModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'uuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUuid(List<CartItemLocalModel> objects) {
    return putAllByIndex(r'uuid', objects);
  }

  List<Id> putAllByUuidSync(List<CartItemLocalModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'uuid', objects, saveLinks: saveLinks);
  }
}

extension CartItemLocalModelQueryWhereSort
    on QueryBuilder<CartItemLocalModel, CartItemLocalModel, QWhere> {
  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CartItemLocalModelQueryWhere
    on QueryBuilder<CartItemLocalModel, CartItemLocalModel, QWhereClause> {
  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterWhereClause>
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

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterWhereClause>
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

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterWhereClause>
      uuidEqualTo(String uuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'uuid',
        value: [uuid],
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterWhereClause>
      uuidNotEqualTo(String uuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [],
              upper: [uuid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [uuid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [uuid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [],
              upper: [uuid],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterWhereClause>
      cartIdEqualTo(String cartId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'cartId',
        value: [cartId],
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterWhereClause>
      cartIdNotEqualTo(String cartId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cartId',
              lower: [],
              upper: [cartId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cartId',
              lower: [cartId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cartId',
              lower: [cartId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cartId',
              lower: [],
              upper: [cartId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterWhereClause>
      inventoryIdEqualTo(String inventoryId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'inventoryId',
        value: [inventoryId],
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterWhereClause>
      inventoryIdNotEqualTo(String inventoryId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'inventoryId',
              lower: [],
              upper: [inventoryId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'inventoryId',
              lower: [inventoryId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'inventoryId',
              lower: [inventoryId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'inventoryId',
              lower: [],
              upper: [inventoryId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension CartItemLocalModelQueryFilter
    on QueryBuilder<CartItemLocalModel, CartItemLocalModel, QFilterCondition> {
  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      availableQuantityEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'availableQuantity',
        value: value,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      availableQuantityGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'availableQuantity',
        value: value,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      availableQuantityLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'availableQuantity',
        value: value,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      availableQuantityBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'availableQuantity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      cartIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cartId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      cartIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cartId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      cartIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cartId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      cartIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cartId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      cartIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cartId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      cartIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cartId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      cartIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cartId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      cartIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cartId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      cartIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cartId',
        value: '',
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      cartIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cartId',
        value: '',
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
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

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
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

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
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

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
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

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
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

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
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

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      imageUrlsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imageUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      imageUrlsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'imageUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      imageUrlsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'imageUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      imageUrlsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'imageUrls',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      imageUrlsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'imageUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      imageUrlsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'imageUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      imageUrlsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'imageUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      imageUrlsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'imageUrls',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      imageUrlsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imageUrls',
        value: '',
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      imageUrlsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'imageUrls',
        value: '',
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      imageUrlsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imageUrls',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      imageUrlsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imageUrls',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      imageUrlsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imageUrls',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      imageUrlsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imageUrls',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      imageUrlsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imageUrls',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      imageUrlsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imageUrls',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      inventoryIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'inventoryId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      inventoryIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'inventoryId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      inventoryIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'inventoryId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      inventoryIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'inventoryId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      inventoryIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'inventoryId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      inventoryIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'inventoryId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      inventoryIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'inventoryId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      inventoryIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'inventoryId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      inventoryIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'inventoryId',
        value: '',
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      inventoryIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'inventoryId',
        value: '',
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      productNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'productName',
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      productNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'productName',
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      productNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      productNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'productName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      productNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'productName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      productNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'productName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      productNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'productName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      productNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'productName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      productNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'productName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      productNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'productName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      productNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productName',
        value: '',
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      productNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'productName',
        value: '',
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      productVariantIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productVariantId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      productVariantIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'productVariantId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      productVariantIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'productVariantId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      productVariantIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'productVariantId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      productVariantIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'productVariantId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      productVariantIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'productVariantId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      productVariantIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'productVariantId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      productVariantIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'productVariantId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      productVariantIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productVariantId',
        value: '',
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      productVariantIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'productVariantId',
        value: '',
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      quantityEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quantity',
        value: value,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      quantityGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'quantity',
        value: value,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      quantityLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'quantity',
        value: value,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      quantityBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'quantity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      subtotalEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subtotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      subtotalGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'subtotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      subtotalLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'subtotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      subtotalBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'subtotal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      unitPriceEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unitPrice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      unitPriceGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unitPrice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      unitPriceLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unitPrice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      unitPriceBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unitPrice',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
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

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
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

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
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

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      uuidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      uuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      uuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      uuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      uuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      uuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      uuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      uuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      uuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uuid',
        value: '',
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      uuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uuid',
        value: '',
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      variantNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'variantName',
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      variantNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'variantName',
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      variantNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'variantName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      variantNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'variantName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      variantNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'variantName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      variantNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'variantName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      variantNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'variantName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      variantNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'variantName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      variantNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'variantName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      variantNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'variantName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      variantNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'variantName',
        value: '',
      ));
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterFilterCondition>
      variantNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'variantName',
        value: '',
      ));
    });
  }
}

extension CartItemLocalModelQueryObject
    on QueryBuilder<CartItemLocalModel, CartItemLocalModel, QFilterCondition> {}

extension CartItemLocalModelQueryLinks
    on QueryBuilder<CartItemLocalModel, CartItemLocalModel, QFilterCondition> {}

extension CartItemLocalModelQuerySortBy
    on QueryBuilder<CartItemLocalModel, CartItemLocalModel, QSortBy> {
  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      sortByAvailableQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'availableQuantity', Sort.asc);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      sortByAvailableQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'availableQuantity', Sort.desc);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      sortByCartId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cartId', Sort.asc);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      sortByCartIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cartId', Sort.desc);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      sortByInventoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inventoryId', Sort.asc);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      sortByInventoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inventoryId', Sort.desc);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      sortByProductName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productName', Sort.asc);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      sortByProductNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productName', Sort.desc);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      sortByProductVariantId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productVariantId', Sort.asc);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      sortByProductVariantIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productVariantId', Sort.desc);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      sortByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      sortByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      sortBySubtotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtotal', Sort.asc);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      sortBySubtotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtotal', Sort.desc);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      sortByUnitPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unitPrice', Sort.asc);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      sortByUnitPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unitPrice', Sort.desc);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      sortByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      sortByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      sortByVariantName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'variantName', Sort.asc);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      sortByVariantNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'variantName', Sort.desc);
    });
  }
}

extension CartItemLocalModelQuerySortThenBy
    on QueryBuilder<CartItemLocalModel, CartItemLocalModel, QSortThenBy> {
  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      thenByAvailableQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'availableQuantity', Sort.asc);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      thenByAvailableQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'availableQuantity', Sort.desc);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      thenByCartId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cartId', Sort.asc);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      thenByCartIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cartId', Sort.desc);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      thenByInventoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inventoryId', Sort.asc);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      thenByInventoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inventoryId', Sort.desc);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      thenByProductName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productName', Sort.asc);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      thenByProductNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productName', Sort.desc);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      thenByProductVariantId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productVariantId', Sort.asc);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      thenByProductVariantIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productVariantId', Sort.desc);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      thenByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      thenByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      thenBySubtotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtotal', Sort.asc);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      thenBySubtotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtotal', Sort.desc);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      thenByUnitPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unitPrice', Sort.asc);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      thenByUnitPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unitPrice', Sort.desc);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      thenByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      thenByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      thenByVariantName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'variantName', Sort.asc);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QAfterSortBy>
      thenByVariantNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'variantName', Sort.desc);
    });
  }
}

extension CartItemLocalModelQueryWhereDistinct
    on QueryBuilder<CartItemLocalModel, CartItemLocalModel, QDistinct> {
  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QDistinct>
      distinctByAvailableQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'availableQuantity');
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QDistinct>
      distinctByCartId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cartId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QDistinct>
      distinctByImageUrls() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'imageUrls');
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QDistinct>
      distinctByInventoryId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'inventoryId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QDistinct>
      distinctByProductName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'productName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QDistinct>
      distinctByProductVariantId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'productVariantId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QDistinct>
      distinctByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quantity');
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QDistinct>
      distinctBySubtotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subtotal');
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QDistinct>
      distinctByUnitPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unitPrice');
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QDistinct>
      distinctByUuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CartItemLocalModel, CartItemLocalModel, QDistinct>
      distinctByVariantName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'variantName', caseSensitive: caseSensitive);
    });
  }
}

extension CartItemLocalModelQueryProperty
    on QueryBuilder<CartItemLocalModel, CartItemLocalModel, QQueryProperty> {
  QueryBuilder<CartItemLocalModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CartItemLocalModel, int, QQueryOperations>
      availableQuantityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'availableQuantity');
    });
  }

  QueryBuilder<CartItemLocalModel, String, QQueryOperations> cartIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cartId');
    });
  }

  QueryBuilder<CartItemLocalModel, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<CartItemLocalModel, List<String>, QQueryOperations>
      imageUrlsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'imageUrls');
    });
  }

  QueryBuilder<CartItemLocalModel, String, QQueryOperations>
      inventoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'inventoryId');
    });
  }

  QueryBuilder<CartItemLocalModel, String?, QQueryOperations>
      productNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'productName');
    });
  }

  QueryBuilder<CartItemLocalModel, String, QQueryOperations>
      productVariantIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'productVariantId');
    });
  }

  QueryBuilder<CartItemLocalModel, int, QQueryOperations> quantityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quantity');
    });
  }

  QueryBuilder<CartItemLocalModel, double, QQueryOperations>
      subtotalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subtotal');
    });
  }

  QueryBuilder<CartItemLocalModel, double, QQueryOperations>
      unitPriceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unitPrice');
    });
  }

  QueryBuilder<CartItemLocalModel, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<CartItemLocalModel, String, QQueryOperations> uuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uuid');
    });
  }

  QueryBuilder<CartItemLocalModel, String?, QQueryOperations>
      variantNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'variantName');
    });
  }
}
