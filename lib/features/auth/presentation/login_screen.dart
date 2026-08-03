import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>(); // Chave de validação
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(
      authControllerProvider,
      (previous, next) async {
        if (next.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.error.toString()),
              backgroundColor: Colors.red,
            ),
          );
        } else if (!next.isLoading && !next.hasError && previous?.isLoading == true) {
          // Busca o perfil do usuário logado para verificar o cargo
          final user = Supabase.instance.client.auth.currentUser;
          if (user != null) {
            try {
              final response = await Supabase.instance.client
                  .from('profiles')
                  .select('role')
                  .eq('id', user.id)
                  .single();

              final role = response['role'];

              if (!context.mounted) return;

              if (role == 'professor' || role == 'personal') {
                context.go('/professor-home');
              } else {
                context.go('/home');
              }
            } catch (_) {
              if (!context.mounted) return;
              context.go('/home'); // Fallback padrão caso dê erro na consulta
            }
          }
        }
      },
    );

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey, // Envolvendo os campos no Form
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.fitness_center, size: 80, color: Theme.of(context).primaryColor),
                const SizedBox(height: 24),
                const Text(
                  'GymApp',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 48),
                
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
                  validator: (value) => value == null || value.isEmpty ? 'Informe seu e-mail' : null,
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
                  validator: (value) => value == null || value.isEmpty ? 'Informe sua senha' : null,
                ),
                const SizedBox(height: 24),
                
                // Botão Entrar
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            ref.read(authControllerProvider.notifier).signIn(
                                  _emailController.text.trim(),
                                  _passwordController.text.trim(),
                                );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text('ENTRAR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                
                const SizedBox(height: 16),
                TextButton(
                  onPressed: isLoading ? null : () => context.push('/signup'),
                  child: const Text('Não tem uma conta? Cadastre-se'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}