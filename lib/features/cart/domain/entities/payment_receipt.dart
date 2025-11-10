import 'package:equatable/equatable.dart';

class PaymentReceipt extends Equatable {
  final String id;
  final String storagePath;
  final String status;
  final String? notes;
  final String uploadedBy;
  final DateTime createdAt;
  final String? reviewedBy;
  final DateTime? reviewedAt;

  const PaymentReceipt({
    required this.id,
    required this.storagePath,
    required this.status,
    this.notes,
    required this.uploadedBy,
    required this.createdAt,
    this.reviewedBy,
    this.reviewedAt,
  });

  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isSubmitted => status == 'submitted';

  @override
  List<Object?> get props => [
        id,
        storagePath,
        status,
        notes,
        uploadedBy,
        createdAt,
        reviewedBy,
        reviewedAt,
      ];
}








