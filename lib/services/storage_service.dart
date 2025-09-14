import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants.dart';

class StorageService {
  final _s = Supabase.instance.client;

  Future<String> uploadPostImage(File file) async {
    final ext = p.extension(file.path);
    final name = 'img_${DateTime.now().millisecondsSinceEpoch}$ext';
    final path = '${AppStorage.postsPath}/$name';

    await _s.storage.from(AppStorage.imagesBucket).upload(
      path,
      file,
      fileOptions: const FileOptions(upsert: true, cacheControl: '3600'),
    );

    return _s.storage.from(AppStorage.imagesBucket).getPublicUrl(path);
  }

  Future<String> uploadAvatar(File file, String userId) async {
    final ext  = p.extension(file.path);
    final name = 'avatar_$userId$ext';
    final path = '${AppStorage.avatarsPath}/$name';

    await _s.storage.from(AppStorage.imagesBucket).upload(
      path,
      file,
      fileOptions: const FileOptions(upsert: true, cacheControl: '3600'),
    );

    return _s.storage.from(AppStorage.imagesBucket).getPublicUrl(path);
  }
}