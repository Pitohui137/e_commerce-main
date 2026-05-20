import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/app_exception.dart';
import '../../../data/repositories/order_repository.dart';
import 'active_orders_state.dart';

class ActiveOrdersCubit extends Cubit<ActiveOrdersState> {
  ActiveOrdersCubit(this._repository) : super(const ActiveOrdersInitial());

  final OrderRepository _repository;

  Future<void> load() async {
    emit(const ActiveOrdersLoading());
    try {
      final orders = await _repository.fetchInDelivery();
      emit(ActiveOrdersLoaded(orders));
    } on AppException catch (e) {
      emit(ActiveOrdersError(e.message));
    } catch (_) {
      emit(const ActiveOrdersError('Gagal memuat pesanan aktif.'));
    }
  }

  Future<void> confirmReceived(String orderId) async {
    final current = state;
    final orders = switch (current) {
      ActiveOrdersLoaded s => s.orders,
      ActiveOrdersConfirming s => s.orders,
      _ => null,
    };
    if (orders == null) return;

    emit(ActiveOrdersConfirming(orders, orderId));
    try {
      await _repository.markAsReceived(orderId);
      await load();
    } on AppException catch (e) {
      emit(ActiveOrdersError(e.message));
    } catch (_) {
      emit(const ActiveOrdersError('Gagal mengonfirmasi pesanan.'));
    }
  }
}
