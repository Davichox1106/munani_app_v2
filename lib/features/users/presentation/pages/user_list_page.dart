import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/user.dart' as user_management;
import '../../domain/entities/enriched_user.dart';
import '../bloc/user_management_bloc.dart';
import '../bloc/user_management_event.dart';
import '../bloc/user_management_state.dart';
import 'user_form_page.dart';

/// Página de lista de usuarios
///
/// Solo accesible por Administradores
/// Muestra todos los usuarios del sistema con su rol y estado
class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  String _roleFilter = 'all'; // all, admin, store_manager, warehouse_manager, customer
  String _statusFilter = 'all'; // all, active, inactive

  @override
  void initState() {
    super.initState();
    // Cargar usuarios al iniciar
    context.read<UserManagementBloc>().add(LoadUsers());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Usuarios'),
        actions: [
          // Botón de depuración
          // Botón de recargar
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              context.read<UserManagementBloc>().add(LoadUsers());
            },
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros
          _buildFilters(),
          
          // Lista de usuarios
          Expanded(
            child: BlocConsumer<UserManagementBloc, UserManagementState>(
              buildWhen: (previous, current) {
                // Solo reconstruir cuando cambian los datos, no en operaciones
                return current is UserManagementLoading ||
                       current is EnrichedUsersLoaded ||
                       current is UserManagementError;
              },
              listener: (context, state) {
                if (state is UserCreated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } else if (state is UserUpdated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } else if (state is UserDeactivated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.warning,
                    ),
                  );
                } else if (state is UserManagementError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is UserManagementLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                if (state is EnrichedUsersLoaded) {
                  final filteredUsers = _filterEnrichedUsers(state.enrichedUsers);

                  if (filteredUsers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No hay usuarios',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final enrichedUser = filteredUsers[index];
                      return _UserCard(
                        enrichedUser: enrichedUser,
                        onEdit: () => _navigateToEdit(enrichedUser.user),
                        onDeactivate: () => _confirmDeactivate(enrichedUser.user),
                      );
                    },
                  );
                }

                if (state is UserManagementError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Error al cargar usuarios',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.error,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          state.message,
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            context.read<UserManagementBloc>().add(LoadUsers());
                          },
                          icon: Icon(Icons.refresh),
                          label: Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                return Center(child: Text('Estado desconocido'));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreate,
        icon: Icon(Icons.person_add),
        label: Text('Nuevo Usuario'),
        backgroundColor: AppColors.primaryOrange,
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtros:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _roleFilter,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Rol',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: [
                    DropdownMenuItem(value: 'all', child: Text('Todos')),
                    DropdownMenuItem(value: 'admin', child: Text('Admins')),
                    DropdownMenuItem(
                        value: 'store_manager', child: Text('Enc. Tienda')),
                    DropdownMenuItem(
                        value: 'warehouse_manager',
                        child: Text('Enc. Almacén')),
                    DropdownMenuItem(value: 'customer', child: Text('Clientes')),
                  ],
                  onChanged: (value) {
                    setState(() => _roleFilter = value!);
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _statusFilter,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Estado',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: [
                    DropdownMenuItem(value: 'all', child: Text('Todos')),
                    DropdownMenuItem(value: 'active', child: Text('Activos')),
                    DropdownMenuItem(value: 'inactive', child: Text('Inactivos')),
                  ],
                  onChanged: (value) {
                    setState(() => _statusFilter = value!);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  List<EnrichedUser> _filterEnrichedUsers(List<EnrichedUser> enrichedUsers) {
    return enrichedUsers.where((enrichedUser) {
      final user = enrichedUser.user;
      // Filtro de rol
      if (_roleFilter != 'all' && user.role != _roleFilter) {
        return false;
      }

      // Filtro de estado
      if (_statusFilter == 'active' && !user.isActive) {
        return false;
      }
      if (_statusFilter == 'inactive' && user.isActive) {
        return false;
      }

      return true;
    }).toList();
  }

  void _navigateToCreate() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserFormPage(
          userManagementBloc: context.read<UserManagementBloc>(),
        ),
      ),
    );
  }

  void _navigateToEdit(user_management.User user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserFormPage(
          user: user,
          userManagementBloc: context.read<UserManagementBloc>(),
        ),
      ),
    );
  }

  void _confirmDeactivate(user_management.User user) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Confirmar Desactivación'),
        content: Text(
          '¿Estás seguro de que deseas desactivar al usuario "${user.name}"?\n\n'
          'El usuario no podrá iniciar sesión.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context
                  .read<UserManagementBloc>()
                  .add(DeactivateUser(user.id));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text('Desactivar'),
          ),
        ],
      ),
    );
  }
}

/// Card de usuario
class _UserCard extends StatelessWidget {
  final EnrichedUser enrichedUser;
  final VoidCallback onEdit;
  final VoidCallback onDeactivate;

  const _UserCard({
    required this.enrichedUser,
    required this.onEdit,
    required this.onDeactivate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Nombre y estado
            Row(
              children: [
                // Ícono según rol
                _getRoleIcon(),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        enrichedUser.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        enrichedUser.email,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                // Badge de estado
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: enrichedUser.isActive
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    enrichedUser.isActive ? 'Activo' : 'Inactivo',
                    style: TextStyle(
                      color: enrichedUser.isActive ? AppColors.success : AppColors.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            // Rol
            Row(
              children: [
                Icon(Icons.badge, size: 16, color: AppColors.textSecondary),
                SizedBox(width: 4),
                Text(
                  _getRoleName(),
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),

            // Ubicación asignada (si aplica)
            if (enrichedUser.hasAssignedLocation) ...[
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    enrichedUser.assignedLocationType == 'store'
                        ? Icons.store
                        : Icons.warehouse,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      enrichedUser.assignedLocationName != null
                          ? '${enrichedUser.assignedLocationType == 'store' ? 'Tienda' : 'Almacén'}: ${enrichedUser.assignedLocationName}'
                          : '${enrichedUser.assignedLocationType == 'store' ? 'Tienda' : 'Almacén'} asignado',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ],

            SizedBox(height: 16),

            // Acciones
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: Icon(Icons.edit, size: 18),
                  label: Text('Editar'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.accentBlue,
                  ),
                ),
                if (enrichedUser.isActive) ...[
                  SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: onDeactivate,
                    icon: Icon(Icons.block, size: 18),
                    label: Text('Desactivar'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _getRoleIcon() {
    IconData icon;
    Color color;

    switch (enrichedUser.role) {
      case 'admin':
        icon = Icons.admin_panel_settings;
        color = AppColors.error;
        break;
      case 'store_manager':
        icon = Icons.store;
        color = AppColors.accentBlue;
        break;
      case 'warehouse_manager':
        icon = Icons.warehouse;
        color = AppColors.accentGreen;
        break;
      case 'customer':
        icon = Icons.person;
        color = AppColors.accentGrey;
        break;
      default:
        icon = Icons.person_outline;
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  String _getRoleName() {
    switch (enrichedUser.role) {
      case 'admin':
        return 'Administrador';
      case 'store_manager':
        return 'Encargado de Tienda';
      case 'warehouse_manager':
        return 'Encargado de Almacén';
      case 'customer':
        return 'Cliente';
      default:
        return enrichedUser.role;
    }
  }
}

