// lib/screens/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;

  final _supabase = Supabase.instance.client;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_loading) return;
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    setState(() => _loading = true);
    try {
      final res = await _supabase.auth.signUp(
        email: _email.text.trim(),
        password: _pass.text,
      );

      if (!mounted) return;
      if (res.session != null) {
        // مباشرةً مسجل – بعض المشاريع تتطلب تأكيد إيميل ولن ترجع Session
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (r) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check your email to confirm your account.'),
          ),
        );
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected error: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _pass,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password'),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _signUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.secondary,
                          foregroundColor: cs.onSecondary,
                          shape: const StadiumBorder(),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Create account'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _loading
                          ? null
                          : () => Navigator.of(context).pushNamed('/login'),
                      child: const Text('I have an account'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}