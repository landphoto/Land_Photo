import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _s = Supabase.instance.client;

/// شاشة الملف الشخصي للمستخدم الحالي
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _loading = true;
  bool _saving = false;
  final _username = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    try {
      final uid = _s.auth.currentUser!.id;
      final res = await _s
          .from('profiles')
          .select('id, username, avatar_url, email')
          .eq('id', uid)
          .maybeSingle();

      _profile = res;
      _username.text = (_profile?['username'] as String?) ?? '';
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذّر تحميل الملف الشخصي: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final uid = _s.auth.currentUser!.id;
      await _s.from('profiles').upsert({
        'id': uid,
        'username': _username.text.trim().isEmpty
            ? 'مستخدم'
            : _username.text.trim(),
      });
      await _loadProfile();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('تم الحفظ')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('فشل الحفظ: $e')));
    } finally {
      setState(() => _saving = false);
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    try {
      final x = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (x == null) return;

      final uid = _s.auth.currentUser!.id;
      final fileName = 'avatars/$uid-${DateTime.now().millisecondsSinceEpoch}.png';

      // ملاحظة: في النسخ الجديدة نستخدم FileOptions(upsert: true)
      await _s.storage
          .from('public')
          .upload(fileName, File(x.path),
              fileOptions: const FileOptions(upsert: true));

      final publicUrl = _s.storage.from('public').getPublicUrl(fileName);

      await _s.from('profiles').upsert({
        'id': uid,
        'avatar_url': publicUrl,
      });

      await _loadProfile();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('فشل رفع الصورة: $e')));
    }
  }

  @override
  void dispose() {
    _username.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final email = _s.auth.currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('الملف الشخصي')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundImage: (_profile?['avatar_url'] as String?)
                                ?.isNotEmpty ==
                            true
                            ? NetworkImage(_profile!['avatar_url'])
                            : null,
                        child: (_profile?['avatar_url'] as String?)?.isEmpty ??
                                true
                            ? const Icon(Icons.person, size: 48)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: IconButton.filledTonal(
                          onPressed: _pickAndUploadAvatar,
                          icon: const Icon(Icons.edit),
                          tooltip: 'تغيير الصورة',
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    email,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _username,
                  decoration: const InputDecoration(
                    labelText: 'اسم المستخدم',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('حفظ التغييرات'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('تسجيل الخروج'),
                  onPressed: () async {
                    await _s.auth.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            ),
    );
  }
}