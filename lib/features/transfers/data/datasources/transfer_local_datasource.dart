import '../models/transfer_request_local_model.dart';

/// Datasource local para transferencias
abstract class TransferLocalDataSource {
  /// Obtiene todas las transferencias
  Future<List<TransferRequestLocalModel>> getAllTransfers();

  /// Observa todas las transferencias (Stream reactivo)
  Stream<List<TransferRequestLocalModel>> watchAllTransfers();

  /// Obtiene transferencias por ubicación
  Future<List<TransferRequestLocalModel>> getTransfersByLocation(
    String locationId,
    String locationType,
  );
  
  /// Obtiene transferencias pendientes por ubicación
  Future<List<TransferRequestLocalModel>> getPendingTransfersByLocation(
    String locationId,
    String locationType,
  );
  
  /// Obtiene transferencias por usuario
  Future<List<TransferRequestLocalModel>> getTransfersByUser(String userId);
  
  /// Crea una nueva transferencia
  Future<TransferRequestLocalModel> createTransfer(TransferRequestLocalModel transfer);
  
  /// Actualiza una transferencia
  Future<TransferRequestLocalModel> updateTransfer(TransferRequestLocalModel transfer);
  
  /// Elimina una transferencia
  Future<void> deleteTransfer(String transferId);
  
  /// Busca transferencias
  Future<List<TransferRequestLocalModel>> searchTransfers(String query);
  
  /// Obtiene una transferencia por ID
  Future<TransferRequestLocalModel?> getTransferById(String transferId);
}























