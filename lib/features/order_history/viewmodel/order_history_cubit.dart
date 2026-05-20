import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/app_exception.dart';
import '../../../data/repositories/order_repository.dart';
import 'order_history_state.dart';

class OrderHistoryCubit extends Cubit<OrderHistoryState> {
  OrderHistoryCubit(this._repository) : super(const OrderHistoryInitial());

  final OrderRepository _repository;

  Future<void> load() async {
    emit(const OrderHistoryLoading());
    try {
      final orders = await _repository.fetchReceived();
      emit(OrderHistoryLoaded(orders));
    } on AppException catch (e) {
      emit(OrderHistoryError(e.message));
    } catch (_) {
      emit(const OrderHistoryError('Gagal memuat riwayat pembelian.'));
    }
  }
}
