import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Meu Perfil', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Foto e Nome
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Vitor Pedro Rodrigues Calixto',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '19 anos • Aluno VIP',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Opções de Menu
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _buildListTile(Icons.person_outline, 'Editar Dados Pessoais'),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildListTile(Icons.lock_outline, 'Privacidade e Senha'),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildListTile(Icons.notifications_none, 'Notificações'),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildListTile(Icons.help_outline, 'Ajuda e Suporte'),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Botão de Sair
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[50], // Fundo vermelho claro
                    foregroundColor: Colors.red,     // Texto vermelho
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    // Lógica de logout futuramente
                  },
                  child: const Text('Sair da Conta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para as linhas do menu
  Widget _buildListTile(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {
        // Navegação futura para a tela específica
      },
    );
  }
}