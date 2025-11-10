import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/transfer_repository.dart';
import 'transfer_event.dart';
import 'transfer_state.dart';

/// BLoC para manejar transferencias
class TransferBloc extends Bloc<TransferEvent, TransferState> {
  final TransferRepository repository;

  TransferBloc({required this.repository}) : super(const TransferInitial()) {
    on<LoadAllTransfers>(_onLoadAllTransfers);
    on<LoadTransfersByLocation>(_onLoadTransfersByLocation);
    on<LoadPendingTransfersByLocation>(_onLoadPendingTransfersByLocation);
    on<LoadTransfersByUser>(_onLoadTransfersByUser);
    on<CreateTransferRequest>(_onCreateTransferRequest);
    on<ApproveTransferRequest>(_onApproveTransferRequest);
    on<RejectTransferRequest>(_onRejectTransferRequest);
    on<CancelTransferRequest>(_onCancelTransferRequest);
    on<CompleteTransferRequest>(_onCompleteTransferRequest);
    on<SearchTransfers>(_onSearchTransfers);
  }

  Future<void> _onLoadAllTransfers(
    LoadAllTransfers event,
    Emitter<TransferState> emit,
  ) async {
    emit(const TransferLoading());

    await emit.forEach(
      repository.watchAllTransfers(),
      onData: (transfers) => TransfersLoaded(transfers),
      onError: (error, stackTrace) => TransferError(error.toString()),
    );
  }

  Future<void> _onLoadTransfersByLocation(
    LoadTransfersByLocation event,
    Emitter<TransferState> emit,
  ) async {
    emit(const TransferLoading());
    final result = await repository.getTransfersByLocation(
      event.locationId,
      event.locationType,
    );
    result.fold(
      (failure) => emit(TransferError(failure.message)),
      (transfers) => emit(TransfersLoaded(transfers)),
    );
  }

  Future<void> _onLoadPendingTransfersByLocation(
    LoadPendingTransfersByLocation event,
    Emitter<TransferState> emit,
  ) async {
    emit(const TransferLoading());
    final result = await repository.getPendingTransfersByLocation(
      event.locationId,
      event.locationType,
    );
    result.fold(
      (failure) => emit(TransferError(failure.message)),
      (transfers) => emit(PendingTransfersLoaded(transfers)),
    );
  }

  Future<void> _onLoadTransfersByUser(
    LoadTransfersByUser event,
    Emitter<TransferState> emit,
  ) async {
    emit(const TransferLoading());
    final result = await repository.getTransfersByUser(event.userId);
    result.fold(
      (failure) => emit(TransferError(failure.message)),
      (transfers) => emit(TransfersLoaded(transfers)),
    );
  }

  Future<void> _onCreateTransferRequest(
    CreateTransferRequest event,
    Emitter<TransferState> emit,
  ) async {
    emit(const TransferLoading());
    final result = await repository.createTransferRequest(event.request);
    result.fold(
      (failure) => emit(TransferError(failure.message)),
      (transfer) => emit(TransferCreated(transfer)),
    );
  }

  Future<void> _onApproveTransferRequest(
    ApproveTransferRequest event,
    Emitter<TransferState> emit,
  ) async {
    emit(const TransferLoading());
    final result = await repository.approveTransferRequest(
      event.transferId,
      event.approvedBy,
      event.approvedByName,
    );
    result.fold(
      (failure) => emit(TransferError(failure.message)),
      (transfer) => emit(TransferApproved(transfer)),
    );
  }

  Future<void> _onRejectTransferRequest(
    RejectTransferRequest event,
    Emitter<TransferState> emit,
  ) async {
    emit(const TransferLoading());
    final result = await repository.rejectTransferRequest(
      event.transferId,
      event.rejectedBy,
      event.rejectedByName,
      event.rejectionReason,
    );
    result.fold(
      (failure) => emit(TransferError(failure.message)),
      (transfer) => emit(TransferRejected(transfer)),
    );
  }

  Future<void> _onCancelTransferRequest(
    CancelTransferRequest event,
    Emitter<TransferState> emit,
  ) async {
    emit(const TransferLoading());
    final result = await repository.cancelTransferRequest(
      event.transferId,
      event.cancelledBy,
    );
    result.fold(
      (failure) => emit(TransferError(failure.message)),
      (transfer) => emit(TransferCancelled(transfer)),
    );
  }

  Future<void> _onCompleteTransferRequest(
    CompleteTransferRequest event,
    Emitter<TransferState> emit,
  ) async {
    emit(const TransferLoading());
    final result = await repository.completeTransferRequest(
      event.transferId,
      event.completedBy,
    );
    result.fold(
      (failure) => emit(TransferError(failure.message)),
      (transfer) => emit(TransferCompleted(transfer)),
    );
  }

  Future<void> _onSearchTransfers(
    SearchTransfers event,
    Emitter<TransferState> emit,
  ) async {
    emit(const TransferLoading());
    final result = await repository.searchTransfers(event.query);
    result.fold(
      (failure) => emit(TransferError(failure.message)),
      (transfers) => emit(TransfersSearched(
        transfers: transfers,
        query: event.query,
      )),
    );
  }

}























