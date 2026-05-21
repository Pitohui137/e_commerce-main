import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../home/view/main_shell.dart';
import '../viewmodel/auth_cubit.dart';
import '../viewmodel/auth_state.dart';
import 'login_screen.dart';

/// Sits at the root of the widget tree and switches between
/// [LoginScreen] and [MainShell] based on the [AuthCubit] state.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return switch (state) {
          AuthAuthenticated() => const MainShell(),
          AuthLoading() => const _SplashView(),
          _ => const LoginScreen(),
        };
      },
    );
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0F0F0F),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'VERNIQUE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 8,
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Color(0xFFC9A84C),
                strokeWidth: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}