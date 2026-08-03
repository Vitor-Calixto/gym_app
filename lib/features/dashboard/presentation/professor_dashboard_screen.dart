import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../workouts/presentation/workout_builder_screen.dart';



class ProfessorDashboardScreen extends StatefulWidget {

  const ProfessorDashboardScreen({super.key});



  @override

  State<ProfessorDashboardScreen> createState() => _ProfessorDashboardScreenState();

}



class _ProfessorDashboardScreenState extends State<ProfessorDashboardScreen> {

  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isLoading = true;

  List<Map<String, dynamic>> _students = [];

  String _searchQuery = '';



  @override

  void initState() {

    super.initState();

    _loadStudents();

  }



  // Buscar alunos cadastrados no banco

  Future<void> _loadStudents() async {

    setState(() => _isLoading = true);

    try {

      final response = await _supabase

          .from('profiles')

          .select()

          .eq('role', 'student');



      setState(() {

        _students = List<Map<String, dynamic>>.from(response);

      });

    } catch (e) {

      try {

        final response = await _supabase.from('profiles').select();

        setState(() {

          _students = List<Map<String, dynamic>>.from(response);

        });

      } catch (_) {

        // Se falhar, mantém lista vazia para evitar crash

      }

    } finally {

      if (mounted) setState(() => _isLoading = false);

    }

  }



  @override

  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text('Painel do Professor - FitClan'),

        backgroundColor: Colors.deepPurple,

        foregroundColor: Colors.white,

        actions: [

          IconButton(

            icon: const Icon(Icons.refresh),

            onPressed: _loadStudents,

            tooltip: 'Atualizar Lista',

          ),

          IconButton(

            icon: const Icon(Icons.logout),

            onPressed: () async {

              await _supabase.auth.signOut();

            },

            tooltip: 'Sair',

          ),

        ],

      ),

      body: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          // Cabeçalho de Boas-Vindas

          Container(

            padding: const EdgeInsets.all(20.0),

            color: Colors.deepPurple.shade50,

            child: Row(

              children: [

                const CircleAvatar(

                  radius: 30,

                  backgroundColor: Colors.deepPurple,

                  child: Icon(Icons.fitness_center, color: Colors.white, size: 30),

                ),

                const SizedBox(width: 16),

                Expanded(

                  child: Column(

                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: const [

                      Text(

                        'Bem-vindo, Professor!',

                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple),

                      ),

                      SizedBox(height: 4),

                      Text(

                        'Selecione um aluno abaixo para montar ou editar as fichas de treino.',

                        style: TextStyle(color: Colors.black54, fontSize: 14),

                      ),

                    ],

                  ),

                ),

              ],

            ),

          ),



          // Barra de Pesquisa de Alunos

          Padding(

            padding: const EdgeInsets.all(16.0),

            child: TextField(

              onChanged: (value) => setState(() => _searchQuery = value),

              decoration: InputDecoration(

                hintText: 'Pesquisar aluno por nome...',

                prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),

                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),

                filled: true,

                fillColor: Colors.white,

              ),

            ),

          ),



          // Título da Seção

          const Padding(

            padding: EdgeInsets.symmetric(horizontal: 16.0),

            child: Text(

              'Seus Alunos',

              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),

            ),

          ),

          const SizedBox(height: 8),



          // Lista de Alunos

          Expanded(

            child: _isLoading

                ? const Center(child: CircularProgressIndicator())

                : _students.isEmpty

                    ? Center(

                        child: Column(

                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [

                            Icon(Icons.group_off_outlined, size: 64, color: Colors.grey.shade400),

                            const SizedBox(height: 12),

                            const Text('Nenhum aluno encontrado no sistema.', style: TextStyle(color: Colors.grey, fontSize: 16)),

                            const SizedBox(height: 8),

                            ElevatedButton(

                              onPressed: _loadStudents,

                              child: const Text('Recarregar'),

                            ),

                          ],

                        ),

                      )

                    : ListView.builder(

                        padding: const EdgeInsets.symmetric(horizontal: 16),

                        itemCount: _students.where((s) {

                          final name = (s['full_name'] ?? s['name'] ?? '').toString().toLowerCase();

                          return name.contains(_searchQuery.toLowerCase());

                        }).length,

                        itemBuilder: (context, index) {

                          final filteredList = _students.where((s) {

                            final name = (s['full_name'] ?? s['name'] ?? '').toString().toLowerCase();

                            return name.contains(_searchQuery.toLowerCase());

                          }).toList();



                          final student = filteredList[index];

                          final studentName = student['full_name'] ?? student['name'] ?? 'Aluno sem nome';

                          final studentEmail = student['email'] ?? 'Sem e-mail';

                          final studentId = student['id'] ?? '';



                          return Card(

                            elevation: 2,

                            margin: const EdgeInsets.only(bottom: 12),

                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

                            child: ListTile(

                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

                              leading: CircleAvatar(

                                backgroundColor: Colors.deepPurple.shade100,

                                child: Text(

                                  studentName.isNotEmpty ? studentName[0].toUpperCase() : 'A',

                                  style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),

                                ),

                              ),

                              title: Text(studentName, style: const TextStyle(fontWeight: FontWeight.bold)),

                              subtitle: Text(studentEmail),

                              trailing: ElevatedButton.icon(

                                onPressed: () {

                                  Navigator.push(

                                    context,

                                    MaterialPageRoute(

                                      builder: (context) => WorkoutBuilderScreen(

                                        studentId: studentId,

                                        studentName: studentName,

                                      ),

                                    ),

                                  );

                                },

                                icon: const Icon(Icons.fitness_center, size: 16),

                                label: const Text('Montar Treino'),

                                style: ElevatedButton.styleFrom(

                                  backgroundColor: Colors.deepPurple,

                                  foregroundColor: Colors.white,

                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),

                                ),

                              ),

                            ),

                          );

                        },

                      ),

          ),

        ],

      ),

    );

  }

}