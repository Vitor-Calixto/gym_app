import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PrivacyPasswordScreen extends StatefulWidget {
  const PrivacyPasswordScreen({super.key});

  @override
  State<PrivacyPasswordScreen> createState() => _PrivacyPasswordScreenState();
}

class _PrivacyPasswordScreenState extends State<PrivacyPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null || user.email == null) {
        throw Exception('Usuário não autenticado.');
      }

      // 1. Reautentica o usuário com a senha atual. 
      // Isso prova para o Supabase que o dono da conta está autorizando a mudança.
      await supabase.auth.signInWithPassword(
        email: user.email!,
        password: _currentPasswordController.text.trim(),
      );

      // 2. Com a sessão renovada e verificada, envia a nova senha.
      await supabase.auth.updateUser(
        UserAttributes(password: _newPasswordController.text.trim()),
      );

      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Senha atualizada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Volta para a tela anterior

    } on AuthException catch (e) {
      if (!context.mounted) return;
      
      // Traduz o erro caso a senha atual digitada esteja errada
      String errorMsg = e.message;
      if (e.message.contains('Invalid login credentials')) {
        errorMsg = 'A senha atual está incorreta.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $errorMsg'), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro inesperado: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacidade e Senha'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Atualizar Senha',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Para sua segurança, informe sua senha atual antes de definir uma nova.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Campo Senha Atual
              TextFormField(
                controller: _currentPasswordController,
                obscureText: _obscureCurrent,
                decoration: InputDecoration(
                  labelText: 'Senha Atual',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureCurrent ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Informe a senha atual' : null,
              ),
              const SizedBox(height: 16),

              // Campo Nova Senha
              TextFormField(
                controller: _newPasswordController,
                obscureText: _obscureNew,
                decoration: InputDecoration(
                  labelText: 'Nova Senha (Mínimo 6 caracteres)',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureNew ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Informe a nova senha';
                  if (val.length < 6) return 'A senha deve ter pelo menos 6 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Botão Atualizar
              ElevatedButton(
                onPressed: _isLoading ? null : _updatePassword,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20, 
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'ATUALIZAR SENHA',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}