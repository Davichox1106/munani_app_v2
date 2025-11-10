import 'package:equatable/equatable.dart';
import '../../domain/entities/sales_report.dart';
import '../../domain/entities/purchases_report.dart';
import '../../domain/entities/transfers_report.dart';
import '../../domain/entities/daily_sales_report.dart';

abstract class ReportsState extends Equatable {
  const ReportsState();

  @override
  List<Object?> get props => [];
}

class ReportsInitial extends ReportsState {}

class ReportsLoading extends ReportsState {}

class SalesReportLoaded extends ReportsState {
  final SalesReport report;

  const SalesReportLoaded(this.report);

  @override
  List<Object?> get props => [report];
}

class PurchasesReportLoaded extends ReportsState {
  final PurchasesReport report;

  const PurchasesReportLoaded(this.report);

  @override
  List<Object?> get props => [report];
}

class TransfersReportLoaded extends ReportsState {
  final TransfersReport report;

  const TransfersReportLoaded(this.report);

  @override
  List<Object?> get props => [report];
}

class DailySalesReportLoaded extends ReportsState {
  final DailySalesReport report;

  const DailySalesReportLoaded(this.report);

  @override
  List<Object?> get props => [report];
}

class ReportsError extends ReportsState {
  final String message;

  const ReportsError(this.message);

  @override
  List<Object?> get props => [message];
}






