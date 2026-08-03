// lib/features/workouts/data/workout_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class WorkoutRepository {
  final SupabaseClient _supabase = Supabase.instance.client;


 // Busca exercícios no catálogo do Supabase filtrando por nome
  Future<List<Map<String, dynamic>>> searchExercises(String query) async {
    try {
      final response = await _supabase
          .from('exercises')
          .select()
          .ilike('name', '%$query%') // Busca case-insensitive aproximada
          .limit(20);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Erro ao buscar exercícios: $e');
    }
  }
  
  Future<void> saveWorkout({
    required String title,
    required String focus,
    required String studentId,
    required List<Map<String, dynamic>> exercises,
  }) async {
    try {
      // 1. Pega o ID do professor logado no momento
      final trainerId = _supabase.auth.currentUser!.id;

      // 2. Cria o cabeçalho do Treino e pega o ID gerado
      final workoutResponse = await _supabase.from('workouts').insert({
        'title': title,
        'focus': focus,
        'student_id': studentId,
        'trainer_id': trainerId,
      }).select('id').single();

      final String workoutId = workoutResponse['id'];

      // 3. Prepara a lista de exercícios para salvar de uma vez só (Batch Insert)
      final List<Map<String, dynamic>> itemsToInsert = [];
      
      for (int i = 0; i < exercises.length; i++) {
        final ex = exercises[i];
        
        // Limpa o "s" do descanso para salvar como número (ex: "60s" vira 60)
        final int restTime = int.tryParse(ex['rest'].toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 60;
        final int setsCount = int.tryParse(ex['sets'].toString()) ?? 3;

        itemsToInsert.add({
          'workout_id': workoutId,
          'custom_exercise_name': ex['name'], // Salvando como customizado por enquanto
          'sets': setsCount,
          'reps': ex['reps'],
          'rest_seconds': restTime,
          'note': ex['note'],
          'is_biset': ex['isBiset'],
          'order_index': i, // Salva a ordem exata que o professor organizou na tela
        });
      }

      // 4. Envia todos os exercícios para o banco
      if (itemsToInsert.isNotEmpty) {
        await _supabase.from('workout_items').insert(itemsToInsert);
      }
      
    } catch (e) {
      throw Exception('Erro ao salvar treino: $e');
    }
  }
}