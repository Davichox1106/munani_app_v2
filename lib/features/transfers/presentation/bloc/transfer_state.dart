import 'package:equatable/equatable.dart';
import '../../domain/entities/transfer_request.dart';

/// Estados del BLoC de transferencias
abstract class TransferState extends Equatable {
  const TransferState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class TransferInitial extends TransferState {
  const TransferInitial();
}

/// Cargando transferencias
class TransferLoading extends TransferState {
  const TransferLoading();
}

/// Transferencias cargadas exitosamente
class TransfersLoaded extends TransferState {
  final List<TransferRequest> transfers;

  const TransfersLoaded(this.transfers);

  @override
  List<Object?> get props => [transfers];
}

/// Transferencias pendientes cargadas
class PendingTransfersLoaded extends TransferState {
  final List<TransferRequest> transfers;

  const PendingTransfersLoaded(this.transfers);

  @override
  List<Object?> get props => [transfers];
}

/// Transferencias filtradas por búsqueda
class TransfersSearched extends TransferState {
  final List<TransferRequest> transfers;
  final String query;

  const TransfersSearched({
    required this.transfers,
    required this.query,
  });

  @override
  List<Object?> get props => [transfers, query];
}

/// Transferencia creada exitosamente
class TransferCreated extends TransferState {
  final TransferRequest transfer;

  const TransferCreated(this.transfer);

  @override
  List<Object?> get props => [transfer];
}

/// Transferencia aprobada exitosamente
class TransferApproved extends TransferState {
  final TransferRequest transfer;

  const TransferApproved(this.transfer);

  @override
  List<Object?> get props => [transfer];
}

/// Transferencia rechazada exitosamente
class TransferRejected extends TransferState {
  final TransferRequest transfer;

  const TransferRejected(this.transfer);

  @override
  List<Object?> get props => [transfer];
}

/// Transferencia cancelada exitosamente
class TransferCancelled extends TransferState {
  final TransferRequest transfer;

  const TransferCancelled(this.transfer);

  @override
  List<Object?> get props => [transfer];
}

/// Transferencia completada exitosamente
class TransferCompleted extends TransferState {
  final TransferRequest transfer;

  const TransferCompleted(this.transfer);

  @override
  List<Object?> get props => [transfer];
}

/// Estado de error
class TransferError extends TransferState {
  final String message;

  const TransferError(this.message);

  @override
  List<Object?> get props => [message];
}























