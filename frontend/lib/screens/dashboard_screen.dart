import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().fetchTasks();
    });
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    context.go(Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final tasks = taskProvider.tasks;
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
                style: KairosTheme.mono(size: 9, color: KairosColors.neutral700, letterSpacing: 3),
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
                style: KairosTheme.mono(size: 10, color: KairosColors.neutral400, letterSpacing: 4)),
          ),
          Expanded(
            child: taskProvider.isLoading && tasks.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(
                        color: KairosColors.neutral700, strokeWidth: 1))
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: tasks.length,
                    itemBuilder: (c, i) => TaskCard(
                      task: tasks[i],
                      onToggle: (t) {
                        if (t.completed && !tasks[i].completed) {
                          taskProvider.completeTask(int.parse(tasks[i].id));
                        }
                      },
                    ),
                  ),
          ),
          const Divider(),
          _PreviewBar(),
        ],
      ),
      floatingActionButton: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.elasticOut,
        builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
        child: FloatingActionButton(
          onPressed: () => context.go(Routes.create),
          backgroundColor: KairosColors.neutral700,
          foregroundColor: KairosColors.neutral900,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          child: const Icon(Icons.add, size: 22),
        ),
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
                    style: KairosTheme.mono(size: 10, color: KairosColors.neutral700, letterSpacing: 3)),
              ),
            ),
          ),
        );
    return Row(
      children: [
        link(Strings.tunnel, Routes.tunnel),
        const VerticalDivider(width: 1, color: KairosColors.neutral300),
        link(Strings.focus, Routes.focus),
        const VerticalDivider(width: 1, color: KairosColors.neutral300),
        link(Strings.minos, Routes.confessional),
        const VerticalDivider(width: 1, color: KairosColors.neutral300),
        link('STATS', Routes.stats),
        const VerticalDivider(width: 1, color: KairosColors.neutral300),
        link('ZONAS', Routes.geofence),
      ],
    );
  }
}
