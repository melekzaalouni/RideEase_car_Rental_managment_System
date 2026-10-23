import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/format.dart';
import '../../core/network/api_exception.dart';
import '../../core/widgets/common.dart';
import 'auth_controller.dart';
import 'login_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  // Keys are the exact JSON names expected by the backend.
  final _c = {
    for (final k in ['username', 'email', 'password', 'firstName', 'lastName', 'phoneNumber', 'driverLicenseNumber'])
      k: TextEditingController(),
  };
  bool _hide = true;
  bool _busy = false;

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _field(
    String key,
    String label,
    IconData icon,
    String? Function(String?) validator, {
    TextInputType? type,
    bool password = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _c[key],
        keyboardType: type,
        obscureText: password && _hide,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: password
              ? IconButton(
                  icon: Icon(_hide ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _hide = !_hide),
                )
              : null,
        ),
        validator: validator,
      ),
    );
  }

  String? _req(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;
  String? _min(String? v, int n) => (v == null || v.trim().length < n) ? 'At least $n characters' : null;

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final body = <String, dynamic>{
        for (final e in _c.entries) e.key: e.key == 'password' ? e.value.text : e.value.text.trim(),
        'registrationDate': apiDate(DateTime.now()),
      };
      await ref.read(authProvider.notifier).register(body);
    } on ApiException catch (e) {
      if (!mounted) return;
      // Duplicate username/email is a plain RuntimeException on the server (HTTP 500).
      final msg = (e.status == 500 && e.fieldErrors.isEmpty)
          ? 'Username or email already exists'
          : e.display;
      showSnack(context, msg, isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AuthHero(title: 'Create account', subtitle: 'Takes less than a minute'),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Account', style: title),
                    const SizedBox(height: 12),
                    _field('username', 'Username', Icons.person_outline, (v) => _min(v, 3)),
                    _field('email', 'Email', Icons.mail_outline, (v) {
                      final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch((v ?? '').trim());
                      return ok ? null : 'Enter a valid email';
                    }, type: TextInputType.emailAddress),
                    _field('password', 'Password', Icons.lock_outline, (v) => (v == null || v.length < 8) ? 'At least 8 characters' : null,
                        password: true),
                    const SizedBox(height: 8),
                    Text('Driver details', style: title),
                    const SizedBox(height: 12),
                    _field('firstName', 'First name', Icons.badge_outlined, (v) => _min(v, 3)),
                    _field('lastName', 'Last name', Icons.badge_outlined, (v) => _min(v, 3)),
                    _field('phoneNumber', 'Phone', Icons.phone_outlined, (v) {
                      final n = (v ?? '').trim().length;
                      return (n < 8 || n > 12) ? '8 to 12 characters' : null;
                    }, type: TextInputType.phone),
                    _field('driverLicenseNumber', 'Driver license no.', Icons.credit_card, (v) {
                      final n = (v ?? '').trim().length;
                      return (n < 5 || n > 30) ? '5 to 30 characters' : null;
                    }),
                    const SizedBox(height: 8),
                    PrimaryButton(label: 'Create account', loading: _busy, onPressed: _submit),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text('I already have an account'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
