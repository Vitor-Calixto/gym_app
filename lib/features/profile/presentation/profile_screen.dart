import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ==========================================
// 1. PROVIDER REATIVO (STREAM)
// ==========================================
// Escuta o banco de dados em tempo real. Se o usuário alterar a foto ou nome
// em outra tela, esta tela atualizará automaticamente.
final profileStreamProvider = StreamProvider.autoDispose<Map<String, dynamic>>((ref) {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser?.id;

  if (userId == null) {
    return const Stream.empty();
  }

  // Stream da tabela 'profiles' filtrado pelo ID do usuário atual
  return supabase
      .from('profiles')
      .stream(primaryKey: ['id'])
      .eq('id', userId)
      .map((list) => list.first); // Pega a primeira (e única) linha do usuário
});

// ==========================================
// 2. INTERFACE (CONSUMER WIDGET)
// ==========================================
// Trocamos StatelessWidget por ConsumerWidget para acessar o "ref"
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fica assistindo o stream de dados
    final profileAsyncValue = ref.watch(profileStreamProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Meu Perfil', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      // O '.when' lida automaticamente com Carregamento, Erro e Sucesso
      body: profileAsyncValue.when(
        
        // --- ESTADO 1: CARREGANDO ---
        loading: () => const Center(child: CircularProgressIndicator()),
        
        // --- ESTADO 2: ERRO ---
        error: (error, stack) => Center(
          child: Text('Erro ao carregar dados: $error', style: const TextStyle(color: Colors.red)),
        ),
        
        // --- ESTADO 3: DADOS PRONTOS ---
        data: (profileData) {
          // Extração segura dos dados retornados pelo Supabase
          final fullName = profileData['full_name'] as String? ?? 'Usuário';
          final age = profileData['age'] as int? ?? 0;
          final role = profileData['role'] as String? ?? 'student';
          final avatarUrl = profileData['avatar_url'] as String?;

          // Formatação condicional baseada na role
          final roleText = role == 'trainer' ? 'Professor / Personal' : 'Aluno VIP';
          final ageText = age > 0 ? '$age anos • ' : '';

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),
                
                // === FOTO E NOME DINÂMICOS ===
                Center(
                  child: Column(
                    children: [
          // === FOTO E NOME DINÂMICOS ===
CircleAvatar(
  radius: 50,
  backgroundColor: Colors.purple[100],
  // Só carrega se a URL existir, não for vazia E não for um link de placeholder bloqueado
  backgroundImage: avatarUrl != null && 
                   avatarUrl.isNotEmpty && 
                   !avatarUrl.contains('placeholder.com')
      ? NetworkImage(avatarUrl)
      : null,
  child: avatarUrl == null || 
         avatarUrl.isEmpty || 
         avatarUrl.contains('placeholder.com')
      ? const Icon(Icons.person, size: 50, color: Colors.white)
      : null,
),
                      const SizedBox(height: 16),
                      Text(
                        fullName,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$ageText$roleText',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // === MENU DE OPÇÕES ===
                Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      _buildListTile(context, Icons.person_outline, 'Editar Dados Pessoais', '/profile-edit'),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      _buildListTile(context, Icons.lock_outline, 'Privacidade e Senha', '/privacy'),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      _buildListTile(context, Icons.notifications_none, 'Notificações', '/notifications'),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      _buildListTile(context, Icons.help_outline, 'Ajuda e Suporte', '/support'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // === BOTÃO DE SAIR ===
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[50],
                        foregroundColor: Colors.red,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        try {
                          await Supabase.instance.client.auth.signOut();
                          if (context.mounted) {
                            context.go('/login');
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Erro ao sair da conta.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('Sair da Conta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  // === WIDGET AUXILIAR DO MENU ===
  Widget _buildListTile(BuildContext context, IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {
        context.push(route);
      },
    );
  }
}