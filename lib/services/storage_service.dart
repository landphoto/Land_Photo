import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../secrets.dart';
import 'supabase_service.dart';

class StorageService {
  final _s = SupaService.I.client;

  Future<String> uploadToBucket({
    required String bucket,
    required String fileName,
    required File file,
  }) async {
    final bytes = await file.readAsBytes();
    await _s.storage
        .from(bucket)
        .uploadBinary(fileName, bytes, fileOptions: const FileOptions(upsert: true));
    final publicUrl = _s.storage.from(bucket).getPublicUrl(fileName);
    return publicUrl;
  }
}