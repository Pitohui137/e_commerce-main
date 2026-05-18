import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import '../../../core/errors/app_exception.dart';
import '../../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthInitial()) {
    _init();
  }

  final AuthRepository _repository;
  StreamSubscription<dynamic>? _authSub;

  void _init() {
    final user = _repository.currentUser;
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(const AuthUnauthenticated());
    }

    _authSub = _repository.authStateChanges.listen((event) {
      final u = event.session?.user;
      if (u != null) {
        emit(AuthAuthenticated(u));
      } else {
        emit(const AuthUnauthenticated());
      }
    });
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
    _authSub?.cancel();
    return super.close();
  }
}