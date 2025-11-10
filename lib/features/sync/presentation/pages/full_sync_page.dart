import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/services/auto_sync_service.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/widgets/custom_button.dart';

/// Página para ejecutar sincronización completa desde Supabase a Isar
class FullSyncPage extends StatefulWidget {
  const FullSyncPage({super.key});

  @override
  State<FullSyncPage> createState() => _FullSyncPageState();
}

class _FullSyncPageState extends State<FullSyncPage> {
  bool _isLoading = false;
  Map<String, dynamic>? _syncResults;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sincronización Completa'),
        backgroundColor: AppColors.primaryOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Información
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sincronización Completa',
                      style: AppTextStyles.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Esta operación sincronizará todos los datos desde Supabase hacia la base de datos local (Isar).',
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Icon(Icons.sync, color: AppColors.primaryOrange),
                        SizedBox(width: 8),
                        Text('Productos'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Icon(Icons.store, color: AppColors.primaryOrange),
                        SizedBox(width: 8),
                        Text('Tiendas'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Icon(Icons.warehouse, color: AppColors.primaryOrange),
                        SizedBox(width: 8),
                        Text('Almacenes'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Icon(Icons.inventory, color: AppColors.primaryOrange),
                        SizedBox(width: 8),
                        Text('Inventarios'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Icon(Icons.transfer_within_a_station, color: AppColors.primaryOrange),
                        SizedBox(width: 8),
                        Text('Transferencias'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Icon(Icons.people, color: AppColors.primaryOrange),
                        SizedBox(width: 8),
                        Text('Usuarios'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Botón de sincronización
            CustomButton(
              onPressed: _isLoading ? null : _performFullSync,
              text: 'Iniciar Sincronización Completa',
              isLoading: _isLoading,
            ),

            const SizedBox(height: 24),

            // Resultados
            if (_syncResults != null) ...[
              Text(
                'Resultados de Sincronización',
                style: AppTextStyles.headlineSmall,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: _buildResultCards(),
                ),
              ),
            ],

            // Error
            if (_error != null) ...[
              Card(
                color: AppColors.error.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: AppColors.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildResultCards() {
    final results = _syncResults!['results'] as Map<String, dynamic>;
    final widgets = <Widget>[];

    results.forEach((module, result) {
      final isSuccess = result['success'] == true;
      widgets.add(
        Card(
          color: isSuccess 
              ? AppColors.success.withValues(alpha: 0.1)
              : AppColors.error.withValues(alpha: 0.1),
          child: ListTile(
            leading: Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: isSuccess ? AppColors.success : AppColors.error,
            ),
            title: Text(
              _getModuleName(module),
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              isSuccess 
                  ? result['message'] ?? 'Sincronizado correctamente'
                  : result['error'] ?? 'Error desconocido',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSuccess ? AppColors.success : AppColors.error,
              ),
            ),
          ),
        ),
      );
    });

    return widgets;
  }

  String _getModuleName(String module) {
    switch (module) {
      case 'products':
        return 'Productos';
      case 'variants':
        return 'Variantes de Productos';
      case 'stores':
        return 'Tiendas';
      case 'warehouses':
        return 'Almacenes';
      case 'inventory':
        return 'Inventarios';
      case 'transfers':
        return 'Transferencias';
      case 'users':
        return 'Usuarios';
      default:
        return module;
    }
  }

  Future<void> _performFullSync() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _syncResults = null;
    });

    try {
      // Usar AutoSyncService del contenedor de dependencias
      final autoSyncService = di.sl<AutoSyncService>();
      final results = await autoSyncService.forceSync();

      setState(() {
        _isLoading = false;
        _syncResults = results;
        if (!results['success']) {
          _error = results['error'];
        }
      });

      // Mostrar mensaje de resultado
      if (!mounted) return;
      if (results['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sincronización completada: ${results['successCount']}/${results['totalCount']} módulos',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error en sincronización: ${results['error']}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
