import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/reports_repository.dart';
import 'reports_event.dart';
import 'reports_state.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final ReportsRepository repository;

  ReportsBloc({required this.repository}) : super(ReportsInitial()) {
    on<LoadSalesReport>(_onLoadSalesReport);
    on<LoadPurchasesReport>(_onLoadPurchasesReport);
    on<LoadTransfersReport>(_onLoadTransfersReport);
    on<LoadDailySalesReport>(_onLoadDailySalesReport);
  }

  Future<void> _onLoadSalesReport(
    LoadSalesReport event,
    Emitter<ReportsState> emit,
  ) async {
    emit(ReportsLoading());
    try {
      final report = await repository.getSalesReport(
        locationId: event.locationId,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(SalesReportLoaded(report));
    } catch (e) {
      emit(ReportsError('Error al cargar reporte de ventas: ${e.toString()}'));
    }
  }

  Future<void> _onLoadPurchasesReport(
    LoadPurchasesReport event,
    Emitter<ReportsState> emit,
  ) async {
    emit(ReportsLoading());
    try {
      final report = await repository.getPurchasesReport(
        locationId: event.locationId,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(PurchasesReportLoaded(report));
    } catch (e) {
      emit(ReportsError('Error al cargar reporte de compras: ${e.toString()}'));
    }
  }

  Future<void> _onLoadTransfersReport(
    LoadTransfersReport event,
    Emitter<ReportsState> emit,
  ) async {
    emit(ReportsLoading());
    try {
      final report = await repository.getTransfersReport(
        startDate: event.startDate,
        endDate: event.endDate,
        locationId: event.locationId,
      );
      emit(TransfersReportLoaded(report));
    } catch (e) {
      emit(ReportsError('Error al cargar reporte de transferencias: ${e.toString()}'));
    }
  }

  Future<void> _onLoadDailySalesReport(
    LoadDailySalesReport event,
    Emitter<ReportsState> emit,
  ) async {
    emit(ReportsLoading());
    try {
      final report = await repository.getDailySalesReport(date: event.date);
      emit(DailySalesReportLoaded(report));
    } catch (e) {
      emit(ReportsError('Error al cargar venta del día: ${e.toString()}'));
    }
  }
}






