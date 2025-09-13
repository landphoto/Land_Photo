import 'package:supabase_flutter/supabase_flutter.dart';
import '../secrets.dart';

final supa = Supabase.instance.client;

class SupabaseService {
  static Future<void> init() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      realtimeClientOptions: const RealtimeClientOptions(eventsPerSecond: 40),
    );
  }

  static Future<void> ensureProfileRow() async {
    final user = supa.auth.currentUser;
    if (user == null) return;
    // يعمل upsert لسطر البروفايل لو ما موجود
    await supa.from('profiles').upsert({
      'id': user.id,
      'username': user.email?.split('@').first ?? 'user_${user.id.substring(0,6)}',
    }, onConflict: 'id');
  }
}