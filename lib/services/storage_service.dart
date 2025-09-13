import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class StorageService {
  final _s = S.c;

  static const imagesBucket  = 'images';
  static const avatarsBucket = 'avatars';

  Future<String> uploadImageAndCreatePost({
    required File file,
    String? caption,
  }) async {
    final uid = _s.auth.currentUser!.id;
    final fileName = 'img_${DateTime.now().millisecondsSinceEpoch}.png';
    await _s.storage.from(imagesBucket).upload(fileName, file);
    final publicUrl = _s.storage.from(imagesBucket).getPublicUrl(fileName);

    await _s.from('posts').insert({
      'user_id': uid,
      'image_url': publicUrl,
      'caption': caption,
    });

    return publicUrl;
  }

  Future<String> uploadAvatar(File file) async {
    final uid = _s.auth.currentUser!.id;
    final fileName = 'av_$uid.png';
    await _s.storage.from(avatarsBucket).upload(fileName, file, upsert: true);
    final url = _s.storage.from(avatarsBucket).getPublicUrl(fileName);
    await _s.from('profiles').update({'avatar_url': url}).eq('id', uid);
    return url;
  }
}