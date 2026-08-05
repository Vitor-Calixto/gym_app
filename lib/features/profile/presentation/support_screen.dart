import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajuda e Suporte')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const ExpansionTile(
            title: Text('Como alterar meu treino?'),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Apenas o seu personal trainer pode alterar o seu plano de treino. Entre em contato com ele diretamente pelo aplicativo.'),
              )
            ],
          ),
          const ExpansionTile(
            title: Text('Esqueci minha senha, o que fazer?'),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Você pode alterar sua senha na aba "Privacidade e Senha" no seu perfil. Caso não consiga logar, use a opção "Esqueci minha senha" na tela inicial.'),
              )
            ],
          ),
          const ExpansionTile(
            title: Text('Como funciona a cobrança?'),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Os pagamentos são gerenciados diretamente pelo seu personal ou pela academia. Verifique a aba de Finanças para ver seu status.'),
              )
            ],
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              // Lógica para abrir o WhatsApp ou enviar um E-mail
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Abrindo chat com o suporte...')),
              );
            },
            icon: const Icon(Icons.support_agent),
            label: const Text('FALAR COM UM ATENDENTE'),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          )
        ],
      ),
    );
  }
}