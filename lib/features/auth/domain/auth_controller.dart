// lib/features/auth/domain/auth_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(const AsyncValue.data(null));

  // 🔴 1. MÉTODO DE LOGIN (O que estava faltando)
  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.signIn(email, password));
  }

  // 🔴 2. MÉTODO DE CADASTRO
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? trainerId,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.signUp(
      email: email,
      password: password,
      fullName: fullName,
      role: role,
      trainerId: trainerId,
    ));
  }

  // 🔴 3. MÉTODO DE LOGOUT
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.signOut());
  }
}