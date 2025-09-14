import 'package:supabase_flutter/supabase_flutter.dart';
import '../secrets.dart';

class SupaService {
  SupaService._();
  static final SupaService I = SupaService._();

  late final SupabaseClient client;

  Future<void> init() async {
    await Supabase.initialize(
      url: AppSecrets.supabaseUrl,
      anonKey: AppSecrets.supabaseAnonKey,
    );
    client = Supabase.instance.client;
  }
}