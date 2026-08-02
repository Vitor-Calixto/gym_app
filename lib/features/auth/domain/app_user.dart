// lib/features/auth/domain/app_user.dart

class AppUser {
  final String id;
  final String fullName;
  final String role; // 'trainer' ou 'student'
  final String? trainerId; // Será nulo se o usuário for professor ou um aluno sem vínculo

  AppUser({
    required this.id,
    required this.fullName,
    required this.role,
    this.trainerId,
  });

  // Fábrica para converter os dados que vêm do Supabase em um objeto Dart
  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String,
      fullName: map['full_name'] as String,
      role: map['role'] as String,
      trainerId: map['trainer_id'] as String?,
    );
  }
}