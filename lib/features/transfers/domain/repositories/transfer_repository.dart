import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/transfer_request.dart';

/// Repositorio para manejar transferencias
abstract class TransferRepository {
  /// Obtiene todas las transferencias
  Future<Either<Failure, List<TransferRequest>>> getAllTransfers();

  /// Observa todas las transferencias (Stream reactivo)
  Stream<List<TransferRequest>> watchAllTransfers();

  /// Obtiene transferencias por ubicación
  Future<Either<Failure, List<TransferRequest>>> getTransfersByLocation(
    String locationId,
    String locationType,
  );
  
  /// Obtiene transferencias pendientes por ubicación
  Future<Either<Failure, List<TransferRequest>>> getPendingTransfersByLocation(
    String locationId,
    String locationType,
  );
  
  /// Obtiene transferencias solicitadas por usuario
  Future<Either<Failure, List<TransferRequest>>> getTransfersByUser(String userId);
  
  /// Crea una nueva solicitud de transferencia
  Future<Either<Failure, TransferRequest>> createTransferRequest(
    TransferRequest request,
  );
  
  /// Aprueba una solicitud de transferencia
  Future<Either<Failure, TransferRequest>> approveTransferRequest(
    String transferId,
    String approvedBy,
    String approvedByName,
  );
  
  /// Rechaza una solicitud de transferencia
  Future<Either<Failure, TransferRequest>> rejectTransferRequest(
    String transferId,
    String rejectedBy,
    String rejectedByName,
    String rejectionReason,
  );
  
  /// Cancela una solicitud de transferencia
  Future<Either<Failure, TransferRequest>> cancelTransferRequest(
    String transferId,
    String cancelledBy,
  );
  
  /// Completa una transferencia (ejecuta el movimiento de inventario)
  Future<Either<Failure, TransferRequest>> completeTransferRequest(
    String transferId,
    String completedBy,
  );
  
  /// Busca transferencias por criterios
  Future<Either<Failure, List<TransferRequest>>> searchTransfers(String query);
  
  /// Crea una transferencia
  Future<Either<Failure, TransferRequest>> createTransfer(TransferRequest transfer);
  
  /// Actualiza una transferencia
  Future<Either<Failure, TransferRequest>> updateTransfer(TransferRequest transfer);
  
  /// Elimina una transferencia
  Future<Either<Failure, void>> deleteTransfer(String transferId);
  
  /// Obtiene una transferencia por ID
  Future<Either<Failure, TransferRequest?>> getTransferById(String transferId);

  /// Sincronizar transferencias desde Supabase a Isar (descarga)
  Future<Either<Failure, void>> syncFromRemote();
}

