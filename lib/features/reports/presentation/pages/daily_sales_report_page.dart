import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/reports_bloc.dart';
import '../bloc/reports_event.dart';
import '../bloc/reports_state.dart';

class DailySalesReportPage extends StatefulWidget {
  const DailySalesReportPage({super.key});

  @override
  State<DailySalesReportPage> createState() => _DailySalesReportPageState();
}

class _DailySalesReportPageState extends State<DailySalesReportPage> {
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  void _loadReport() {
    context.read<ReportsBloc>().add(LoadDailySalesReport(date: selectedDate));
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _loadReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Venta Global del Día'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
          ),
        ],
      ),
      body: Column(
        children: [
          // Selector de fecha
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Fecha: ${dateFormat.format(selectedDate)}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadReport,
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
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (state is DailySalesReportLoaded) {
                  final report = state.report;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Resumen global
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text(
                                  'RESUMEN GLOBAL',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const Divider(),
                                _SummaryRow(
                                  label: 'Total Transacciones:',
                                  value: '${report.totalTransactions}',
                                ),
                                _SummaryRow(
                                  label: 'Subtotal:',
                                  value: currencyFormat.format(report.totalSales),
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

                        // Ventas por ubicación
                        Text(
                          'VENTAS POR UBICACIÓN',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),

                        ...report.byLocation.map((location) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ExpansionTile(
                              title: Text(location.locationName),
                              subtitle: Text(
                                location.locationType == 'store'
                                    ? 'Tienda'
                                    : 'Almacén',
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      _SummaryRow(
                                        label: 'Ventas:',
                                        value: '${location.salesCount}',
                                      ),
                                      _SummaryRow(
                                        label: 'Subtotal:',
                                        value: currencyFormat.format(location.subtotal),
                                      ),
                                      _SummaryRow(
                                        label: 'Impuestos:',
                                        value: currencyFormat.format(location.tax),
                                      ),
                                      const Divider(),
                                      _SummaryRow(
                                        label: 'Total:',
                                        value: currencyFormat.format(location.total),
                                        isTotal: true,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                }

                return const Center(
                  child: Text('Selecciona una fecha para ver el reporte'),
                );
              },
            ),
          ),
        ],
      ),
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


