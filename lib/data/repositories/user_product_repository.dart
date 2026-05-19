import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_exception.dart';
import '../models/user_product.dart';

const _table = 'user_products';

class UserProductRepository {
  UserProductRepository(this._supabase);

  final SupabaseClient _supabase;

  String get _uid {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw const AppException('Anda harus login untuk mengelola produk jualan.');
    }
    return user.id;
  }

  Future<List<UserProduct>> fetchAll() async {
    try {
      final data = await _supabase
          .from(_table)
          .select()
          .eq('user_id', _uid)
          .order('created_at', ascending: false);

      return (data as List)
          .map((e) => UserProduct.fromJson(e as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  Future<UserProduct> create({
    required String title,
    required double price,
    required String description,
    required String category,
    required String imageUrl,
  }) async {
    try {
      final data = await _supabase
          .from(_table)
          .insert({
            'user_id': _uid,
            'title': title.trim(),
            'price': price,
            'description': description.trim(),
            'category': category.trim(),
            'image_url': imageUrl,
          })
          .select()
          .single();

      return UserProduct.fromJson(data as Map<String, dynamic>);
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
