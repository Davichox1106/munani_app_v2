// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_variant_local_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetProductVariantLocalModelCollection on Isar {
  IsarCollection<ProductVariantLocalModel> get productVariantLocalModels =>
      this.collection();
}

const ProductVariantLocalModelSchema = CollectionSchema(
  name: r'ProductVariantLocalModel',
  id: 4255882384010663421,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'isActive': PropertySchema(
      id: 1,
      name: r'isActive',
      type: IsarType.bool,
    ),
    r'pendingSync': PropertySchema(
      id: 2,
      name: r'pendingSync',
      type: IsarType.bool,
    ),
    r'priceBuy': PropertySchema(
      id: 3,
      name: r'priceBuy',
      type: IsarType.double,
    ),
    r'priceSell': PropertySchema(
      id: 4,
      name: r'priceSell',
      type: IsarType.double,
    ),
    r'productId': PropertySchema(
      id: 5,
      name: r'productId',
      type: IsarType.string,
    ),
    r'sku': PropertySchema(
      id: 6,
      name: r'sku',
      type: IsarType.string,
    ),
    r'syncedAt': PropertySchema(
      id: 7,
      name: r'syncedAt',
      type: IsarType.dateTime,
    ),
    r'uuid': PropertySchema(
      id: 8,
      name: r'uuid',
      type: IsarType.string,
    ),
    r'variantAttributesJson': PropertySchema(
      id: 9,
      name: r'variantAttributesJson',
      type: IsarType.string,
    ),
    r'variantName': PropertySchema(
      id: 10,
      name: r'variantName',
      type: IsarType.string,
    )
  },
  estimateSize: _productVariantLocalModelEstimateSize,
  serialize: _productVariantLocalModelSerialize,
  deserialize: _productVariantLocalModelDeserialize,
  deserializeProp: _productVariantLocalModelDeserializeProp,
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
    r'productId': IndexSchema(
      id: 5580769080710688203,
      name: r'productId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'productId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'sku': IndexSchema(
      id: -3348042439688860591,
      name: r'sku',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'sku',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _productVariantLocalModelGetId,
  getLinks: _productVariantLocalModelGetLinks,
  attach: _productVariantLocalModelAttach,
  version: '3.1.0+1',
);

int _productVariantLocalModelEstimateSize(
  ProductVariantLocalModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.productId.length * 3;
  bytesCount += 3 + object.sku.length * 3;
  bytesCount += 3 + object.uuid.length * 3;
  {
    final value = object.variantAttributesJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.variantName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _productVariantLocalModelSerialize(
  ProductVariantLocalModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeBool(offsets[1], object.isActive);
  writer.writeBool(offsets[2], object.pendingSync);
  writer.writeDouble(offsets[3], object.priceBuy);
  writer.writeDouble(offsets[4], object.priceSell);
  writer.writeString(offsets[5], object.productId);
  writer.writeString(offsets[6], object.sku);
  writer.writeDateTime(offsets[7], object.syncedAt);
  writer.writeString(offsets[8], object.uuid);
  writer.writeString(offsets[9], object.variantAttributesJson);
  writer.writeString(offsets[10], object.variantName);
}

ProductVariantLocalModel _productVariantLocalModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ProductVariantLocalModel();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.id = id;
  object.isActive = reader.readBool(offsets[1]);
  object.pendingSync = reader.readBool(offsets[2]);
  object.priceBuy = reader.readDouble(offsets[3]);
  object.priceSell = reader.readDouble(offsets[4]);
  object.productId = reader.readString(offsets[5]);
  object.sku = reader.readString(offsets[6]);
  object.syncedAt = reader.readDateTimeOrNull(offsets[7]);
  object.uuid = reader.readString(offsets[8]);
  object.variantAttributesJson = reader.readStringOrNull(offsets[9]);
  object.variantName = reader.readStringOrNull(offsets[10]);
  return object;
}

P _productVariantLocalModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _productVariantLocalModelGetId(ProductVariantLocalModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _productVariantLocalModelGetLinks(
    ProductVariantLocalModel object) {
  return [];
}

void _productVariantLocalModelAttach(
    IsarCollection<dynamic> col, Id id, ProductVariantLocalModel object) {
  object.id = id;
}

extension ProductVariantLocalModelByIndex
    on IsarCollection<ProductVariantLocalModel> {
  Future<ProductVariantLocalModel?> getByUuid(String uuid) {
    return getByIndex(r'uuid', [uuid]);
  }

  ProductVariantLocalModel? getByUuidSync(String uuid) {
    return getByIndexSync(r'uuid', [uuid]);
  }

  Future<bool> deleteByUuid(String uuid) {
    return deleteByIndex(r'uuid', [uuid]);
  }

  bool deleteByUuidSync(String uuid) {
    return deleteByIndexSync(r'uuid', [uuid]);
  }

  Future<List<ProductVariantLocalModel?>> getAllByUuid(
      List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uuid', values);
  }

  List<ProductVariantLocalModel?> getAllByUuidSync(List<String> uuidValues) {
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

  Future<Id> putByUuid(ProductVariantLocalModel object) {
    return putByIndex(r'uuid', object);
  }

  Id putByUuidSync(ProductVariantLocalModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'uuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUuid(List<ProductVariantLocalModel> objects) {
    return putAllByIndex(r'uuid', objects);
  }

  List<Id> putAllByUuidSync(List<ProductVariantLocalModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'uuid', objects, saveLinks: saveLinks);
  }

  Future<ProductVariantLocalModel?> getBySku(String sku) {
    return getByIndex(r'sku', [sku]);
  }

  ProductVariantLocalModel? getBySkuSync(String sku) {
    return getByIndexSync(r'sku', [sku]);
  }

  Future<bool> deleteBySku(String sku) {
    return deleteByIndex(r'sku', [sku]);
  }

  bool deleteBySkuSync(String sku) {
    return deleteByIndexSync(r'sku', [sku]);
  }

  Future<List<ProductVariantLocalModel?>> getAllBySku(List<String> skuValues) {
    final values = skuValues.map((e) => [e]).toList();
    return getAllByIndex(r'sku', values);
  }

  List<ProductVariantLocalModel?> getAllBySkuSync(List<String> skuValues) {
    final values = skuValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'sku', values);
  }

  Future<int> deleteAllBySku(List<String> skuValues) {
    final values = skuValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'sku', values);
  }

  int deleteAllBySkuSync(List<String> skuValues) {
    final values = skuValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'sku', values);
  }

  Future<Id> putBySku(ProductVariantLocalModel object) {
    return putByIndex(r'sku', object);
  }

  Id putBySkuSync(ProductVariantLocalModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'sku', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySku(List<ProductVariantLocalModel> objects) {
    return putAllByIndex(r'sku', objects);
  }

  List<Id> putAllBySkuSync(List<ProductVariantLocalModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'sku', objects, saveLinks: saveLinks);
  }
}

extension ProductVariantLocalModelQueryWhereSort on QueryBuilder<
    ProductVariantLocalModel, ProductVariantLocalModel, QWhere> {
  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ProductVariantLocalModelQueryWhere on QueryBuilder<
    ProductVariantLocalModel, ProductVariantLocalModel, QWhereClause> {
  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
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

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
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

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterWhereClause> uuidEqualTo(String uuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'uuid',
        value: [uuid],
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterWhereClause> uuidNotEqualTo(String uuid) {
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

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterWhereClause> productIdEqualTo(String productId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'productId',
        value: [productId],
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterWhereClause> productIdNotEqualTo(String productId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'productId',
              lower: [],
              upper: [productId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'productId',
              lower: [productId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'productId',
              lower: [productId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'productId',
              lower: [],
              upper: [productId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterWhereClause> skuEqualTo(String sku) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sku',
        value: [sku],
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterWhereClause> skuNotEqualTo(String sku) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sku',
              lower: [],
              upper: [sku],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sku',
              lower: [sku],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sku',
              lower: [sku],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sku',
              lower: [],
              upper: [sku],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ProductVariantLocalModelQueryFilter on QueryBuilder<
    ProductVariantLocalModel, ProductVariantLocalModel, QFilterCondition> {
  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
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

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
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

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
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

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
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

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
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

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
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

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> isActiveEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isActive',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> pendingSyncEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pendingSync',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> priceBuyEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'priceBuy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> priceBuyGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'priceBuy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> priceBuyLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'priceBuy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> priceBuyBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'priceBuy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> priceSellEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'priceSell',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> priceSellGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'priceSell',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> priceSellLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'priceSell',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> priceSellBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'priceSell',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> productIdEqualTo(
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

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> productIdGreaterThan(
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

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> productIdLessThan(
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

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> productIdBetween(
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

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> productIdStartsWith(
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

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> productIdEndsWith(
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

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
          QAfterFilterCondition>
      productIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'productId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
          QAfterFilterCondition>
      productIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'productId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> productIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productId',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> productIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'productId',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> skuEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sku',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> skuGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sku',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> skuLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sku',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> skuBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sku',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> skuStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sku',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> skuEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sku',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
          QAfterFilterCondition>
      skuContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sku',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
          QAfterFilterCondition>
      skuMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sku',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> skuIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sku',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> skuIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sku',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> syncedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'syncedAt',
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> syncedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'syncedAt',
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> syncedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> syncedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'syncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> syncedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'syncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> syncedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'syncedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> uuidEqualTo(
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

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> uuidGreaterThan(
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

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> uuidLessThan(
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

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> uuidBetween(
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

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> uuidStartsWith(
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

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> uuidEndsWith(
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

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
          QAfterFilterCondition>
      uuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
          QAfterFilterCondition>
      uuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> uuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uuid',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> uuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uuid',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> variantAttributesJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'variantAttributesJson',
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> variantAttributesJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'variantAttributesJson',
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> variantAttributesJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'variantAttributesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> variantAttributesJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'variantAttributesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> variantAttributesJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'variantAttributesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> variantAttributesJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'variantAttributesJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> variantAttributesJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'variantAttributesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> variantAttributesJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'variantAttributesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
          QAfterFilterCondition>
      variantAttributesJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'variantAttributesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
          QAfterFilterCondition>
      variantAttributesJsonMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'variantAttributesJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> variantAttributesJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'variantAttributesJson',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> variantAttributesJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'variantAttributesJson',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> variantNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'variantName',
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> variantNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'variantName',
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> variantNameEqualTo(
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

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> variantNameGreaterThan(
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

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> variantNameLessThan(
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

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> variantNameBetween(
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

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> variantNameStartsWith(
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

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> variantNameEndsWith(
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

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
          QAfterFilterCondition>
      variantNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'variantName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
          QAfterFilterCondition>
      variantNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'variantName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> variantNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'variantName',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel,
      QAfterFilterCondition> variantNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'variantName',
        value: '',
      ));
    });
  }
}

extension ProductVariantLocalModelQueryObject on QueryBuilder<
    ProductVariantLocalModel, ProductVariantLocalModel, QFilterCondition> {}

extension ProductVariantLocalModelQueryLinks on QueryBuilder<
    ProductVariantLocalModel, ProductVariantLocalModel, QFilterCondition> {}

extension ProductVariantLocalModelQuerySortBy on QueryBuilder<
    ProductVariantLocalModel, ProductVariantLocalModel, QSortBy> {
  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QAfterSortBy>
      sortByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QAfterSortBy>
      sortByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QAfterSortBy>
      sortByPendingSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingSync', Sort.asc);
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QAfterSortBy>
      sortByPendingSyncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingSync', Sort.desc);
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QAfterSortBy>
      sortByPriceBuy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priceBuy', Sort.asc);
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QAfterSortBy>
      sortByPriceBuyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priceBuy', Sort.desc);
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QAfterSortBy>
      sortByPriceSell() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priceSell', Sort.asc);
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QAfterSortBy>
      sortByPriceSellDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priceSell', Sort.desc);
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QAfterSortBy>
      sortByProductId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productId', Sort.asc);
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QAfterSortBy>
      sortByProductIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productId', Sort.desc);
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QAfterSortBy>
      sortBySku() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sku', Sort.asc);
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QAfterSortBy>
      sortBySkuDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sku', Sort.desc);
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QAfterSortBy>
      sortBySyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.asc);
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QAfterSortBy>
      sortBySyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.desc);
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QAfterSortBy>
      sortByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QAfterSortBy>
      sortByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QAfterSortBy>
      sortByVariantAttributesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'variantAttributesJson', Sort.asc);
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QAfterSortBy>
      sortByVariantAttributesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'variantAttributesJson', Sort.desc);
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QAfterSortBy>
      sortByVariantName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'variantName', Sort.asc);
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QAfterSortBy>
      sortByVariantNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'variantName', Sort.desc);
    });
  }
}

extension ProductVariantLocalModelQuerySortThenBy on QueryBuilder<
    ProductVariantLocalModel, ProductVariantLocalModel, QSortThenBy> {
  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QAfterSortBy>
      thenByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QAfterSortBy>
      thenByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QAfterSortBy>
      thenByPendingSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingSync', Sort.asc);
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QAfterSortBy>
      thenByPendingSyncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingSync', Sort.desc);
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QAfterSortBy>
      thenByPriceBuy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priceBuy', Sort.asc);
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QAfterSortBy>
      thenByPriceBuyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priceBuy', Sort.desc);
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QAfterSortBy>
      thenByPriceSell() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priceSell', Sort.asc);
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QAfterSortBy>
      thenByPriceSellDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priceSell', Sort.desc);
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QAfterSortBy>
      thenByProductId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productId', Sort.asc);
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QAfterSortBy>
      thenByProductIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productId', Sort.desc);
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QAfterSortBy>
      thenBySku() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sku', Sort.asc);
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QAfterSortBy>
      thenBySkuDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sku', Sort.desc);
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QAfterSortBy>
      thenBySyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.asc);
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QAfterSortBy>
      thenBySyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.desc);
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QAfterSortBy>
      thenByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QAfterSortBy>
      thenByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QAfterSortBy>
      thenByVariantAttributesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'variantAttributesJson', Sort.asc);
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QAfterSortBy>
      thenByVariantAttributesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'variantAttributesJson', Sort.desc);
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QAfterSortBy>
      thenByVariantName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'variantName', Sort.asc);
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QAfterSortBy>
      thenByVariantNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'variantName', Sort.desc);
    });
  }
}

extension ProductVariantLocalModelQueryWhereDistinct on QueryBuilder<
    ProductVariantLocalModel, ProductVariantLocalModel, QDistinct> {
  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QDistinct>
      distinctByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isActive');
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QDistinct>
      distinctByPendingSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pendingSync');
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QDistinct>
      distinctByPriceBuy() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'priceBuy');
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QDistinct>
      distinctByPriceSell() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'priceSell');
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QDistinct>
      distinctByProductId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'productId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QDistinct>
      distinctBySku({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sku', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QDistinct>
      distinctBySyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncedAt');
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QDistinct>
      distinctByUuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QDistinct>
      distinctByVariantAttributesJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'variantAttributesJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProductVariantLocalModel, ProductVariantLocalModel, QDistinct>
      distinctByVariantName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'variantName', caseSensitive: caseSensitive);
    });
  }
}

extension ProductVariantLocalModelQueryProperty on QueryBuilder<
    ProductVariantLocalModel, ProductVariantLocalModel, QQueryProperty> {
  QueryBuilder<ProductVariantLocalModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ProductVariantLocalModel, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<ProductVariantLocalModel, bool, QQueryOperations>
      isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isActive');
    });
  }

  QueryBuilder<ProductVariantLocalModel, bool, QQueryOperations>
      pendingSyncProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pendingSync');
    });
  }

  QueryBuilder<ProductVariantLocalModel, double, QQueryOperations>
      priceBuyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'priceBuy');
    });
  }

  QueryBuilder<ProductVariantLocalModel, double, QQueryOperations>
      priceSellProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'priceSell');
    });
  }

  QueryBuilder<ProductVariantLocalModel, String, QQueryOperations>
      productIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'productId');
    });
  }

  QueryBuilder<ProductVariantLocalModel, String, QQueryOperations>
      skuProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sku');
    });
  }

  QueryBuilder<ProductVariantLocalModel, DateTime?, QQueryOperations>
      syncedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncedAt');
    });
  }

  QueryBuilder<ProductVariantLocalModel, String, QQueryOperations>
      uuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uuid');
    });
  }

  QueryBuilder<ProductVariantLocalModel, String?, QQueryOperations>
      variantAttributesJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'variantAttributesJson');
    });
  }

  QueryBuilder<ProductVariantLocalModel, String?, QQueryOperations>
      variantNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'variantName');
    });
  }
}
