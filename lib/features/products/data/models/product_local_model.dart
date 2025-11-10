import 'package:isar/isar.dart';
import '../../domain/entities/product.dart';

part 'product_local_model.g.dart';

/// Modelo de Isar para Product (Base de datos local)
///
/// Este modelo se usa para almacenar productos localmente con Isar.
/// Incluye control de sincronización offline-first.
@collection
class ProductLocalModel {
  /// ID local de Isar (autoincremental)
  Id id = Isar.autoIncrement;

  /// UUID del producto (sincronización con Supabase)
  @Index(unique: true)
  late String uuid;

  /// Nombre del producto
  @Index(type: IndexType.value)
  late String name;

  /// Descripción del producto (opcional)
  String? description;

  /// Categoría del producto
  @Enumerated(EnumType.name)
  late ProductCategory category;

  /// Precio base de venta del producto
  late double basePriceSell;
  
  /// Precio base de compra del producto
  late double basePriceBuy;

  /// Indica si el producto tiene variantes
  late bool hasVariants;

  /// URLs/paths de imágenes asociadas
  List<String> imageUrls = [];

  /// UUID del usuario que creó el producto
  late String createdBy;

  /// Fecha de creación
  late DateTime createdAt;

  /// Fecha de última actualización
  late DateTime updatedAt;

  /// Control de sincronización: indica si hay cambios pendientes de sincronizar
  late bool pendingSync;

  /// Fecha de última sincronización exitosa con Supabase
  DateTime? syncedAt;

  /// Constructor vacío requerido por Isar
  ProductLocalModel();

  /// Constructor desde entidad de dominio
  factory ProductLocalModel.fromEntity(Product product) {
    return ProductLocalModel()
      ..uuid = product.id
      ..name = product.name
      ..description = product.description
      ..category = product.category
      ..basePriceSell = product.basePriceSell
      ..basePriceBuy = product.basePriceBuy
      ..hasVariants = product.hasVariants
      ..imageUrls = List<String>.from(product.imageUrls)
      ..createdBy = product.createdBy
      ..createdAt = product.createdAt
      ..updatedAt = product.updatedAt
      ..pendingSync = false
      ..syncedAt = DateTime.now();
  }

  /// Constructor desde modelo remoto (para sincronización)
  factory ProductLocalModel.fromRemote({
    required String id,
    required String name,
    String? description,
    required ProductCategory category,
    required double basePriceSell,
    required double basePriceBuy,
    required bool hasVariants,
    List<String>? imageUrls,
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) {
    return ProductLocalModel()
      ..uuid = id
      ..name = name
      ..description = description
      ..category = category
      ..basePriceSell = basePriceSell
      ..basePriceBuy = basePriceBuy
      ..hasVariants = hasVariants
      ..imageUrls = imageUrls != null ? List<String>.from(imageUrls) : <String>[]
      ..createdBy = createdBy
      ..createdAt = createdAt
      ..updatedAt = updatedAt
      ..pendingSync = false
      ..syncedAt = DateTime.now();
  }

  /// Convertir a entidad de dominio
  Product toEntity() {
    return Product(
      id: uuid,
      name: name,
      description: description,
      category: category,
      basePriceSell: basePriceSell,
      basePriceBuy: basePriceBuy,
      hasVariants: hasVariants,
      imageUrls: List<String>.from(imageUrls),
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Convertir a JSON para sincronización
  Map<String, dynamic> toJson() {
    return {
      'id': uuid,
      'name': name,
      'description': description,
      'category': category.value, // ✅ Convertir a snake_case para SQL
      'base_price_sell': basePriceSell,
      'base_price_buy': basePriceBuy,
      'has_variants': hasVariants,
      'image_urls': imageUrls,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Marcar como pendiente de sincronización
  void markForSync() {
    pendingSync = true;
    updatedAt = DateTime.now();
  }

  /// Marcar como sincronizado
  void markAsSynced() {
    pendingSync = false;
    syncedAt = DateTime.now();
  }
}
