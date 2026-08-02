// lib/features/auth/presentation/auth_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';

// Provider que expõe o Controller para a tela
final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;

  // Iniciamos com o estado de sucesso (sem estar carregando e sem erros)
  AuthController(this._authRepository) : super(const AsyncData(null));

  Future<void> signIn(String email, String password) async {
    // Muda o estado para "carregando", o que vai desabilitar o botão na tela
    state = const AsyncLoading();
    
    // AsyncValue.guard tenta rodar a função. Se der erro (ex: senha errada), ele salva o erro no estado.
    state = await AsyncValue.guard(() => _authRepository.signIn(email, password));
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _authRepository.signUp(
          email: email,
          password: password,
          fullName: fullName,
          role: role,
        ));
  }
}
