import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'storage_service.dart';

final _s = Supabase.instance.client;

/// ???? ????? ?????????
class ProfileService {
  const ProfileService._();
  static const ProfileService I = ProfileService._();

  /// ????? ?? ???????? ?? ?? ???? profiles
  Future<void> ensureRow() async {
    final uid = _s.auth.currentUser?.id;
    if (uid == null) return;

    final existsRes = await _s
        .from('profiles')
        .select('id')
        .eq('id', uid)
        .maybeSingle();

    if (existsRes == null) {
      await _s.from('profiles').insert({
        'id': uid,
        'username': null,
        'avatar_url': null,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<Map<String, dynamic>?> getMyProfile() async {
    final uid = _s.auth.currentUser?.id;
    if (uid == null) return null;
    return await _s.from('profiles').select().eq('id', uid).maybeSingle();
  }

  Future<void> updateUsername(String username) async {
    final uid = _s.auth.currentUser?.id;
    if (uid == null) return;
    await _s.from('profiles').update({'username': username}).eq('id', uid);
  }

  /// ??? ???? ?????? ?????? ?????? ?? ?????????
  Future<String> uploadAvatar({
    required Uint8List bytes,
    String bucket = 'avatars',
  }) async {
    final uid = _s.auth.currentUser?.id;
    if (uid == null) throw Exception('No user');

    final url = await StorageService.I.uploadToBucket(
      bucket: bucket,
      path: '$uid.jpg',
      bytes: bytes,
      contentType: 'image/jpeg',
      upsert: true,
    );

    await _s.from('profiles').update({'avatar_url': url}).eq('id', uid);
    return url;
  }
}