import '../models/transfer_request_local_model.dart';

/// Contrato para el datasource remoto de transferencias
abstract class TransferRemoteDataSource {
  /// Obtiene todas las transferencias desde el servidor
  Future<List<TransferRequestLocalModel>> getAllTransfers();

  /// Obtiene transferencias por ubicación desde el servidor
  Future<List<TransferRequestLocalModel>> getTransfersByLocation(
    String locationId,
    String locationType,
  );

  /// Obtiene transferencias pendientes por ubicación desde el servidor
  Future<List<TransferRequestLocalModel>> getPendingTransfersByLocation(
    String locationId,
    String locationType,
  );

  /// Obtiene transferencias por usuario desde el servidor
  Future<List<TransferRequestLocalModel>> getTransfersByUser(String userId);

  /// Crea una transferencia en el servidor
  Future<TransferRequestLocalModel> createTransfer(TransferRequestLocalModel transfer);

  /// Actualiza una transferencia en el servidor
  Future<TransferRequestLocalModel> updateTransfer(TransferRequestLocalModel transfer);

  /// Elimina una transferencia del servidor
  Future<void> deleteTransfer(String transferId);

  /// Busca transferencias en el servidor
  Future<List<TransferRequestLocalModel>> searchTransfers(String query);

  /// Obtiene una transferencia por ID desde el servidor
  Future<TransferRequestLocalModel?> getTransferById(String transferId);
}






















