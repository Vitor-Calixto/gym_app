// lib/features/home/presentation/home_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Importação necessária para usar o GoRouter de navegação

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Define a cor de fundo padrão da tela um pouco acinzentada para destacar os componentes brancos
      backgroundColor: Colors.grey[100],
      
      // Barra superior do aplicativo (Header) contendo a foto, saudação e botão de saída
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            // Exibe a foto de perfil do usuário em formato circular
            const CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage('https://via.placeholder.com/150'), 
            ),
            const SizedBox(width: 12),
            // Coluna contendo a saudação e o nome do usuário
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Bora treinar! 🔥', style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text('Vitor', style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        // Ações exibidas no canto direito da barra superior (botão de logout)
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.redAccent),
            onPressed: () {
              // TODO: Adicionar lógica de logout e redirecionamento para o login
            },
          ),
        ],
      ),
      
      // Corpo principal com rolagem vertical para se adaptar perfeitamente a telas de celular
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              // --- SEÇÃO 1: LINKS RÁPIDOS ---
              const Text('Acesso Rápido', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              
              // Permite que os ícones de acesso rápido deslizem para o lado caso a tela seja pequena
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    // Cada _buildQuickLink recebe o contexto, ícone, texto e a rota configurada no app_router.dart
                    _buildQuickLink(context, Icons.person, 'Perfil', '/profile'),
                    const SizedBox(width: 16),
                    _buildQuickLink(context, Icons.attach_money, 'Financeiro', '/finance'),
                    const SizedBox(width: 16),
                    _buildQuickLink(context, Icons.people, 'Alunos', '/students'),
                    const SizedBox(width: 16),
                    _buildQuickLink(context, Icons.fitness_center, 'Treinos', '/workouts'),
                    const SizedBox(width: 16),
                    _buildQuickLink(context, Icons.monitor_weight, 'Avaliação', '/assessment'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- SEÇÃO 2: BANNER DINÂMICO DE DESTAQUE ---
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  // Imagem de fundo ilustrativa de treino
                  image: const DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=1470&auto=format&fit=crop'),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
                  ]
                ),
                // Gradiente escuro sobreposto na imagem para garantir a legibilidade do texto branco
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                    ),
                  ),
                  alignment: Alignment.bottomLeft,
                  padding: const EdgeInsets.all(16),
                  child: const Text(
                    'Treino de Hoje:\nMembros Superiores',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- SEÇÃO 3: PAINEL PRINCIPAL EM GRADE (GRID) ---
              const Text('Seu Painel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              
              // Organiza os cards do dashboard em 2 colunas responsivas para dispositivos móveis
              GridView.count(
                crossAxisCount: 2, 
                shrinkWrap: true, 
                physics: const NeverScrollableScrollPhysics(), // Desativa o scroll interno do grid para usar o geral da página
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.3, 
                children: [
                  _buildDashCard('Meus Treinos', 'Ficha A, B, C', Icons.assignment, Colors.blue),
                  _buildDashCard('Progresso', 'Cargas e Histórico', Icons.trending_up, Colors.green),
                  _buildDashCard('Agendamentos', 'Sessões Livres', Icons.calendar_today, Colors.purple),
                  _buildDashCard('Gamificação', 'Ranking do Clan', Icons.emoji_events, Colors.orange),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // WIDGETS AUXILIARES (Funções que retornam componentes reutilizáveis)
  // ==========================================================================

  /// Constrói cada botão circular da barra de Acesso Rápido com suporte a navegação
  Widget _buildQuickLink(BuildContext context, IconData icon, String label, String routePath) {
    return GestureDetector(
      onTap: () {
        // Executa a navegação moderna utilizando o GoRouter configurado no projeto
        context.push(routePath);
      },
      child: Column(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 4, spreadRadius: 1)
              ]
            ),
            child: Icon(icon, color: Colors.black87, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label, 
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Constrói os cards informativos do painel principal (Grid)
  Widget _buildDashCard(String title, String subtitle, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Caixa colorida contendo o ícone representativo do card
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const Spacer(),
          // Título principal do card
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          // Subtítulo descritivo do card
          Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }
}