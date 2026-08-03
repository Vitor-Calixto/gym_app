// lib/features/workouts/presentation/workout_builder_screen.dart
import 'package:flutter/material.dart';
import '../data/workout_repository.dart';

class WorkoutBuilderScreen extends StatefulWidget {
  final String studentId;
  final String studentName;

  const WorkoutBuilderScreen({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  @override
  State<WorkoutBuilderScreen> createState() => _WorkoutBuilderScreenState();
}

class _WorkoutBuilderScreenState extends State<WorkoutBuilderScreen> {
  final _repository = WorkoutRepository();
  final _titleController = TextEditingController();
  
  bool _isLoading = false;
  String _selectedFocus = 'Hipertrofia';

  // Lista inicial limpa ou com estrutura padrão
  final List<Map<String, dynamic>> _selectedExercises = [
    {
      'name': 'Supino Reto com Barra',
      'sets': '4',
      'reps': '10-12',
      'rest': '60s',
      'note': '',
      'isBiset': false,
    },
    {
      'name': 'Crucifixo no Crossover',
      'sets': '3',
      'reps': '12',
      'rest': '45s',
      'note': 'Focar no pico de contração',
      'isBiset': true,
    },
  ];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Montar Ficha do Aluno', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // ==========================================
          // 1. CABEÇALHO DO TREINO (Título, Aluno, Foco)
          // ==========================================
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título do Treino (Ex: Treino A - Peito)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Exibição limpa do Aluno utilizando os dados passados por parâmetro
                    Expanded(
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Aluno',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        ),
                        child: Text(
                          widget.studentName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Dropdown de Foco funcional
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedFocus,
                        decoration: const InputDecoration(
                          labelText: 'Foco',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Hipertrofia', child: Text('Hipertrofia')),
                          DropdownMenuItem(value: 'Emagrecimento', child: Text('Emagrecimento')),
                          DropdownMenuItem(value: 'Força', child: Text('Força')),
                          DropdownMenuItem(value: 'Resistência', child: Text('Resistência')),
                        ],
                        onChanged: (value) {
                          if (value != null) setState(() => _selectedFocus = value);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8), 

          // ==========================================
          // 2. LISTA REORDENÁVEL DE EXERCÍCIOS
          // ==========================================
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _selectedExercises.length,
              onReorderItem: (oldIndex, newIndex) {
                setState(() {
                  // O onReorderItem já calcula o índice corrigido automaticamente!
                  final item = _selectedExercises.removeAt(oldIndex);
                  _selectedExercises.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final ex = _selectedExercises[index];
                return Card(
                  key: ValueKey('${ex['name']}_$index'), // Correção na chave para evitar conflito de string
                  // ... restante dos widgets do card ...
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: ex['isBiset'] ? Colors.orange.shade300 : Colors.grey.shade300,
                      width: ex['isBiset'] ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.drag_handle, color: Colors.grey),
                            const SizedBox(width: 8),
                            Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.fitness_center, color: Colors.deepPurple, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ex['name'],
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  if (ex['isBiset'])
                                    const Text('🔗 Bi-set com o próximo', style: TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.redAccent, size: 20),
                              onPressed: () => setState(() => _selectedExercises.removeAt(index)),
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildMiniInput('Séries', index, 'sets')),
                            const SizedBox(width: 8),
                            Expanded(child: _buildMiniInput('Reps', index, 'reps')),
                            const SizedBox(width: 8),
                            Expanded(child: _buildMiniInput('Pausa', index, 'rest')),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              onPressed: () => _editNoteDialog(context, index),
                              icon: const Icon(Icons.chat_bubble_outline, size: 16),
                              label: Text(ex['note'].toString().isEmpty ? 'Adicionar nota' : 'Editar nota', style: const TextStyle(fontSize: 12)),
                            ),
                            IconButton(
                              icon: Icon(Icons.link, color: ex['isBiset'] ? Colors.orange : Colors.grey),
                              tooltip: 'Alternar Bi-set',
                              onPressed: () => setState(() => ex['isBiset'] = !ex['isBiset']),
                            )
                          ],
                        ),
                        if (ex['note'].toString().isNotEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.only(top: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber.shade200),
                            ),
                            child: Text('Obs: ${ex['note']}', style: TextStyle(fontSize: 12, color: Colors.amber.shade900)),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ==========================================
          // 3. BOTÃO ADICIONAR NOVO EXERCÍCIO
          // ==========================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: OutlinedButton.icon(
              onPressed: () => _showExercisePicker(context),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.add),
              label: const Text('ADICIONAR EXERCÍCIO', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),

      // ==========================================
      // 4. RODAPÉ FIXO: BOTÃO SALVAR NO BANCO
      // ==========================================
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : () async {
            if (_titleController.text.trim().isEmpty) {
              _showSnackBar('Por favor, digite o título do treino!', Colors.red);
              return;
            }

            if (_selectedExercises.isEmpty) {
              _showSnackBar('Adicione pelo menos um exercício ao treino!', Colors.red);
              return;
            }

            setState(() => _isLoading = true);

            try {
              await _repository.saveWorkout(
                title: _titleController.text.trim(),
                focus: _selectedFocus, 
                studentId: widget.studentId, // ID real injetado via parâmetro
                exercises: _selectedExercises,
              );

              _showSnackBar('Treino salvo na nuvem com sucesso! 🚀', Colors.green);
              
              setState(() {
                _titleController.clear();
                _selectedExercises.clear();
              });

              if (mounted) Navigator.pop(context); // Retorna para a tela anterior ao salvar com sucesso

            } catch (e) {
              _showSnackBar('Erro: $e', Colors.red);
            } finally {
              if (mounted) setState(() => _isLoading = false);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isLoading 
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('SALVAR E ENVIAR FICHA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildMiniInput(String label, int index, String key) {
    return TextFormField(
      initialValue: _selectedExercises[index][key].toString(),
      onChanged: (newValue) => _selectedExercises[index][key] = newValue,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      textAlign: TextAlign.center,
    );
  }

  void _editNoteDialog(BuildContext context, int index) {
    final noteController = TextEditingController(text: _selectedExercises[index]['note']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Observação do Exercício'),
          content: TextField(
            controller: noteController,
            decoration: const InputDecoration(
              hintText: 'Ex: Controlar descida em 3 segundos',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => _selectedExercises[index]['note'] = noteController.text.trim());
                Navigator.pop(context);
              },
              child: const Text('Salvar Nota'),
            ),
          ],
        );
      },
    );
  }

  void _showExercisePicker(BuildContext context) {
    final searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.75,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Biblioteca de Exercícios', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                        ],
                      ),
                      const SizedBox(height: 12), 
                      TextField(
                        controller: searchController,
                        onChanged: (value) => setModalState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Pesquisar exercício...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showCustomExerciseDialog(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple.shade50,
                          foregroundColor: Colors.deepPurple,
                          elevation: 0,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.video_library_outlined),
                        label: const Text('Não achou? Cadastre com seu próprio vídeo', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 16),
                      const Text('Resultados do Catálogo', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 8),
                      Expanded(
                        child: FutureBuilder<List<Map<String, dynamic>>>(
                          future: _repository.searchExercises(searchController.text.trim()),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError) {
                              return Center(child: Text('Erro ao carregar: ${snapshot.error}'));
                            }

                            final exercises = snapshot.data ?? [];

                            if (exercises.isEmpty) {
                              return const Center(
                                child: Text('Nenhum exercício encontrado no catálogo.', style: TextStyle(color: Colors.grey)),
                              );
                            }

                            return ListView.builder(
                              controller: scrollController,
                              itemCount: exercises.length,
                              itemBuilder: (context, index) {
                                final ex = exercises[index];
                                return ListTile(
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurple.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.fitness_center, color: Colors.deepPurple, size: 20),
                                  ),
                                  title: Text(ex['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text('${ex['target_muscle'] ?? 'Geral'} • Catálogo Oficial', style: const TextStyle(fontSize: 12)),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.add_circle, color: Colors.deepPurple),
                                    onPressed: () {
                                      setState(() {
                                        _selectedExercises.add({
                                          'exercise_id': ex['id'],
                                          'name': ex['name'],
                                          'custom_media_url': ex['media_url'],
                                          'sets': '4',
                                          'reps': '10-12',
                                          'rest': '60s',
                                          'note': '',
                                          'isBiset': false,
                                        });
                                      });
                                      Navigator.pop(context);
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showCustomExerciseDialog(BuildContext context) {
    final nameController = TextEditingController();
    final urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Novo Exercício com Vídeo'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Adicione um exercício exclusivo com sua demonstração.', style: TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nome do Exercício', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: urlController,
                  decoration: const InputDecoration(
                    labelText: 'Link do Vídeo ou GIF (URL)',
                    hintText: 'https://exemplo.com/video.mp4',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  setState(() {
                    _selectedExercises.add({
                      'name': nameController.text.trim(),
                      'custom_media_url': urlController.text.trim(),
                      'sets': '4',
                      'reps': '10',
                      'rest': '60s',
                      'note': 'Vídeo customizado do professor',
                      'isBiset': false,
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Salvar e Adicionar'),
            ),
          ],
        );
      },
    );
  }
}