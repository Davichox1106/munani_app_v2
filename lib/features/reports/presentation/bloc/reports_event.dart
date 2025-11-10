import 'package:equatable/equatable.dart';

abstract class ReportsEvent extends Equatable {
  const ReportsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSalesReport extends ReportsEvent {
  final String locationId;
  final DateTime startDate;
  final DateTime endDate;

  const LoadSalesReport({
    required this.locationId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [locationId, startDate, endDate];
}

class LoadPurchasesReport extends ReportsEvent {
  final String locationId;
  final DateTime startDate;
  final DateTime endDate;

  const LoadPurchasesReport({
    required this.locationId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [locationId, startDate, endDate];
}

class LoadTransfersReport extends ReportsEvent {
  final DateTime startDate;
  final DateTime endDate;
  final String? locationId;

  const LoadTransfersReport({
    required this.startDate,
    required this.endDate,
    this.locationId,
  });

  @override
  List<Object?> get props => [startDate, endDate, locationId];
}

class LoadDailySalesReport extends ReportsEvent {
  final DateTime date;

  const LoadDailySalesReport({required this.date});

  @override
  List<Object?> get props => [date];
}






