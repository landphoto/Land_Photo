import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _p = ProfileService.I;
  final _name = TextEditingController();
  String? _email;
  String? _avatar;

  Future<void> _load() async {
    final me = await _p.getMyProfile();
    if (!mounted) return;
    setState(() {
      _name.text = (me?['username'] ?? '') as String;
      _email = me?['email'] as String?; // إذا عندك عمود email في profiles (لو ما عندك اشطب هالسطر)
      _avatar = me?['avatar_url'] as String?;
    });
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _saveName() async {
    await _p.updateUsername(_name.text.trim());
    await _load();
  }

  Future<void> _pickAndUpload() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (x == null) return;
    final bytes = await x.readAsBytes();
    await _p.uploadAvatar(bytes: Uint8List.fromList(bytes));
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('الملف الشخصي')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickAndUpload,
              child: CircleAvatar(
                radius: 46,
                backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
                backgroundImage: _avatar != null ? NetworkImage(_avatar!) : null,
                child: _avatar == null ? const Icon(Icons.person, size: 42) : null,
              ),
            ),
            const SizedBox(height: 14),
            if (_email != null)
              Text(_email!, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'اسم المستخدم'),
            ),
            const SizedBox(height: 10),
            FilledButton(onPressed: _saveName, child: const Text('حفظ التغييرات')),
          ],
        ),
      ),
    );
  }
}