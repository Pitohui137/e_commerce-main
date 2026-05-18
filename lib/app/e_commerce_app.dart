import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/repositories/auth_repository.dart';
import '../data/repositories/cart_repository.dart';
import '../data/repositories/customer_repository.dart';
import '../data/repositories/product_repository.dart';
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
    required this.authRepository,
    required this.customerRepository,
  });

  final ProductRepository productRepository;
  final CartRepository cartRepository;
  final AuthRepository authRepository;
  final CustomerRepository customerRepository;

  @override
  Widget build(BuildContext context) {
    final router = AppRouter(productRepository);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: productRepository),
        RepositoryProvider.value(value: cartRepository),
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: customerRepository),
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