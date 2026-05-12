import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_exception.dart';
import '../models/customer.dart';

const _table = 'customers';

class CustomerRepository {
  CustomerRepository(this._supabase);

  final SupabaseClient _supabase;

  String get _uid => _supabase.auth.currentUser!.id;

  Future<List<Customer>> fetchAll() async {
    try {
      final data = await _supabase
          .from(_table)
          .select()
          .eq('user_id', _uid)
          .order('created_at', ascending: false);

      return (data as List)
          .map((e) => Customer.fromJson(e as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  Future<Customer> create({
    required String name,
    required String email,
    String? phone,
    String? address,
  }) async {
    try {
      final data = await _supabase
          .from(_table)
          .insert({
            'user_id': _uid,
            'name': name.trim(),
            'email': email.trim(),
            if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
            if (address != null && address.trim().isNotEmpty)
              'address': address.trim(),
          })
          .select()
          .single();

      return Customer.fromJson(data as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  Future<Customer> update({
    required String id,
    required String name,
    required String email,
    String? phone,
    String? address,
  }) async {
    try {
      final data = await _supabase
          .from(_table)
          .update({
            'name': name.trim(),
            'email': email.trim(),
            'phone': phone?.trim().isEmpty == true ? null : phone?.trim(),
            'address': address?.trim().isEmpty == true ? null : address?.trim(),
          })
          .eq('id', id)
          .eq('user_id', _uid)
          .select()
          .single();

      return Customer.fromJson(data as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  Future<void> delete(String id) async {
    try {
      await _supabase
          .from(_table)
          .delete()
          .eq('id', id)
          .eq('user_id', _uid);
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    } catch (e) {
      throw AppException(e.toString());
    }
  }
}