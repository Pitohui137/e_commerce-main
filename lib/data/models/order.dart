import 'package:equatable/equatable.dart';

import 'cart_line.dart';
import 'order_status.dart';
import 'payment_method.dart';
import 'shipping_address.dart';

class Order extends Equatable {
  const Order({
    required this.id,
    required this.createdAt,
    required this.lines,
    required this.address,
    required this.paymentMethod,
    required this.subtotal,
    required this.shippingFee,
    required this.total,
    required this.status,
  });

  final String id;
  final DateTime createdAt;
  final List<CartLine> lines;
  final ShippingAddress address;
  final PaymentMethodType paymentMethod;
  final double subtotal;
  final double shippingFee;
  final double total;
  final OrderStatus status;

  bool get isDelivered => status == OrderStatus.diterima;

  /// Baris dari tabel Supabase `purchase_history`.
  factory Order.fromSupabase(Map<String, dynamic> json) {
    final itemsRaw = json['items'] as List<dynamic>;
    return Order(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      lines: itemsRaw
          .map((e) => CartLine.fromJson(e as Map<String, dynamic>))
          .toList(),
      address: ShippingAddress(
        recipientName: json['recipient_name'] as String,
        phone: json['phone'] as String,
        street: json['street'] as String,
        city: json['city'] as String,
        province: json['province'] as String,
        postalCode: json['postal_code'] as String,
      ),
      paymentMethod: PaymentMethodType.values.firstWhere(
        (v) => v.name == json['payment_method'] as String,
      ),
      subtotal: (json['subtotal'] as num).toDouble(),
      shippingFee: (json['shipping_fee'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      status: OrderStatusX.fromDb(json['status'] as String? ?? 'proses_pengantaran'),
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        lines,
        address,
        paymentMethod,
        subtotal,
        shippingFee,
        total,
        status,
      ];
}
