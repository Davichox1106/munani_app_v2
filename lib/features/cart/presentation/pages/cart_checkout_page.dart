import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/services/payment_qr_storage_service.dart';
import '../../../locations/domain/entities/store.dart';
import '../../../locations/domain/entities/warehouse.dart';
import '../../../locations/domain/repositories/location_repository.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_status.dart';
import '../bloc/cart_bloc.dart';

class CartCheckoutPage extends StatefulWidget {
  final Cart cart;

  const CartCheckoutPage({
    super.key,
    required this.cart,
  });

  @override
  State<CartCheckoutPage> createState() => _CartCheckoutPageState();
}

class _CartCheckoutPageState extends State<CartCheckoutPage> {
  final _imagePicker = ImagePicker();
  final Dio _dio = Dio();
  Cart? _cart;
  LocationPaymentInfo? _paymentInfo;
  String? _loadError;
  bool _loadingLocation = false;
  XFile? _receiptFile;
  bool _isDownloadingQr = false;

  @override
  void initState() {
    super.initState();
    _cart = widget.cart;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final bloc = context.read<CartBloc>();
      final currentCart = bloc.state.cart;
      if (currentCart != null) {
        _cart = currentCart;
      }

      final cart = _cart;
      if (cart != null) {
        bloc.add(CartCheckoutInitiated(cartId: cart.id));
      }

      _loadLocationInfo();
    });
  }

  Future<void> _loadLocationInfo() async {
    final cart = _cart;
    if (cart == null || cart.locationId == null || cart.locationType == null) {
      if (!mounted) return;
      setState(() {
        _paymentInfo = null;
        _loadError = 'El carrito no tiene una ubicación asignada.';
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _loadingLocation = true;
      _loadError = null;
    });

    final repo = sl<LocationRepository>();
    final qrService = sl<PaymentQrStorageService>();

    if (cart.locationType == 'store') {
      final result = await repo.getStoreById(cart.locationId!);
      await result.fold<Future<void>>(
        (failure) async {
          if (!mounted) return;
          setState(() {
            _loadError = failure.message;
            _paymentInfo = null;
            _loadingLocation = false;
          });
        },
        (store) async {
          final signedUrl = await qrService.ensureSignedUrl(store.paymentQrUrl);
          if (!mounted) return;
          setState(() {
            _paymentInfo = LocationPaymentInfo(
              displayName: store.name,
              locationType: 'store',
              qrUrl: signedUrl ?? store.paymentQrUrl,
              qrDescription: store.paymentQrDescription,
            );
            _loadingLocation = false;
          });
        },
      );
      return;
    }

    final result = await repo.getWarehouseById(cart.locationId!);
    await result.fold<Future<void>>(
      (failure) async {
        if (!mounted) return;
        setState(() {
          _loadError = failure.message;
          _paymentInfo = null;
          _loadingLocation = false;
        });
      },
      (warehouse) async {
        final signedUrl =
            await qrService.ensureSignedUrl(warehouse.paymentQrUrl);
        if (!mounted) return;
        setState(() {
          _paymentInfo = LocationPaymentInfo(
            displayName: warehouse.name,
            locationType: 'warehouse',
            qrUrl: signedUrl ?? warehouse.paymentQrUrl,
            qrDescription: warehouse.paymentQrDescription,
          );
          _loadingLocation = false;
        });
      },
    );
  }

  Future<void> _pickReceipt() async {
    try {
      final result = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (result != null) {
        setState(() => _receiptFile = result);
      }
    } catch (e) {
      AppLogger.error('Error al seleccionar comprobante: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo seleccionar la imagen ($e)'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _submitReceipt() {
    if (_receiptFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un comprobante antes de continuar.'),
        ),
      );
      return;
    }

    final cart = _cart;
    if (cart == null) {
      return;
    }

    context.read<CartBloc>().add(
          CartSubmitReceipt(
            cartId: cart.id,
            filePath: _receiptFile!.path,
            fileName: _receiptFile!.name,
          ),
        );
  }

  Future<void> _downloadQr() async {
    final info = _paymentInfo;
    if (info == null || info.qrUrl == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay un QR disponible para descargar.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_isDownloadingQr) return;

    setState(() {
      _isDownloadingQr = true;
    });

    try {
      final response = await _dio.get<List<int>>(
        info.qrUrl!,
        options: Options(responseType: ResponseType.bytes),
      );

      Directory targetDirectory;

      if (Platform.isAndroid) {
        final directories = await getExternalStorageDirectories(
          type: StorageDirectory.downloads,
        );

        if (directories != null && directories.isNotEmpty) {
          targetDirectory = directories.first;
        } else {
          targetDirectory = Directory('/storage/emulated/0/Download');
        }
      } else {
        final downloads = await getDownloadsDirectory();
        targetDirectory =
            downloads ?? await getApplicationDocumentsDirectory();
      }

      if (!await targetDirectory.exists()) {
        await targetDirectory.create(recursive: true);
      }

      final fileName =
          'munani_qr_${info.displayName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.png';
      final filePath = p.join(targetDirectory.path, fileName);
      final file = File(filePath);
      await file.writeAsBytes(response.data ?? []);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('QR guardado en: $filePath'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e, stack) {
      AppLogger.error('❌ Error al descargar QR: $e');
      AppLogger.debug('Stack: $stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo descargar el QR: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloadingQr = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CartBloc>().state;
    final cart = state.cart ?? _cart;
    final isProcessingAction = state.status == CartBlocStatus.loading;
    final cartStatus = cart?.status ?? CartStatus.pending;
    final receiptAlreadySent = cartStatus == CartStatus.paymentSubmitted;

    return BlocListener<CartBloc, CartState>(
      listenWhen: (previous, current) =>
          previous.cart != current.cart ||
          previous.message != current.message ||
          previous.error != current.error,
      listener: (context, state) {
        if (state.cart != null) {
          final previousLocation = _cart?.locationId;
          if (mounted) {
            setState(() {
              _cart = state.cart;
            });
          }
          if (previousLocation != state.cart?.locationId) {
            _loadLocationInfo();
          }
        }

        if (state.message != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!),
                backgroundColor: AppColors.success,
              ),
            );
            setState(() {
              _receiptFile = null;
            });
          }
          context.read<CartBloc>().add(const CartMessageShown());
        }

        if (state.error != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: AppColors.error,
              ),
            );
          }
          context.read<CartBloc>().add(const CartMessageShown());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Checkout'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Actualizar información',
              onPressed: _loadingLocation ? null : _loadLocationInfo,
            ),
          ],
        ),
        body: cart == null
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadLocationInfo,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  children: [
                    _buildCartSummaryCard(context, cart, cartStatus),
                    const SizedBox(height: 16),
                    _buildLocationCard(context, cart),
                    const SizedBox(height: 16),
                    _buildReceiptCard(
                      context,
                      cart,
                      isProcessingAction,
                      receiptAlreadySent,
                    ),
                    const SizedBox(height: 16),
                    _buildHelpCard(context),
                  ],
                ),
              ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: FilledButton.icon(
              onPressed: cart == null ||
                      receiptAlreadySent ||
                      isProcessingAction ||
                      _receiptFile == null
                  ? null
                  : _submitReceipt,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.primaryBrown,
              ),
              icon: isProcessingAction
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.cloud_upload_outlined),
              label: Text(
                receiptAlreadySent
                    ? 'Comprobante enviado'
                    : isProcessingAction
                        ? 'Enviando comprobante...'
                        : 'Enviar comprobante',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCartSummaryCard(
    BuildContext context,
    Cart cart,
    CartStatus status,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Resumen del carrito',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            _buildStatusBadge(context, status),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Artículos'),
                Text('${cart.totalItems}'),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  cart.subtotal.toStringAsFixed(2),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            if (cart.locationName != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    cart.locationType == 'store'
                        ? Icons.store
                        : Icons.warehouse,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      cart.locationName!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, CartStatus status) {
    late Color color;
    late IconData icon;
    late String label;

    switch (status) {
      case CartStatus.pending:
        color = AppColors.textSecondary;
        icon = Icons.shopping_cart_outlined;
        label = 'Pendiente';
        break;
      case CartStatus.awaitingPayment:
        color = AppColors.warning;
        icon = Icons.schedule_outlined;
        label = 'Esperando pago';
        break;
      case CartStatus.paymentSubmitted:
        color = AppColors.info;
        icon = Icons.hourglass_bottom_outlined;
        label = 'Pago enviado';
        break;
      case CartStatus.paymentRejected:
        color = AppColors.error;
        icon = Icons.cancel_outlined;
        label = 'Pago rechazado';
        break;
      case CartStatus.completed:
        color = AppColors.success;
        icon = Icons.verified_outlined;
        label = 'Completado';
        break;
      case CartStatus.cancelled:
        color = AppColors.error;
        icon = Icons.block;
        label = 'Cancelado';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context, Cart cart) {
    if (_loadingLocation) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Cargando información de pago...'),
            ],
          ),
        ),
      );
    }

    if (_loadError != null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning_amber_outlined,
                      color: AppColors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _loadError!,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.error),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _loadLocationInfo,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_paymentInfo == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Sin información de pago',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Esta ubicación aún no cuenta con un QR configurado. '
                'Contacta al administrador para completar la configuración.',
              ),
            ],
          ),
        ),
      );
    }

    final info = _paymentInfo!;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  info.locationType == 'store'
                      ? Icons.store
                      : Icons.warehouse,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    info.displayName,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Código QR para pagos',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            if (info.hasQr)
              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.network(
                      info.qrUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.broken_image_outlined,
                                  color: AppColors.error, size: 32),
                              SizedBox(height: 8),
                              Text(
                                'No se pudo descargar el QR',
                                style: TextStyle(color: AppColors.error),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline, color: AppColors.warning),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'La ubicación todavía no ha subido un QR. Solicítalo al administrador.',
                      ),
                    ),
                  ],
                ),
              ),
            if (info.qrDescription != null) ...[
              const SizedBox(height: 12),
              Text(
                info.qrDescription!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            ],
            if (info.hasQr) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: _isDownloadingQr ? null : _downloadQr,
                  icon: _isDownloadingQr
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.download_outlined),
                  label: Text(
                    _isDownloadingQr ? 'Descargando...' : 'Descargar QR',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptCard(
    BuildContext context,
    Cart cart,
    bool isProcessing,
    bool receiptAlreadySent,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Sube tu comprobante',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Adjunta una captura o fotografía del comprobante de pago para que el encargado pueda validar tu pedido.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed:
                  receiptAlreadySent || isProcessing ? null : _pickReceipt,
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(_receiptFile == null
                  ? 'Seleccionar imagen'
                  : 'Cambiar imagen'),
            ),
            if (receiptAlreadySent) ...[
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.info_outline, color: AppColors.info),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Ya enviaste un comprobante. Puedes volver a intentarlo '
                        'si el gerente lo solicita.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (_receiptFile != null) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 220,
                  child: Image.file(
                    File(_receiptFile!.path),
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: const Text(
                          'No se pudo previsualizar el comprobante',
                          style: TextStyle(color: AppColors.error),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Archivo seleccionado: ${_receiptFile!.name}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHelpCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Cómo continúo?',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            _buildStepRow(
              context,
              index: 1,
              text:
                  'Escanea el QR y realiza la transferencia del monto total indicado.',
            ),
            const SizedBox(height: 8),
            _buildStepRow(
              context,
              index: 2,
              text:
                  'Guarda el comprobante de pago (captura de pantalla o foto).',
            ),
            const SizedBox(height: 8),
            _buildStepRow(
              context,
              index: 3,
              text:
                  'Adjunta el comprobante y envíalo. Un encargado revisará tu pedido y te notificará.',
            ),
            const SizedBox(height: 12),
            Text(
              'Estados del pedido:',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            _buildStatusChip(
              label: 'Pendiente',
              description: 'Carrito en edición. Puedes seguir agregando productos.',
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 6),
            _buildStatusChip(
              label: 'Esperando pago',
              description:
                  'Iniciaste el checkout. Realiza el pago y adjunta el comprobante.',
              color: AppColors.warning,
            ),
            const SizedBox(height: 6),
            _buildStatusChip(
              label: 'Pago en revisión',
              description:
                  'Enviaste el comprobante y está esperando la validación del encargado.',
              color: AppColors.info,
            ),
            const SizedBox(height: 6),
            _buildStatusChip(
              label: 'Pago rechazado',
              description:
                  'El encargado rechazó el pago. Revisa las observaciones y vuelve a intentarlo.',
              color: AppColors.error,
            ),
            const SizedBox(height: 6),
            _buildStatusChip(
              label: 'Completado',
              description:
                  'El pago fue aprobado y el inventario será actualizado.',
              color: AppColors.success,
            ),
            const SizedBox(height: 6),
            _buildStatusChip(
              label: 'Cancelado',
              description: 'El pedido fue cancelado o rechazado.',
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepRow(
    BuildContext context, {
    required int index,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: AppColors.primaryOrange,
          child: Text(
            '$index',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip({
    required String label,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, size: 10, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LocationPaymentInfo {
  final String displayName;
  final String locationType;
  final String? qrUrl;
  final String? qrDescription;

  const LocationPaymentInfo({
    required this.displayName,
    required this.locationType,
    this.qrUrl,
    this.qrDescription,
  });

  bool get hasQr => qrUrl != null && qrUrl!.trim().isNotEmpty;

  factory LocationPaymentInfo.fromStore(Store store) {
    return LocationPaymentInfo(
      displayName: store.name,
      locationType: 'store',
      qrUrl: store.paymentQrUrl,
      qrDescription: store.paymentQrDescription,
    );
  }

  factory LocationPaymentInfo.fromWarehouse(Warehouse warehouse) {
    return LocationPaymentInfo(
      displayName: warehouse.name,
      locationType: 'warehouse',
      qrUrl: warehouse.paymentQrUrl,
      qrDescription: warehouse.paymentQrDescription,
    );
  }
}

