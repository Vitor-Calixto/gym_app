import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gymapp/features/auth/domain/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Chaves e controladores para gerenciar o formulário e os inputs
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Variável de estado para controlar a visibilidade da senha (o "olhinho")
  bool _obscurePassword = true;

  @override
  void dispose() {
    // Boa prática: limpar os controladores da memória ao sair da tela
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Traduz os erros retornados pelo Supabase para mensagens amigáveis em português
  String _getFriendlyErrorMessage(String error) {
    if (error.contains('invalid_credentials') || error.contains('Invalid login credentials')) {
      return 'E-mail ou senha incorretos.';
    } else if (error.contains('user_already_exists')) {
      return 'Este e-mail já está cadastrado.';
    } else if (error.contains('invalid-email')) {
      return 'Formato de e-mail inválido.';
    }
    return 'Ocorreu um erro inesperado. Tente novamente.';
  }

  // Caixa de diálogo (Pop-up) para recuperação de senha
  void _showResetPasswordDialog() {
    final resetEmailController = TextEditingController(text: _emailController.text);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Recuperar Senha'),
          content: TextField(
            controller: resetEmailController,
            decoration: const InputDecoration(
              labelText: 'Digite seu e-mail cadastrado',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = resetEmailController.text.trim();
                if (email.isNotEmpty) {
                  // Fecha o pop-up ANTES da chamada assíncrona
                  Navigator.pop(context); 
                  
                  try {
                    await Supabase.instance.client.auth.resetPasswordForEmail(email);
                    
                    // CORREÇÃO: Early return se o widget tiver sido desmontado
                    if (!context.mounted) return;
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('E-mail de recuperação enviado! Verifique sua caixa de entrada.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    // CORREÇÃO: Early return também no bloco de erro
                    if (!context.mounted) return;
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao enviar e-mail: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Enviar Link'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Escuta o estado global de autenticação via Riverpod para redirecionamentos e erros
    ref.listen(
      authControllerProvider,
      (previous, next) {
        if (next.hasError) {
          final errorMessage = _getFriendlyErrorMessage(next.error.toString());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
          );
          return;
        }

        // Se o login for bem-sucedido e não estiver carregando, redireciona o usuário
        if (!next.isLoading && !next.hasError && next.hasValue) {
          final String? role = next.asData?.value as String?;
          if (role == 'trainer') {
            context.go('/professor-home');
          } else {
            context.go('/home'); // Aluno como padrão caso a role venha nula
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
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.fitness_center, size: 80, color: Theme.of(context).primaryColor),
                const SizedBox(height: 24),
                const Text(
                  'Gymapp',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 48),
                
                // Campo de E-mail
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
                
                // Campo de Senha com o botão de alternar visibilidade (olhinho)
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  enabled: !isLoading,
                  validator: (value) => value == null || value.isEmpty ? 'Informe sua senha' : null,
                ),
                
                // Botão de Esqueci a Senha
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: isLoading ? null : _showResetPasswordDialog,
                    child: const Text('Esqueci minha senha'),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Botão de Entrar
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
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('ENTRAR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
                
                // Link para ir à tela de Cadastro
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