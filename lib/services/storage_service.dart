import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

final supa = Supabase.instance.client;

class StorageService {
  /// يرفع ملف لصندوق images (تأكّد مسويه من Supabase > Storage)
  static Future<String> uploadImage({
    required File file,
  }) async {
    final fileName =
        'img_${DateTime.now().millisecondsSinceEpoch}${p.extension(file.path)}';

    await supa.storage.from('images').upload(fileName, file);
    // توليد URL عام (تأكّد مفعّل Public أو أنشئ Signed URL حسب حاجتك)
    final publicUrl = supa.storage.from('images').getPublicUrl(fileName);
    return publicUrl;
  }
}