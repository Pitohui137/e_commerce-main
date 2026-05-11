import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/repositories/cart_repository.dart';
import '../data/repositories/product_repository.dart';
import '../features/cart/viewmodel/cart_cubit.dart';
import 'app_router.dart';
import 'app_theme.dart';

class ECommerceApp extends StatelessWidget {
  const ECommerceApp({
    super.key,
    required this.productRepository,
    required this.cartRepository,
  });

  final ProductRepository productRepository;
  final CartRepository cartRepository;

  @override
  Widget build(BuildContext context) {
    final router = AppRouter(productRepository);

    return RepositoryProvider<ProductRepository>.value(
      value: productRepository,
      child: RepositoryProvider<CartRepository>.value(
        value: cartRepository,
        child: BlocProvider(
          create: (_) => CartCubit(cartRepository),
          child: MaterialApp(
            title: 'Shop',
            theme: buildAppTheme(),
            initialRoute: AppRoutes.home,
            onGenerateRoute: router.onGenerateRoute,
          ),
        ),
      ),
    );
  }
}
