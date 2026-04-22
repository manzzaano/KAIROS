import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../utils/strings.dart';
import '../utils/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;
    context.go(Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final username = auth.user?.username ?? Strings.aspirant;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go(Routes.dashboard),
          icon: const Icon(Icons.arrow_back, size: 20),
        ),
        title: Text(Strings.settings.toUpperCase()),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            _Section(title: Strings.profile),
            _Row(label: Strings.username, value: username),
            _Row(label: Strings.email, value: auth.user?.email ?? '—'),
            const SizedBox(height: 32),
            _Section(title: Strings.preferences),
            _Row(label: Strings.theme, value: Strings.settingsDark),
            _Row(label: Strings.language, value: Strings.settingsSpanish),
            const SizedBox(height: 32),
            _Section(title: Strings.about),
            _Row(label: Strings.developer, value: Strings.developerSignature),
            _Row(label: Strings.school, value: Strings.schoolName),
            _Row(label: Strings.projectType, value: Strings.year),
            _Row(label: 'VERSIÓN', value: Strings.version),
            const SizedBox(height: 44),
            InkWell(
              onTap: () => _logout(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  border: Border.all(color: KairosColors.blood, width: 1),
                  boxShadow: [
                    BoxShadow(color: KairosColors.blood.withOpacity(0.28), blurRadius: 22, spreadRadius: 1),
                  ],
                ),
                child: Center(
                  child: Text(
                    Strings.logout,
                    style: KairosTheme.mono(
                      size: 12,
                      color: KairosColors.blood,
                      letterSpacing: 5,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: Text(Strings.copyright,
                  style: KairosTheme.mono(size: 9, color: KairosColors.muted, letterSpacing: 3)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  const _Section({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title.toUpperCase(),
          style: KairosTheme.mono(size: 10, color: KairosColors.bronze, letterSpacing: 4)),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: KairosColors.hairline, width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label.toUpperCase(),
                style: KairosTheme.mono(size: 10, color: KairosColors.muted, letterSpacing: 3)),
          ),
          Expanded(
            flex: 3,
            child: Text(value,
                textAlign: TextAlign.right,
                style: KairosTheme.serif(size: 16, color: KairosColors.bone)),
          ),
        ],
      ),
    );
  }
}
