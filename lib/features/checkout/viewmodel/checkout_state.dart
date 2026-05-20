import 'package:equatable/equatable.dart';

import '../../../data/models/cart_line.dart';
import '../../../data/models/order.dart';
import '../../../data/models/payment_method.dart';
import '../../../data/models/shipping_address.dart';
import '../../../data/repositories/order_repository.dart';

enum CheckoutStatus { idle, submitting, success, failure }

class CheckoutState extends Equatable {
  const CheckoutState({
    required this.lines,
    this.savedAddress,
    this.selectedPayment = PaymentMethodType.bankTransfer,
    this.status = CheckoutStatus.idle,
    this.errorMessage,
    this.completedOrder,
  });

  final List<CartLine> lines;
  final ShippingAddress? savedAddress;
  final PaymentMethodType selectedPayment;
  final CheckoutStatus status;
  final String? errorMessage;
  final Order? completedOrder;

  double get subtotal =>
      lines.fold(0.0, (sum, line) => sum + line.lineTotal);

  double get shippingFee => kDefaultShippingFee;

  double get total => subtotal + shippingFee;

  bool get isSubmitting => status == CheckoutStatus.submitting;

  CheckoutState copyWith({
    List<CartLine>? lines,
    ShippingAddress? savedAddress,
    PaymentMethodType? selectedPayment,
    CheckoutStatus? status,
    String? errorMessage,
    Order? completedOrder,
    bool clearError = false,
  }) {
    return CheckoutState(
      lines: lines ?? this.lines,
      savedAddress: savedAddress ?? this.savedAddress,
      selectedPayment: selectedPayment ?? this.selectedPayment,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      completedOrder: completedOrder ?? this.completedOrder,
    );
  }

  @override
  List<Object?> get props => [
        lines,
        savedAddress,
        selectedPayment,
        status,
        errorMessage,
        completedOrder,
      ];
}
