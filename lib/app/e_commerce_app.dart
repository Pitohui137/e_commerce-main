import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/repositories/auth_repository.dart';
import '../data/repositories/cart_repository.dart';
import '../data/repositories/customer_repository.dart';
import '../data/repositories/order_repository.dart';
import '../data/repositories/shipping_address_repository.dart';
import '../data/repositories/product_repository.dart';
import '../data/repositories/user_product_repository.dart';
import '../data/services/image_picker_service.dart';
import '../features/auth/view/auth_gate.dart';
import '../features/auth/viewmodel/auth_cubit.dart';
import '../features/cart/viewmodel/cart_cubit.dart';
import '../features/customers/viewmodel/customer_cubit.dart';
import 'app_router.dart';
import 'app_theme.dart';

class ECommerceApp extends StatelessWidget {
  const ECommerceApp({
    super.key,
    required this.productRepository,
    required this.cartRepository,
    required this.shippingAddressRepository,
    required this.orderRepository,
    required this.authRepository,
    required this.customerRepository,
    required this.userProductRepository,
    required this.imagePickerService,
  });

  final ProductRepository productRepository;
  final CartRepository cartRepository;
  final ShippingAddressRepository shippingAddressRepository;
  final OrderRepository orderRepository;
  final AuthRepository authRepository;
  final CustomerRepository customerRepository;
  final UserProductRepository userProductRepository;
  final ImagePickerService imagePickerService;

  @override
  Widget build(BuildContext context) {
    const router = AppRouter();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: productRepository),
        RepositoryProvider.value(value: cartRepository),
        RepositoryProvider.value(value: shippingAddressRepository),
        RepositoryProvider.value(value: orderRepository),
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: customerRepository),
        RepositoryProvider.value(value: userProductRepository),
        RepositoryProvider.value(value: imagePickerService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthCubit(authRepository)),
          BlocProvider(create: (_) => CartCubit(cartRepository)),
          BlocProvider(create: (_) => CustomerCubit(customerRepository)),
        ],
        child: MaterialApp(
          title: 'Vogue Shop',
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(),
          // AuthGate decides whether to show login or the main app
          home: const AuthGate(),
          onGenerateRoute: router.onGenerateRoute,
        ),
      ),
    );
  }
}