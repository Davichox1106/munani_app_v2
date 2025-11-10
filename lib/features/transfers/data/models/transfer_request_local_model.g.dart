// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer_request_local_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTransferRequestLocalModelCollection on Isar {
  IsarCollection<TransferRequestLocalModel> get transferRequestLocalModels =>
      this.collection();
}

const TransferRequestLocalModelSchema = CollectionSchema(
  name: r'TransferRequestLocalModel',
  id: 299189083315533514,
  properties: {
    r'approvedAt': PropertySchema(
      id: 0,
      name: r'approvedAt',
      type: IsarType.dateTime,
    ),
    r'approvedBy': PropertySchema(
      id: 1,
      name: r'approvedBy',
      type: IsarType.string,
    ),
    r'approvedByName': PropertySchema(
      id: 2,
      name: r'approvedByName',
      type: IsarType.string,
    ),
    r'cancelledAt': PropertySchema(
      id: 3,
      name: r'cancelledAt',
      type: IsarType.dateTime,
    ),
    r'cancelledBy': PropertySchema(
      id: 4,
      name: r'cancelledBy',
      type: IsarType.string,
    ),
    r'cancelledByName': PropertySchema(
      id: 5,
      name: r'cancelledByName',
      type: IsarType.string,
    ),
    r'completedAt': PropertySchema(
      id: 6,
      name: r'completedAt',
      type: IsarType.dateTime,
    ),
    r'completedBy': PropertySchema(
      id: 7,
      name: r'completedBy',
      type: IsarType.string,
    ),
    r'completedByName': PropertySchema(
      id: 8,
      name: r'completedByName',
      type: IsarType.string,
    ),
    r'fromLocationId': PropertySchema(
      id: 9,
      name: r'fromLocationId',
      type: IsarType.string,
    ),
    r'fromLocationName': PropertySchema(
      id: 10,
      name: r'fromLocationName',
      type: IsarType.string,
    ),
    r'fromLocationType': PropertySchema(
      id: 11,
      name: r'fromLocationType',
      type: IsarType.string,
    ),
    r'isSynced': PropertySchema(
      id: 12,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'lastUpdated': PropertySchema(
      id: 13,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'notes': PropertySchema(
      id: 14,
      name: r'notes',
      type: IsarType.string,
    ),
    r'productName': PropertySchema(
      id: 15,
      name: r'productName',
      type: IsarType.string,
    ),
    r'productVariantId': PropertySchema(
      id: 16,
      name: r'productVariantId',
      type: IsarType.string,
    ),
    r'quantity': PropertySchema(
      id: 17,
      name: r'quantity',
      type: IsarType.long,
    ),
    r'rejectedAt': PropertySchema(
      id: 18,
      name: r'rejectedAt',
      type: IsarType.dateTime,
    ),
    r'rejectedBy': PropertySchema(
      id: 19,
      name: r'rejectedBy',
      type: IsarType.string,
    ),
    r'rejectedByName': PropertySchema(
      id: 20,
      name: r'rejectedByName',
      type: IsarType.string,
    ),
    r'rejectionReason': PropertySchema(
      id: 21,
      name: r'rejectionReason',
      type: IsarType.string,
    ),
    r'requestedAt': PropertySchema(
      id: 22,
      name: r'requestedAt',
      type: IsarType.dateTime,
    ),
    r'requestedBy': PropertySchema(
      id: 23,
      name: r'requestedBy',
      type: IsarType.string,
    ),
    r'requestedByName': PropertySchema(
      id: 24,
      name: r'requestedByName',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 25,
      name: r'status',
      type: IsarType.byte,
      enumMap: _TransferRequestLocalModelstatusEnumValueMap,
    ),
    r'toLocationId': PropertySchema(
      id: 26,
      name: r'toLocationId',
      type: IsarType.string,
    ),
    r'toLocationName': PropertySchema(
      id: 27,
      name: r'toLocationName',
      type: IsarType.string,
    ),
    r'toLocationType': PropertySchema(
      id: 28,
      name: r'toLocationType',
      type: IsarType.string,
    ),
    r'updatedBy': PropertySchema(
      id: 29,
      name: r'updatedBy',
      type: IsarType.string,
    ),
    r'uuid': PropertySchema(
      id: 30,
      name: r'uuid',
      type: IsarType.string,
    ),
    r'variantName': PropertySchema(
      id: 31,
      name: r'variantName',
      type: IsarType.string,
    )
  },
  estimateSize: _transferRequestLocalModelEstimateSize,
  serialize: _transferRequestLocalModelSerialize,
  deserialize: _transferRequestLocalModelDeserialize,
  deserializeProp: _transferRequestLocalModelDeserializeProp,
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
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _transferRequestLocalModelGetId,
  getLinks: _transferRequestLocalModelGetLinks,
  attach: _transferRequestLocalModelAttach,
  version: '3.1.0+1',
);

int _transferRequestLocalModelEstimateSize(
  TransferRequestLocalModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.approvedBy;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.approvedByName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.cancelledBy;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.cancelledByName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.completedBy;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.completedByName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.fromLocationId.length * 3;
  bytesCount += 3 + object.fromLocationName.length * 3;
  bytesCount += 3 + object.fromLocationType.length * 3;
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.productName.length * 3;
  bytesCount += 3 + object.productVariantId.length * 3;
  {
    final value = object.rejectedBy;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.rejectedByName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.rejectionReason;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.requestedBy.length * 3;
  bytesCount += 3 + object.requestedByName.length * 3;
  bytesCount += 3 + object.toLocationId.length * 3;
  bytesCount += 3 + object.toLocationName.length * 3;
  bytesCount += 3 + object.toLocationType.length * 3;
  bytesCount += 3 + object.updatedBy.length * 3;
  bytesCount += 3 + object.uuid.length * 3;
  bytesCount += 3 + object.variantName.length * 3;
  return bytesCount;
}

void _transferRequestLocalModelSerialize(
  TransferRequestLocalModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.approvedAt);
  writer.writeString(offsets[1], object.approvedBy);
  writer.writeString(offsets[2], object.approvedByName);
  writer.writeDateTime(offsets[3], object.cancelledAt);
  writer.writeString(offsets[4], object.cancelledBy);
  writer.writeString(offsets[5], object.cancelledByName);
  writer.writeDateTime(offsets[6], object.completedAt);
  writer.writeString(offsets[7], object.completedBy);
  writer.writeString(offsets[8], object.completedByName);
  writer.writeString(offsets[9], object.fromLocationId);
  writer.writeString(offsets[10], object.fromLocationName);
  writer.writeString(offsets[11], object.fromLocationType);
  writer.writeBool(offsets[12], object.isSynced);
  writer.writeDateTime(offsets[13], object.lastUpdated);
  writer.writeString(offsets[14], object.notes);
  writer.writeString(offsets[15], object.productName);
  writer.writeString(offsets[16], object.productVariantId);
  writer.writeLong(offsets[17], object.quantity);
  writer.writeDateTime(offsets[18], object.rejectedAt);
  writer.writeString(offsets[19], object.rejectedBy);
  writer.writeString(offsets[20], object.rejectedByName);
  writer.writeString(offsets[21], object.rejectionReason);
  writer.writeDateTime(offsets[22], object.requestedAt);
  writer.writeString(offsets[23], object.requestedBy);
  writer.writeString(offsets[24], object.requestedByName);
  writer.writeByte(offsets[25], object.status.index);
  writer.writeString(offsets[26], object.toLocationId);
  writer.writeString(offsets[27], object.toLocationName);
  writer.writeString(offsets[28], object.toLocationType);
  writer.writeString(offsets[29], object.updatedBy);
  writer.writeString(offsets[30], object.uuid);
  writer.writeString(offsets[31], object.variantName);
}

TransferRequestLocalModel _transferRequestLocalModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TransferRequestLocalModel();
  object.approvedAt = reader.readDateTimeOrNull(offsets[0]);
  object.approvedBy = reader.readStringOrNull(offsets[1]);
  object.approvedByName = reader.readStringOrNull(offsets[2]);
  object.cancelledAt = reader.readDateTimeOrNull(offsets[3]);
  object.cancelledBy = reader.readStringOrNull(offsets[4]);
  object.cancelledByName = reader.readStringOrNull(offsets[5]);
  object.completedAt = reader.readDateTimeOrNull(offsets[6]);
  object.completedBy = reader.readStringOrNull(offsets[7]);
  object.completedByName = reader.readStringOrNull(offsets[8]);
  object.fromLocationId = reader.readString(offsets[9]);
  object.fromLocationName = reader.readString(offsets[10]);
  object.fromLocationType = reader.readString(offsets[11]);
  object.id = id;
  object.isSynced = reader.readBool(offsets[12]);
  object.lastUpdated = reader.readDateTime(offsets[13]);
  object.notes = reader.readStringOrNull(offsets[14]);
  object.productName = reader.readString(offsets[15]);
  object.productVariantId = reader.readString(offsets[16]);
  object.quantity = reader.readLong(offsets[17]);
  object.rejectedAt = reader.readDateTimeOrNull(offsets[18]);
  object.rejectedBy = reader.readStringOrNull(offsets[19]);
  object.rejectedByName = reader.readStringOrNull(offsets[20]);
  object.rejectionReason = reader.readStringOrNull(offsets[21]);
  object.requestedAt = reader.readDateTime(offsets[22]);
  object.requestedBy = reader.readString(offsets[23]);
  object.requestedByName = reader.readString(offsets[24]);
  object.status = _TransferRequestLocalModelstatusValueEnumMap[
          reader.readByteOrNull(offsets[25])] ??
      TransferStatus.pending;
  object.toLocationId = reader.readString(offsets[26]);
  object.toLocationName = reader.readString(offsets[27]);
  object.toLocationType = reader.readString(offsets[28]);
  object.updatedBy = reader.readString(offsets[29]);
  object.uuid = reader.readString(offsets[30]);
  object.variantName = reader.readString(offsets[31]);
  return object;
}

P _transferRequestLocalModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readBool(offset)) as P;
    case 13:
      return (reader.readDateTime(offset)) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    case 15:
      return (reader.readString(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    case 17:
      return (reader.readLong(offset)) as P;
    case 18:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 19:
      return (reader.readStringOrNull(offset)) as P;
    case 20:
      return (reader.readStringOrNull(offset)) as P;
    case 21:
      return (reader.readStringOrNull(offset)) as P;
    case 22:
      return (reader.readDateTime(offset)) as P;
    case 23:
      return (reader.readString(offset)) as P;
    case 24:
      return (reader.readString(offset)) as P;
    case 25:
      return (_TransferRequestLocalModelstatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          TransferStatus.pending) as P;
    case 26:
      return (reader.readString(offset)) as P;
    case 27:
      return (reader.readString(offset)) as P;
    case 28:
      return (reader.readString(offset)) as P;
    case 29:
      return (reader.readString(offset)) as P;
    case 30:
      return (reader.readString(offset)) as P;
    case 31:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _TransferRequestLocalModelstatusEnumValueMap = {
  'pending': 0,
  'approved': 1,
  'rejected': 2,
  'completed': 3,
  'cancelled': 4,
};
const _TransferRequestLocalModelstatusValueEnumMap = {
  0: TransferStatus.pending,
  1: TransferStatus.approved,
  2: TransferStatus.rejected,
  3: TransferStatus.completed,
  4: TransferStatus.cancelled,
};

Id _transferRequestLocalModelGetId(TransferRequestLocalModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _transferRequestLocalModelGetLinks(
    TransferRequestLocalModel object) {
  return [];
}

void _transferRequestLocalModelAttach(
    IsarCollection<dynamic> col, Id id, TransferRequestLocalModel object) {
  object.id = id;
}

extension TransferRequestLocalModelByIndex
    on IsarCollection<TransferRequestLocalModel> {
  Future<TransferRequestLocalModel?> getByUuid(String uuid) {
    return getByIndex(r'uuid', [uuid]);
  }

  TransferRequestLocalModel? getByUuidSync(String uuid) {
    return getByIndexSync(r'uuid', [uuid]);
  }

  Future<bool> deleteByUuid(String uuid) {
    return deleteByIndex(r'uuid', [uuid]);
  }

  bool deleteByUuidSync(String uuid) {
    return deleteByIndexSync(r'uuid', [uuid]);
  }

  Future<List<TransferRequestLocalModel?>> getAllByUuid(
      List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uuid', values);
  }

  List<TransferRequestLocalModel?> getAllByUuidSync(List<String> uuidValues) {
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

  Future<Id> putByUuid(TransferRequestLocalModel object) {
    return putByIndex(r'uuid', object);
  }

  Id putByUuidSync(TransferRequestLocalModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'uuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUuid(List<TransferRequestLocalModel> objects) {
    return putAllByIndex(r'uuid', objects);
  }

  List<Id> putAllByUuidSync(List<TransferRequestLocalModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'uuid', objects, saveLinks: saveLinks);
  }
}

extension TransferRequestLocalModelQueryWhereSort on QueryBuilder<
    TransferRequestLocalModel, TransferRequestLocalModel, QWhere> {
  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TransferRequestLocalModelQueryWhere on QueryBuilder<
    TransferRequestLocalModel, TransferRequestLocalModel, QWhereClause> {
  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
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

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
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

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterWhereClause> uuidEqualTo(String uuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'uuid',
        value: [uuid],
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
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
}

extension TransferRequestLocalModelQueryFilter on QueryBuilder<
    TransferRequestLocalModel, TransferRequestLocalModel, QFilterCondition> {
  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> approvedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'approvedAt',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> approvedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'approvedAt',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> approvedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'approvedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> approvedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'approvedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> approvedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'approvedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> approvedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'approvedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> approvedByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'approvedBy',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> approvedByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'approvedBy',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> approvedByEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'approvedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> approvedByGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'approvedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> approvedByLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'approvedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> approvedByBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'approvedBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> approvedByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'approvedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> approvedByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'approvedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
          QAfterFilterCondition>
      approvedByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'approvedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
          QAfterFilterCondition>
      approvedByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'approvedBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> approvedByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'approvedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> approvedByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'approvedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> approvedByNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'approvedByName',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> approvedByNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'approvedByName',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> approvedByNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'approvedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> approvedByNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'approvedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> approvedByNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'approvedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> approvedByNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'approvedByName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> approvedByNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'approvedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> approvedByNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'approvedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
          QAfterFilterCondition>
      approvedByNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'approvedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
          QAfterFilterCondition>
      approvedByNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'approvedByName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> approvedByNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'approvedByName',
        value: '',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> approvedByNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'approvedByName',
        value: '',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> cancelledAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cancelledAt',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> cancelledAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cancelledAt',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> cancelledAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cancelledAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> cancelledAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cancelledAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> cancelledAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cancelledAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> cancelledAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cancelledAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> cancelledByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cancelledBy',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> cancelledByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cancelledBy',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> cancelledByEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cancelledBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> cancelledByGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cancelledBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> cancelledByLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cancelledBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> cancelledByBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cancelledBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> cancelledByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cancelledBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> cancelledByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cancelledBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
          QAfterFilterCondition>
      cancelledByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cancelledBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
          QAfterFilterCondition>
      cancelledByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cancelledBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> cancelledByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cancelledBy',
        value: '',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> cancelledByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cancelledBy',
        value: '',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> cancelledByNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cancelledByName',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> cancelledByNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cancelledByName',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> cancelledByNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cancelledByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> cancelledByNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cancelledByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> cancelledByNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cancelledByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> cancelledByNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cancelledByName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> cancelledByNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cancelledByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> cancelledByNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cancelledByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
          QAfterFilterCondition>
      cancelledByNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cancelledByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
          QAfterFilterCondition>
      cancelledByNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cancelledByName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> cancelledByNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cancelledByName',
        value: '',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> cancelledByNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cancelledByName',
        value: '',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> completedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'completedAt',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> completedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'completedAt',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> completedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> completedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> completedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> completedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'completedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> completedByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'completedBy',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> completedByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'completedBy',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> completedByEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> completedByGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'completedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> completedByLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'completedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> completedByBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'completedBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> completedByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'completedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> completedByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'completedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
          QAfterFilterCondition>
      completedByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'completedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
          QAfterFilterCondition>
      completedByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'completedBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> completedByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> completedByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'completedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> completedByNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'completedByName',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> completedByNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'completedByName',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> completedByNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> completedByNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'completedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> completedByNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'completedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> completedByNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'completedByName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> completedByNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'completedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> completedByNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'completedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
          QAfterFilterCondition>
      completedByNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'completedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
          QAfterFilterCondition>
      completedByNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'completedByName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> completedByNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completedByName',
        value: '',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> completedByNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'completedByName',
        value: '',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> fromLocationIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fromLocationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> fromLocationIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fromLocationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> fromLocationIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fromLocationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> fromLocationIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fromLocationId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> fromLocationIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fromLocationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> fromLocationIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fromLocationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
          QAfterFilterCondition>
      fromLocationIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fromLocationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
          QAfterFilterCondition>
      fromLocationIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fromLocationId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> fromLocationIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fromLocationId',
        value: '',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> fromLocationIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fromLocationId',
        value: '',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> fromLocationNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fromLocationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> fromLocationNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fromLocationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> fromLocationNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fromLocationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> fromLocationNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fromLocationName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> fromLocationNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fromLocationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> fromLocationNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fromLocationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
          QAfterFilterCondition>
      fromLocationNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fromLocationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
          QAfterFilterCondition>
      fromLocationNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fromLocationName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> fromLocationNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fromLocationName',
        value: '',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> fromLocationNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fromLocationName',
        value: '',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> fromLocationTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fromLocationType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> fromLocationTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fromLocationType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> fromLocationTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fromLocationType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> fromLocationTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fromLocationType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> fromLocationTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fromLocationType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> fromLocationTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fromLocationType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
          QAfterFilterCondition>
      fromLocationTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fromLocationType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
          QAfterFilterCondition>
      fromLocationTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fromLocationType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> fromLocationTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fromLocationType',
        value: '',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> fromLocationTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fromLocationType',
        value: '',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
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

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
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

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
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

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> lastUpdatedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
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

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
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

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
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

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> notesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> notesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> notesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> notesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> notesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> notesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
          QAfterFilterCondition>
      notesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
          QAfterFilterCondition>
      notesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> productNameEqualTo(
    String value, {
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

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> productNameGreaterThan(
    String value, {
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

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> productNameLessThan(
    String value, {
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

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> productNameBetween(
    String lower,
    String upper, {
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

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> productNameStartsWith(
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

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> productNameEndsWith(
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

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
          QAfterFilterCondition>
      productNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'productName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
          QAfterFilterCondition>
      productNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'productName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> productNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productName',
        value: '',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> productNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'productName',
        value: '',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> productVariantIdEqualTo(
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

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> productVariantIdGreaterThan(
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

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> productVariantIdLessThan(
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

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> productVariantIdBetween(
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

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> productVariantIdStartsWith(
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

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> productVariantIdEndsWith(
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

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
          QAfterFilterCondition>
      productVariantIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'productVariantId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
          QAfterFilterCondition>
      productVariantIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'productVariantId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> productVariantIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productVariantId',
        value: '',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> productVariantIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'productVariantId',
        value: '',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> quantityEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quantity',
        value: value,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> quantityGreaterThan(
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

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> quantityLessThan(
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

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> quantityBetween(
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

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> rejectedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'rejectedAt',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> rejectedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'rejectedAt',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> rejectedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rejectedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> rejectedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rejectedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> rejectedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rejectedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> rejectedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rejectedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> rejectedByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'rejectedBy',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> rejectedByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'rejectedBy',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> rejectedByEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rejectedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> rejectedByGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rejectedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> rejectedByLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rejectedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> rejectedByBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rejectedBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> rejectedByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'rejectedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> rejectedByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'rejectedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
          QAfterFilterCondition>
      rejectedByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'rejectedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
          QAfterFilterCondition>
      rejectedByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'rejectedBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> rejectedByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rejectedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> rejectedByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'rejectedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> rejectedByNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'rejectedByName',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> rejectedByNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'rejectedByName',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> rejectedByNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rejectedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> rejectedByNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rejectedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> rejectedByNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rejectedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> rejectedByNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rejectedByName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> rejectedByNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'rejectedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> rejectedByNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'rejectedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
          QAfterFilterCondition>
      rejectedByNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'rejectedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
          QAfterFilterCondition>
      rejectedByNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'rejectedByName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> rejectedByNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rejectedByName',
        value: '',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> rejectedByNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'rejectedByName',
        value: '',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> rejectionReasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'rejectionReason',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> rejectionReasonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'rejectionReason',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> rejectionReasonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rejectionReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> rejectionReasonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rejectionReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> rejectionReasonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rejectionReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> rejectionReasonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rejectionReason',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> rejectionReasonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'rejectionReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> rejectionReasonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'rejectionReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
          QAfterFilterCondition>
      rejectionReasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'rejectionReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
          QAfterFilterCondition>
      rejectionReasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'rejectionReason',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> rejectionReasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rejectionReason',
        value: '',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> rejectionReasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'rejectionReason',
        value: '',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> requestedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'requestedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> requestedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'requestedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> requestedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'requestedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> requestedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'requestedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> requestedByEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'requestedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> requestedByGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'requestedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> requestedByLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'requestedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> requestedByBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'requestedBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> requestedByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'requestedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> requestedByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'requestedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
          QAfterFilterCondition>
      requestedByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'requestedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
          QAfterFilterCondition>
      requestedByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'requestedBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> requestedByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'requestedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> requestedByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'requestedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> requestedByNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'requestedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> requestedByNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'requestedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> requestedByNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'requestedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> requestedByNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'requestedByName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> requestedByNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'requestedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> requestedByNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'requestedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
          QAfterFilterCondition>
      requestedByNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'requestedByName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
          QAfterFilterCondition>
      requestedByNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'requestedByName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> requestedByNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'requestedByName',
        value: '',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> requestedByNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'requestedByName',
        value: '',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> statusEqualTo(TransferStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> statusGreaterThan(
    TransferStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> statusLessThan(
    TransferStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> statusBetween(
    TransferStatus lower,
    TransferStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> toLocationIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'toLocationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> toLocationIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'toLocationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> toLocationIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'toLocationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> toLocationIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'toLocationId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> toLocationIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'toLocationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> toLocationIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'toLocationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
          QAfterFilterCondition>
      toLocationIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'toLocationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
          QAfterFilterCondition>
      toLocationIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'toLocationId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> toLocationIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'toLocationId',
        value: '',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> toLocationIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'toLocationId',
        value: '',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> toLocationNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'toLocationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> toLocationNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'toLocationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> toLocationNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'toLocationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> toLocationNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'toLocationName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> toLocationNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'toLocationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> toLocationNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'toLocationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
          QAfterFilterCondition>
      toLocationNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'toLocationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
          QAfterFilterCondition>
      toLocationNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'toLocationName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> toLocationNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'toLocationName',
        value: '',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> toLocationNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'toLocationName',
        value: '',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> toLocationTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'toLocationType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> toLocationTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'toLocationType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> toLocationTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'toLocationType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> toLocationTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'toLocationType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> toLocationTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'toLocationType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> toLocationTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'toLocationType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
          QAfterFilterCondition>
      toLocationTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'toLocationType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
          QAfterFilterCondition>
      toLocationTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'toLocationType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> toLocationTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'toLocationType',
        value: '',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> toLocationTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'toLocationType',
        value: '',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> updatedByEqualTo(
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

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> updatedByGreaterThan(
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

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> updatedByLessThan(
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

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> updatedByBetween(
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

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> updatedByStartsWith(
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

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> updatedByEndsWith(
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

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
          QAfterFilterCondition>
      updatedByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'updatedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
          QAfterFilterCondition>
      updatedByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'updatedBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> updatedByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> updatedByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'updatedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
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

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
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

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
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

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
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

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
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

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
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

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
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

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
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

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> uuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uuid',
        value: '',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> uuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uuid',
        value: '',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> variantNameEqualTo(
    String value, {
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

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> variantNameGreaterThan(
    String value, {
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

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> variantNameLessThan(
    String value, {
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

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> variantNameBetween(
    String lower,
    String upper, {
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

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
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

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
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

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
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

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
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

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> variantNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'variantName',
        value: '',
      ));
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterFilterCondition> variantNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'variantName',
        value: '',
      ));
    });
  }
}

extension TransferRequestLocalModelQueryObject on QueryBuilder<
    TransferRequestLocalModel, TransferRequestLocalModel, QFilterCondition> {}

extension TransferRequestLocalModelQueryLinks on QueryBuilder<
    TransferRequestLocalModel, TransferRequestLocalModel, QFilterCondition> {}

extension TransferRequestLocalModelQuerySortBy on QueryBuilder<
    TransferRequestLocalModel, TransferRequestLocalModel, QSortBy> {
  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByApprovedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedAt', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByApprovedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedAt', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByApprovedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedBy', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByApprovedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedBy', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByApprovedByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedByName', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByApprovedByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedByName', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByCancelledAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cancelledAt', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByCancelledAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cancelledAt', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByCancelledBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cancelledBy', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByCancelledByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cancelledBy', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByCancelledByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cancelledByName', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByCancelledByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cancelledByName', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByCompletedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedBy', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByCompletedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedBy', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByCompletedByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedByName', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByCompletedByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedByName', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByFromLocationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromLocationId', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByFromLocationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromLocationId', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByFromLocationName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromLocationName', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByFromLocationNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromLocationName', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByFromLocationType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromLocationType', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByFromLocationTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromLocationType', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByProductName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productName', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByProductNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productName', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByProductVariantId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productVariantId', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByProductVariantIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productVariantId', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByRejectedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rejectedAt', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByRejectedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rejectedAt', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByRejectedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rejectedBy', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByRejectedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rejectedBy', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByRejectedByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rejectedByName', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByRejectedByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rejectedByName', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByRejectionReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rejectionReason', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByRejectionReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rejectionReason', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByRequestedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestedAt', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByRequestedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestedAt', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByRequestedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestedBy', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByRequestedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestedBy', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByRequestedByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestedByName', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByRequestedByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestedByName', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByToLocationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toLocationId', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByToLocationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toLocationId', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByToLocationName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toLocationName', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByToLocationNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toLocationName', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByToLocationType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toLocationType', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByToLocationTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toLocationType', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByUpdatedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedBy', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByUpdatedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedBy', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByVariantName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'variantName', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> sortByVariantNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'variantName', Sort.desc);
    });
  }
}

extension TransferRequestLocalModelQuerySortThenBy on QueryBuilder<
    TransferRequestLocalModel, TransferRequestLocalModel, QSortThenBy> {
  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByApprovedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedAt', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByApprovedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedAt', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByApprovedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedBy', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByApprovedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedBy', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByApprovedByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedByName', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByApprovedByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedByName', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByCancelledAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cancelledAt', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByCancelledAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cancelledAt', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByCancelledBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cancelledBy', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByCancelledByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cancelledBy', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByCancelledByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cancelledByName', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByCancelledByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cancelledByName', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByCompletedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedBy', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByCompletedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedBy', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByCompletedByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedByName', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByCompletedByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedByName', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByFromLocationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromLocationId', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByFromLocationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromLocationId', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByFromLocationName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromLocationName', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByFromLocationNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromLocationName', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByFromLocationType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromLocationType', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByFromLocationTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromLocationType', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByProductName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productName', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByProductNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productName', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByProductVariantId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productVariantId', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByProductVariantIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productVariantId', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByRejectedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rejectedAt', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByRejectedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rejectedAt', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByRejectedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rejectedBy', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByRejectedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rejectedBy', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByRejectedByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rejectedByName', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByRejectedByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rejectedByName', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByRejectionReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rejectionReason', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByRejectionReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rejectionReason', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByRequestedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestedAt', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByRequestedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestedAt', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByRequestedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestedBy', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByRequestedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestedBy', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByRequestedByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestedByName', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByRequestedByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestedByName', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByToLocationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toLocationId', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByToLocationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toLocationId', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByToLocationName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toLocationName', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByToLocationNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toLocationName', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByToLocationType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toLocationType', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByToLocationTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toLocationType', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByUpdatedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedBy', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByUpdatedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedBy', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByVariantName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'variantName', Sort.asc);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel,
      QAfterSortBy> thenByVariantNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'variantName', Sort.desc);
    });
  }
}

extension TransferRequestLocalModelQueryWhereDistinct on QueryBuilder<
    TransferRequestLocalModel, TransferRequestLocalModel, QDistinct> {
  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel, QDistinct>
      distinctByApprovedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'approvedAt');
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel, QDistinct>
      distinctByApprovedBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'approvedBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel, QDistinct>
      distinctByApprovedByName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'approvedByName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel, QDistinct>
      distinctByCancelledAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cancelledAt');
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel, QDistinct>
      distinctByCancelledBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cancelledBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel, QDistinct>
      distinctByCancelledByName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cancelledByName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel, QDistinct>
      distinctByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedAt');
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel, QDistinct>
      distinctByCompletedBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel, QDistinct>
      distinctByCompletedByName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedByName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel, QDistinct>
      distinctByFromLocationId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fromLocationId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel, QDistinct>
      distinctByFromLocationName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fromLocationName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel, QDistinct>
      distinctByFromLocationType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fromLocationType',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel, QDistinct>
      distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel, QDistinct>
      distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel, QDistinct>
      distinctByNotes({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel, QDistinct>
      distinctByProductName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'productName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel, QDistinct>
      distinctByProductVariantId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'productVariantId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel, QDistinct>
      distinctByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quantity');
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel, QDistinct>
      distinctByRejectedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rejectedAt');
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel, QDistinct>
      distinctByRejectedBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rejectedBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel, QDistinct>
      distinctByRejectedByName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rejectedByName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel, QDistinct>
      distinctByRejectionReason({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rejectionReason',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel, QDistinct>
      distinctByRequestedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'requestedAt');
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel, QDistinct>
      distinctByRequestedBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'requestedBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel, QDistinct>
      distinctByRequestedByName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'requestedByName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel, QDistinct>
      distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status');
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel, QDistinct>
      distinctByToLocationId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'toLocationId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel, QDistinct>
      distinctByToLocationName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'toLocationName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel, QDistinct>
      distinctByToLocationType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'toLocationType',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel, QDistinct>
      distinctByUpdatedBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel, QDistinct>
      distinctByUuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferRequestLocalModel, QDistinct>
      distinctByVariantName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'variantName', caseSensitive: caseSensitive);
    });
  }
}

extension TransferRequestLocalModelQueryProperty on QueryBuilder<
    TransferRequestLocalModel, TransferRequestLocalModel, QQueryProperty> {
  QueryBuilder<TransferRequestLocalModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TransferRequestLocalModel, DateTime?, QQueryOperations>
      approvedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'approvedAt');
    });
  }

  QueryBuilder<TransferRequestLocalModel, String?, QQueryOperations>
      approvedByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'approvedBy');
    });
  }

  QueryBuilder<TransferRequestLocalModel, String?, QQueryOperations>
      approvedByNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'approvedByName');
    });
  }

  QueryBuilder<TransferRequestLocalModel, DateTime?, QQueryOperations>
      cancelledAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cancelledAt');
    });
  }

  QueryBuilder<TransferRequestLocalModel, String?, QQueryOperations>
      cancelledByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cancelledBy');
    });
  }

  QueryBuilder<TransferRequestLocalModel, String?, QQueryOperations>
      cancelledByNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cancelledByName');
    });
  }

  QueryBuilder<TransferRequestLocalModel, DateTime?, QQueryOperations>
      completedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedAt');
    });
  }

  QueryBuilder<TransferRequestLocalModel, String?, QQueryOperations>
      completedByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedBy');
    });
  }

  QueryBuilder<TransferRequestLocalModel, String?, QQueryOperations>
      completedByNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedByName');
    });
  }

  QueryBuilder<TransferRequestLocalModel, String, QQueryOperations>
      fromLocationIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fromLocationId');
    });
  }

  QueryBuilder<TransferRequestLocalModel, String, QQueryOperations>
      fromLocationNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fromLocationName');
    });
  }

  QueryBuilder<TransferRequestLocalModel, String, QQueryOperations>
      fromLocationTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fromLocationType');
    });
  }

  QueryBuilder<TransferRequestLocalModel, bool, QQueryOperations>
      isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<TransferRequestLocalModel, DateTime, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<TransferRequestLocalModel, String?, QQueryOperations>
      notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<TransferRequestLocalModel, String, QQueryOperations>
      productNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'productName');
    });
  }

  QueryBuilder<TransferRequestLocalModel, String, QQueryOperations>
      productVariantIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'productVariantId');
    });
  }

  QueryBuilder<TransferRequestLocalModel, int, QQueryOperations>
      quantityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quantity');
    });
  }

  QueryBuilder<TransferRequestLocalModel, DateTime?, QQueryOperations>
      rejectedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rejectedAt');
    });
  }

  QueryBuilder<TransferRequestLocalModel, String?, QQueryOperations>
      rejectedByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rejectedBy');
    });
  }

  QueryBuilder<TransferRequestLocalModel, String?, QQueryOperations>
      rejectedByNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rejectedByName');
    });
  }

  QueryBuilder<TransferRequestLocalModel, String?, QQueryOperations>
      rejectionReasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rejectionReason');
    });
  }

  QueryBuilder<TransferRequestLocalModel, DateTime, QQueryOperations>
      requestedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'requestedAt');
    });
  }

  QueryBuilder<TransferRequestLocalModel, String, QQueryOperations>
      requestedByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'requestedBy');
    });
  }

  QueryBuilder<TransferRequestLocalModel, String, QQueryOperations>
      requestedByNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'requestedByName');
    });
  }

  QueryBuilder<TransferRequestLocalModel, TransferStatus, QQueryOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<TransferRequestLocalModel, String, QQueryOperations>
      toLocationIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'toLocationId');
    });
  }

  QueryBuilder<TransferRequestLocalModel, String, QQueryOperations>
      toLocationNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'toLocationName');
    });
  }

  QueryBuilder<TransferRequestLocalModel, String, QQueryOperations>
      toLocationTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'toLocationType');
    });
  }

  QueryBuilder<TransferRequestLocalModel, String, QQueryOperations>
      updatedByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedBy');
    });
  }

  QueryBuilder<TransferRequestLocalModel, String, QQueryOperations>
      uuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uuid');
    });
  }

  QueryBuilder<TransferRequestLocalModel, String, QQueryOperations>
      variantNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'variantName');
    });
  }
}
