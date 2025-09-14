import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> ensureProfileRow() async {
  final supa = Supabase.instance.client;
  final uid = supa.auth.currentUser?.id;
  if (uid == null) return;

  final rows = await supa.from('profiles').select('id').eq('id', uid).maybeSingle();
  if (rows == null) {
    await supa.from('profiles').insert({'id': uid});
  }
}