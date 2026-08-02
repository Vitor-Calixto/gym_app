import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // 🔴 Não esqueça esse import!
import 'core/routing/app_router.dart';

// O main agora precisa ser "async" (assíncrono)
void main() async {
  // 1. Garante que os widgets do Flutter estão prontos
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Inicializa o Supabase ANTES do runApp
  await Supabase.initialize(
    url: 'https://quudqcjdmagjzmunxqfc.supabase.co',
    anonKey: 'sb_publishable_9CO__JE0yOflQINCrAPJzQ_Y3Z6PgxO',
  );

  // 3. Roda o aplicativo
  runApp(
    const ProviderScope(
      child: FitClanApp(),
    ),
  );
}

class FitClanApp extends StatelessWidget {
  const FitClanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FitClan',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), 
        useMaterial3: true,
      ),
      routerConfig: appRouter, 
    );
  }
}