import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../utils/strings.dart';
import '../utils/theme.dart';
import '../widgets/doric_column.dart';
import '../widgets/stoic_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String? _shownError;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _goNext(AuthProvider auth) {
    context.go(auth.hasSeenOnboarding ? Routes.dashboard : Routes.onboarding);
  }

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    if (email.isEmpty || pass.isEmpty) return;
    final auth = context.read<AuthProvider>();
    await auth.login(email, pass);
    if (!mounted) return;
    if (auth.isAuthenticated) _goNext(auth);
  }

  Future<void> _google() async {
    final auth = context.read<AuthProvider>();
    await auth.loginWithGoogle();
    if (!mounted) return;
    if (auth.isAuthenticated) _goNext(auth);
  }

  Future<void> _apple() async {
    final auth = context.read<AuthProvider>();
    await auth.loginWithApple();
    if (!mounted) return;
    if (auth.isAuthenticated) _goNext(auth);
  }

  void _maybeShowError(AuthProvider auth) {
    if (auth.error != null && auth.error != _shownError) {
      _shownError = auth.error;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: KairosColors.blood,
            content: Text(auth.error!,
                style: KairosTheme.mono(size: 11, color: KairosColors.bone)),
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
      body: Stack(
        children: [
          Positioned(
            right: -60,
            top: 40,
            bottom: 40,
            child: Opacity(
              opacity: 0.5,
              child: DoricColumn(
                  width: 220, height: MediaQuery.of(context).size.height - 80),
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),
                        Text(Strings.appName,
                            style: KairosTheme.mono(
                                size: 11,
                                color: KairosColors.bronze,
                                letterSpacing: 6)),
                        const SizedBox(height: 36),
                        Text(
                          Strings.loginQuote,
                          style: KairosTheme.serif(
                              size: 32,
                              weight: FontWeight.w300,
                              height: 1.15,
                              color: KairosColors.bone),
                        ),
                        const SizedBox(height: 8),
                        Text(Strings.loginAuthor,
                            style: KairosTheme.mono(
                                size: 9,
                                color: KairosColors.muted,
                                letterSpacing: 3)),
                        const SizedBox(height: 48),
                        StoicInput(
                            label: Strings.email,
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress),
                        const SizedBox(height: 28),
                        StoicInput(
                            label: Strings.password,
                            controller: _passCtrl,
                            obscure: true),
                        const SizedBox(height: 44),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: auth.isLoading ? null : _submit,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                auth.isLoading
                                    ? Strings.signInAwaiting
                                    : Strings.signIn,
                                style: KairosTheme.mono(
                                  size: 12,
                                  color: KairosColors.black,
                                  letterSpacing: 4,
                                  weight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _OAuthButton(
                          label: Strings.signInGoogle,
                          onTap: auth.isLoading ? null : _google,
                        ),
                        const SizedBox(height: 10),
                        _OAuthButton(
                          label: Strings.signInApple,
                          onTap: null,
                        ),
                        const Spacer(),
                        Center(
                          child: GestureDetector(
                            onTap: () => context.go(Routes.register),
                            child: Text(
                              Strings.noAccount,
                              style: KairosTheme.mono(
                                  size: 10,
                                  color: KairosColors.bronze,
                                  letterSpacing: 3),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Text(Strings.copyright,
                              style: KairosTheme.mono(
                                  size: 9,
                                  color: KairosColors.muted,
                                  letterSpacing: 3)),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OAuthButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const _OAuthButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: KairosColors.hairline, width: 1),
          ),
          child: Center(
            child: Text(
              label,
              style: KairosTheme.mono(
                size: 10,
                color: onTap == null ? KairosColors.muted : KairosColors.bone,
                letterSpacing: 4,
                weight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
