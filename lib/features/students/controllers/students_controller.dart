import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 1. Definimos as opções das abas
enum StudentTab { todos, ativos, inativos, vencidos }

// 2. Controla qual aba está ativa no momento (começa em 'todos')
final selectedTabProvider = StateProvider<StudentTab>((ref) => StudentTab.todos);

// 3. Faz a busca no Supabase e reage sempre que a aba mudar
final studentsListProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final tab = ref.watch(selectedTabProvider);
  final supabase = Supabase.instance.client;
  
  // Pegamos o ID do professor logado
  final trainerId = supabase.auth.currentUser!.id;

  // Consulta base: busca apenas alunos vinculados a este professor
  var query = supabase
      .from('profiles')
      .select()
      .eq('role', 'student')
      .eq('trainer_id', trainerId);

  // Adiciona as cláusulas WHERE dinamicamente conforme a aba escolhida
  switch (tab) {
    case StudentTab.ativos:
      query = query.eq('status', 'ativo');
      break;
    case StudentTab.inativos:
      query = query.eq('status', 'inativo');
      break;
    case StudentTab.vencidos:
      // Exemplo: Alunos cuja ficha venceu há mais de 30 dias
      final trintaDiasAtras = DateTime.now().subtract(const Duration(days: 30)).toIso8601String();
      query = query.lte('ultima_ficha_data', trintaDiasAtras);
      break;
    case StudentTab.todos:
    default:
      // Mantém a query base, sem filtros adicionais
      break; 
  }

  // Executa a requisição no Supabase
  final List<Map<String, dynamic>> response = await query;
  return response;
});