// lib/features/home/presentation/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:gymapp/features/auth/domain/auth_controller.dart';
import 'package:gymapp/features/workouts/data/workout_repository.dart';

/// ===============================================================
/// HOME DO ALUNO
/// ===============================================================
///
/// Mostra:
/// - Nome real
/// - Avatar real
/// - Próximo treino
/// - Quantidade de treinos
/// - Lista de treinos
/// - Estado vazio quando não há treino
/// ===============================================================

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Usuário não autenticado.'),
        ),
      );
    }

    final workoutsAsync = ref.watch(
      studentWorkoutsProvider(user.id),
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],

      /// ==========================================================
      /// APP BAR
      /// ==========================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        title: profileAsync.when(
          loading: () => const Text('Carregando...'),

          error: (_, __) => const Text('Olá!'),

          data: (profile) {
            final name =
                profile['full_name']?.toString() ?? 'Aluno';

            final avatar =
                profile['avatar_url']?.toString();

            return Row(
              children: [
                CircleAvatar(
                  radius: 21,
                  backgroundColor: Colors.deepPurple.shade100,

                  backgroundImage:
                      avatar != null && avatar.isNotEmpty
                          ? NetworkImage(avatar)
                          : null,

                  child: avatar == null || avatar.isEmpty
                      ? const Icon(Icons.person)
                      : null,
                ),

                const SizedBox(width: 12),

                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bora treinar! 🔥',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),

                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),

        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none,
              color: Colors.black87,
            ),
            onPressed: () {
              context.push('/notifications');
            },
          ),

          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();

              if (!context.mounted) return;

              context.go('/login');
            },
          ),
        ],
      ),

      /// ==========================================================
      /// BODY
      /// ==========================================================

      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(
            studentWorkoutsProvider(user.id),
          );
        },

        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              /// ---------------------------------------------------
              /// ACESSO RÁPIDO
              /// ---------------------------------------------------

              const Text(
                'Acesso Rápido',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,

                child: Row(
                  children: [
                    _quickLink(
                      context,
                      Icons.person,
                      'Perfil',
                      '/profile',
                    ),

                    _quickLink(
                      context,
                      Icons.fitness_center,
                      'Treinos',
                      '/workouts',
                    ),

                    _quickLink(
                      context,
                      Icons.monitor_weight,
                      'Avaliação',
                      '/assessment',
                    ),

                    _quickLink(
                      context,
                      Icons.notifications,
                      'Avisos',
                      '/notifications',
                    ),

                    _quickLink(
                      context,
                      Icons.help_outline,
                      'Suporte',
                      '/support',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              /// ---------------------------------------------------
              /// TREINO ATUAL
              /// ---------------------------------------------------

              workoutsAsync.when(
                loading: () => _loadingWorkoutBanner(),

                error: (error, _) => _errorCard(
                  'Não foi possível carregar seus treinos.',
                ),

                data: (workouts) {
                  if (workouts.isEmpty) {
                    return _emptyWorkoutBanner(
                      context,
                    );
                  }

                  final workout = workouts.first;

                  final title =
                      workout['title']?.toString() ??
                          'Treino';

                  final focus =
                      workout['focus']?.toString() ??
                          'Treino personalizado';

                  final items =
                      List<Map<String, dynamic>>.from(
                    workout['workout_items'] ?? [],
                  );

                  return _buildWorkoutBanner(
                    context,
                    title: title,
                    focus: focus,
                    exercises: items.length,
                    studentId: user.id,
                  );
                },
              ),

              const SizedBox(height: 24),

              /// ---------------------------------------------------
              /// MEUS TREINOS
              /// ---------------------------------------------------

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,

                children: [
                  const Text(
                    'Meus Treinos',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      context.push('/workouts');
                    },
                    child: const Text('Ver todos'),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              workoutsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),

                error: (error, _) => _errorCard(
                  'Erro ao carregar treinos.',
                ),

                data: (workouts) {
                  if (workouts.isEmpty) {
                    return _emptyList();
                  }

                  return Column(
                    children: workouts
                        .take(3)
                        .map(
                          (workout) => _workoutCard(
                            context,
                            workout,
                            user.id,
                          ),
                        )
                        .toList(),
                  );
                },
              ),

              const SizedBox(height: 24),

              /// ---------------------------------------------------
              /// PAINEL
              /// ---------------------------------------------------

              const Text(
                'Seu Painel',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              workoutsAsync.when(
                loading: () => const SizedBox(),

                error: (_, __) => const SizedBox(),

                data: (workouts) {
                  return GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.35,

                    children: [
                      _dashboardCard(
                        'Treinos',
                        '${workouts.length}',
                        Icons.fitness_center,
                        Colors.blue,
                      ),

                      _dashboardCard(
                        'Exercícios',
                        _countExercises(workouts)
                            .toString(),
                        Icons.list_alt,
                        Colors.green,
                      ),

                      _dashboardCard(
                        'Avaliações',
                        'Consultar',
                        Icons.monitor_weight,
                        Colors.orange,
                        onTap: () =>
                            context.push('/assessment'),
                      ),

                      _dashboardCard(
                        'Perfil',
                        'Ver dados',
                        Icons.person,
                        Colors.purple,
                        onTap: () =>
                            context.push('/profile'),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ===============================================================
  /// ACESSO RÁPIDO
  /// ===============================================================

  Widget _quickLink(
    BuildContext context,
    IconData icon,
    String title,
    String route,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 14),

      child: InkWell(
        onTap: () => context.push(route),

        borderRadius: BorderRadius.circular(40),

        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,

              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: 0.06,
                    ),
                    blurRadius: 8,
                  ),
                ],
              ),

              child: Icon(
                icon,
                size: 26,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ===============================================================
  /// BANNER DO TREINO
  /// ===============================================================

  Widget _buildWorkoutBanner(
    BuildContext context, {
    required String title,
    required String focus,
    required int exercises,
    required String studentId,
  }) {
    return Container(
      height: 190,
      width: double.infinity,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),

        image: const DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=1400&auto=format&fit=crop',
          ),
          fit: BoxFit.cover,
        ),
      ),

      child: Container(
        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),

          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,

            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.9),
            ],
          ),
        ),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.end,

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            const Text(
              'TREINO ATUAL 🔥',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              '$focus • $exercises exercícios',
              style: const TextStyle(
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                context.push(
                  '/workouts',
                  extra: studentId,
                );
              },
              child: const Text(
                'Ver treino',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyWorkoutBanner(
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        children: [
          const Icon(
            Icons.fitness_center,
            size: 52,
            color: Colors.grey,
          ),

          const SizedBox(height: 12),

          const Text(
            'Você ainda não possui treinos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Quando seu professor montar um treino, ele aparecerá aqui.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 14),

          OutlinedButton(
            onPressed: () =>
                context.push('/support'),
            child: const Text('Ajuda'),
          ),
        ],
      ),
    );
  }

  Widget _loadingWorkoutBanner() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _workoutCard(
    BuildContext context,
    Map<String, dynamic> workout,
    String studentId,
  ) {
    final title =
        workout['title']?.toString() ??
            'Treino';

    final focus =
        workout['focus']?.toString() ??
            'Treino';

    final items =
        List<Map<String, dynamic>>.from(
      workout['workout_items'] ?? [],
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),

      child: ListTile(
        contentPadding:
            const EdgeInsets.all(12),

        leading: Container(
          width: 54,
          height: 54,

          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(12),

            image: const DecorationImage(
              image: NetworkImage(
                'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?q=80&w=300&auto=format&fit=crop',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),

        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Text(
          '$focus • ${items.length} exercícios',
        ),

        trailing: const Icon(
          Icons.chevron_right,
        ),

        onTap: () {
          context.push(
            '/workouts',
            extra: studentId,
          );
        },
      ),
    );
  }

  Widget _dashboardCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,

      borderRadius:
          BorderRadius.circular(16),

      child: Container(
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(16),
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),

            const Spacer(),

            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorCard(String text) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),

      child: Text(
        text,
        style: const TextStyle(
          color: Colors.red,
        ),
      ),
    );
  }

  Widget _emptyList() {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Center(
        child: Text(
          'Nenhum treino cadastrado ainda.',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  int _countExercises(
    List<Map<String, dynamic>> workouts,
  ) {
    int total = 0;

    for (final workout in workouts) {
      final items =
          List<Map<String, dynamic>>.from(
        workout['workout_items'] ?? [],
      );

      total += items.length;
    }

    return total;
  }
}

/// ===============================================================
/// PROVIDER DOS TREINOS DO ALUNO
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