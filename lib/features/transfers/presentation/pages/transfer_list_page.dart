import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/permissions/permission_helper.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/transfer_request.dart';
import '../bloc/transfer_bloc.dart';
import '../bloc/transfer_event.dart';
import '../bloc/transfer_state.dart';
import 'transfer_form_page.dart';

/// Página de lista de transferencias
class TransferListPage extends StatefulWidget {
  const TransferListPage({super.key});

  @override
  State<TransferListPage> createState() => _TransferListPageState();
}

class _TransferListPageState extends State<TransferListPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;
  String _selectedFilter = 'all'; // 'all', 'pending', 'sent', 'received'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      _onFilterSelected(_selectedFilter);
    } else {
      context.read<TransferBloc>().add(SearchTransfers(query));
    }
  }

  void _onFilterSelected(String filter) {
    setState(() {
      _selectedFilter = filter;
    });

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final user = authState.user;

    if (user.isAdmin) {
      // Administradores ven todas las transferencias
      context.read<TransferBloc>().add(const LoadAllTransfers());
    } else if (user.hasAssignedLocation) {
      // Gerentes ven transferencias de su ubicación
      switch (filter) {
        case 'all':
          context.read<TransferBloc>().add(LoadTransfersByLocation(
            locationId: user.assignedLocationId!,
            locationType: user.assignedLocationType!,
          ));
          break;
        case 'pending':
          context.read<TransferBloc>().add(LoadPendingTransfersByLocation(
            locationId: user.assignedLocationId!,
            locationType: user.assignedLocationType!,
          ));
          break;
        case 'sent':
          context.read<TransferBloc>().add(LoadTransfersByUser(user.id));
          break;
        case 'received':
          context.read<TransferBloc>().add(LoadTransfersByLocation(
            locationId: user.assignedLocationId!,
            locationType: user.assignedLocationType!,
          ));
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transferencias'),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                  _onFilterSelected(_selectedFilter);
                }
              });
            },
          ),
        ],
      ),
      floatingActionButton: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthAuthenticated) {
            final user = authState.user;
            if (PermissionHelper.canRequestTransfers(user)) {
              return FloatingActionButton.extended(
                onPressed: () => _navigateToCreate(context),
                icon: const Icon(Icons.add),
                label: const Text('Nueva Solicitud'),
                backgroundColor: AppColors.primaryOrange,
              );
            }
          }
          return const SizedBox.shrink();
        },
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          if (_showSearch)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Buscar por producto, ubicación, usuario...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _onFilterSelected(_selectedFilter);
                          },
                        )
                      : null,
                ),
                onChanged: _onSearchChanged,
              ),
            ),

          // Filtros
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('all', 'Todas'),
                const SizedBox(width: 8),
                _buildFilterChip('pending', 'Pendientes'),
                const SizedBox(width: 8),
                _buildFilterChip('sent', 'Enviadas'),
                const SizedBox(width: 8),
                _buildFilterChip('received', 'Recibidas'),
              ],
            ),
          ),

          // Lista de transferencias
          Expanded(
            child: BlocConsumer<TransferBloc, TransferState>(
              buildWhen: (previous, current) {
                // Solo reconstruir cuando cambian los datos, no en operaciones
                return current is TransferLoading ||
                       current is TransfersLoaded ||
                       current is PendingTransfersLoaded ||
                       current is TransfersSearched ||
                       current is TransferError;
              },
              listener: (context, state) {
                if (state is TransferCreated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Solicitud de transferencia creada'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  // Stream reactivo se encarga de actualizar la lista automáticamente
                } else if (state is TransferApproved) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transferencia aprobada'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  // Stream reactivo se encarga de actualizar la lista automáticamente
                } else if (state is TransferRejected) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transferencia rechazada'),
                      backgroundColor: AppColors.warning,
                    ),
                  );
                  // Stream reactivo se encarga de actualizar la lista automáticamente
                } else if (state is TransferCancelled) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transferencia cancelada'),
                      backgroundColor: AppColors.warning,
                    ),
                  );
                  // Stream reactivo se encarga de actualizar la lista automáticamente
                } else if (state is TransferCompleted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transferencia completada'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  // Stream reactivo se encarga de actualizar la lista automáticamente
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
                if (state is TransferLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is TransfersLoaded) {
                  return _buildTransfersList(state.transfers);
                } else if (state is PendingTransfersLoaded) {
                  return _buildTransfersList(state.transfers);
                } else if (state is TransfersSearched) {
                  return _buildTransfersList(state.transfers);
                } else if (state is TransferError) {
                  return _buildErrorState(state.message);
                } else {
                  return _buildEmptyState();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filter, String label) {
    final isSelected = _selectedFilter == filter;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          _onFilterSelected(filter);
        }
      },
      selectedColor: AppColors.primaryOrange.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primaryOrange,
    );
  }

  Widget _buildTransfersList(List<TransferRequest> transfers) {
    if (transfers.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transfers.length,
      itemBuilder: (context, index) {
        final transfer = transfers[index];
        return _TransferCard(
          transfer: transfer,
          onApprove: () => _approveTransfer(context, transfer),
          onReject: () => _rejectTransfer(context, transfer),
          onCancel: () => _cancelTransfer(context, transfer),
          onComplete: () => _completeTransfer(context, transfer),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.swap_horiz,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay transferencias',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Las solicitudes de transferencia aparecerán aquí',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Error al cargar transferencias',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.red.shade600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.red.shade500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _navigateToCreate(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<TransferBloc>(),
          child: const TransferFormPage(),
        ),
      ),
    );
  }

  void _approveTransfer(BuildContext context, TransferRequest transfer) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<TransferBloc>().add(ApproveTransferRequest(
        transferId: transfer.id,
        approvedBy: authState.user.id,
        approvedByName: authState.user.name,
      ));
    }
  }

  void _rejectTransfer(BuildContext context, TransferRequest transfer) {
    // Mostrar confirmación antes de rechazar
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rechazar Transferencia'),
        content: const Text('¿Estás seguro de que deseas rechazar esta transferencia?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              final authState = context.read<AuthBloc>().state;
              if (authState is AuthAuthenticated) {
                context.read<TransferBloc>().add(RejectTransferRequest(
                  transferId: transfer.id,
                  rejectedBy: authState.user.id,
                  rejectedByName: authState.user.name,
                  rejectionReason: 'Rechazado por el usuario',
                ));
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
  }


  void _cancelTransfer(BuildContext context, TransferRequest transfer) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<TransferBloc>().add(CancelTransferRequest(
        transferId: transfer.id,
        cancelledBy: authState.user.id,
      ));
    }
  }

  void _completeTransfer(BuildContext context, TransferRequest transfer) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<TransferBloc>().add(CompleteTransferRequest(
        transferId: transfer.id,
        completedBy: authState.user.id,
      ));
    }
  }
}

class _TransferCard extends StatelessWidget {
  final TransferRequest transfer;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onCancel;
  final VoidCallback onComplete;

  const _TransferCard({
    required this.transfer,
    required this.onApprove,
    required this.onReject,
    required this.onCancel,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        bool canApprove = false;
        bool canReject = false;
        bool canCancel = false;
        bool canComplete = false;

        if (authState is AuthAuthenticated) {
          final user = authState.user;
          canApprove = PermissionHelper.canApproveSpecificTransfer(
            user, 
            transfer.toLocationId, 
            transfer.toLocationType
          ) && transfer.isPending;
          canReject = PermissionHelper.canApproveSpecificTransfer(
            user, 
            transfer.toLocationId, 
            transfer.toLocationType
          ) && transfer.isPending;
          canCancel = transfer.requestedBy == user.id && 
                      (transfer.isPending || transfer.isApproved);
          canComplete = PermissionHelper.canApproveSpecificTransfer(
            user, 
            transfer.toLocationId, 
            transfer.toLocationType
          ) && transfer.isApproved;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con estado
                Row(
                  children: [
                    _buildStatusChip(transfer.status),
                    const Spacer(),
                    Text(
                      transfer.requestedAt.toString().substring(0, 10),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Información del producto
                Text(
                  '${transfer.productName} - ${transfer.variantName}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cantidad: ${transfer.quantity}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),

                // Información de ubicaciones
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.red.shade400),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'De: ${transfer.fromLocationName}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.green.shade400),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'A: ${transfer.toLocationName}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Información del solicitante
                Text(
                  'Solicitado por: ${transfer.requestedByName}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),

                // Botones de acción
                if (canApprove || canReject || canCancel || canComplete) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (canApprove)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onApprove,
                            icon: const Icon(Icons.check, size: 16),
                            label: const Text('Aprobar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      if (canApprove && canReject) const SizedBox(width: 8),
                      if (canReject)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onReject,
                            icon: const Icon(Icons.close, size: 16),
                            label: const Text('Rechazar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      if (canCancel) ...[
                        if (canApprove || canReject) const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onCancel,
                            icon: const Icon(Icons.cancel, size: 16),
                            label: const Text('Cancelar'),
                          ),
                        ),
                      ],
                      if (canComplete) ...[
                        if (canApprove || canReject || canCancel) const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onComplete,
                            icon: const Icon(Icons.done_all, size: 16),
                            label: const Text('Completar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.info,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(TransferStatus status) {
    Color color;
    switch (status) {
      case TransferStatus.pending:
        color = AppColors.warning;
        break;
      case TransferStatus.approved:
        color = AppColors.info;
        break;
      case TransferStatus.rejected:
        color = AppColors.error;
        break;
      case TransferStatus.completed:
        color = AppColors.success;
        break;
      case TransferStatus.cancelled:
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status == TransferStatus.pending ? 'Pendiente' :
        status == TransferStatus.approved ? 'Aprobada' :
        status == TransferStatus.rejected ? 'Rechazada' :
        status == TransferStatus.completed ? 'Completada' : 'Cancelada',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}


