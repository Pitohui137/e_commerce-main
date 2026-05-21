import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../viewmodel/auth_cubit.dart';
import '../viewmodel/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  final _loginEmail = TextEditingController();
  final _loginPass = TextEditingController();
  final _loginKey = GlobalKey<FormState>();
  bool _loginObscure = true;

  final _regEmail = TextEditingController();
  final _regPass = TextEditingController();
  final _regConfirm = TextEditingController();
  final _regKey = GlobalKey<FormState>();
  bool _regObscure = true;
  bool _regConfirmObscure = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _loginEmail.dispose();
    _loginPass.dispose();
    _regEmail.dispose();
    _regPass.dispose();
    _regConfirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFFD32F2F),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F0F),
        body: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final loading = state is AuthLoading;
            return SafeArea(
              child: Column(
                children: [
                  // Brand header
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(0xFFC9A84C), width: 1.5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.diamond_outlined,
                                color: Color(0xFFC9A84C), size: 28),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'VERNIQUE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 6,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Luxury fashion at your fingertips',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.45),
                              fontSize: 13,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Form card
                  Expanded(
                    flex: 5,
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFAF9F7),
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(28)),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Tab switcher
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEEDE9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TabBar(
                                controller: _tabCtrl,
                                indicator: BoxDecoration(
                                  color: const Color(0xFF0F0F0F),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                indicatorSize: TabBarIndicatorSize.tab,
                                indicatorPadding: const EdgeInsets.all(3),
                                labelColor: Colors.white,
                                unselectedLabelColor: const Color(0xFF888888),
                                labelStyle: const TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 14),
                                dividerColor: Colors.transparent,
                                tabs: const [
                                  Tab(text: 'Masuk'),
                                  Tab(text: 'Daftar'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),

                            SizedBox(
                              height: 290,
                              child: TabBarView(
                                controller: _tabCtrl,
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  // ── Login ──
                                  Form(
                                    key: _loginKey,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        _AuthField(
                                          controller: _loginEmail,
                                          label: 'Email',
                                          icon: Icons.alternate_email_rounded,
                                          type: TextInputType.emailAddress,
                                          validator: (v) {
                                            if (v == null ||
                                                v.trim().isEmpty) {
                                              return 'Masukkan email';
                                            }
                                            if (!v.contains('@')) {
                                              return 'Email tidak valid';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 14),
                                        _AuthField(
                                          controller: _loginPass,
                                          label: 'Password',
                                          icon: Icons.lock_outline_rounded,
                                          obscure: _loginObscure,
                                          onToggle: () => setState(() =>
                                              _loginObscure = !_loginObscure),
                                          action: TextInputAction.done,
                                          validator: (v) {
                                            if (v == null || v.isEmpty) {
                                              return 'Masukkan password';
                                            }
                                            if (v.length < 6) {
                                              return 'Minimal 6 karakter';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 24),
                                        _SubmitBtn(
                                          loading: loading,
                                          label: 'Masuk',
                                          onPressed: () {
                                            if (_loginKey.currentState!
                                                .validate()) {
                                              context.read<AuthCubit>().signIn(
                                                    email: _loginEmail.text
                                                        .trim(),
                                                    password: _loginPass.text,
                                                  );
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),

                                  // ── Register ──
                                  Form(
                                    key: _regKey,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        _AuthField(
                                          controller: _regEmail,
                                          label: 'Email',
                                          icon: Icons.alternate_email_rounded,
                                          type: TextInputType.emailAddress,
                                          validator: (v) {
                                            if (v == null ||
                                                v.trim().isEmpty) {
                                              return 'Masukkan email';
                                            }
                                            if (!v.contains('@')) {
                                              return 'Email tidak valid';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 12),
                                        _AuthField(
                                          controller: _regPass,
                                          label: 'Password',
                                          icon: Icons.lock_outline_rounded,
                                          obscure: _regObscure,
                                          onToggle: () => setState(
                                              () => _regObscure = !_regObscure),
                                          validator: (v) {
                                            if (v == null || v.isEmpty) {
                                              return 'Masukkan password';
                                            }
                                            if (v.length < 6) {
                                              return 'Minimal 6 karakter';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 12),
                                        _AuthField(
                                          controller: _regConfirm,
                                          label: 'Konfirmasi Password',
                                          icon: Icons.lock_outline_rounded,
                                          obscure: _regConfirmObscure,
                                          onToggle: () => setState(() =>
                                              _regConfirmObscure =
                                                  !_regConfirmObscure),
                                          action: TextInputAction.done,
                                          validator: (v) {
                                            if (v != _regPass.text) {
                                              return 'Password tidak cocok';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 20),
                                        _SubmitBtn(
                                          loading: loading,
                                          label: 'Buat Akun',
                                          onPressed: () {
                                            if (_regKey.currentState!
                                                .validate()) {
                                              context.read<AuthCubit>().signUp(
                                                    email:
                                                        _regEmail.text.trim(),
                                                    password: _regPass.text,
                                                  );
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.label,
    required this.icon,
    this.type = TextInputType.text,
    this.action = TextInputAction.next,
    this.obscure = false,
    this.onToggle,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType type;
  final TextInputAction action;
  final bool obscure;
  final VoidCallback? onToggle;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      textInputAction: action,
      obscureText: obscure,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: const Color(0xFF888888)),
        suffixIcon: onToggle != null
            ? IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 18,
                  color: const Color(0xFF888888),
                ),
                onPressed: onToggle,
              )
            : null,
      ),
    );
  }
}

class _SubmitBtn extends StatelessWidget {
  const _SubmitBtn({
    required this.loading,
    required this.label,
    required this.onPressed,
  });

  final bool loading;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: loading ? null : onPressed,
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
      child: loading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            )
          : Text(label),
    );
  }
}