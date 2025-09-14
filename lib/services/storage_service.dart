import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

final _s = Supabase.instance.client;

/// ???? ??????? ???? ??????? (Storage)
class StorageService {
  const StorageService._();
  static const StorageService I = StorageService._();

  /// ???? ?????? ??? ??? ????? ????? ???? ???
  Future<String> uploadToBucket({
    required String bucket,
    required String path,
    required Uint8List bytes,
    String contentType = 'image/jpeg',
    bool upsert = true,
  }) async {
    final storage = _s.storage.from(bucket);

    await storage.uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(contentType: contentType, upsert: upsert),
    );

    return storage.getPublicUrl(path);
  }
}