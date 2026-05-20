import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/e_commerce_app.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/cart_repository.dart';
import 'data/repositories/customer_repository.dart';
import 'data/repositories/order_repository.dart';
import 'data/repositories/shipping_address_repository.dart';
import 'data/repositories/product_repository.dart';
import 'data/repositories/user_product_repository.dart';
import 'data/services/fake_store_api_client.dart';
import 'data/services/image_picker_service.dart';
import 'data/services/supabase_constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

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
      shippingAddressRepository: ShippingAddressRepository(prefs),
      orderRepository: OrderRepository(supabase),
      authRepository: AuthRepository(supabase),
      customerRepository: CustomerRepository(supabase),
      userProductRepository: UserProductRepository(supabase),
      imagePickerService: ImagePickerService(supabase),
    ),
  );
}