import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../ui/glass.dart';
import '../services/storage_service.dart';
import '../services/supabase_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _s = S.c;
  final _store = StorageService();
  bool _loading = true;
  Map<String, dynamic>? _profile;

  Future<void> _load() async {
    final uid = _s.auth.currentUser!.id;
    final res = await _s.from('profiles').select('id, username, avatar_url').eq('id', uid).maybeSingle();
    setState(() { _profile = res; _loading = false; });
  }

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _changeAvatar() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (x == null) return;
    await _store.uploadAvatar(File(x.path));
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final p = _profile;
    return Scaffold(
      appBar: AppBar(title: const Text('الملف الشخصي')),
      body: _loading ? const Center(child: CircularProgressIndicator()) : ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Glass(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundImage: p?['avatar_url'] != null ? NetworkImage(p!['avatar_url']) : null,
                  child: p?['avatar_url'] == null ? const Icon(Icons.person) : null,
                ),
                const SizedBox(width: 16),
                Expanded(child: Text(p?['username'] ?? 'مستخدم')),
                OutlinedButton.icon(
                  onPressed: _changeAvatar,
                  icon: const Icon(Icons.photo_camera),
                  label: const Text('تغيير الصورة'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}