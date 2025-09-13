import 'package:flutter/material.dart';
import '../theme.dart';
import '../ui/glass.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loginMode = true, _loading = false;
  String? _error;

  void _toggleMode() => setState(() => _loginMode = !_loginMode);

  Future<void> _submit() async {
    setState(() { _loading = true; _error = null; });
    try {
      if (_loginMode) {
        await _auth.signIn(_email.text.trim(), _pass.text.trim());
      } else {
        await _auth.signUp(
          email: _email.text.trim(),
          password: _pass.text.trim(),
          username: _name.text.trim().isEmpty ? 'مستخدم' : _name.text.trim(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم الإرسال، أكّد بريدك ثم سجّل دخول')),
          );
        }
      }
    } catch (_) {
      _error = 'حدث خطأ غير متوقع';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text('LandPhoto', style: t.displaySmall?.copyWith(
                  color: AppColors.mint, fontWeight: FontWeight.bold)),
                const SizedBox(height: 28),
                Glass(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      if (!_loginMode) ...[
                        TextField(controller: _name,
                          decoration: const InputDecoration(
                            labelText: 'اسم المستخدم', prefixIcon: Icon(Icons.person))),
                        const SizedBox(height: 12),
                      ],
                      TextField(controller: _email, keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'البريد الإلكتروني', prefixIcon: Icon(Icons.mail))),
                      const SizedBox(height: 12),
                      TextField(controller: _pass, obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'كلمة المرور', prefixIcon: Icon(Icons.lock))),
                      const SizedBox(height: 16),
                      if (_error != null)
                        Padding(padding: const EdgeInsets.only(bottom: 8),
                          child: Text(_error!, style: const TextStyle(color: AppColors.danger))),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _loading ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.mint, foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: _loading
                                ? const SizedBox(width:20,height:20,child: CircularProgressIndicator(strokeWidth:2))
                                : Text(_loginMode ? 'تسجيل الدخول' : 'إنشاء حساب'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(onPressed: _toggleMode,
                        child: Text(_loginMode ? 'لا تملك حساب؟ إنشاء' : 'لديك حساب؟ تسجيل الدخول')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}