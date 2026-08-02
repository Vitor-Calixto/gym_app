// lib/features/auth/data/auth_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/supabase_client.dart';
import '../domain/app_user.dart';

// Provider para injetar o repositório em qualquer lugar do app
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseProvider));
});

class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository(this._supabase);

  // 1. Busca o perfil do usuário logado atualmente
  Future<AppUser?> getCurrentUser() async {
    final session = _supabase.auth.currentSession;
    if (session == null) return null;

    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', session.user.id)
        .maybeSingle();

    if (response == null) return null;
    return AppUser.fromMap(response);
  }

  // 2. Faz o Login
  Future<void> signIn(String email, String password) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  // 3. Faz o Cadastro (Cria no auth.users e depois na nossa tabela profiles)
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user != null) {
      // Assim que cria a conta secreta, insere os dados públicos na nossa tabela
      await _supabase.from('profiles').insert({
        'id': response.user!.id,
        'full_name': fullName,
        'role': role,
      });
    }
  }

  // 4. Faz o Logout
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}