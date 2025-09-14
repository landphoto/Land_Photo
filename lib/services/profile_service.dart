import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  ProfileService._();
  static final I = ProfileService._();
  final _c = Supabase.instance.client;

  Future<void> ensureRow() async {
    final uid = _c.auth.currentUser?.id;
    if (uid == null) return;
    final row = await _c.from('profiles').select('id').eq('id', uid).maybeSingle();
    if (row == null) {
      await _c.from('profiles').insert({'id': uid});
    }
  }

  Future<void> updateProfile({String? avatarUrl, String? username}) async {
    final uid = _c.auth.currentUser?.id;
    if (uid == null) return;
    final data = <String, dynamic>{};
    if (avatarUrl != null) data['avatar_url'] = avatarUrl;
    if (username != null) data['username'] = username;
    if (data.isNotEmpty) {
      await _c.from('profiles').update(data).eq('id', uid);
    }
  }
}