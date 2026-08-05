import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _avatarUrlController = TextEditingController();
  
  bool _isLoading = false;
  bool _isFetching = true;
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  // Carrega os dados atuais do usuário para preencher os campos automaticamente
  Future<void> _loadUserData() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final data = await _supabase
            .from('profiles')
            .select('full_name, age, avatar_url')
            .eq('id', user.id)
            .maybeSingle();

        if (data != null) {
          _nameController.text = data['full_name'] ?? '';
          _ageController.text = data['age']?.toString() ?? '';
          _avatarUrlController.text = data['avatar_url'] ?? '';
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar perfil: $e');
    } finally {
      if (mounted) setState(() => _isFetching = false);
    }
  }

  // Atualiza os dados no Supabase
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        await _supabase.from('profiles').update({
          'full_name': _nameController.text.trim(),
          'age': int.tryParse(_ageController.text.trim()),
          'avatar_url': _avatarUrlController.text.trim().isEmpty ? null : _avatarUrlController.text.trim(),
        }).eq('id', user.id);

        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil atualizado com sucesso!'), 
            backgroundColor: Colors.green
          ),
        );
        context.pop(); // Volta para a tela anterior
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar: $e'), 
          backgroundColor: Colors.red
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Dados Pessoais')),
      body: _isFetching
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Preview do Avatar
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                        CircleAvatar(
  radius: 50,
  backgroundColor: Colors.purple.shade100,
  backgroundImage: _avatarUrlController.text.trim().isNotEmpty
      ? NetworkImage(_avatarUrlController.text.trim())
      : null,
  // CORREÇÃO: onBackgroundImageError agora fica nulo se não houver imagem, evitando o crash!
  onBackgroundImageError: _avatarUrlController.text.trim().isNotEmpty
      ? (error, stackTrace) {
          debugPrint('Erro ao carregar a imagem do avatar: $error');
        }
      : null,
  child: _avatarUrlController.text.trim().isEmpty
      ? const Icon(Icons.person, size: 50, color: Colors.purple)
      : null,
),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Campo URL da Imagem
                    TextFormField(
                      controller: _avatarUrlController,
                      decoration: const InputDecoration(
                        labelText: 'URL da Imagem do Perfil',
                        hintText: 'https://exemplo.com/foto.jpg',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.image),
                      ),
                      onChanged: (val) => setState(() {}), // Atualiza o preview do avatar em tempo real
                    ),
                    const SizedBox(height: 16),

                    // Campo Nome Completo
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome Completo',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Informe seu nome' : null,
                    ),
                    const SizedBox(height: 16),

                    // Campo Idade
                    TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Idade',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.cake),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Botão Salvar
                    ElevatedButton(
                      onPressed: _isLoading ? null : _updateProfile,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading 
                          ? const SizedBox(
                              height: 20, 
                              width: 20, 
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            ) 
                          : const Text(
                              'SALVAR ALTERAÇÕES', 
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}