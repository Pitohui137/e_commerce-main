import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/product.dart';
import '../data/repositories/product_repository.dart';
import '../features/cart/view/cart_screen.dart';
import '../features/home/view/home_screen.dart';
import '../features/home/viewmodel/home_cubit.dart';
import '../features/insert_product/view/insert_product_page.dart';
import '../features/insert_product/viewmodel/insert_product_cubit.dart';
import '../features/product_detail/view/product_detail_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String productDetail = '/product';
  static const String cart = '/cart';
  static const String insertProduct = '/insert-product';
}

class AppRouter {
  AppRouter(this._productRepository);

  final ProductRepository _productRepository;

  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (context) => BlocProvider(
            create: (_) => HomeCubit(_productRepository)..load(),
            child: const HomeScreen(),
          ),
        );
      case AppRoutes.productDetail:
        final product = settings.arguments as Product?;
        if (product == null) {
          return MaterialPageRoute<void>(
            builder: (_) => const _MissingArgsScreen(),
          );
        }
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => ProductDetailScreen(product: product),
        );
      case AppRoutes.cart:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const CartScreen(),
        );
      case AppRoutes.insertProduct:
        return MaterialPageRoute<Product?>(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => InsertProductCubit(_productRepository),
            child: const InsertProductPage(),
          ),
        );
      default:
        return null;
    }
  }
}

class _MissingArgsScreen extends StatelessWidget {
  const _MissingArgsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: const Center(child: Text('Missing product')),
    );
  }
}
