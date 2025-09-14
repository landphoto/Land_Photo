import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import '../services/storage_service.dart';
import '../services/profile_service.dart';

final _storage = StorageService();
final _profile = ProfileService();

/// استدعِ هذه الدالة من زر "تغيير الصورة" في شاشة البروفايل
Future<void> pickAndUploadAvatar() async {
  final picker = ImagePicker();
  final x = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
  if (x == null) return;

  final bytes = await x.readAsBytes();
  final url = await _storage.uploadToBucket(
    bucket: 'avatars',
    path: x.name,
    bytes: Uint8List.fromList(bytes),
    contentType: 'image/${x.name.split('.').last}',
  );

  await _profile.updateProfile(avatarUrl: url);
}