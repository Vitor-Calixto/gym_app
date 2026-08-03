// lib/features/students/presentation/students_screen.dart
import 'package:flutter/material.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  String _selectedFilter = 'Todos';
  String _searchQuery = '';

  // Lista simulada de alunos
  final List<Map<String, dynamic>> _students = [
    {'name': 'Lucas Silva', 'goal': 'Hipertrofia', 'status': 'Ativo', 'color': Colors.green},
    {'name': 'Mariana Costa', 'goal': 'Emagrecimento', 'status': 'Ativo', 'color': Colors.green},
    {'name': 'Roberto Carlos', 'goal': 'Condicionamento', 'status': 'Inativo', 'color': Colors.red},
    {'name': 'Ana Beatriz', 'goal': 'Hipertrofia', 'status': 'Ficha Vencida', 'color': Colors.orange},
    {'name': 'João Pedro', 'goal': 'Reabilitação', 'status': 'Ativo', 'color': Colors.green},
  ];

  @override
  Widget build(BuildContext context) {
    // Filtra os alunos com base na busca e na categoria selecionada
    final filteredStudents = _students.where((student) {
      final matchesSearch = student['name'].toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter = _selectedFilter == 'Todos' || student['status'] == _selectedFilter;
      return matchesSearch && matchesFilter;
    }).toList();

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
                // Chips de Filtro Horizontal
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['Todos', 'Ativos', 'Inativos', 'Ficha Vencida'].map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (selected) => setState(() => _selectedFilter = filter),
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
          
          // Lista de Alunos Dinâmica
          Expanded(
            child: filteredStudents.isEmpty
                ? const Center(child: Text('Nenhum aluno encontrado.', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredStudents.length,
                    itemBuilder: (context, index) {
                      final student = filteredStudents[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.purple[100],
                            child: Text(student['name'][0], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
                          ),
                          title: Text(student['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('Objetivo: ${student['goal']}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(width: 8, height: 8, decoration: BoxDecoration(color: student['color'], shape: BoxShape.circle)),
                                  const SizedBox(width: 6),
                                  Text(student['status'], style: TextStyle(color: student['color'], fontSize: 12, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                          onTap: () {
                            // Ação ao clicar no aluno (exibe um modal com detalhes)
                            _showStudentDetails(context, student);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Modal de Detalhes do Aluno
  void _showStudentDetails(BuildContext context, Map<String, dynamic> student) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(student['name'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Objetivo: ${student['goal']}'),
            Text('Status: ${student['status']}'),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, minimumSize: const Size(double.infinity, 48)),
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.edit, color: Colors.white),
              label: const Text('Editar Ficha de Treino', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}