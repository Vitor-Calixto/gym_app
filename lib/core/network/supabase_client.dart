// lib/core/network/supabase_client.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Provedor global para acessar o Supabase em qualquer lugar do app de forma limpa
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});