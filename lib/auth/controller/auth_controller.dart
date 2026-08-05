// lib/features/auth/domain/auth_controller.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// ===============================================================
/// CONTROLLER DE AUTENTICAÇÃO
/// ===============================================================
///
/// Responsável por:
/// - Login
/// - Cadastro
/// - Logout
/// - Recuperação da role do usuário
///
/// Roles utilizadas:
/// - student
/// - trainer
/// ===============================================================

class AuthController extends StateNotifier<AsyncValue<String?>> {
  AuthController() : super(const AsyncData(null));

  final SupabaseClient _supabase = Supabase.instance.client;

  /// ---------------------------------------------------------------
  /// LOGIN
  /// ---------------------------------------------------------------

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      final user = response.user;

      if (user == null) {
        throw Exception('Não foi possível identificar o usuário.');
      }

      /// Procura o perfil do usuário.
      final profile = await _supabase
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      String role;

      /// Se o perfil ainda não existir,
      /// cria um perfil padrão de aluno.
      if (profile == null || profile['role'] == null) {
        role = 'student';

        await _supabase.from('profiles').upsert({
          'id': user.id,
          'full_name': user.email?.split('@').first ?? 'Usuário',
          'role': role,
        });
      } else {
        role = profile['role'].toString();
      }

      /// A tela de Login escuta esse estado.
      state = AsyncData(role);
    } catch (e, stackTrace) {
      debugPrint('ERRO NO LOGIN: $e');

      state = AsyncError(
        e.toString(),
        stackTrace,
      );
    }
  }

  /// ---------------------------------------------------------------
  /// CADASTRO
  /// ---------------------------------------------------------------

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? trainerId,
  }) async {
    state = const AsyncLoading();

    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
      );

      final user = response.user;

      if (user == null) {
        throw Exception('Erro ao criar conta.');
      }

      final Map<String, dynamic> profileData = {
        'id': user.id,
        'full_name': fullName.trim(),
        'role': role,
      };

      /// Somente aluno precisa receber trainer_id.
      if (trainerId != null && trainerId.trim().isNotEmpty) {
        profileData['trainer_id'] = trainerId.trim();
      }

      await _supabase
          .from('profiles')
          .upsert(profileData);

      state = const AsyncData('success');
    } catch (e, stackTrace) {
      debugPrint('ERRO NO CADASTRO: $e');

      state = AsyncError(
        e.toString(),
        stackTrace,
      );
    }
  }

  /// ---------------------------------------------------------------
  /// LOGOUT
  /// ---------------------------------------------------------------

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();

      state = const AsyncData(null);
    } catch (e) {
      debugPrint('Erro ao sair: $e');
    }
  }
}

/// ===============================================================
/// PROVIDER DO AUTH CONTROLLER
/// ===============================================================

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<String?>>(
  (ref) => AuthController(),
);

/// ===============================================================
/// PERFIL DO USUÁRIO LOGADO
/// ===============================================================
///
/// Este provider é compartilhado por:
/// - Home do aluno
/// - Home do professor
/// - Perfil
/// - Outras telas
///
/// NÃO crie outro userProfileProvider em outra tela.
/// ===============================================================

final userProfileProvider =
    StreamProvider.autoDispose<Map<String, dynamic>>((ref) {
  final supabase = Supabase.instance.client;

  final user = supabase.auth.currentUser;

  if (user == null) {
    return const Stream.empty();
  }

  return supabase
      .from('profiles')
      .stream(primaryKey: ['id'])
      .eq('id', user.id)
      .map((rows) {
        if (rows.isEmpty) {
          return <String, dynamic>{};
        }

        return rows.first;
      });
});