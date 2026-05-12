import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_exception.dart';
import '../../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthInitial()) {
    _init();
  }

  final AuthRepository _repository;
  StreamSubscription<AuthState>? _sub;

  void _init() {
    // Check current session first
    if (_repository.isLoggedIn) {
      emit(AuthAuthenticated(_repository.currentUser!));
    } else {
      emit(const AuthUnauthenticated());
    }

    // Listen to auth changes (token refresh, sign-out from other tab, etc.)
    _sub = _repository.authStateChanges.map((event) {
      final user = event.session?.user;
      if (user != null) return AuthAuthenticated(user);
      return const AuthUnauthenticated();
    }).listen(emit);
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());
    try {
      final user = await _repository.signIn(email: email, password: password);
      emit(AuthAuthenticated(user));
    } on AppException catch (e) {
      emit(AuthError(e.message));
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());
    try {
      final user = await _repository.signUp(email: email, password: password);
      emit(AuthAuthenticated(user));
    } on AppException catch (e) {
      emit(AuthError(e.message));
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    emit(const AuthUnauthenticated());
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}