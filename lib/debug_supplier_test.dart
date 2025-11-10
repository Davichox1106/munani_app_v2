import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection_container.dart';
import 'core/utils/app_logger.dart';
import 'features/purchases/presentation/bloc/supplier_bloc.dart';
import 'features/purchases/presentation/bloc/supplier_event.dart';
import 'features/purchases/presentation/bloc/supplier_state.dart';

/// Widget de prueba para debuggear el SupplierBloc
class DebugSupplierTest extends StatefulWidget {
  const DebugSupplierTest({super.key});

  @override
  State<DebugSupplierTest> createState() => _DebugSupplierTestState();
}

class _DebugSupplierTestState extends State<DebugSupplierTest> {
  late final SupplierBloc _supplierBloc;

  @override
  void initState() {
    super.initState();
    AppLogger.debug('🧪 DebugSupplierTest - Inicializando...');

    try {
      _supplierBloc = sl<SupplierBloc>();
      AppLogger.debug('✅ DebugSupplierTest - SupplierBloc creado');

      _supplierBloc.add(const LoadSuppliers());
      AppLogger.debug('✅ DebugSupplierTest - Evento LoadSuppliers enviado');
    } catch (e, stackTrace) {
      AppLogger.error('❌ DebugSupplierTest - Error: $e');
      AppLogger.error('❌ DebugSupplierTest - Stack trace: $stackTrace');
    }
  }

  @override
  void dispose() {
    _supplierBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Supplier Test'),
      ),
      body: BlocProvider.value(
        value: _supplierBloc,
        child: BlocBuilder<SupplierBloc, SupplierState>(
          builder: (context, state) {
            AppLogger.debug('🔍 DebugSupplierTest - Estado: ${state.runtimeType}');
            
            if (state is SupplierLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Cargando proveedores...'),
                  ],
                ),
              );
            }
            
            if (state is SupplierError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 64),
                    const SizedBox(height: 16),
                    Text('Error: ${state.message}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _supplierBloc.add(const LoadSuppliers());
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }
            
            if (state is SupplierLoaded) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 64),
                    const SizedBox(height: 16),
                    Text('Proveedores cargados: ${state.suppliers.length}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _supplierBloc.add(const CreateTestSupplier());
                      },
                      child: const Text('Crear Proveedor de Prueba'),
                    ),
                  ],
                ),
              );
            }
            
            return const Center(
              child: Text('Estado desconocido'),
            );
          },
        ),
      ),
    );
  }
}



















