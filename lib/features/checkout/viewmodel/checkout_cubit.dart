import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/app_exception.dart';
import '../../../data/models/payment_method.dart';
import '../../../data/models/shipping_address.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/repositories/shipping_address_repository.dart';
import '../../cart/viewmodel/cart_cubit.dart';
import 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit({
    required CartCubit cartCubit,
    required ShippingAddressRepository addressRepository,
    required OrderRepository orderRepository,
  })  : _cartCubit = cartCubit,
        _address = addressRepository,
        _orders = orderRepository,
        super(CheckoutState(lines: cartCubit.state.lines));

  final CartCubit _cartCubit;
  final ShippingAddressRepository _address;
  final OrderRepository _orders;

  void load() {
    emit(state.copyWith(savedAddress: _address.load(), clearError: true));
  }

  void selectPayment(PaymentMethodType type) {
    emit(state.copyWith(selectedPayment: type, clearError: true));
  }

  Future<void> placeOrder({
    required String recipientName,
    required String phone,
    required String street,
    required String city,
    required String province,
    required String postalCode,
  }) async {
    if (state.lines.isEmpty) {
      emit(state.copyWith(
        status: CheckoutStatus.failure,
        errorMessage: 'Keranjang kosong.',
      ));
      return;
    }

    emit(state.copyWith(status: CheckoutStatus.submitting, clearError: true));

    try {
      final address = ShippingAddress(
        recipientName: recipientName.trim(),
        phone: phone.trim(),
        street: street.trim(),
        city: city.trim(),
        province: province.trim(),
        postalCode: postalCode.trim(),
      );

      await _address.save(address);

      final order = await _orders.create(
        lines: state.lines,
        address: address,
        paymentMethod: state.selectedPayment,
        subtotal: state.subtotal,
        shippingFee: state.shippingFee,
      );

      _cartCubit.clear();

      emit(state.copyWith(
        status: CheckoutStatus.success,
        completedOrder: order,
        lines: const [],
      ));
    } on AppException catch (e) {
      emit(state.copyWith(
        status: CheckoutStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: CheckoutStatus.failure,
        errorMessage: 'Gagal memproses pesanan. Coba lagi.',
      ));
    }
  }

  void resetStatus() {
    emit(state.copyWith(status: CheckoutStatus.idle, clearError: true));
  }
}
