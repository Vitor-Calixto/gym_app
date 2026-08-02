// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Importações da nossa Clean Architecture
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

// Instância global do Isar (Banco de dados offline)
// Deixamos 'late' pois ela será inicializada antes de o app rodar, dentro do main().
late Isar isar;

/// Função principal que inicializa o aplicativo.
/// Como temos operações assíncronas (banco local e Supabase), o main precisa ser 'async'.
void main() async {
  // 1. Prevenção de Erros de Binding
  // Garante que os motores do Flutter estejam prontos para executar códigos nativos
  // antes da renderização da tela (ex: ler pastas do sistema, inicializar dependências).
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Configuração do Isar (Banco Local / Offline-first)
  // Buscamos o diretório seguro de documentos do dispositivo (Android/iOS) para salvar os dados.
  final dir = await getApplicationDocumentsDirectory();
  
  // Abre a conexão com o banco local. 
  isar = await Isar.open(
    [
      // TODO: Fase 4 - Adicionar os schemas gerados (ex: WorkoutSchema, ExerciseSchema)
    ],
    directory: dir.path,
  );

  // 3. Configuração do Supabase (BaaS / Backend na nuvem)
  // Inicializa o cliente global que será utilizado para Autenticação e Sincronização.
  // NOTA: Lembre-se de substituir as strings abaixo pelas credenciais reais do seu projeto.
  await Supabase.initialize(
    url: ' https://quudqcjdmagjzmunxqfc.supabase.co',
    anonKey: 'sb_publishable_9CO__JE0yOflQINCrAPJzQ_Y3Z6PgxO',
  );

  // 4. Inicialização da Interface
  // O ProviderScope abraça todo o aplicativo, permitindo que o Riverpod gerencie 
  // os estados globais (como o nosso router e o cliente do Supabase).
  runApp(
    const ProviderScope(
      child: FitClanApp(),
    ),
  );
}

/// Widget raiz da aplicação.
/// Herda de ConsumerWidget em vez de StatelessWidget para podermos "escutar" os Providers do Riverpod.
class FitClanApp extends ConsumerWidget {
  const FitClanApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 5. Configuração Dinâmica de Rotas
    // Observa (watch) o provider de rotas. 
    // Qualquer mudança no estado de autenticação futuramente pode forçar o roteador a redirecionar a tela.
    final goRouter = ref.watch(routerProvider);

    // 6. Retorno do App Material
    // Retorna o MaterialApp configurado com o GoRouter e o FlexColorScheme.
    return MaterialApp.router(
      title: 'FitClan',
      
      // Aplica o tema claro centralizado no arquivo app_theme.dart
      theme: AppTheme.lightTheme(context),
      
      // Aplica o tema escuro centralizado no arquivo app_theme.dart
      darkTheme: AppTheme.darkTheme(context),
      
      // Define que o app deve respeitar o tema do sistema do usuário (claro/escuro automático)
      themeMode: ThemeMode.system,
      
      // Injeta a configuração de rotas do GoRouter
      routerConfig: goRouter,
      
      // Oculta a faixa de "DEBUG" no canto superior direito da tela
      debugShowCheckedModeBanner: false,
    );
  }
}