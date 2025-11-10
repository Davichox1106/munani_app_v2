import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../inventory/domain/entities/inventory_item.dart';
import '../../../inventory/presentation/bloc/inventory_bloc.dart';
import '../../../users/domain/services/location_name_service.dart';
import '../../domain/entities/transfer_request.dart';
import '../bloc/transfer_bloc.dart';
import '../bloc/transfer_event.dart';
import '../bloc/transfer_state.dart';
import 'destination_selector_page.dart';
import 'product_selector_page.dart';

/// Página para crear una nueva solicitud de transferencia
class TransferFormPage extends StatefulWidget {
  const TransferFormPage({super.key});

  @override
  State<TransferFormPage> createState() => _TransferFormPageState();
}

class _TransferFormPageState extends State<TransferFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();

  InventoryItem? _selectedInventoryItem;
  String? _selectedToLocationId;
  String? _selectedToLocationName;
  String? _selectedToLocationType;

  late final LocationNameService _locationNameService;

  @override
  void initState() {
    super.initState();
    _locationNameService = di.sl<LocationNameService>();
    // Inicializar el servicio si no está inicializado
    if (!_locationNameService.isInitialized) {
      _locationNameService.initialize();
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Solicitud de Transferencia'),
        actions: [
          TextButton(
            onPressed: _submitForm,
            child: const Text(
              'Enviar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: BlocConsumer<TransferBloc, TransferState>(
        listener: (context, state) {
          if (state is TransferCreated) {
            Navigator.of(context).pop();
          } else if (state is TransferError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Información del producto
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Producto',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        if (_selectedInventoryItem != null) ...[
                          Text('Producto: ${_selectedInventoryItem!.productName}'),
                          Text('Variante: ${_selectedInventoryItem!.variantName}'),
                          Text('Stock disponible: ${_selectedInventoryItem!.quantity}'),
                        ] else ...[
                          const Text('Selecciona un producto de tu inventario'),
                        ],
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _selectProduct,
                          icon: const Icon(Icons.search),
                          label: const Text('Seleccionar Producto'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Cantidad
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cantidad',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Cantidad a transferir',
                            hintText: 'Ingresa la cantidad',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingresa la cantidad';
                            }
                            final quantity = int.tryParse(value);
                            if (quantity == null || quantity <= 0) {
                              return 'La cantidad debe ser mayor a 0';
                            }
                            if (_selectedInventoryItem != null && 
                                quantity > _selectedInventoryItem!.quantity) {
                              return 'No hay suficiente stock disponible';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Ubicación destino
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ubicación Origen',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        if (_selectedToLocationName != null) ...[
                          Text('Origen: $_selectedToLocationName'),
                          Text('Tipo: ${_selectedToLocationType == 'store' ? 'Tienda' : 'Almacén'}'),
                        ] else ...[
                          const Text('Selecciona de dónde quieres que te transfieran'),
                        ],
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _selectDestination,
                          icon: const Icon(Icons.location_on),
                          label: const Text('Seleccionar Origen'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Destino automático (ubicación del usuario)
                Card(
                  color: AppColors.primaryOrange.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: AppColors.primaryOrange,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Destino Automático',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryOrange,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Builder(
                          builder: (context) {
                            final authState = context.read<AuthBloc>().state;
                            if (authState is AuthAuthenticated) {
                              final user = authState.user;
                              return Text(
                                'Los productos se transferirán hacia tu ${user.assignedLocationType == 'store' ? 'tienda' : 'almacén'}: ${user.assignedLocationId}',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              );
                            }
                            return const Text('Cargando información del usuario...');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Notas
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notas (Opcional)',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _notesController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Motivo de la transferencia',
                            hintText: 'Ej: Necesidad urgente de stock...',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Botón de envío
                if (state is! TransferLoading)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Enviar Solicitud',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  )
                else
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _selectProduct() async {
    final result = await Navigator.push<InventoryItem>(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => di.sl<InventoryBloc>(),
            ),
            BlocProvider.value(
              value: context.read<AuthBloc>(),
            ),
          ],
          child: const ProductSelectorPage(),
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedInventoryItem = result;
      });
    }
  }

  void _selectDestination() async {
    if (_selectedInventoryItem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primero selecciona un producto'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => di.sl<InventoryBloc>(),
            ),
            BlocProvider.value(
              value: context.read<AuthBloc>(),
            ),
          ],
          child: DestinationSelectorPage(
            selectedProduct: _selectedInventoryItem!,
          ),
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedToLocationId = result['id'];
        _selectedToLocationName = result['name'];
        _selectedToLocationType = result['type'];
      });
    }
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedInventoryItem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un producto'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (_selectedToLocationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una ubicación destino'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final user = authState.user;
    final quantity = int.parse(_quantityController.text);

    // Para gerentes de tienda/almacén: solicitan que les transfieran HACIA su ubicación
    // fromLocationId = de dónde quieren que les transfieran (seleccionado)
    // toLocationId = su ubicación (automática)

    // Obtener el nombre real de la ubicación del usuario
    final userLocationName = _locationNameService.getLocationName(
      user.assignedLocationId,
      user.assignedLocationType,
    ) ?? 'Ubicación Desconocida';

    final transferRequest = TransferRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      productVariantId: _selectedInventoryItem!.productVariantId,
      productName: _selectedInventoryItem!.productName ?? 'Producto',
      variantName: _selectedInventoryItem!.variantName ?? 'Variante',
      fromLocationId: _selectedToLocationId!, // De dónde quieren que les transfieran
      fromLocationName: _selectedToLocationName!, // Nombre del origen
      fromLocationType: _selectedToLocationType!, // Tipo del origen
      toLocationId: user.assignedLocationId!, // Su ubicación (destino automático)
      toLocationName: userLocationName, // Nombre REAL de la ubicación del usuario
      toLocationType: user.assignedLocationType!, // Su tipo de ubicación
      quantity: quantity,
      requestedBy: user.id,
      requestedByName: user.name,
      requestedAt: DateTime.now(),
      status: TransferStatus.pending,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    context.read<TransferBloc>().add(CreateTransferRequest(transferRequest));
  }
}
