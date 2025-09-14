import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  StorageService._();
  static final I = StorageService._();
  final _c = Supabase.instance.client;

  Future<String> uploadToBucket({
    required String bucket,
    required String path,
    required Uint8List bytes,
    required String contentType,
  }) async {
    final res = await _c.storage.from(bucket).uploadBinary(path, bytes, fileOptions: FileOptions(contentType: contentType, upsert: true));
    // ??? ??? public: ???? publicUrl
    final pub = _c.storage.from(bucket).getPublicUrl(path);
    return pub;
  }
}