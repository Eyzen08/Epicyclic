import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/ui_helpers.dart';
import 'auth_widgets.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  bool _awaitingConfirmation = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .signUp(
            fullName: _name.text,
            email: _email.text,
            password: _password.text,
          );
      ref.invalidate(profileProvider);
      ref.invalidate(addressesProvider);
      if (!mounted) return;
      if (user.id.isEmpty ||
          ref.read(authRepositoryProvider).currentUser == null) {
        setState(() => _awaitingConfirmation = true);
      } else {
        context.go('/home');
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    if (_awaitingConfirmation) {
      return AuthScaffold(
        title: 'Check Your Inbox',
        subtitle:
            'We sent a confirmation link to ${_email.text.trim()}. Confirm your email, then sign in.',
        onBack: () => context.go('/login'),
        showMark: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: palette.primarySoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.mark_email_read_outlined,
                size: 42,
                color: palette.primary,
              ),
            ),
            const SizedBox(height: 20),
            const DemoNotice(
              message: 'Email delivery depends on your Supabase project settings. This app does not send email itself.',
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => context.go('/login'),
              child: const Text('Back To Sign In'),
            ),
          ],
        ),
      );
    }

    return AuthScaffold(
      title: 'Create Your Account',
      subtitle:
          'Save your setup, track orders, and pick up where you left off.',
      onBack: () => context.canPop() ? context.pop() : context.go('/login'),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Already have an account?',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          TextButton(
            onPressed: () => context.go('/login'),
            child: const Text('Sign In'),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null) AuthErrorBox(message: _error!),
            const AuthFieldLabel(text: 'Full Name'),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              validator: Validators.name,
              decoration: const InputDecoration(
                hintText: 'Enter your full name',
                prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
              ),
            ),
            const SizedBox(height: 16),
            const AuthFieldLabel(text: 'Email Address'),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: Validators.email,
              decoration: const InputDecoration(
                hintText: 'Enter your email address',
                prefixIcon: Icon(Icons.mail_outline_rounded, size: 20),
              ),
            ),
            const SizedBox(height: 16),
            const AuthFieldLabel(text: 'Password'),
            TextFormField(
              controller: _password,
              obscureText: _obscure,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              validator: Validators.password,
              decoration: InputDecoration(
                hintText: 'At least 8 characters',
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const AuthFieldLabel(text: 'Confirm Password'),
            TextFormField(
              controller: _confirm,
              obscureText: _obscure,
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Confirm your password.';
                }
                if (value != _password.text) return 'Passwords do not match.';
                return null;
              },
              onFieldSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                hintText: 'Re-enter your password',
                prefixIcon: Icon(Icons.lock_reset_rounded, size: 20),
              ),
            ),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Create Account'),
            ),
            const SizedBox(height: 16),
            const DemoNotice(
              message: 'Demo mode stores this profile only on this device. No verification email is sent.',
            ),
          ],
        ),
      ),
    );
  }
}
