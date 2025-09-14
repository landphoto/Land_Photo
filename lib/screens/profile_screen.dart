import 'package:flutter/material.dart';
import '../services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    ProfileService.I.ensureRow();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( // <? ???? const
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(child: Text('Profile page')),
    );
  }
}