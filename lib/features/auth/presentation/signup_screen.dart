// lib/features/auth/presentation/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// No topo do login_screen.dart e do signup_screen.dart:

import '../domain/auth_controller.dart'; // 👈 Certifique-se de que o caminho é este!

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _trainerIdController = TextEditingController(); // 🔴 Adicionado o controller do código
  
  String _selectedRole = 'student'; // Padrão como Aluno

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _trainerIdController.dispose(); // 🔴 Não esqueça de descartar aqui
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Escuta o estado para tratar erros ou sucesso no cadastro
    ref.listen<AsyncValue>(
      authControllerProvider,
      (_, state) {
        if (state.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error.toString()),
              backgroundColor: Colors.red,
            ),
          );
        } else if (!state.isLoading && !state.hasError && state.hasValue) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Conta criada com sucesso! Faça login para continuar.'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop(); // Volta para a tela de login
        }
      },
    );

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Conta - FitClan'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Junte-se ao FitClan',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              // Nome Completo
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome Completo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                enabled: !isLoading,
              ),
              const SizedBox(height: 16),

              // E-mail
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                enabled: !isLoading,
              ),
              const SizedBox(height: 16),

              // Senha
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                enabled: !isLoading,
              ),
              const SizedBox(height: 16),

              // Seletor de Perfil (Aluno ou Professor)
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Perfil',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                ),
                items: const [
                  DropdownMenuItem(value: 'student', child: Text('Aluno')),
                  DropdownMenuItem(value: 'trainer', child: Text('Professor / Personal')),
                ],
                onChanged: isLoading
                    ? null
                    : (value) {
                        setState(() {
                          _selectedRole = value!;
                          // Limpa o código se mudar de ideia e virar professor
                          if (_selectedRole == 'trainer') {
                            _trainerIdController.clear();
                          }
                        });
                      },
              ),
              const SizedBox(height: 16),

              // 🔴 Campo Condicional: Só aparece se for Aluno
              if (_selectedRole == 'student') ...[
                TextFormField(
                  controller: _trainerIdController,
                  decoration: const InputDecoration(
                    labelText: 'Código do Professor (Opcional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.qr_code), // Um ícone legal para o código
                    helperText: 'Peça o código de convite ao seu personal.',
                  ),
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
              ],
              
              const SizedBox(height: 8),

              // Botão de Cadastrar
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        // 🔴 Aqui enviamos o trainerId se ele existir e for aluno
                        ref.read(authControllerProvider.notifier).signUp(
                              email: _emailController.text.trim(),
                              password: _passwordController.text.trim(),
                              fullName: _nameController.text.trim(),
                              role: _selectedRole,
                              trainerId: _selectedRole == 'student' && _trainerIdController.text.isNotEmpty
                                  ? _trainerIdController.text.trim()
                                  : null,
                            );
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('CADASTRAR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}