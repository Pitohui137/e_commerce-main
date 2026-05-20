import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_exception.dart';
import '../models/cart_line.dart';
import '../models/order.dart';
import '../models/order_status.dart';
import '../models/payment_method.dart';
import '../models/shipping_address.dart';

const _table = 'purchase_history';

/// Biaya ongkir flat untuk simulasi checkout Indonesia.
const double kDefaultShippingFee = 15000;

class OrderRepository {
  OrderRepository(this._supabase);

  final SupabaseClient _supabase;

  String get _uid {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw const AppException('Anda harus login untuk checkout.');
    }
    return user.id;
  }

  Future<List<Order>> _fetchByStatus(OrderStatus status) async {
    try {
      final data = await _supabase
          .from(_table)
          .select()
          .eq('user_id', _uid)
          .eq('status', status.dbValue)
          .order('created_at', ascending: false);

      return (data as List)
          .map((e) => Order.fromSupabase(e as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  /// Pesanan yang sudah dikonfirmasi diterima — tampil di Riwayat Pembelian.
  Future<List<Order>> fetchReceived() => _fetchByStatus(OrderStatus.diterima);

  /// Pesanan yang masih dalam pengantaran.
  Future<List<Order>> fetchInDelivery() =>
      _fetchByStatus(OrderStatus.prosesPengantaran);

  Future<bool> hasPendingDelivery() async {
    final pending = await fetchInDelivery();
    return pending.isNotEmpty;
  }

  Future<Order?> fetchById(String id) async {
    try {
      final data = await _supabase
          .from(_table)
          .select()
          .eq('id', id)
          .eq('user_id', _uid)
          .maybeSingle();

      if (data == null) return null;
      return Order.fromSupabase(data);
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  Future<Order> create({
    required List<CartLine> lines,
    required ShippingAddress address,
    required PaymentMethodType paymentMethod,
    required double subtotal,
    double shippingFee = kDefaultShippingFee,
  }) async {
    try {
      final total = subtotal + shippingFee;
      final data = await _supabase
          .from(_table)
          .insert({
            'user_id': _uid,
            'payment_method': paymentMethod.name,
            'subtotal': subtotal,
            'shipping_fee': shippingFee,
            'total': total,
            'recipient_name': address.recipientName,
            'phone': address.phone,
            'street': address.street,
            'city': address.city,
            'province': address.province,
            'postal_code': address.postalCode,
            'items': lines.map((e) => e.toJson()).toList(),
            'status': OrderStatus.prosesPengantaran.dbValue,
          })
          .select()
          .single();

      return Order.fromSupabase(data);
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  Future<Order> markAsReceived(String id) async {
    try {
      final data = await _supabase
          .from(_table)
          .update({'status': OrderStatus.diterima.dbValue})
          .eq('id', id)
          .eq('user_id', _uid)
          .eq('status', OrderStatus.prosesPengantaran.dbValue)
          .select()
          .maybeSingle();

      if (data == null) {
        throw const AppException('Pesanan tidak ditemukan atau sudah diterima.');
      }
      return Order.fromSupabase(data);
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(e.toString());
    }
  }
}
