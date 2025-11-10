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

class SalesReportPage extends StatefulWidget {
  const SalesReportPage({super.key});

  @override
  State<SalesReportPage> createState() => _SalesReportPageState();
}

class _SalesReportPageState extends State<SalesReportPage> {
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
          selectedLocationId = user.assignedLocationId;
        });
        _loadReport(); // Cargar reporte automáticamente
        return;
      }

      // Si es admin, cargar todas las ubicaciones
      final storesResult = await locationRepository.getAllStores();
      final warehousesResult = await locationRepository.getAllWarehouses();

      final List<Map<String, dynamic>> locations = [];

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
    if (selectedLocationId != null) {
      context.read<ReportsBloc>().add(LoadSalesReport(
            locationId: selectedLocationId!,
            startDate: startDate,
            endDate: endDate,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final isAdmin = authState is AuthAuthenticated && authState.user.role == 'admin';

        return Scaffold(
          appBar: AppBar(
            title: const Text('Reporte de Ventas'),
          ),
          body: Column(
            children: [
              // Filtros
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                child: Column(
                  children: [
                    // Selector de ubicación
                    _isLoadingLocations
                        ? const Center(child: CircularProgressIndicator())
                        : DropdownButtonFormField<String>(
                            initialValue: selectedLocationId,
                            decoration: InputDecoration(
                              labelText: 'Ubicación',
                              prefixIcon: const Icon(Icons.store),
                              border: const OutlineInputBorder(),
                              helperText: isAdmin ? null : 'Mostrando solo tu ubicación asignada',
                            ),
                            hint: const Text('Selecciona una ubicación'),
                            items: _availableLocations.map((location) {
                              return DropdownMenuItem<String>(
                                value: location['id'] as String,
                                child: Row(
                                  children: [
                                    Icon(
                                      location['type'] == 'store'
                                          ? Icons.store
                                          : Icons.warehouse,
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
                        Icon(Icons.error_outline, size: 48, color: Colors.red),
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

                if (state is SalesReportLoaded) {
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
                                  'RESUMEN DE VENTAS',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const Divider(),
                                _SummaryRow(
                                  label: 'Ubicación:',
                                  value: report.locationName,
                                ),
                                _SummaryRow(
                                  label: 'Tipo:',
                                  value: report.locationType == 'store'
                                      ? 'Tienda'
                                      : 'Almacén',
                                ),
                                _SummaryRow(
                                  label: 'Período:',
                                  value:
                                      '${dateFormat.format(report.startDate)} - ${dateFormat.format(report.endDate)}',
                                ),
                                _SummaryRow(
                                  label: 'Total Ventas:',
                                  value: '${report.totalSales}',
                                ),
                                _SummaryRow(
                                  label: 'Subtotal:',
                                  value: currencyFormat.format(report.totalAmount),
                                ),
                                _SummaryRow(
                                  label: 'Impuestos:',
                                  value: currencyFormat.format(report.totalTax),
                                ),
                                const Divider(),
                                _SummaryRow(
                                  label: 'TOTAL:',
                                  value: currencyFormat.format(report.grandTotal),
                                  isTotal: true,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Lista de ventas
                        Text(
                          'DETALLE DE VENTAS',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),

                        ...report.items.map((item) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text('Venta #${item.saleNumber}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(dateFormat.format(item.saleDate)),
                                  if (item.customerName != null)
                                    Text('Cliente: ${item.customerName}'),
                                  Text('Estado: ${item.status}'),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    currencyFormat.format(item.total),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                  ),
                                  Text(
                                    'Imp: ${currencyFormat.format(item.tax)}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              isThreeLine: true,
                            ),
                          );
                        }),

                        if (report.items.isEmpty)
                          const Card(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: Text('No hay ventas en el período seleccionado'),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }

                return const Center(
                  child: Text('Selecciona una ubicación y genera el reporte'),
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
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    )
                : null,
          ),
          Text(
            value,
            style: isTotal
                ? Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    )
                : Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}


