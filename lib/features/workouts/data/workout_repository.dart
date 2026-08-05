import 'package:supabase_flutter/supabase_flutter.dart';

class WorkoutRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================================
  // BUSCAR EXERCÍCIOS
  // ============================================================
  Future<List<Map<String, dynamic>>> searchExercises(
    String query,
  ) async {
    try {
      final response = await _supabase
          .from('exercises')
          .select()
          .ilike('name', '%$query%')
          .limit(20);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Erro ao buscar exercícios: $e');
    }
  }

  // ============================================================
  // SALVAR FICHA DE TREINO
  // ============================================================
  Future<void> saveWorkout({
    required String title,
    required String focus,
    required String studentId,
    required List<Map<String, dynamic>> exercises,
  }) async {
    try {
      // ----------------------------------------------------------
      // 1. Usuário autenticado
      // ----------------------------------------------------------
      final currentUser = _supabase.auth.currentUser;

      if (currentUser == null) {
        throw Exception(
          'Nenhum usuário autenticado. Faça login novamente.',
        );
      }

      final trainerId = currentUser.id;

      // ----------------------------------------------------------
      // 2. Criar o cabeçalho da ficha
      // ----------------------------------------------------------
      final workoutResponse = await _supabase
          .from('workouts')
          .insert({
            'title': title,
            'focus': focus,
            'student_id': studentId,
            'trainer_id': trainerId,
          })
          .select('id')
          .single();

      final String workoutId = workoutResponse['id'].toString();

      // ----------------------------------------------------------
      // 3. Preparar os exercícios
      // ----------------------------------------------------------
      final List<Map<String, dynamic>> itemsToInsert = [];

      for (int i = 0; i < exercises.length; i++) {
        final ex = exercises[i];

        // --------------------------------------------------------
        // Séries
        // --------------------------------------------------------
        final int setsCount =
            int.tryParse(ex['sets']?.toString() ?? '') ?? 3;

        // --------------------------------------------------------
        // Descanso
        //
        // Exemplos:
        // "60s" -> 60
        // "90 segundos" -> 90
        // "45" -> 45
        // --------------------------------------------------------
        final int restTime = int.tryParse(
              (ex['rest']?.toString() ?? '')
                  .replaceAll(RegExp(r'[^0-9]'), ''),
            ) ??
            60;

        // --------------------------------------------------------
        // ID do exercício do catálogo
        // --------------------------------------------------------
        final dynamic exerciseId = ex['exercise_id'];

        // --------------------------------------------------------
        // Montamos o item básico.
        // --------------------------------------------------------
        final Map<String, dynamic> item = {
          'workout_id': workoutId,
          'sets': setsCount,
          'reps': ex['reps']?.toString() ?? '',
          'rest_seconds': restTime,
          'note': ex['note']?.toString() ?? '',
          'is_biset': ex['isBiset'] == true,
          'order_index': i,
        };

        // --------------------------------------------------------
        // EXERCÍCIO DO CATÁLOGO
        // --------------------------------------------------------
        //
        // Quando veio da tabela exercises, salvamos o ID real.
        //
        if (exerciseId != null &&
            exerciseId.toString().trim().isNotEmpty) {
          item['exercise_id'] = exerciseId;
        }

        // --------------------------------------------------------
        // EXERCÍCIO PERSONALIZADO
        // --------------------------------------------------------
        //
        // Quando não existe exercise_id, usamos os campos
        // customizados.
        //
        else {
          final customName = ex['name']?.toString().trim() ?? '';
          final customMediaUrl =
              ex['custom_media_url']?.toString().trim() ?? '';

          if (customName.isNotEmpty) {
            item['custom_exercise_name'] = customName;
          }

          if (customMediaUrl.isNotEmpty) {
            item['custom_media_url'] = customMediaUrl;
          }
        }

        itemsToInsert.add(item);
      }

      // ----------------------------------------------------------
      // 4. Salvar todos os exercícios
      // ----------------------------------------------------------
      if (itemsToInsert.isNotEmpty) {
        await _supabase
            .from('workout_items')
            .insert(itemsToInsert);
      }
    } catch (e) {
      throw Exception('Erro ao salvar treino: $e');
    }
  }
}