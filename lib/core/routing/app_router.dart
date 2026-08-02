// lib/core/routing/app_router.dart
import 'package:go_router/go_router.dart';
import 'package:gymapp/features/home/home_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/home/presentation/home_screen.dart';

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
      path: '/home', // 🔴 Rota adicionada!
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);