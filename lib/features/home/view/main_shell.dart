import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/viewmodel/auth_cubit.dart';
import '../../auth/viewmodel/auth_state.dart';
import './home_screen.dart';
import './profile_screen.dart';
import 'home_cubit.dart';
import '../../jual/view/jual_screen.dart';
import '../../jual/viewmodel/jual_cubit.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/user_product_repository.dart';
import '../../../data/services/image_picker_service.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;
  late HomeCubit _homeCubit;

  @override
  void initState() {
    super.initState();
    _homeCubit = HomeCubit(
      context.read<ProductRepository>(),
      context.read<UserProductRepository>(), // <-- tambahkan ini
    )..load();
  }

  @override
  void dispose() {
    _homeCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _homeCubit),
        BlocProvider(
          create: (ctx) => JualCubit(
            repository: ctx.read<UserProductRepository>(),
            imageService: ctx.read<ImagePickerService>(),
          ),
        ),
      ],
      child: Builder(
        builder: (context) {
          final screens = [
            const _HomeTab(),
            const JualScreen(),
            _ProfileTab(),
          ];
          return Scaffold(
            body: IndexedStack(index: _tab, children: screens),
            bottomNavigationBar: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFF0EFED))),
              ),
              child: BottomNavigationBar(
                currentIndex: _tab,
                onTap: (i) => setState(() => _tab = i),
                backgroundColor: Colors.white,
                elevation: 0,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.grid_view_rounded),
                    label: 'Produk',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.storefront_outlined),
                    label: 'Jual',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline_rounded),
                    label: 'Profil',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}

class _ProfileTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthCubit>().state;
    final email = state is AuthAuthenticated ? state.user.email ?? '' : '';
    return ProfileScreen(email: email);
  }
}