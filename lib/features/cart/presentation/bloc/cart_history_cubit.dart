import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_status.dart';
import '../../domain/usecases/sync_customer_carts.dart';
import '../../domain/usecases/watch_cart_history.dart';

enum CartHistoryStatus { initial, loading, success, failure }

class CartHistoryState extends Equatable {
  final CartHistoryStatus status;
  final List<Cart> carts;
  final String? error;
  final bool isSyncing;

  const CartHistoryState({
    this.status = CartHistoryStatus.initial,
    this.carts = const [],
    this.error,
    this.isSyncing = false,
  });

  CartHistoryState copyWith({
    CartHistoryStatus? status,
    List<Cart>? carts,
    String? error,
    bool? isSyncing,
    bool clearError = false,
  }) {
    return CartHistoryState(
      status: status ?? this.status,
      carts: carts ?? this.carts,
      error: clearError ? null : (error ?? this.error),
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }

  @override
  List<Object?> get props => [status, carts, error, isSyncing];
}

class CartHistoryCubit extends Cubit<CartHistoryState> {
  final WatchCartHistory watchCartHistory;
  final SyncCustomerCarts syncCustomerCarts;

  StreamSubscription<Either<Failure, List<Cart>>>? _subscription;
  String? _customerId;
  List<CartStatus>? _statuses;

  CartHistoryCubit({
    required this.watchCartHistory,
    required this.syncCustomerCarts,
  }) : super(const CartHistoryState());

  Future<void> load({
    required String customerId,
    List<CartStatus>? statuses,
  }) async {
    _subscription?.cancel();
    _customerId = customerId;
    _statuses = statuses;

    emit(
      state.copyWith(
        status: CartHistoryStatus.loading,
        isSyncing: true,
        clearError: true,
      ),
    );

    _subscription = watchCartHistory(
      customerId: customerId,
      statuses: statuses,
    ).listen((either) {
      either.fold(
        (failure) => emit(
          state.copyWith(
            status: CartHistoryStatus.failure,
            error: failure.message,
            isSyncing: false,
          ),
        ),
        (carts) => emit(
          state.copyWith(
            status: CartHistoryStatus.success,
            carts: carts,
            isSyncing: false,
            clearError: true,
          ),
        ),
      );
    });

    final result = await syncCustomerCarts(
      customerId: customerId,
      statuses: statuses,
    );

    result.fold(
      (failure) {
        final hasData = state.carts.isNotEmpty;
        emit(
          state.copyWith(
            status: hasData ? state.status : CartHistoryStatus.failure,
            error: failure.message,
            isSyncing: false,
          ),
        );
      },
      (_) => emit(state.copyWith(isSyncing: false)),
    );
  }

  Future<void> refresh() async {
    final customerId = _customerId;
    if (customerId == null) return;

    emit(state.copyWith(isSyncing: true, clearError: true));

    final result = await syncCustomerCarts(
      customerId: customerId,
      statuses: _statuses,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          error: failure.message,
          isSyncing: false,
        ),
      ),
      (_) => emit(
        state.copyWith(isSyncing: false),
      ),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}



