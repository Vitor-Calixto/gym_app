// lib/features/students/presentation/students_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/students_controller.dart'; 

class StudentsScreen extends ConsumerStatefulWidget {
  const StudentsScreen({super.key});

  @override
  ConsumerState<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends ConsumerState<StudentsScreen> {
  String _searchQuery = '';

  // Mapeamento visual para o enum do backend
  final Map<String, StudentTab> _tabMapping = {
    'Todos': StudentTab.todos,
    'Ativos': StudentTab.ativos,
    'Inativos': StudentTab.inativos,
    'Ficha Vencida': StudentTab.vencidos,
  };

  @override
  Widget build(BuildContext context) {
    // 1. Escuta qual aba está selecionada no provedor global
    final selectedTab = ref.watch(selectedTabProvider);
    // 2. Escuta os dados reais vindos do Supabase
    final studentsAsync = ref.watch(studentsListProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Meus Alunos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Barra de Pesquisa e Filtros
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Buscar aluno por nome...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
                const SizedBox(height: 12),
                // Chips de Filtro Horizontal integrados com Riverpod
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _tabMapping.keys.map((filterName) {
                      final tabEnum = _tabMapping[filterName]!;
                      final isSelected = selectedTab == tabEnum;
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(filterName),
                          selected: isSelected,
                          onSelected: (selected) {
                            // Atualiza o provedor, o que forçará o Supabase a buscar novos dados
                            ref.read(selectedTabProvider.notifier).state = tabEnum;
                          },
                          selectedColor: Colors.black,
                          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          // Lista de Alunos Dinâmica (Reativa ao Supabase)
          Expanded(
            child: studentsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: Colors.black)),
              error: (err, stack) => Center(child: Text('Erro ao carregar alunos: $err')),
              data: (students) {
                // Filtro local apenas para a barra de pesquisa de texto
                final filteredStudents = students.where((student) {
                  final name = student['full_name'] ?? '';
                  return name.toLowerCase().contains(_searchQuery.toLowerCase());
                }).toList();

                if (filteredStudents.isEmpty) {
                  return const Center(child: Text('Nenhum aluno encontrado.', style: TextStyle(color: Colors.grey)));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredStudents.length,
                  itemBuilder: (context, index) {
                    final student = filteredStudents[index];
                    
                    // Tratamento seguro dos dados vindos do banco
                    final name = student['full_name'] ?? 'Sem Nome';
                    final status = student['status'] ?? 'indefinido';
                    final goal = student['goal'] ?? 'Geral'; 
                    
                    // Define cor baseada no status real do banco
                    Color statusColor = Colors.green;
                    if (status == 'inativo') statusColor = Colors.red;
                    if (status == 'vencido') statusColor = Colors.orange;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.purple[100],
                          child: Text(name[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
                        ),
                        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Objetivo: $goal', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(width: 8, height: 8, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                                const SizedBox(width: 6),
                                Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                        onTap: () {
                          // Abre o modal passando os dados reais do banco
                          _showStudentDetails(context, student);
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
  }

  // Modal de Detalhes do Aluno (Corrigido)
  void _showStudentDetails(BuildContext context, Map<String, dynamic> student) {
    final name = student['full_name'] ?? 'Sem Nome';
    final goal = student['goal'] ?? 'Geral';
    final status = student['status'] ?? 'indefinido';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Objetivo: $goal'),
            Text('Status: ${status.toUpperCase()}'),
            const SizedBox(height: 20),
            
            // Botão 1: Editar Ficha de Treino
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, minimumSize: const Size(double.infinity, 48)),
              onPressed: () {
                Navigator.pop(context); // Fecha o modal atual
                context.push('/workout-builder', extra: student['id']); 
              },
              icon: const Icon(Icons.edit, color: Colors.white),
              label: const Text('Editar Ficha de Treino', style: TextStyle(color: Colors.white)),
            ),
            
            const SizedBox(height: 12),
            
            // Botão 2: Nova Avaliação Física
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
              onPressed: () {
                Navigator.pop(context); // Fecha o modal de detalhes
                _showEvaluationForm(context, student); // Abre o formulário de avaliação
              },
              icon: const Icon(Icons.monitor_weight_outlined, color: Colors.black),
              label: const Text('Nova Avaliação Física', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  // Formulário de Avaliação Física
  void _showEvaluationForm(BuildContext context, Map<String, dynamic> student) {
    final weightController = TextEditingController();
    final bfController = TextEditingController();
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              top: 24, left: 24, right: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Avaliação: ${student['full_name']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                TextField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Peso (kg)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.monitor_weight),
                  ),
                ),
                const SizedBox(height: 12),
                
                TextField(
                  controller: bfController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Percentual de Gordura (BF %)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.percent),
                  ),
                ),
                const SizedBox(height: 24),
                
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  onPressed: isSaving ? null : () async {
                    if (weightController.text.isEmpty) return;

                    setModalState(() => isSaving = true);

                    try {
                      await Supabase.instance.client.from('physical_evaluations').insert({
                        'student_id': student['id'], 
                        'weight': double.tryParse(weightController.text.replaceAll(',', '.')) ?? 0.0,
                        'body_fat': double.tryParse(bfController.text.replaceAll(',', '.')) ?? 0.0,
                        'evaluation_date': DateTime.now().toIso8601String(),
                      });

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Avaliação salva com sucesso!'), backgroundColor: Colors.green),
                        );
                      }
                    } catch (e) {
                      setModalState(() => isSaving = false);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erro ao salvar: $e'), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  child: isSaving 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Salvar Avaliação', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}