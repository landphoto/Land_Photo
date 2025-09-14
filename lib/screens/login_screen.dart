import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'feed_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _username = TextEditingController();
  bool _isSignup = false;
  bool _loading = false;
  final _auth = AuthService();

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      if (_isSignup) {
        await _auth.signUp(
          email: _email.text.trim(),
          password: _pass.text,
          username: _username.text.trim().isEmpty ? 'مستخدم' : _username.text.trim(),
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إنشاء الحساب، راجع بريدك لتأكيد الإيميل')),
        );
      } else {
        await _auth.signIn(email: _email.text.trim(), password: _pass.text);
        if (!mounted) return;
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (_) => const FeedScreen()));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final headline = GoogleFonts.poppins(
      fontSize: 36, fontWeight: FontWeight.w700, color: Colors.white,
    );
    return Scaffold(
      backgroundColor: const Color(0xFF0E0F12),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              const SizedBox(height: 40),
              Text('LandPhoto', style: headline, textAlign: TextAlign.center),
              const SizedBox(height: 30),
              if (_isSignup)
                TextField(
                  controller: _username,
                  decoration: _decor('اسم المستخدم'),
                ),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: _decor('البريد الإلكتروني'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _pass,
                obscureText: true,
                decoration: _decor('كلمة المرور'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white12,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(_isSignup ? 'إنشاء حساب' : 'تسجيل الدخول'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _loading ? null : () => setState(() => _isSignup = !_isSignup),
                child: Text(_isSignup ? 'عندك حساب؟ تسجيل الدخول' : 'ما عندك حساب؟ إنشاء حساب'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _decor(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white10,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white24),
          borderRadius: BorderRadius.circular(14),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white54),
          borderRadius: BorderRadius.circular(14),
        ),
      );
}