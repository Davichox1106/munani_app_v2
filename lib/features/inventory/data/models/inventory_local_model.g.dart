// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_local_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetInventoryLocalModelCollection on Isar {
  IsarCollection<InventoryLocalModel> get inventoryLocalModels =>
      this.collection();
}

const InventoryLocalModelSchema = CollectionSchema(
  name: r'InventoryLocalModel',
  id: 9095884520216775211,
  properties: {
    r'costUpdatedAt': PropertySchema(
      id: 0,
      name: r'costUpdatedAt',
      type: IsarType.dateTime,
    ),
    r'imageUrls': PropertySchema(
      id: 1,
      name: r'imageUrls',
      type: IsarType.stringList,
    ),
    r'lastCost': PropertySchema(
      id: 2,
      name: r'lastCost',
      type: IsarType.double,
    ),
    r'lastSyncedAt': PropertySchema(
      id: 3,
      name: r'lastSyncedAt',
      type: IsarType.dateTime,
    ),
    r'lastUpdated': PropertySchema(
      id: 4,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'locationId': PropertySchema(
      id: 5,
      name: r'locationId',
      type: IsarType.string,
    ),
    r'locationName': PropertySchema(
      id: 6,
      name: r'locationName',
      type: IsarType.string,
    ),
    r'locationType': PropertySchema(
      id: 7,
      name: r'locationType',
      type: IsarType.string,
    ),
    r'maxStock': PropertySchema(
      id: 8,
      name: r'maxStock',
      type: IsarType.long,
    ),
    r'minStock': PropertySchema(
      id: 9,
      name: r'minStock',
      type: IsarType.long,
    ),
    r'needsSync': PropertySchema(
      id: 10,
      name: r'needsSync',
      type: IsarType.bool,
    ),
    r'productName': PropertySchema(
      id: 11,
      name: r'productName',
      type: IsarType.string,
    ),
    r'productVariantId': PropertySchema(
      id: 12,
      name: r'productVariantId',
      type: IsarType.string,
    ),
    r'quantity': PropertySchema(
      id: 13,
      name: r'quantity',
      type: IsarType.long,
    ),
    r'totalCost': PropertySchema(
      id: 14,
      name: r'totalCost',
      type: IsarType.double,
    ),
    r'unitCost': PropertySchema(
      id: 15,
      name: r'unitCost',
      type: IsarType.double,
    ),
    r'updatedBy': PropertySchema(
      id: 16,
      name: r'updatedBy',
      type: IsarType.string,
    ),
    r'uuid': PropertySchema(
      id: 17,
      name: r'uuid',
      type: IsarType.string,
    ),
    r'variantName': PropertySchema(
      id: 18,
      name: r'variantName',
      type: IsarType.string,
    )
  },
  estimateSize: _inventoryLocalModelEstimateSize,
  serialize: _inventoryLocalModelSerialize,
  deserialize: _inventoryLocalModelDeserialize,
  deserializeProp: _inventoryLocalModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'uuid': IndexSchema(
      id: 2134397340427724972,
      name: r'uuid',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'uuid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'productVariantId': IndexSchema(
      id: 8357303093618660280,
      name: r'productVariantId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'productVariantId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'locationId': IndexSchema(
      id: 8924247506386354970,
      name: r'locationId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'locationId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'locationType': IndexSchema(
      id: -329961797783839228,
      name: r'locationType',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'locationType',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'lastUpdated': IndexSchema(
      id: 8989359681631629925,
      name: r'lastUpdated',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'lastUpdated',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'needsSync': IndexSchema(
      id: 582046641891238027,
      name: r'needsSync',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'needsSync',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _inventoryLocalModelGetId,
  getLinks: _inventoryLocalModelGetLinks,
  attach: _inventoryLocalModelAttach,
  version: '3.1.0+1',
);

int _inventoryLocalModelEstimateSize(
  InventoryLocalModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.imageUrls.length * 3;
  {
    for (var i = 0; i < object.imageUrls.length; i++) {
      final value = object.imageUrls[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.locationId.length * 3;
  {
    final value = object.locationName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.locationType.length * 3;
  {
    final value = object.productName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.productVariantId.length * 3;
  bytesCount += 3 + object.updatedBy.length * 3;
  bytesCount += 3 + object.uuid.length * 3;
  {
    final value = object.variantName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _inventoryLocalModelSerialize(
  InventoryLocalModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.costUpdatedAt);
  writer.writeStringList(offsets[1], object.imageUrls);
  writer.writeDouble(offsets[2], object.lastCost);
  writer.writeDateTime(offsets[3], object.lastSyncedAt);
  writer.writeDateTime(offsets[4], object.lastUpdated);
  writer.writeString(offsets[5], object.locationId);
  writer.writeString(offsets[6], object.locationName);
  writer.writeString(offsets[7], object.locationType);
  writer.writeLong(offsets[8], object.maxStock);
  writer.writeLong(offsets[9], object.minStock);
  writer.writeBool(offsets[10], object.needsSync);
  writer.writeString(offsets[11], object.productName);
  writer.writeString(offsets[12], object.productVariantId);
  writer.writeLong(offsets[13], object.quantity);
  writer.writeDouble(offsets[14], object.totalCost);
  writer.writeDouble(offsets[15], object.unitCost);
  writer.writeString(offsets[16], object.updatedBy);
  writer.writeString(offsets[17], object.uuid);
  writer.writeString(offsets[18], object.variantName);
}

InventoryLocalModel _inventoryLocalModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = InventoryLocalModel();
  object.costUpdatedAt = reader.readDateTimeOrNull(offsets[0]);
  object.id = id;
  object.imageUrls = reader.readStringList(offsets[1]) ?? [];
  object.lastCost = reader.readDoubleOrNull(offsets[2]);
  object.lastSyncedAt = reader.readDateTimeOrNull(offsets[3]);
  object.lastUpdated = reader.readDateTime(offsets[4]);
  object.locationId = reader.readString(offsets[5]);
  object.locationName = reader.readStringOrNull(offsets[6]);
  object.locationType = reader.readString(offsets[7]);
  object.maxStock = reader.readLong(offsets[8]);
  object.minStock = reader.readLong(offsets[9]);
  object.needsSync = reader.readBool(offsets[10]);
  object.productName = reader.readStringOrNull(offsets[11]);
  object.productVariantId = reader.readString(offsets[12]);
  object.quantity = reader.readLong(offsets[13]);
  object.totalCost = reader.readDoubleOrNull(offsets[14]);
  object.unitCost = reader.readDoubleOrNull(offsets[15]);
  object.updatedBy = reader.readString(offsets[16]);
  object.uuid = reader.readString(offsets[17]);
  object.variantName = reader.readStringOrNull(offsets[18]);
  return object;
}

P _inventoryLocalModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readStringList(offset) ?? []) as P;
    case 2:
      return (reader.readDoubleOrNull(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readBool(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readLong(offset)) as P;
    case 14:
      return (reader.readDoubleOrNull(offset)) as P;
    case 15:
      return (reader.readDoubleOrNull(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    case 17:
      return (reader.readString(offset)) as P;
    case 18:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _inventoryLocalModelGetId(InventoryLocalModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _inventoryLocalModelGetLinks(
    InventoryLocalModel object) {
  return [];
}

void _inventoryLocalModelAttach(
    IsarCollection<dynamic> col, Id id, InventoryLocalModel object) {
  object.id = id;
}

extension InventoryLocalModelQueryWhereSort
    on QueryBuilder<InventoryLocalModel, InventoryLocalModel, QWhere> {
  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterWhere>
      anyLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'lastUpdated'),
      );
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterWhere>
      anyNeedsSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'needsSync'),
      );
    });
  }
}

extension InventoryLocalModelQueryWhere
    on QueryBuilder<InventoryLocalModel, InventoryLocalModel, QWhereClause> {
  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterWhereClause>
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

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterWhereClause>
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

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterWhereClause>
      uuidEqualTo(String uuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'uuid',
        value: [uuid],
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterWhereClause>
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

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterWhereClause>
      productVariantIdEqualTo(String productVariantId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'productVariantId',
        value: [productVariantId],
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterWhereClause>
      productVariantIdNotEqualTo(String productVariantId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'productVariantId',
              lower: [],
              upper: [productVariantId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'productVariantId',
              lower: [productVariantId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'productVariantId',
              lower: [productVariantId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'productVariantId',
              lower: [],
              upper: [productVariantId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterWhereClause>
      locationIdEqualTo(String locationId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'locationId',
        value: [locationId],
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterWhereClause>
      locationIdNotEqualTo(String locationId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'locationId',
              lower: [],
              upper: [locationId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'locationId',
              lower: [locationId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'locationId',
              lower: [locationId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'locationId',
              lower: [],
              upper: [locationId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterWhereClause>
      locationTypeEqualTo(String locationType) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'locationType',
        value: [locationType],
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterWhereClause>
      locationTypeNotEqualTo(String locationType) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'locationType',
              lower: [],
              upper: [locationType],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'locationType',
              lower: [locationType],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'locationType',
              lower: [locationType],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'locationType',
              lower: [],
              upper: [locationType],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterWhereClause>
      lastUpdatedEqualTo(DateTime lastUpdated) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'lastUpdated',
        value: [lastUpdated],
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterWhereClause>
      lastUpdatedNotEqualTo(DateTime lastUpdated) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastUpdated',
              lower: [],
              upper: [lastUpdated],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastUpdated',
              lower: [lastUpdated],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastUpdated',
              lower: [lastUpdated],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastUpdated',
              lower: [],
              upper: [lastUpdated],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterWhereClause>
      lastUpdatedGreaterThan(
    DateTime lastUpdated, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastUpdated',
        lower: [lastUpdated],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterWhereClause>
      lastUpdatedLessThan(
    DateTime lastUpdated, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastUpdated',
        lower: [],
        upper: [lastUpdated],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterWhereClause>
      lastUpdatedBetween(
    DateTime lowerLastUpdated,
    DateTime upperLastUpdated, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastUpdated',
        lower: [lowerLastUpdated],
        includeLower: includeLower,
        upper: [upperLastUpdated],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterWhereClause>
      needsSyncEqualTo(bool needsSync) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'needsSync',
        value: [needsSync],
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterWhereClause>
      needsSyncNotEqualTo(bool needsSync) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'needsSync',
              lower: [],
              upper: [needsSync],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'needsSync',
              lower: [needsSync],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'needsSync',
              lower: [needsSync],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'needsSync',
              lower: [],
              upper: [needsSync],
              includeUpper: false,
            ));
      }
    });
  }
}

extension InventoryLocalModelQueryFilter on QueryBuilder<InventoryLocalModel,
    InventoryLocalModel, QFilterCondition> {
  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      costUpdatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'costUpdatedAt',
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      costUpdatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'costUpdatedAt',
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      costUpdatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'costUpdatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      costUpdatedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'costUpdatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      costUpdatedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'costUpdatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      costUpdatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'costUpdatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
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

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
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

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
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

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
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

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
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

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
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

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
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

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
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

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
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

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      imageUrlsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'imageUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      imageUrlsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'imageUrls',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      imageUrlsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imageUrls',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      imageUrlsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'imageUrls',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
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

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
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

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
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

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
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

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
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

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
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

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      lastCostIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastCost',
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      lastCostIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastCost',
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      lastCostEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      lastCostGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      lastCostLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      lastCostBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastCost',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      lastSyncedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastSyncedAt',
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      lastSyncedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastSyncedAt',
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      lastSyncedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSyncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      lastSyncedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastSyncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      lastSyncedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastSyncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      lastSyncedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastSyncedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      lastUpdatedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
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

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
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

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
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

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      locationIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'locationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      locationIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'locationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      locationIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'locationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      locationIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'locationId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      locationIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'locationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      locationIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'locationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      locationIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'locationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      locationIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'locationId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      locationIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'locationId',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      locationIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'locationId',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      locationNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'locationName',
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      locationNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'locationName',
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      locationNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'locationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      locationNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'locationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      locationNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'locationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      locationNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'locationName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      locationNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'locationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      locationNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'locationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      locationNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'locationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      locationNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'locationName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      locationNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'locationName',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      locationNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'locationName',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      locationTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'locationType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      locationTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'locationType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      locationTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'locationType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      locationTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'locationType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      locationTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'locationType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      locationTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'locationType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      locationTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'locationType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      locationTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'locationType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      locationTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'locationType',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      locationTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'locationType',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      maxStockEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maxStock',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      maxStockGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maxStock',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      maxStockLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maxStock',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      maxStockBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maxStock',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      minStockEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'minStock',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      minStockGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'minStock',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      minStockLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'minStock',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      minStockBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'minStock',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      needsSyncEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'needsSync',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      productNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'productName',
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      productNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'productName',
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
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

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
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

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
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

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
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

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
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

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
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

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      productNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'productName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      productNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'productName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      productNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productName',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      productNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'productName',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
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

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
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

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
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

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
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

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
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

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
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

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      productVariantIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'productVariantId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      productVariantIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'productVariantId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      productVariantIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productVariantId',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      productVariantIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'productVariantId',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      quantityEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quantity',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
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

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
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

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
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

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      totalCostIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'totalCost',
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      totalCostIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'totalCost',
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      totalCostEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      totalCostGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      totalCostLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      totalCostBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalCost',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      unitCostIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'unitCost',
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      unitCostIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'unitCost',
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      unitCostEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unitCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      unitCostGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unitCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      unitCostLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unitCost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      unitCostBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unitCost',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      updatedByEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      updatedByGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      updatedByLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      updatedByBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      updatedByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'updatedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      updatedByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'updatedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      updatedByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'updatedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      updatedByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'updatedBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      updatedByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      updatedByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'updatedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
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

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
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

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
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

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
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

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
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

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
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

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      uuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      uuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      uuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uuid',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      uuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uuid',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      variantNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'variantName',
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      variantNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'variantName',
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
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

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
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

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
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

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
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

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
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

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
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

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      variantNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'variantName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      variantNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'variantName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      variantNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'variantName',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterFilterCondition>
      variantNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'variantName',
        value: '',
      ));
    });
  }
}

extension InventoryLocalModelQueryObject on QueryBuilder<InventoryLocalModel,
    InventoryLocalModel, QFilterCondition> {}

extension InventoryLocalModelQueryLinks on QueryBuilder<InventoryLocalModel,
    InventoryLocalModel, QFilterCondition> {}

extension InventoryLocalModelQuerySortBy
    on QueryBuilder<InventoryLocalModel, InventoryLocalModel, QSortBy> {
  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      sortByCostUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      sortByCostUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costUpdatedAt', Sort.desc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      sortByLastCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCost', Sort.asc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      sortByLastCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCost', Sort.desc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      sortByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.asc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      sortByLastSyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.desc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      sortByLocationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationId', Sort.asc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      sortByLocationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationId', Sort.desc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      sortByLocationName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationName', Sort.asc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      sortByLocationNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationName', Sort.desc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      sortByLocationType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationType', Sort.asc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      sortByLocationTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationType', Sort.desc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      sortByMaxStock() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxStock', Sort.asc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      sortByMaxStockDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxStock', Sort.desc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      sortByMinStock() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minStock', Sort.asc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      sortByMinStockDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minStock', Sort.desc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      sortByNeedsSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needsSync', Sort.asc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      sortByNeedsSyncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needsSync', Sort.desc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      sortByProductName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productName', Sort.asc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      sortByProductNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productName', Sort.desc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      sortByProductVariantId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productVariantId', Sort.asc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      sortByProductVariantIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productVariantId', Sort.desc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      sortByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      sortByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      sortByTotalCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCost', Sort.asc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      sortByTotalCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCost', Sort.desc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      sortByUnitCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unitCost', Sort.asc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      sortByUnitCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unitCost', Sort.desc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      sortByUpdatedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedBy', Sort.asc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      sortByUpdatedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedBy', Sort.desc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      sortByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      sortByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      sortByVariantName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'variantName', Sort.asc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      sortByVariantNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'variantName', Sort.desc);
    });
  }
}

extension InventoryLocalModelQuerySortThenBy
    on QueryBuilder<InventoryLocalModel, InventoryLocalModel, QSortThenBy> {
  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      thenByCostUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      thenByCostUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costUpdatedAt', Sort.desc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      thenByLastCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCost', Sort.asc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      thenByLastCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCost', Sort.desc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      thenByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.asc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      thenByLastSyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.desc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      thenByLocationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationId', Sort.asc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      thenByLocationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationId', Sort.desc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      thenByLocationName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationName', Sort.asc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      thenByLocationNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationName', Sort.desc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      thenByLocationType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationType', Sort.asc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      thenByLocationTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationType', Sort.desc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      thenByMaxStock() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxStock', Sort.asc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      thenByMaxStockDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxStock', Sort.desc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      thenByMinStock() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minStock', Sort.asc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      thenByMinStockDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minStock', Sort.desc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      thenByNeedsSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needsSync', Sort.asc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      thenByNeedsSyncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needsSync', Sort.desc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      thenByProductName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productName', Sort.asc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      thenByProductNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productName', Sort.desc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      thenByProductVariantId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productVariantId', Sort.asc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      thenByProductVariantIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productVariantId', Sort.desc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      thenByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      thenByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      thenByTotalCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCost', Sort.asc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      thenByTotalCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCost', Sort.desc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      thenByUnitCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unitCost', Sort.asc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      thenByUnitCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unitCost', Sort.desc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      thenByUpdatedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedBy', Sort.asc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      thenByUpdatedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedBy', Sort.desc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      thenByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      thenByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      thenByVariantName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'variantName', Sort.asc);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QAfterSortBy>
      thenByVariantNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'variantName', Sort.desc);
    });
  }
}

extension InventoryLocalModelQueryWhereDistinct
    on QueryBuilder<InventoryLocalModel, InventoryLocalModel, QDistinct> {
  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QDistinct>
      distinctByCostUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'costUpdatedAt');
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QDistinct>
      distinctByImageUrls() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'imageUrls');
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QDistinct>
      distinctByLastCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastCost');
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QDistinct>
      distinctByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSyncedAt');
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QDistinct>
      distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QDistinct>
      distinctByLocationId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'locationId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QDistinct>
      distinctByLocationName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'locationName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QDistinct>
      distinctByLocationType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'locationType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QDistinct>
      distinctByMaxStock() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxStock');
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QDistinct>
      distinctByMinStock() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'minStock');
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QDistinct>
      distinctByNeedsSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'needsSync');
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QDistinct>
      distinctByProductName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'productName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QDistinct>
      distinctByProductVariantId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'productVariantId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QDistinct>
      distinctByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quantity');
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QDistinct>
      distinctByTotalCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalCost');
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QDistinct>
      distinctByUnitCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unitCost');
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QDistinct>
      distinctByUpdatedBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QDistinct>
      distinctByUuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventoryLocalModel, InventoryLocalModel, QDistinct>
      distinctByVariantName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'variantName', caseSensitive: caseSensitive);
    });
  }
}

extension InventoryLocalModelQueryProperty
    on QueryBuilder<InventoryLocalModel, InventoryLocalModel, QQueryProperty> {
  QueryBuilder<InventoryLocalModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<InventoryLocalModel, DateTime?, QQueryOperations>
      costUpdatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'costUpdatedAt');
    });
  }

  QueryBuilder<InventoryLocalModel, List<String>, QQueryOperations>
      imageUrlsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'imageUrls');
    });
  }

  QueryBuilder<InventoryLocalModel, double?, QQueryOperations>
      lastCostProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastCost');
    });
  }

  QueryBuilder<InventoryLocalModel, DateTime?, QQueryOperations>
      lastSyncedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSyncedAt');
    });
  }

  QueryBuilder<InventoryLocalModel, DateTime, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<InventoryLocalModel, String, QQueryOperations>
      locationIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'locationId');
    });
  }

  QueryBuilder<InventoryLocalModel, String?, QQueryOperations>
      locationNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'locationName');
    });
  }

  QueryBuilder<InventoryLocalModel, String, QQueryOperations>
      locationTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'locationType');
    });
  }

  QueryBuilder<InventoryLocalModel, int, QQueryOperations> maxStockProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxStock');
    });
  }

  QueryBuilder<InventoryLocalModel, int, QQueryOperations> minStockProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'minStock');
    });
  }

  QueryBuilder<InventoryLocalModel, bool, QQueryOperations>
      needsSyncProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'needsSync');
    });
  }

  QueryBuilder<InventoryLocalModel, String?, QQueryOperations>
      productNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'productName');
    });
  }

  QueryBuilder<InventoryLocalModel, String, QQueryOperations>
      productVariantIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'productVariantId');
    });
  }

  QueryBuilder<InventoryLocalModel, int, QQueryOperations> quantityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quantity');
    });
  }

  QueryBuilder<InventoryLocalModel, double?, QQueryOperations>
      totalCostProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalCost');
    });
  }

  QueryBuilder<InventoryLocalModel, double?, QQueryOperations>
      unitCostProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unitCost');
    });
  }

  QueryBuilder<InventoryLocalModel, String, QQueryOperations>
      updatedByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedBy');
    });
  }

  QueryBuilder<InventoryLocalModel, String, QQueryOperations> uuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uuid');
    });
  }

  QueryBuilder<InventoryLocalModel, String?, QQueryOperations>
      variantNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'variantName');
    });
  }
}
