import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/e_commerce_app.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/cart_repository.dart';
import 'data/repositories/customer_repository.dart';
import 'data/repositories/product_repository.dart';
import 'data/repositories/user_product_repository.dart';
import 'data/services/fake_store_api_client.dart';
import 'data/services/image_picker_service.dart';
import 'data/services/supabase_constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Init Supabase
  await Supabase.initialize(
    url: SupabaseConstants.supabaseUrl,
    anonKey: SupabaseConstants.supabaseAnonKey,
  );

  // 2. Other dependencies
  final prefs = await SharedPreferences.getInstance();
  final supabase = Supabase.instance.client;

  runApp(
    ECommerceApp(
      productRepository: ProductRepository(FakeStoreApiClient()),
      cartRepository: CartRepository(prefs),
      authRepository: AuthRepository(supabase),
      customerRepository: CustomerRepository(supabase),
      userProductRepository: UserProductRepository(supabase),
      imagePickerService: ImagePickerService(supabase),
    ),
  );
}