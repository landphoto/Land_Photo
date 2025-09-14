import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final _s = Supabase.instance.client;

  /// ???? ?????? ?????? ??? ?????? ??????? ???? ???
  Future<String> uploadToBucket({
    required String bucket,
    required String path,
    required Uint8List bytes,
    String contentType = 'image/jpeg',
  }) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${path.split('/').last}';

    await _s.storage.from(bucket).uploadBinary(
          fileName,
          bytes,
          fileOptions: FileOptions(
            contentType: contentType,
            upsert: true,
          ),
        );

    // ????? ???? ???
    final publicUrl = _s.storage.from(bucket).getPublicUrl(fileName);
    return publicUrl;
  }
}