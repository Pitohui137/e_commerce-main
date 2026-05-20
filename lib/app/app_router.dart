import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/product.dart';
import '../data/models/user_product.dart';
import '../data/repositories/user_product_repository.dart';
import '../data/services/image_picker_service.dart';
import '../data/repositories/order_repository.dart';
import '../data/repositories/shipping_address_repository.dart';
import '../features/cart/view/cart_screen.dart';
import '../features/cart/viewmodel/cart_cubit.dart';
import '../features/checkout/view/checkout_screen.dart';
import '../features/checkout/viewmodel/checkout_cubit.dart';
import '../features/insert_product/view/insert_product_page.dart';
import '../features/insert_product/viewmodel/insert_product_cubit.dart';
import '../features/order_history/view/active_orders_screen.dart';
import '../features/order_history/view/order_detail_screen.dart';
import '../features/order_history/view/order_history_screen.dart';
import '../features/order_history/viewmodel/active_orders_cubit.dart';
import '../features/order_history/viewmodel/order_history_cubit.dart';
import '../features/product_detail/view/product_detail_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String productDetail = '/product';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderHistory = '/order-history';
  static const String activeOrders = '/active-orders';
  static const String orderDetail = '/order-detail';
  static const String insertProduct = '/insert-product';
}

class AppRouter {
  const AppRouter();

  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.productDetail:
        final product = settings.arguments as Product?;
        if (product == null) {
          return MaterialPageRoute<void>(
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: const Center(child: Text('Produk tidak ditemukan.')),
            ),
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

      case AppRoutes.checkout:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (ctx) => BlocProvider(
            create: (_) => CheckoutCubit(
              cartCubit: ctx.read<CartCubit>(),
              addressRepository: ctx.read<ShippingAddressRepository>(),
              orderRepository: ctx.read<OrderRepository>(),
            )..load(),
            child: const CheckoutScreen(),
          ),
        );

      case AppRoutes.activeOrders:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (ctx) => BlocProvider(
            create: (_) => ActiveOrdersCubit(ctx.read<OrderRepository>()),
            child: const ActiveOrdersScreen(),
          ),
        );

      case AppRoutes.orderHistory:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (ctx) => BlocProvider(
            create: (_) => OrderHistoryCubit(ctx.read<OrderRepository>()),
            child: const OrderHistoryScreen(),
          ),
        );

      case AppRoutes.orderDetail:
        final orderId = settings.arguments as String?;
        if (orderId == null || orderId.isEmpty) {
          return MaterialPageRoute<void>(
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: const Center(child: Text('Pesanan tidak ditemukan.')),
            ),
          );
        }
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => OrderDetailScreen(orderId: orderId),
        );

      case AppRoutes.insertProduct:
        return MaterialPageRoute<UserProduct>(
          settings: settings,
          builder: (ctx) => BlocProvider(
            create: (_) => InsertProductCubit(
              repository: ctx.read<UserProductRepository>(),
              imageService: ctx.read<ImagePickerService>(),
            ),
            child: const InsertProductPage(),
          ),
        );

      default:
        return null;
    }
  }
}