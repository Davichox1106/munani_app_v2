import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../locations/domain/repositories/location_repository.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/reports_bloc.dart';
import '../bloc/reports_event.dart';
import '../bloc/reports_state.dart';

class TransfersReportPage extends StatefulWidget {
  const TransfersReportPage({super.key});

  @override
  State<TransfersReportPage> createState() => _TransfersReportPageState();
}

class _TransfersReportPageState extends State<TransfersReportPage> {
  DateTime startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime endDate = DateTime.now();
  String? selectedLocationId;
  List<Map<String, dynamic>> _availableLocations = [];
  bool _isLoadingLocations = false;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    setState(() => _isLoadingLocations = true);

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) return;

      final user = authState.user;
      final isAdmin = user.role == 'admin';

      final locationRepository = di.sl<LocationRepository>();

      // Si es manager, solo mostrar su ubicación asignada
      if (!isAdmin && user.hasAssignedLocation) {
        setState(() {
          _availableLocations = [{
            'id': user.assignedLocationId!,
            'name': user.assignedLocationName ?? 'Mi Ubicación',
            'type': user.assignedLocationType!,
          }];
          selectedLocationId = user.assignedLocationId; // Auto-seleccionar
        });
        _loadReport(); // Cargar reporte automáticamente
        return;
      }

      // Si es admin, cargar todas las ubicaciones + opción "Todas"
      final storesResult = await locationRepository.getAllStores();
      final warehousesResult = await locationRepository.getAllWarehouses();

      final List<Map<String, dynamic>> locations = [
        {'id': null, 'name': 'Todas las ubicaciones', 'type': 'all'},
      ];

      storesResult.fold(
        (failure) => debugPrint('Error cargando tiendas: ${failure.message}'),
        (stores) {
          locations.addAll(stores.map((store) => {
            'id': store.id,
            'name': store.name,
            'type': 'store',
          }));
        },
      );

      warehousesResult.fold(
        (failure) => debugPrint('Error cargando almacenes: ${failure.message}'),
        (warehouses) {
          locations.addAll(warehouses.map((warehouse) => {
            'id': warehouse.id,
            'name': warehouse.name,
            'type': 'warehouse',
          }));
        },
      );

      setState(() => _availableLocations = locations);
    } catch (e) {
      debugPrint('Error cargando ubicaciones: $e');
    } finally {
      setState(() => _isLoadingLocations = false);
    }
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(2020),
      lastDate: endDate,
    );
    if (picked != null) {
      setState(() => startDate = picked);
      _loadReport();
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate,
      firstDate: startDate,
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => endDate = picked);
      _loadReport();
    }
  }

  void _loadReport() {
    context.read<ReportsBloc>().add(LoadTransfersReport(
          startDate: startDate,
          endDate: endDate,
          locationId: selectedLocationId,
        ));
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pendiente';
      case 'approved':
        return 'Aprobada';
      case 'completed':
        return 'Completada';
      case 'rejected':
        return 'Rechazada';
      case 'cancelled':
        return 'Cancelada';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final isAdmin = authState is AuthAuthenticated && authState.user.role == 'admin';

        return Scaffold(
          appBar: AppBar(
            title: const Text('Reporte de Transferencias'),
          ),
          body: Column(
            children: [
              // Filtros
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            child: Column(
              children: [
                // Selector de ubicación (opcional para admin, fijo para managers)
                _isLoadingLocations
                    ? const Center(child: CircularProgressIndicator())
                    : DropdownButtonFormField<String?>(
                        initialValue: selectedLocationId,
                        decoration: InputDecoration(
                          labelText: isAdmin ? 'Ubicación (Opcional)' : 'Ubicación',
                          prefixIcon: const Icon(Icons.store),
                          border: const OutlineInputBorder(),
                          helperText: isAdmin
                            ? 'Deja vacío para ver todas'
                            : 'Mostrando solo transferencias de tu ubicación',
                        ),
                        hint: const Text('Todas las ubicaciones'),
                        items: _availableLocations.map((location) {
                          return DropdownMenuItem<String?>(
                            value: location['id'] as String?,
                            child: Row(
                              children: [
                                Icon(
                                  location['type'] == 'all'
                                      ? Icons.all_inclusive
                                      : (location['type'] == 'store'
                                          ? Icons.store
                                          : Icons.warehouse),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(location['name'] as String),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: isAdmin ? (value) {
                          setState(() => selectedLocationId = value);
                          _loadReport();
                        } : null, // Deshabilitar para managers
                      ),
                const SizedBox(height: 16),

                // Rango de fechas
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _selectStartDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Fecha Inicio',
                            prefixIcon: Icon(Icons.calendar_today),
                            border: OutlineInputBorder(),
                          ),
                          child: Text(dateFormat.format(startDate)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: _selectEndDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Fecha Fin',
                            prefixIcon: Icon(Icons.calendar_today),
                            border: OutlineInputBorder(),
                          ),
                          child: Text(dateFormat.format(endDate)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _loadReport,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Generar Reporte'),
                ),
              ],
            ),
          ),

          // Reporte
          Expanded(
            child: BlocBuilder<ReportsBloc, ReportsState>(
              builder: (context, state) {
                if (state is ReportsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ReportsError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (state is TransfersReportLoaded) {
                  final report = state.report;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Resumen
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text(
                                  'RESUMEN DE TRANSFERENCIAS',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const Divider(),
                                _SummaryRow(
                                  label: 'Período:',
                                  value:
                                      '${dateFormat.format(report.startDate)} - ${dateFormat.format(report.endDate)}',
                                ),
                                _SummaryRow(
                                  label: 'Total Transferencias:',
                                  value: '${report.totalTransfers}',
                                ),
                                const Divider(),
                                _StatusCountRow(
                                  label: 'Pendientes:',
                                  value: '${report.pendingCount}',
                                  color: Colors.orange,
                                ),
                                _StatusCountRow(
                                  label: 'Aprobadas:',
                                  value: '${report.approvedCount}',
                                  color: Colors.blue,
                                ),
                                _StatusCountRow(
                                  label: 'Completadas:',
                                  value: '${report.completedCount}',
                                  color: Colors.green,
                                ),
                                _StatusCountRow(
                                  label: 'Rechazadas:',
                                  value: '${report.rejectedCount}',
                                  color: Colors.red,
                                ),
                                _StatusCountRow(
                                  label: 'Canceladas:',
                                  value: '${report.cancelledCount}',
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Lista de transferencias
                        Text(
                          'DETALLE DE TRANSFERENCIAS',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),

                        ...report.items.map((item) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ExpansionTile(
                              title: Text(item.productName),
                              subtitle: Text(
                                '${dateFormat.format(item.requestDate)} - Cantidad: ${item.quantity}',
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(item.status)
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.swap_horiz,
                                  color: _getStatusColor(item.status),
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _DetailRow(
                                        label: 'Variante:',
                                        value: item.variantName,
                                      ),
                                      _DetailRow(
                                        label: 'Desde:',
                                        value:
                                            '${item.fromLocationName} (${item.fromLocationType == 'store' ? 'Tienda' : 'Almacén'})',
                                      ),
                                      _DetailRow(
                                        label: 'Hacia:',
                                        value:
                                            '${item.toLocationName} (${item.toLocationType == 'store' ? 'Tienda' : 'Almacén'})',
                                      ),
                                      _DetailRow(
                                        label: 'Estado:',
                                        value: _getStatusText(item.status),
                                        valueColor: _getStatusColor(item.status),
                                      ),
                                      _DetailRow(
                                        label: 'Solicitado por:',
                                        value: item.requestedBy,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        if (report.items.isEmpty)
                          const Card(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: Text(
                                    'No hay transferencias en el período seleccionado'),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }

                return const Center(
                  child: Text('Selecciona un período y genera el reporte'),
                );
              },
            ),
          ),
        ],
      ),
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _StatusCountRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatusCountRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(label),
            ],
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: valueColor,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}




