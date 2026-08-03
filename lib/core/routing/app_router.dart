// lib/core/routing/app_router.dart
import 'package:go_router/go_router.dart';
import 'package:gymapp/features/auth/presentation/login_screen.dart';
import 'package:gymapp/features/auth/presentation/signup_screen.dart';
import 'package:gymapp/features/dashboard/presentation/professor_dashboard_screen.dart';
import 'package:gymapp/features/home/presentation/home_screen.dart';
import 'package:gymapp/features/profile/presentation/profile_screen.dart';
import 'package:gymapp/features/finance/presentation/finance_screen.dart';
import 'package:gymapp/features/students/presentation/students_screen.dart';
import 'package:gymapp/features/workouts/presentation/workouts_screen.dart';
import 'package:gymapp/features/assessment/presentation/assessment_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/professor-home',
      builder: (context, state) => const ProfessorDashboardScreen(),
    ),
    // Novas rotas das funcionalidades
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/finance',
      builder: (context, state) => const FinanceScreen(),
    ),
    GoRoute(
      path: '/students',
      builder: (context, state) => const StudentsScreen(),
    ),
    GoRoute(
      path: '/workouts',
      builder: (context, state) => const WorkoutsScreen(),
    ),
    GoRoute(
      path: '/assessment',
      builder: (context, state) => const AssessmentScreen(),
    ),
  ],
);