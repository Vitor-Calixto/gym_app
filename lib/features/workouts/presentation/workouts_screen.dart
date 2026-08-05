// lib/features/workouts/presentation/workouts_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:gymapp/features/workouts/data/workout_repository.dart';

/// ===============================================================
/// TELA DE TREINOS
/// ===============================================================
///
/// Pode ser utilizada por:
///
/// ALUNO:
/// /workouts
///
/// PROFESSOR:
/// /workouts + studentId
///
/// O studentId vem pelo state.extra do GoRouter.
/// ===============================================================

class WorkoutsScreen extends ConsumerStatefulWidget {
  final String? studentId;

  const WorkoutsScreen({
    super.key,
    this.studentId,
  });

  @override
  ConsumerState<WorkoutsScreen> createState() =>
      _WorkoutsScreenState();
}

class _WorkoutsScreenState
    extends ConsumerState<WorkoutsScreen> {
  String? _selectedWorkoutId;

  String? get _effectiveStudentId {
    /// Se o professor abriu um aluno específico,
    /// usamos esse ID.
    if (widget.studentId != null &&
        widget.studentId!.isNotEmpty) {
      return widget.studentId;
    }

    /// Caso contrário, estamos na tela do próprio aluno.
    return Supabase
        .instance
        .client
        .auth
        .currentUser
        ?.id;
  }

  @override
  Widget build(BuildContext context) {
    final studentId =
        _effectiveStudentId;

    if (studentId == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Não foi possível identificar o aluno.',
          ),
        ),
      );
    }

    final workoutsAsync = ref.watch(
      studentWorkoutsProvider(studentId),
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],

      /// ==========================================================
      /// APP BAR
      /// ==========================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        iconTheme:
            const IconThemeData(
          color: Colors.black,
        ),

        title: const Text(
          'Meus Treinos',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,

        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
            ),
            onPressed: () {
              ref.invalidate(
                studentWorkoutsProvider(
                  studentId,
                ),
              );
            },
          ),
        ],
      ),

      /// ==========================================================
      /// BODY
      /// ==========================================================

      body: workoutsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),

        error: (error, stack) =>
            _buildError(error),

        data: (workouts) {
          if (workouts.isEmpty) {
            return _buildEmptyState(
              context,
            );
          }

          /// Se ainda não existe treino selecionado,
          /// selecionamos automaticamente o primeiro.
          if (_selectedWorkoutId == null) {
            _selectedWorkoutId =
                workouts.first['id']
                    ?.toString();
          }

          final selectedWorkout =
              workouts.firstWhere(
            (workout) =>
                workout['id']
                    ?.toString() ==
                _selectedWorkoutId,

            orElse: () => workouts.first,
          );

          final exercises =
              List<Map<String, dynamic>>.from(
            selectedWorkout[
                    'workout_items'] ??
                [],
          );

          return Column(
            children: [
              /// ---------------------------------------------------
              /// SELETOR DE TREINOS
              /// ---------------------------------------------------

              Container(
                color: Colors.white,

                padding:
                    const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 10,
                ),

                child: SizedBox(
                  height: 82,

                  child: ListView.separated(
                    scrollDirection:
                        Axis.horizontal,

                    itemCount:
                        workouts.length,

                    separatorBuilder:
                        (_, __) =>
                            const SizedBox(
                      width: 10,
                    ),

                    itemBuilder:
                        (context, index) {
                      final workout =
                          workouts[index];

                      final id =
                          workout['id']
                              ?.toString();

                      final title =
                          workout['title']
                                  ?.toString() ??
                              'Treino';

                      final focus =
                          workout['focus']
                                  ?.toString() ??
                              '';

                      return _buildWorkoutSelector(
                        id: id,
                        title: title,
                        focus: focus,
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 14),

              /// ---------------------------------------------------
              /// CABEÇALHO
              /// ---------------------------------------------------

              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                ),

                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,

                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [
                          Text(
                            selectedWorkout[
                                    'title']
                                ?.toString() ??
                                'Treino',

                            style:
                                const TextStyle(
                              fontSize: 20,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(
                            height: 4,
                          ),

                          Text(
                            selectedWorkout[
                                    'focus']
                                ?.toString() ??
                                'Treino personalizado',

                            style: TextStyle(
                              color:
                                  Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Text(
                      '${exercises.length} exercícios',
                      style: TextStyle(
                        color:
                            Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              /// ---------------------------------------------------
              /// LISTA
              /// ---------------------------------------------------

              Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),

                  itemCount:
                      exercises.length + 1,

                  itemBuilder:
                      (context, index) {
                    if (index ==
                        exercises.length) {
                      return const SizedBox(
                        height: 100,
                      );
                    }

                    return _buildExerciseCard(
                      exercises[index],
                      index,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),

      /// ==========================================================
      /// BOTÃO INICIAR
      /// ==========================================================

      floatingActionButton:
          workoutsAsync.maybeWhen(
        data: (workouts) {
          if (workouts.isEmpty) {
            return null;
          }

          return FloatingActionButton.extended(
            backgroundColor:
                Colors.black87,

            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Modo treino será iniciado aqui.',
                  ),
                ),
              );
            },

            icon: const Icon(
              Icons.play_arrow,
              color: Colors.white,
            ),

            label: const Text(
              'Iniciar Treino',
              style: TextStyle(
                color: Colors.white,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          );
        },

        orElse: () => null,
      ),

      floatingActionButtonLocation:
          FloatingActionButtonLocation
              .centerFloat,
    );
  }

  /// ===============================================================
  /// SELETOR DE TREINO
  /// ===============================================================

  Widget _buildWorkoutSelector({
    required String? id,
    required String title,
    required String focus,
  }) {
    final selected =
        id == _selectedWorkoutId;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedWorkoutId = id;
        });
      },

      child: Container(
        width: 125,

        padding:
            const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),

        decoration: BoxDecoration(
          color: selected
              ? Colors.black87
              : Colors.white,

          borderRadius:
              BorderRadius.circular(15),

          border: Border.all(
            color: selected
                ? Colors.black87
                : Colors.grey.shade300,
          ),

          boxShadow: selected
              ? [
                  const BoxShadow(
                    color: Colors.black26,
                    blurRadius: 7,
                    offset:
                        Offset(0, 3),
                  ),
                ]
              : null,
        ),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Text(
              title,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,

              style: TextStyle(
                color: selected
                    ? Colors.white
                    : Colors.black87,

                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              focus,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,

              style: TextStyle(
                color: selected
                    ? Colors.white70
                    : Colors.grey,

                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ===============================================================
  /// CARD DO EXERCÍCIO
  /// ===============================================================

  Widget _buildExerciseCard(
    Map<String, dynamic> exercise,
    int index,
  ) {
    final name =
        exercise['custom_exercise_name']
                ?.toString() ??
            'Exercício';

    final sets =
        exercise['sets']?.toString() ??
            '3';

    final reps =
        exercise['reps']?.toString() ??
            '10';

    final rest =
        exercise['rest_seconds']
                ?.toString() ??
            '60';

    final note =
        exercise['note']?.toString();

    final isBiset =
        exercise['is_biset'] == true;

    return Container(
      margin:
          const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(
              alpha: 0.04,
            ),

            blurRadius: 8,

            offset:
                const Offset(0, 3),
          ),
        ],
      ),

      child: Row(
        children: [
          /// Imagem ilustrativa.
          Container(
            width: 66,
            height: 66,

            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(14),

              image:
                  const DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?q=80&w=300&auto=format&fit=crop',
                ),

                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(width: 14),

          /// Informações
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    if (isBiset)
                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),

                        decoration:
                            BoxDecoration(
                          color:
                              Colors.purple[50],
                          borderRadius:
                              BorderRadius
                                  .circular(
                            6,
                          ),
                        ),

                        child: const Text(
                          'BISET',
                          style: TextStyle(
                            color:
                                Colors.purple,
                            fontSize: 9,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 5),

                Text(
                  'Descanso: ${rest}s',
                  style: TextStyle(
                    color:
                        Colors.grey[600],
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 10),

                Wrap(
                  spacing: 7,
                  runSpacing: 5,

                  children: [
                    _tag(
                      '${sets}x $reps',
                      Colors.blue,
                    ),

                    if (note != null &&
                        note.isNotEmpty)
                      _tag(
                        note,
                        Colors.orange,
                      ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 5),

          /// Check do exercício
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.check_circle_outline,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// ===============================================================
  /// TAG
  /// ===============================================================

  Widget _tag(
    String text,
    MaterialColor color,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),

      decoration: BoxDecoration(
        color: color[50],
        borderRadius:
            BorderRadius.circular(7),
      ),

      child: Text(
        text,
        style: TextStyle(
          color: color[700],
          fontSize: 10,
          fontWeight:
              FontWeight.bold,
        ),
      ),
    );
  }

  /// ===============================================================
  /// ESTADO VAZIO
  /// ===============================================================

  Widget _buildEmptyState(
    BuildContext context,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Container(
              width: 120,
              height: 120,

              decoration: BoxDecoration(
                color: Colors.deepPurple[50],
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.fitness_center,
                size: 60,
                color: Colors.deepPurple,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Nenhum treino encontrado',
              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 21,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Quando um professor criar um treino para este aluno, ele aparecerá automaticamente aqui.',
              textAlign: TextAlign.center,

              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            OutlinedButton.icon(
              onPressed: () {
                ref.invalidate(
                  studentWorkoutsProvider(
                    _effectiveStudentId!,
                  ),
                );
              },

              icon: const Icon(
                Icons.refresh,
              ),

              label: const Text(
                'Atualizar',
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ===============================================================
  /// ERRO
  /// ===============================================================

  Widget _buildError(
    Object error,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(24),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red,
            ),

            const SizedBox(height: 15),

            const Text(
              'Não foi possível carregar os treinos.',
              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              error.toString(),
              textAlign: TextAlign.center,

              style: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===============================================================
/// PROVIDER DOS TREINOS
/// ===============================================================

final studentWorkoutsProvider =
    FutureProvider.family<
        List<Map<String, dynamic>>,
        String>((ref, studentId) async {
  final repository =
      ref.read(workoutRepositoryProvider);

  return repository.getStudentWorkouts(
    studentId,
  );
});