import 'package:flutter/foundation.dart';

import '../models/task.dart';
import '../services/supabase_client.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _service;

  List<Task> _tasks = [];
  Map<String, dynamic>? _debt;
  bool _isLoading = false;
  String? _error;

  TaskProvider({TaskService? service})
      : _service = service ?? TaskService(supabaseClient);

  List<Task> get tasks => _tasks;
  Map<String, dynamic>? get debt => _debt;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get debtTotalMinutes => (_debt?['total_debt_minutes'] as int?) ?? 0;
  int get debtHours => debtTotalMinutes ~/ 60;
  int get debtMinutes => debtTotalMinutes % 60;
  int get streakDays => (_debt?['streak_days'] as int?) ?? 0;
  int get freeTimeMinutes => (_debt?['free_time_minutes'] as int?) ?? 0;
  int get sessionsCompleted => _tasks.where((t) => t.completed).length;

  Future<void> fetchTasks({String status = 'all'}) async {
    _setLoading(true);
    try {
      _tasks = await _service.fetchTasks(status: status);
      _error = null;
    } catch (e) {
      _error = _clean(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchDebt() async {
    _setLoading(true);
    try {
      _debt = await _service.fetchDebt();
      _error = null;
    } catch (e) {
      _error = _clean(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createTask({
    required String title,
    required int priority,
    required int energy,
    required int estimatedMinutes,
    double? latitude,
    double? longitude,
  }) async {
    _setLoading(true);
    try {
      final task = await _service.createTask(
        title: title,
        priority: priority,
        energy: energy,
        estimatedMinutes: estimatedMinutes,
        latitude: latitude,
        longitude: longitude,
      );
      _tasks.insert(0, task);
      _error = null;
    } catch (e) {
      _error = _clean(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> completeTask(String taskId) async {
    try {
      final task = _tasks.firstWhere((t) => t.id == taskId);
      final updated = await _service.completeTask(taskId, task.estimatedMinutes);
      _updateTaskInList(updated);
      await fetchDebt();
    } catch (e) {
      _error = _clean(e.toString());
      notifyListeners();
    }
  }

  Future<void> abandonTask(String taskId) async {
    try {
      final task = _tasks.firstWhere((t) => t.id == taskId);
      final updated = await _service.abandonTask(taskId, task.estimatedMinutes);
      _updateTaskInList(updated);
      await fetchDebt();
    } catch (e) {
      _error = _clean(e.toString());
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _service.deleteTask(taskId);
      _tasks.removeWhere((t) => t.id == taskId);
      notifyListeners();
    } catch (e) {
      _error = _clean(e.toString());
      notifyListeners();
    }
  }

  Future<void> payDebt(int minutesPaid) async {
    _setLoading(true);
    try {
      _debt = await _service.payDebt(minutesPaid);
      _error = null;
    } catch (e) {
      _error = _clean(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  List<Map<String, int>> computeDailyStats() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: 6 - i));
      int completed = 0;
      int abandoned = 0;
      for (final task in _tasks) {
        if (task.completed && task.completedAt != null) {
          if (_sameDay(task.completedAt!, day)) completed++;
        }
        if (task.abandoned && task.abandonedAt != null) {
          if (_sameDay(task.abandonedAt!, day)) abandoned++;
        }
      }
      return {'completed': completed, 'abandoned': abandoned};
    });
  }

  void _updateTaskInList(Task updated) {
    final idx = _tasks.indexWhere((t) => t.id == updated.id);
    if (idx >= 0) _tasks[idx] = updated;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  String _clean(String raw) {
    const prefix = 'Exception: ';
    return raw.startsWith(prefix) ? raw.substring(prefix.length) : raw;
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
