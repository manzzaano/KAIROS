import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../utils/strings.dart';
import '../utils/theme.dart';
import '../widgets/task_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<Task> _tasks = [
    Task(id: '1', title: 'Reportar errores críticos', priority: 3, energy: 4),
    Task(id: '2', title: 'Reunión con el consejo', priority: 2, energy: 2),
    Task(id: '3', title: 'Revisión de código · PR XLII', priority: 2, energy: 3),
    Task(id: '4', title: 'Responder correspondencia', priority: 1, energy: 1),
    Task(id: '5', title: 'Refactorizar módulo de autenticación', priority: 3, energy: 5),
  ];

  void _toggleTask(int i, Task t) => setState(() => _tasks[i] = t);

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    context.go(Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final username = (auth.user?.username.isNotEmpty ?? false)
        ? auth.user!.username
        : (auth.user?.email ?? 'ASPIRANT');

    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.appName),
        actions: [
          IconButton(
            tooltip: Strings.settings,
            onPressed: () => context.go(Routes.settings),
            icon: const Icon(Icons.settings_outlined, size: 20),
          ),
          IconButton(
            tooltip: Strings.surrenderSession,
            onPressed: _logout,
            icon: const Icon(Icons.logout, size: 20),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${Strings.aspirant} · ${username.toUpperCase()}',
                style: KairosTheme.mono(size: 9, color: KairosColors.bronze, letterSpacing: 3),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            alignment: Alignment.centerLeft,
            child: Text(Strings.todayLedger,
                style: KairosTheme.mono(size: 10, color: KairosColors.muted, letterSpacing: 4)),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _tasks.length,
              itemBuilder: (c, i) => TaskCard(task: _tasks[i], onToggle: (t) => _toggleTask(i, t)),
            ),
          ),
          const Divider(),
          _PreviewBar(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => debugPrint('Add task'),
        backgroundColor: KairosColors.bronze,
        foregroundColor: KairosColors.black,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: const Icon(Icons.add, size: 22),
      ),
    );
  }
}

class _PreviewBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget link(String label, String path) => Expanded(
          child: InkWell(
            onTap: () => context.go(path),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(label,
                    style: KairosTheme.mono(size: 10, color: KairosColors.bronze, letterSpacing: 3)),
              ),
            ),
          ),
        );
    return Row(
      children: [
        link(Strings.tunnel, Routes.tunnel),
        const VerticalDivider(width: 1, color: KairosColors.hairline),
        link(Strings.focus, Routes.focus),
        const VerticalDivider(width: 1, color: KairosColors.hairline),
        link(Strings.minos, Routes.confessional),
      ],
    );
  }
}
