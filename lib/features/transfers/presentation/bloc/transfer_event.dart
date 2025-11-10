import 'package:equatable/equatable.dart';
import '../../domain/entities/transfer_request.dart';

/// Eventos del BLoC de transferencias
abstract class TransferEvent extends Equatable {
  const TransferEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar todas las transferencias
class LoadAllTransfers extends TransferEvent {
  const LoadAllTransfers();
}

/// Cargar transferencias por ubicación
class LoadTransfersByLocation extends TransferEvent {
  final String locationId;
  final String locationType;

  const LoadTransfersByLocation({
    required this.locationId,
    required this.locationType,
  });

  @override
  List<Object?> get props => [locationId, locationType];
}

/// Cargar transferencias pendientes por ubicación
class LoadPendingTransfersByLocation extends TransferEvent {
  final String locationId;
  final String locationType;

  const LoadPendingTransfersByLocation({
    required this.locationId,
    required this.locationType,
  });

  @override
  List<Object?> get props => [locationId, locationType];
}

/// Cargar transferencias por usuario
class LoadTransfersByUser extends TransferEvent {
  final String userId;

  const LoadTransfersByUser(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Crear nueva solicitud de transferencia
class CreateTransferRequest extends TransferEvent {
  final TransferRequest request;

  const CreateTransferRequest(this.request);

  @override
  List<Object?> get props => [request];
}

/// Aprobar transferencia
class ApproveTransferRequest extends TransferEvent {
  final String transferId;
  final String approvedBy;
  final String approvedByName;

  const ApproveTransferRequest({
    required this.transferId,
    required this.approvedBy,
    required this.approvedByName,
  });

  @override
  List<Object?> get props => [transferId, approvedBy, approvedByName];
}

/// Rechazar transferencia
class RejectTransferRequest extends TransferEvent {
  final String transferId;
  final String rejectedBy;
  final String rejectedByName;
  final String rejectionReason;

  const RejectTransferRequest({
    required this.transferId,
    required this.rejectedBy,
    required this.rejectedByName,
    required this.rejectionReason,
  });

  @override
  List<Object?> get props => [transferId, rejectedBy, rejectedByName, rejectionReason];
}

/// Cancelar transferencia
class CancelTransferRequest extends TransferEvent {
  final String transferId;
  final String cancelledBy;

  const CancelTransferRequest({
    required this.transferId,
    required this.cancelledBy,
  });

  @override
  List<Object?> get props => [transferId, cancelledBy];
}

/// Completar transferencia
class CompleteTransferRequest extends TransferEvent {
  final String transferId;
  final String completedBy;

  const CompleteTransferRequest({
    required this.transferId,
    required this.completedBy,
  });

  @override
  List<Object?> get props => [transferId, completedBy];
}

/// Buscar transferencias
class SearchTransfers extends TransferEvent {
  final String query;

  const SearchTransfers(this.query);

  @override
  List<Object?> get props => [query];
}























