// lib/features/workouts/presentation/workout_builder_screen.dart
import 'package:flutter/material.dart';

class WorkoutBuilderScreen extends StatefulWidget {
  const WorkoutBuilderScreen({super.key});

  @override
  State<WorkoutBuilderScreen> createState() => _WorkoutBuilderScreenState();
}

class _WorkoutBuilderScreenState extends State<WorkoutBuilderScreen> {
  // Lista estruturada para conter nome, séries, reps, descanso, nota e status de bi-set
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
          // 1. Cabeçalho de Metadados
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Título do Treino (Ex: Treino A - Peito)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Aluno',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        items: const [
                          DropdownMenuItem(value: '1', child: Text('João Silva'))
                        ],
                        onChanged: (value) {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Foco',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        items: const [
                          DropdownMenuItem(value: '1', child: Text('Hipertrofia'))
                        ],
                        onChanged: (value) {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 2. Lista Reordenável de Exercícios
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _selectedExercises.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) newIndex -= 1;
                  final item = _selectedExercises.removeAt(oldIndex);
                  _selectedExercises.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final ex = _selectedExercises[index];
                return Card(
                  key: ValueKey(ex['name'] + index.toString()),
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
                              onPressed: () {
                                setState(() {
                                  _selectedExercises.removeAt(index);
                                });
                              },
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildMiniInput('Séries', ex['sets'])),
                            const SizedBox(width: 8),
                            Expanded(child: _buildMiniInput('Reps', ex['reps'])),
                            const SizedBox(width: 8),
                            Expanded(child: _buildMiniInput('Pausa', ex['rest'])),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Botão de Nota Rápida
                            TextButton.icon(
                              onPressed: () => _editNoteDialog(context, index),
                              icon: const Icon(Icons.chat_bubble_outline, size: 16),
                              label: Text(ex['note'].toString().isEmpty ? 'Adicionar nota' : 'Editar nota', style: const TextStyle(fontSize: 12)),
                            ),
                            // Botão de Bi-set
                            IconButton(
                              icon: Icon(Icons.link, color: ex['isBiset'] ? Colors.orange : Colors.grey),
                              tooltip: 'Alternar Bi-set',
                              onPressed: () {
                                setState(() {
                                  ex['isBiset'] = !ex['isBiset'];
                                });
                              },
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

          // 3. Botão Adicionar Exercício
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
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ficha salva e enviada com sucesso!')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('SALVAR E ENVIAR FICHA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildMiniInput(String label, String initialValue) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      textAlign: TextAlign.center,
    );
  }

  // Diálogo para editar nota do exercício
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
                setState(() {
                  _selectedExercises[index]['note'] = noteController.text.trim();
                });
                Navigator.pop(context);
              },
              child: const Text('Salvar Nota'),
            ),
          ],
        );
      },
    );
  }

  // Gaveta de Seleção de Exercícios + Atalho para Criar Customizado
  void _showExercisePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
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
                    decoration: InputDecoration(
                      hintText: 'Pesquisar exercício...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Botão Especial: Cadastrar Exercício Próprio com Vídeo
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
                    label: const Text('Não achou? Cadastre exercício com seu vídeo', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 16),
                  const Text('Sugestões Rápidas', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),

                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.fitness_center, color: Colors.deepPurple),
                          title: const Text('Tríceps Corda na Polia'),
                          subtitle: const Text('Tríceps • Polia'),
                          trailing: IconButton(
                            icon: const Icon(Icons.add_circle, color: Colors.deepPurple),
                            onPressed: () {
                              setState(() {
                                _selectedExercises.add({
                                  'name': 'Tríceps Corda na Polia',
                                  'sets': '4',
                                  'reps': '12',
                                  'rest': '45s',
                                  'note': '',
                                  'isBiset': false,
                                });
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.fitness_center, color: Colors.deepPurple),
                          title: const Text('Desenvolvimento com Halteres'),
                          subtitle: const Text('Ombro • Halteres'),
                          trailing: IconButton(
                            icon: const Icon(Icons.add_circle, color: Colors.deepPurple),
                            onPressed: () {
                              setState(() {
                                _selectedExercises.add({
                                  'name': 'Desenvolvimento com Halteres',
                                  'sets': '3',
                                  'reps': '10',
                                  'rest': '60s',
                                  'note': '',
                                  'isBiset': false,
                                });
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Modal para Criar Exercício Personalizado com URL de Vídeo/GIF
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
                const Text(
                  'Adicione um exercício exclusivo com sua demonstração.',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
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
                if (nameController.text.isNotEmpty) {
                  setState(() {
                    _selectedExercises.add({
                      'name': nameController.text.trim(),
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