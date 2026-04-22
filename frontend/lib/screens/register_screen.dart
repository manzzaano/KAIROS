import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../utils/strings.dart';
import '../utils/theme.dart';
import '../widgets/doric_column.dart';
import '../widgets/stoic_input.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  static final _usernameRe = RegExp(r'^[A-Za-z0-9_]{3,30}$');

  final _emailCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String? _localError;
  String? _shownError;
  late final AnimationController _fade;

  @override
  void initState() {
    super.initState();
    _fade = AnimationController(vsync: this, duration: Timings.fadeIn)..forward();
  }

  @override
  void dispose() {
    _fade.dispose();
    _emailCtrl.dispose();
    _usernameCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final username = _usernameCtrl.text.trim();
    final pass = _passCtrl.text;
    if (email.isEmpty || username.isEmpty || pass.isEmpty) {
      setState(() => _localError = Strings.errorFieldsRequired);
      return;
    }
    if (!_usernameRe.hasMatch(username)) {
      setState(() => _localError = Strings.errorUsernamePattern);
      return;
    }
    if (pass != _confirmCtrl.text) {
      setState(() => _localError = Strings.errorPasswordMismatch.toUpperCase());
      return;
    }
    setState(() => _localError = null);
    final auth = context.read<AuthProvider>();
    await auth.register(email, username, pass);
    if (!mounted) return;
    if (auth.isAuthenticated) context.go(Routes.onboarding);
  }

  void _maybeShowError(AuthProvider auth) {
    if (auth.error != null && auth.error != _shownError) {
      _shownError = auth.error;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: KairosColors.error600,
            content: Text(auth.error!, style: KairosTheme.mono(size: 11, color: KairosColors.neutral50)),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    _maybeShowError(auth);

    return Scaffold(
      body: FadeTransition(
        opacity: _fade,
        child: Stack(
          children: [
            Positioned(
              left: -60,
              top: 40,
              bottom: 40,
              child: Opacity(
                opacity: 0.4,
                child: DoricColumn(width: 200, height: MediaQuery.of(context).size.height - 80),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(Strings.appName,
                            style: KairosTheme.mono(size: 11, color: KairosColors.neutral400, letterSpacing: 2)),
                        GestureDetector(
                          onTap: () => context.go(Routes.login),
                          child: Text(Strings.back,
                              style: KairosTheme.mono(size: 10, color: KairosColors.neutral400, letterSpacing: 1)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 36),
                    Text(Strings.registerQuote,
                        style: KairosTheme.serif(
                            size: 32, weight: FontWeight.w300, height: 1.15, color: KairosColors.neutral50)),
                    const SizedBox(height: 8),
                    Text(Strings.registerAuthor,
                        style: KairosTheme.mono(size: 9, color: KairosColors.neutral400, letterSpacing: 1)),
                    const SizedBox(height: 40),
                    StoicInput(
                        label: Strings.email,
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 24),
                    StoicInput(label: Strings.username, controller: _usernameCtrl),
                    const SizedBox(height: 24),
                    StoicInput(label: Strings.password, controller: _passCtrl, obscure: true),
                    const SizedBox(height: 24),
                    StoicInput(label: Strings.confirmPassword, controller: _confirmCtrl, obscure: true),
                    if (_localError != null) ...[
                      const SizedBox(height: 20),
                      Text(_localError!,
                          style: KairosTheme.mono(size: 10, color: KairosColors.error600, letterSpacing: 1)),
                    ],
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: auth.isLoading ? null : _submit,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            auth.isLoading ? Strings.signInAwaiting : Strings.register,
                            style: KairosTheme.mono(
                              size: 12,
                              color: KairosColors.neutral900,
                              letterSpacing: 2,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Center(
                      child: GestureDetector(
                        onTap: () => context.go(Routes.login),
                        child: Text(Strings.alreadyHaveAccount,
                            style: KairosTheme.mono(size: 10, color: KairosColors.neutral400, letterSpacing: 2)),
                      ),
                    ),
                    const SizedBox(height: 24),
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
