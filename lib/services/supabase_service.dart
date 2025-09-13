import 'package:supabase_flutter/supabase_flutter.dart';

class S {
  S._();
  static SupabaseClient get c => Supabase.instance.client;
}