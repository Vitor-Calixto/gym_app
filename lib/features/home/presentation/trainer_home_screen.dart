import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymapp/features/auth/domain/auth_controller.dart';

// Provider para escutar os dados do perfil em tempo real (caso já não tenha criado globalmente)
final userProfileProvider = StreamProvider.autoDispose<Map<String, dynamic>>((ref) {
  // Certifique-se de ajustar conforme o arquivo de providers do seu projeto
  // ignore: 
  return Stream.empty(); 
});

class TrainerHomeScreen extends ConsumerWidget {
  const TrainerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuta os dados do professor logado (nome, avatar, etc.)
    // Se preferir usar o stream direto, substitua pelo seu provider de perfil
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Painel do Professor', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.purple.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair da Conta',
            onPressed: () async {
              // Executa o logout e redireciona para a tela de login
              await ref.read(authControllerProvider.notifier).signOut();
              if (!context.mounted) return;
              context.go('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. CABEÇALHO VIBRANTE COM GRADIENTE E PERFIL
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade800, Colors.deepPurple.shade400],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Avatar Dinâmico
                  profileAsync.when(
                    data: (profile) {
                      final avatarUrl = profile['avatar_url'] as String?;
                      return CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.white,
                        backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                            ? NetworkImage(avatarUrl)
                            : null,
                        child: avatarUrl == null || avatarUrl.isEmpty
                            ? const Icon(Icons.person, size: 32, color: Colors.purple)
                            : null,
                      );
                    },
                    loading: () => const CircleAvatar(radius: 32, backgroundColor: Colors.white24),
                    error: (_, __) => const CircleAvatar(radius: 32, backgroundColor: Colors.white24, child: Icon(Icons.error, color: Colors.white)),
                  ),
                  const SizedBox(width: 16),
                  
                  // Saudação e Nome
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bem-vindo de volta,',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        profileAsync.when(
                          data: (profile) => Text(
                            profile['full_name'] ?? 'Professor',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          loading: () => const Text('Carregando...', style: TextStyle(color: Colors.white, fontSize: 18)),
                          error: (_, __) => const Text('Professor', style: TextStyle(color: Colors.white, fontSize: 20)),
                        ),
                      ],
                    ),
                  ),
                  
                  // Botão de Editar Perfil Rápido
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white70),
                    onPressed: () => context.push('/profile-edit'),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),

            // 2. BANNER DE DESTAQUE COM FOTO DE TREINO (Vibrante)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=1000&auto=format&fit=crop'),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.bottomLeft,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Foco na Alta Performance ⚡',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Gerencie seus alunos e potencialize resultados.',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 3. SEÇÃO DE GERENCIAMENTO (Ações Rápidas)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: const Text(
                'Gerenciamento',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.3,
                children: [
                  _buildActionCard(
                    context,
                    title: 'Meus Alunos',
                    subtitle: 'Acompanhar cadastros',
                    icon: Icons.group,
                    color: Colors.blue,
                    onTap: () {
                      // TODO: Navegar para lista de alunos
                    },
                  ),
                  _buildActionCard(
                    context,
                    title: 'Fichas de Treino',
                    subtitle: 'Montar e editar treinos',
                    icon: Icons.fitness_center,
                    color: Colors.purple,
                    onTap: () {
                      // TODO: Navegar para fichas
                    },
                  ),
                  _buildActionCard(
                    context,
                    title: 'Avaliações',
                    subtitle: 'Medidas e histórico',
                    icon: Icons.monitor_weight,
                    color: Colors.orange,
                    onTap: () {
                      // TODO: Navegar para avaliações
                    },
                  ),
                  _buildActionCard(
                    context,
                    title: 'Relatórios',
                    subtitle: 'Estatísticas gerais',
                    icon: Icons.bar_chart,
                    color: Colors.green,
                    onTap: () {
                      // TODO: Navegar para relatórios
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para desenhar os cards de ação do grid
  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[600], fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}