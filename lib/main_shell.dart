import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/viewmodel/auth_cubit.dart';
import '../../auth/viewmodel/auth_state.dart';
import '../../customers/view/customer_screen.dart';
import '../../customers/viewmodel/customer_cubit.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

/// Bottom-navigation shell shown after login.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;

  static const _screens = [
    _HomeTab(),
    _CustomersTab(),
    _ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tab, children: _screens),
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
              icon: Icon(Icons.people_outline_rounded),
              label: 'Pelanggan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

// Wrappers so each tab rebuilds independently

class _HomeTab extends StatelessWidget {
  const _HomeTab();
  @override
  Widget build(BuildContext context) => const HomeScreen();
}

class _CustomersTab extends StatelessWidget {
  const _CustomersTab();
  @override
  Widget build(BuildContext context) {
    // Re-load whenever tab is first shown
    return BlocProvider.value(
      value: context.read<CustomerCubit>(),
      child: const CustomerScreen(),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthCubit>().state;
    final email = state is AuthAuthenticated ? state.user.email ?? '' : '';
    return ProfileScreen(email: email);
  }
}