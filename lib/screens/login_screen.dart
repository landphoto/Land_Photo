import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _u = TextEditingController();
  final _p = TextEditingController();
  bool _busy = false;

  Future<void> _login() async {
    setState(() => _busy = true);
    await Future.delayed(const Duration(milliseconds: 600)); // محاكاة
    if (!mounted) return;
    setState(() => _busy = false);
    Navigator.pushReplacementNamed(context, '/feed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Land Photo',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
              const SizedBox(height: 18),
              TextField(
                  controller: _u,
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person_outline),
                      labelText: 'اسم المستخدم')),
              const SizedBox(height: 12),
              TextField(
                  controller: _p,
                  obscureText: true,
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.lock_outline),
                      labelText: 'كلمة المرور')),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _busy ? null : _login,
                  child: Text(_busy ? 'يرجى الانتظار…' : 'تسجيل الدخول'),
                ),
              ),
              TextButton(
                  onPressed: () {}, child: const Text('إنشاء حساب جديد')),
            ]),
          ),
        ),
      ),
    );
  }
}