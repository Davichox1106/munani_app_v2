import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/services/payment_qr_storage_service.dart';
import '../../domain/entities/warehouse.dart';
import '../bloc/warehouse/warehouse_bloc.dart';
import '../bloc/warehouse/warehouse_event.dart' as warehouse_events;

/// Página de formulario para crear/editar almacenes
class WarehouseFormPage extends StatefulWidget {
  final Warehouse? warehouse;

  const WarehouseFormPage({super.key, this.warehouse});

  @override
  State<WarehouseFormPage> createState() => _WarehouseFormPageState();
}

class _WarehouseFormPageState extends State<WarehouseFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _qrUrlController = TextEditingController();
  final _qrDescriptionController = TextEditingController();
  bool _isActive = true;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploadingQr = false;
  File? _qrLocalPreview;
  String? _qrPreviewUrl;

  String? _validateQrReference(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La URL del QR es obligatoria';
    }

    final trimmed = value.trim();
    if (trimmed.contains('://')) {
      final uri = Uri.tryParse(trimmed);
      if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https') || uri.host.isEmpty) {
        return 'Ingresa una URL válida (https://...)';
      }
      return null;
    }

    if (!trimmed.contains('/')) {
      return 'Ingresa una ruta válida (warehouses/... o https://...)';
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    if (widget.warehouse != null) {
      _nameController.text = widget.warehouse!.name;
      _addressController.text = widget.warehouse!.address;
      _phoneController.text = widget.warehouse!.phone ?? '';
      _qrUrlController.text = widget.warehouse!.paymentQrUrl ?? '';
      _qrDescriptionController.text =
          widget.warehouse!.paymentQrDescription ?? '';
      _isActive = widget.warehouse!.isActive;
    }

    final initialQr = _qrUrlController.text.trim();
    if (initialQr.isNotEmpty) {
      _qrPreviewUrl = initialQr;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _refreshStoredQrUrl();
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _qrUrlController.dispose();
    _qrDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.warehouse != null;
    final qrPreview = _buildQrPreview();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Almacén' : 'Nuevo Almacén'),
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icono
                Icon(
                  Icons.warehouse,
                  size: 80,
                  color: AppColors.warning,
                ),
                const SizedBox(height: 24),

                // Nombre
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Almacén *',
                    hintText: 'Ej: Almacén Principal',
                    prefixIcon: Icon(Icons.business),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // URL QR de pago
                TextFormField(
                  controller: _qrUrlController,
                  decoration: const InputDecoration(
                    labelText: 'URL del QR de Pagos',
                    hintText: 'Ej: warehouses/archivo.png o https://...',
                    prefixIcon: Icon(Icons.qr_code_2_outlined),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.url,
                  onChanged: _onQrUrlChanged,
                  validator: _validateQrReference,
                ),
                const SizedBox(height: 16),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _isUploadingQr ? null : _handlePickQrImage,
                      icon: const Icon(Icons.photo_library_outlined),
                      label: Text(_isUploadingQr ? 'Subiendo...' : 'Seleccionar desde galería'),
                    ),
                    if (_isUploadingQr)
                      const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                if (qrPreview != null) ...[
                  const SizedBox(height: 12),
                  qrPreview,
                ],
                const SizedBox(height: 16),

                // Descripción QR
                TextFormField(
                  controller: _qrDescriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción del QR',
                    hintText: 'Ej: Pago rápido QR para despachos.',
                    prefixIcon: Icon(Icons.notes_outlined),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La descripción del QR es obligatoria';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Dirección
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Dirección *',
                    hintText: 'Ej: Zona Industrial #456',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La dirección es obligatoria';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Teléfono
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    hintText: 'Ej: +591 12345678',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                // Estado Activo/Inactivo
                if (isEditing)
                  SwitchListTile(
                    title: const Text('Almacén Activo'),
                    subtitle: Text(_isActive ? 'En operación' : 'Inactivo'),
                    value: _isActive,
                    onChanged: (value) {
                      setState(() {
                        _isActive = value;
                      });
                    },
                    activeThumbColor: AppColors.success,
                  ),

                const SizedBox(height: 24),

                // Botón Guardar
                ElevatedButton.icon(
                  onPressed: _handleSubmit,
                  icon: const Icon(Icons.save),
                  label: Text(isEditing ? 'Actualizar Almacén' : 'Crear Almacén'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warning,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),

                const SizedBox(height: 16),

                // Nota
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isEditing
                              ? 'Los cambios se sincronizarán automáticamente'
                              : 'El almacén se creará localmente y se sincronizará cuando haya conexión',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }

  void _onQrUrlChanged(String value) {
    final trimmed = value.trim();
    setState(() {
      _qrPreviewUrl = trimmed.isEmpty ? null : trimmed;
      if (trimmed.isNotEmpty) {
        _qrLocalPreview = null;
      }
    });
  }

  Future<void> _refreshStoredQrUrl() async {
    final current = _qrUrlController.text.trim();
    if (current.isEmpty) return;

    final service = sl<PaymentQrStorageService>();
    final normalized = service.normalizeReference(current);
    final signed = await service.ensureSignedUrl(normalized);
    if (!mounted) return;

    setState(() {
      _qrUrlController.text = normalized;
      _qrPreviewUrl = signed ?? normalized;
    });
  }

  Future<void> _handlePickQrImage() async {
    if (_isUploadingQr) return;

    setState(() {
      _isUploadingQr = true;
    });

    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (image == null) {
        if (!mounted) return;
        setState(() {
          _isUploadingQr = false;
        });
        return;
      }

      final networkInfo = sl<NetworkInfo>();
      final isConnected = await networkInfo.isConnected;

      if (!isConnected) {
        if (!mounted) return;
        setState(() {
          _isUploadingQr = false;
          _qrLocalPreview = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Necesitas conexión a internet para subir el QR.'),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }

      final file = File(image.path);

      if (!mounted) return;
      setState(() {
        _qrLocalPreview = file;
      });

      final storageService = sl<PaymentQrStorageService>();
      final storagePath = await storageService.uploadPaymentQrImage(
        file,
        locationType: PaymentQrLocationType.warehouse,
        existingLocationId: widget.warehouse?.id,
      );

      final signedUrl = await storageService.ensureSignedUrl(storagePath);

      if (!mounted) return;

      setState(() {
        _qrUrlController.text = storagePath;
        _qrPreviewUrl = signedUrl ?? storagePath;
        _qrLocalPreview = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR cargado correctamente.'),
          backgroundColor: AppColors.success,
        ),
      );
    } on PaymentQrStorageException catch (e) {
      if (!mounted) return;
      setState(() {
        _qrLocalPreview = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppColors.error,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _qrLocalPreview = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo subir la imagen: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingQr = false;
        });
      }
    }
  }

  Widget? _buildQrPreview() {
    if (_qrLocalPreview == null && (_qrPreviewUrl == null || _qrPreviewUrl!.isEmpty)) {
      return null;
    }

    Widget imageWidget;
    if (_qrLocalPreview != null) {
      imageWidget = Image.file(
        _qrLocalPreview!,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 64),
      );
    } else {
      imageWidget = Image.network(
        _qrPreviewUrl!,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 64),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vista previa del QR',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ColoredBox(
              color: Colors.grey.shade100,
              child: Center(child: imageWidget),
            ),
          ),
        ),
      ],
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final address = _addressController.text.trim();
    final phone = _phoneController.text.trim();
    final qrUrl = _qrUrlController.text.trim();
    final qrDescription = _qrDescriptionController.text.trim();

    final warehouseBloc = sl<WarehouseBloc>();

    if (widget.warehouse != null) {
      // Actualizar almacén existente
      final updatedWarehouse = Warehouse(
        id: widget.warehouse!.id,
        name: name,
        address: address,
        phone: phone.isEmpty ? null : phone,
        managerId: widget.warehouse!.managerId,
        isActive: _isActive,
        paymentQrUrl: qrUrl,
        paymentQrDescription: qrDescription,
        createdAt: widget.warehouse!.createdAt,
        updatedAt: DateTime.now(),
      );

      warehouseBloc.add(warehouse_events.UpdateWarehouse(updatedWarehouse));
    } else {
      // Crear nuevo almacén
      warehouseBloc.add(
        warehouse_events.CreateWarehouse(
          name: name,
          address: address,
          phone: phone.isEmpty ? null : phone,
          paymentQrUrl: qrUrl,
          paymentQrDescription: qrDescription,
        ),
      );
    }

    // Regresar a la pantalla anterior
    Navigator.of(context).pop();
  }
}

