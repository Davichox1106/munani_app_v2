import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/services/product_image_storage_service.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/product.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';

/// Página de formulario de productos
///
/// Permite crear o editar un producto con:
/// - Nombre (requerido)
/// - Descripción (opcional)
/// - Categoría (requerido)
/// - Precio base (requerido)
/// - Indicador de variantes
class ProductFormPage extends StatefulWidget {
  final Product? product; // null = crear, con valor = editar

  const ProductFormPage({
    super.key,
    this.product,
  });

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceSellController = TextEditingController();
  final _priceBuyController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  ProductCategory _selectedCategory = ProductCategory.otros;
  bool _hasVariants = false;
  bool _isLoading = false;
  bool _isUploadingImages = false;
  List<String> _imagePaths = [];

  bool get _isEditMode => widget.product != null;

  @override
  void initState() {
    super.initState();

    // Si es modo edición, prellenar los campos
    if (_isEditMode) {
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description ?? '';
      _priceSellController.text = widget.product!.basePriceSell.toString();
      _priceBuyController.text = widget.product!.basePriceBuy.toString();
      _selectedCategory = widget.product!.category;
      _hasVariants = widget.product!.hasVariants;
      _imagePaths = List<String>.from(widget.product!.imageUrls);

      if (_imagePaths.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _refreshExistingImageUrls();
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceSellController.dispose();
    _priceBuyController.dispose();
    super.dispose();
  }

  Future<void> _refreshExistingImageUrls() async {
    final storageService = sl<ProductImageStorageService>();
    final refreshed = <String>[];

    for (final url in _imagePaths) {
      final updatedUrl = await storageService.ensureSignedUrl(url);
      refreshed.add(updatedUrl);
    }

    if (!mounted) return;
    setState(() {
      _imagePaths = refreshed;
    });
  }

  Future<void> _pickImages() async {
    if (_isLoading || _isUploadingImages) return;

    final images = await _imagePicker.pickMultiImage(imageQuality: 85);

    if (images.isEmpty) return;

    final networkInfo = sl<NetworkInfo>();
    final isConnected = await networkInfo.isConnected;

    if (!isConnected) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Necesitas conexión a internet para subir imágenes.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isUploadingImages = true);

    final storageService = sl<ProductImageStorageService>();
    final uploadedUrls = <String>[];
    final errors = <String>[];

    for (final image in images) {
      final file = File(image.path);
      if (!file.existsSync()) {
        errors.add('El archivo seleccionado no existe.');
        continue;
      }

      try {
        final url = await storageService.uploadProductImage(
          file,
          productId: widget.product?.id,
        );

        uploadedUrls.add(url);
      } on ProductImageStorageException catch (e) {
        errors.add(e.message);
      } catch (e) {
        errors.add('No se pudo subir una imagen: $e');
      }
    }

    if (!mounted) return;

    if (uploadedUrls.isNotEmpty) {
      setState(() {
        _imagePaths.addAll(uploadedUrls);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            uploadedUrls.length == 1
                ? 'Imagen subida correctamente.'
                : '${uploadedUrls.length} imágenes subidas correctamente.',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }

    if (errors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errors.first),
          backgroundColor: AppColors.error,
        ),
      );
    }

    setState(() => _isUploadingImages = false);
  }

  Future<void> _addImageFromUrl() async {
    if (_isLoading) return;

    final url = await showDialog<String?>(
      context: context,
      builder: (dialogContext) => const _AddImageUrlDialog(),
    );

    if (url == null || url.isEmpty) {
      return;
    }

    setState(() {
      _imagePaths.add(url);
    });
  }

  void _removeImage(String path) {
    setState(() {
      _imagePaths.remove(path);
    });

    if (!path.startsWith('http')) {
      final file = File(path);
      if (file.existsSync()) {
        file.deleteSync();
      }
    }
  }

  bool _isRemoteImage(String path) {
    return path.startsWith('http');
  }

  Widget _buildThumbnail(String path) {
    final imageWidget = _isRemoteImage(path)
        ? Image.network(
            path,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 28),
          )
        : Image.file(
            File(path),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 28),
          );

    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ColoredBox(
              color: Colors.grey.shade200,
              child: imageWidget,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeImage(path),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onSave() {
    // OWASP A03: Validación de entrada
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes estar autenticado'),
          backgroundColor: AppColors.error,
        ),
      );
      setState(() => _isLoading = false);
      return;
    }

    if (_isEditMode) {
      // Editar producto existente
      final updatedProduct = widget.product!.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        category: _selectedCategory,
        basePriceSell: double.parse(_priceSellController.text),
        basePriceBuy: double.parse(_priceBuyController.text),
        hasVariants: _hasVariants,
        imageUrls: List<String>.from(_imagePaths),
        updatedAt: DateTime.now(),
      );

      context.read<ProductBloc>().add(UpdateProduct(updatedProduct));
    } else {
      // Crear nuevo producto
      context.read<ProductBloc>().add(
            CreateProduct(
              name: _nameController.text.trim(),
              description: _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
              category: _selectedCategory,
              basePriceSell: double.parse(_priceSellController.text),
              basePriceBuy: double.parse(_priceBuyController.text),
              hasVariants: _hasVariants,
              imageUrls: List<String>.from(_imagePaths),
              createdBy: authState.user.id,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Editar Producto' : 'Nuevo Producto'),
      ),
      body: BlocListener<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Producto "${state.product.name}" creado exitosamente'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.of(context).pop();
          }

          if (state is ProductUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Producto "${state.product.name}" actualizado'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.of(context).pop();
          }

          if (state is ProductError) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Nombre del producto
                TextFormField(
                  controller: _nameController,
                  enabled: !_isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Producto *',
                    hintText: 'Ej: Barrita de Quinoa y Miel',
                    prefixIcon: Icon(Icons.inventory_2),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre es requerido';
                    }
                    if (value.trim().length < 3) {
                      return 'Mínimo 3 caracteres';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

                // Imágenes del producto
                _ProductImagesSection(
                  imagePaths: _imagePaths,
                  onAddFromGallery: _pickImages,
                  onAddFromUrl: _addImageFromUrl,
                  isLoading: _isLoading,
                  isUploading: _isUploadingImages,
                  builder: _buildThumbnail,
                ),

                const SizedBox(height: 16),

                // Descripción (opcional)
                TextFormField(
                  controller: _descriptionController,
                  enabled: !_isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Descripción (opcional)',
                    hintText: 'Ej: Barrita energizante con semillas y frutos rojos',
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),

                // Categoría
                DropdownButtonFormField<ProductCategory>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Categoría *',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: ProductCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category.displayName),
                    );
                  }).toList(),
                  onChanged: _isLoading
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() => _selectedCategory = value);
                          }
                        },
                ),
                const SizedBox(height: 16),

                // Precios base
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceSellController,
                        enabled: !_isLoading,
                        decoration: const InputDecoration(
                          labelText: 'Precio Venta Base *',
                          hintText: '0.00',
                          prefixIcon: Icon(Icons.sell),
                          prefixText: '\$ ',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: Validators.price,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _priceBuyController,
                        enabled: !_isLoading,
                        decoration: const InputDecoration(
                          labelText: 'Precio Compra Base *',
                          hintText: '0.00',
                          prefixIcon: Icon(Icons.shopping_cart),
                          prefixText: '\$ ',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: Validators.price,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Switch de variantes
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.tune,
                        color: AppColors.primaryOrange,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '¿Tiene variantes?',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Ej: Colores, tamaños, dimensiones',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _hasVariants,
                        onChanged: _isLoading
                            ? null
                            : (value) => setState(() => _hasVariants = value),
                        activeTrackColor: AppColors.primaryOrange.withValues(alpha: 0.5),
                        thumbColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return AppColors.primaryOrange;
                          }
                          return null;
                        }),
                      ),
                    ],
                  ),
                ),

                // Información de variantes
                if (_hasVariants) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppColors.info,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Las variantes se gestionarán en una pantalla separada después de crear el producto',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // Botón de guardar
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _onSave,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(_isEditMode ? Icons.save : Icons.add),
                  label: Text(_isEditMode ? 'Guardar Cambios' : 'Crear Producto'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),

                const SizedBox(height: 16),

                // Información de seguridad
                if (!_isEditMode)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.cloud_outlined,
                          size: 20,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Las imágenes se subirán a Supabase Storage. Necesitas conexión a internet.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductImagesSection extends StatelessWidget {
  final List<String> imagePaths;
  final Future<void> Function() onAddFromGallery;
  final Future<void> Function() onAddFromUrl;
  final Widget Function(String path) builder;
  final bool isLoading;
  final bool isUploading;

  const _ProductImagesSection({
    required this.imagePaths,
    required this.onAddFromGallery,
    required this.onAddFromUrl,
    required this.builder,
    required this.isLoading,
    required this.isUploading,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = isLoading || isUploading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Imágenes del producto',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: isDisabled
                  ? null
                  : () {
                      onAddFromGallery();
                    },
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Desde galería'),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: isDisabled
                  ? null
                  : () {
                      onAddFromUrl();
                    },
              icon: const Icon(Icons.link),
              label: const Text('Agregar URL'),
            ),
          ],
        ),
        if (isUploading) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Text(
                'Subiendo imágenes...',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        if (imagePaths.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(12),
              color: AppColors.background,
            ),
            child: Text(
              'Aún no has agregado imágenes. Puedes seleccionar varias desde la galería o agregar enlaces públicos.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          )
        else
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: imagePaths
                .map(
                  (path) => SizedBox(
                    width: 90,
                    height: 90,
                    child: builder(path),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class _AddImageUrlDialog extends StatefulWidget {
  const _AddImageUrlDialog();

  @override
  State<_AddImageUrlDialog> createState() => _AddImageUrlDialogState();
}

class _AddImageUrlDialogState extends State<_AddImageUrlDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar imagen desde URL'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: 'https://…',
          labelText: 'URL de la imagen',
        ),
        keyboardType: TextInputType.url,
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(_controller.text.trim());
          },
          child: const Text('Agregar'),
        ),
      ],
    );
  }
}

