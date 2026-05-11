import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/e_commerce_app.dart';
import 'data/repositories/cart_repository.dart';
import 'data/repositories/product_repository.dart';
import 'data/services/fake_store_api_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final cartRepository = CartRepository(prefs);
  final productRepository = ProductRepository(FakeStoreApiClient());

  runApp(
    ECommerceApp(
      productRepository: productRepository,
      cartRepository: cartRepository,
    ),
  );
}
