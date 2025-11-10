import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = state.user;
        final isAdmin = user.role == 'admin';
        final isStoreManager = user.role == 'store_manager';

        // Construir lista de reportes según el rol
        final List<Widget> reportCards = [];

        // 1. Ventas (todos pueden ver)
        reportCards.add(_ReportCard(
          title: isAdmin
            ? 'Ventas por Ubicación'
            : (isStoreManager ? 'Ventas de Mi Tienda' : 'Ventas de Mi Almacén'),
          icon: Icons.point_of_sale,
          color: Colors.green,
          onTap: () => Navigator.pushNamed(context, AppRoutes.salesReport),
        ));

        // 2. Compras (todos pueden ver)
        reportCards.add(_ReportCard(
          title: isAdmin
            ? 'Compras por Ubicación'
            : (isStoreManager ? 'Compras de Mi Tienda' : 'Compras de Mi Almacén'),
          icon: Icons.shopping_cart,
          color: Colors.blue,
          onTap: () => Navigator.pushNamed(context, AppRoutes.purchasesReport),
        ));

        // 3. Transferencias (todos pueden ver)
        reportCards.add(_ReportCard(
          title: isAdmin ? 'Transferencias Globales' : 'Mis Transferencias',
          icon: Icons.swap_horiz,
          color: Colors.orange,
          onTap: () => Navigator.pushNamed(context, AppRoutes.transfersReport),
        ));

        // 4. Venta del Día (SOLO ADMIN)
        if (isAdmin) {
          reportCards.add(_ReportCard(
            title: 'Venta Global del Día',
            icon: Icons.today,
            color: Colors.purple,
            onTap: () => Navigator.pushNamed(context, AppRoutes.dailySalesReport),
          ));
        }

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Reportes'),
                Text(
                  _getRoleLabel(user.role),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          body: GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.all(16),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: reportCards,
          ),
        );
      },
    );
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'admin':
        return 'Administrador - Acceso Total';
      case 'store_manager':
        return 'Gerente de Tienda';
      case 'warehouse_manager':
        return 'Gerente de Almacén';
      default:
        return role;
    }
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ReportCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

