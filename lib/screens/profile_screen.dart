import 'package:flutter/material.dart';
import '../services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _p = ProfileService(); // بدلاً من ProfileService.I

  @override
  void initState() {
    super.initState();
    // لو كان عندك ensureRow خليها هنا
    _p.ensureRow();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Profile')),
    );
  }
}