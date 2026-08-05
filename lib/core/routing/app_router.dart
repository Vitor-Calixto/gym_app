// lib/core/routing/app_router.dart

import 'package:go_router/go_router.dart';

import 'package:gymapp/features/auth/presentation/login_screen.dart';
import 'package:gymapp/features/auth/presentation/signup_screen.dart';

import 'package:gymapp/features/home/presentation/home_screen.dart';
import 'package:gymapp/features/home/presentation/trainer_home_screen.dart';

import 'package:gymapp/features/dashboard/presentation/professor_dashboard_screen.dart';

import 'package:gymapp/features/profile/presentation/profile_screen.dart';
import 'package:gymapp/features/profile/presentation/profile_edit_screen.dart';
import 'package:gymapp/features/profile/presentation/privacy_password_screen.dart';
import 'package:gymapp/features/profile/presentation/notifications_screen.dart';
import 'package:gymapp/features/profile/presentation/support_screen.dart';

import 'package:gymapp/features/finance/presentation/finance_screen.dart';
import 'package:gymapp/features/students/presentation/students_screen.dart';

import 'package:gymapp/features/workouts/presentation/workouts_screen.dart';
import 'package:gymapp/features/assessment/presentation/assessment_screen.dart';

/// ===============================================================
/// ROTAS DO APLICATIVO
/// ===============================================================

final appRouter = GoRouter(
  initialLocation: '/login',

  routes: [
    /// ===========================================================
    /// AUTH
    /// ===========================================================

    GoRoute(
      path: '/login',
      builder: (context, state) =>
          const LoginScreen(),
    ),

    GoRoute(
      path: '/signup',
      builder: (context, state) =>
          const SignUpScreen(),
    ),

    /// ===========================================================
    /// HOME ALUNO
    /// ===========================================================

    GoRoute(
      path: '/home',
      builder: (context, state) =>
          const HomeScreen(),
    ),

    /// ===========================================================
    /// HOME PROFESSOR
    /// ===========================================================

    GoRoute(
      path: '/professor-home',
      builder: (context, state) =>
          const TrainerHomeScreen(),
    ),

    /// ===========================================================
    /// DASHBOARD PROFESSOR
    /// ===========================================================

    GoRoute(
      path: '/professor-dashboard',
      builder: (context, state) =>
          const ProfessorDashboardScreen(),
    ),

    /// ===========================================================
    /// PERFIL
    /// ===========================================================

    GoRoute(
      path: '/profile',
      builder: (context, state) =>
          const ProfileScreen(),
    ),

    GoRoute(
      path: '/profile-edit',
      builder: (context, state) =>
          const ProfileEditScreen(),
    ),

    GoRoute(
      path: '/privacy',
      builder: (context, state) =>
          const PrivacyPasswordScreen(),
    ),

    GoRoute(
      path: '/notifications',
      builder: (context, state) =>
          const NotificationsScreen(),
    ),

    GoRoute(
      path: '/support',
      builder: (context, state) =>
          const SupportScreen(),
    ),

    /// ===========================================================
    /// FINANCEIRO
    /// ===========================================================

    GoRoute(
      path: '/finance',
      builder: (context, state) =>
          const FinanceScreen(),
    ),

    /// ===========================================================
    /// ALUNOS
    /// ===========================================================

    GoRoute(
      path: '/students',
      builder: (context, state) =>
          const StudentsScreen(),
    ),

    /// ===========================================================
    /// TREINOS
    /// ===========================================================
    ///
    /// Pode receber:
    ///
    /// context.push('/workouts');
    ///
    /// ou:
    ///
    /// context.push('/workouts', extra: studentId);
    ///
    /// ===========================================================

    GoRoute(
      path: '/workouts',

      builder: (context, state) {
        final studentId =
            state.extra as String?;

        return WorkoutsScreen(
          studentId: studentId,
        );
      },
    ),

    /// ===========================================================
    /// AVALIAÇÃO
    /// ===========================================================

    GoRoute(
      path: '/assessment',

      builder: (context, state) {
        final studentId =
            state.extra as String?;

        return AssessmentScreen(
          studentId: studentId,
        );
      },
    ),
  ],
);