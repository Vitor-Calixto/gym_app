import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymapp/features/auth/domain/auth_controller.dart'; 

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  // Controladores dos campos de texto do cadastro
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _trainerIdController = TextEditingController(); 
  
  String _selectedRole = 'student'; // 'student' (aluno) ou 'trainer' (professor)
  bool _obscurePassword = true;     // Estado do "olhinho" de ver senha

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _trainerIdController.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Observa o estado do AuthController para feedback de sucesso ou erro
    ref.listen<AsyncValue>(
      authControllerProvider,
      (_, state) {
        if (state.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error.toString()), backgroundColor: Colors.red),
          );
        } else if (!state.isLoading && !state.hasError && state.hasValue) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Conta criada com sucesso! Faça login para continuar.'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop(); // Retorna para a tela de login
        }
      },
    );

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Conta - GymApp'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Junte-se ao GymApp',
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
                  validator: (value) => value == null || value.isEmpty ? 'Informe seu nome' : null,
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
                  validator: (value) => value == null || value.isEmpty ? 'Informe um e-mail' : null,
                ),
                const SizedBox(height: 16),

                // Senha com botão de ver/ocultar
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Senha (mínimo 6 caracteres)',
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
                  validator: (value) => value == null || value.length < 6 ? 'A senha deve ter no mínimo 6 caracteres' : null,
                ),
                const SizedBox(height: 16),

                // Seletor de Tipo de Perfil (Aluno ou Professor)
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
                            if (_selectedRole == 'trainer') {
                              _trainerIdController.clear();
                            }
                          });
                        },
                ),
                const SizedBox(height: 16),

                // Campo condicional: Exibido apenas se o perfil selecionado for 'Aluno'
                if (_selectedRole == 'student') ...[
                  TextFormField(
                    controller: _trainerIdController,
                    decoration: const InputDecoration(
                      labelText: 'Código do Professor (Opcional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.qr_code),
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
                          if (_formKey.currentState!.validate()) {
                            ref.read(authControllerProvider.notifier).signUp(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text.trim(),
                                  fullName: _nameController.text.trim(),
                                  role: _selectedRole,
                                  trainerId: _selectedRole == 'student' && _trainerIdController.text.isNotEmpty
                                      ? _trainerIdController.text.trim()
                                      : null,
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
                      : const Text('CADASTRAR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}