import 'package:flutter/foundation.dart';

import '../models/task.dart';
import '../services/api_client.dart';

class TaskProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();

  List<Task> _tasks = [];
  Map<String, dynamic>? _debt;
  bool _isLoading = false;
  String? _error;

  List<Task> get tasks => _tasks;
  Map<String, dynamic>? get debt => _debt;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get debtTotalMinutes => (_debt?['total_debt_minutes'] as int?) ?? 0;
  int get debtHours => debtTotalMinutes ~/ 60;
  int get debtMinutes => debtTotalMinutes % 60;
  int get streakDays => (_debt?['streak_days'] as int?) ?? 0;
  int get sessionsCompleted => _tasks.where((t) => t.completed).length;

  Future<void> fetchTasks({String status = 'all'}) async {
    _setLoading(true);
    try {
      final response = await _api.getTasksList(status: status);
      final list = response['tasks'] as List<dynamic>? ?? [];
      _tasks = list
          .map((e) => Task.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
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
      _debt = await _api.getProductivityDebt();
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
      final json = await _api.createTask(
        title: title,
        priority: priority,
        energy: energy,
        estimatedMinutes: estimatedMinutes,
        latitude: latitude,
        longitude: longitude,
      );
      _tasks.insert(0, Task.fromJson(json));
      _error = null;
    } catch (e) {
      _error = _clean(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> completeTask(int taskId) async {
    try {
      final json = await _api.completeTask(taskId);
      _updateTaskInList(Task.fromJson(json));
      await fetchDebt();
    } catch (e) {
      _error = _clean(e.toString());
      notifyListeners();
    }
  }

  Future<void> abandonTask(int taskId) async {
    try {
      final json = await _api.abandonTask(taskId);
      _updateTaskInList(Task.fromJson(json));
      await fetchDebt();
    } catch (e) {
      _error = _clean(e.toString());
      notifyListeners();
    }
  }

  Future<void> deleteTask(int taskId) async {
    try {
      await _api.deleteTask(taskId);
      _tasks.removeWhere((t) => t.id == taskId.toString());
      notifyListeners();
    } catch (e) {
      _error = _clean(e.toString());
      notifyListeners();
    }
  }

  Future<void> payDebt(int minutesPaid) async {
    _setLoading(true);
    try {
      _debt = await _api.payDebt(minutesPaid);
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
          final d = task.completedAt!;
          if (_sameDay(d, day)) completed++;
        }
        if (task.abandoned && task.abandonedAt != null) {
          final d = task.abandonedAt!;
          if (_sameDay(d, day)) abandoned++;
        }
      }
      return {'completed': completed, 'abandoned': abandoned};
    });
  }

  void _updateTaskInList(Task updated) {
    final idx = _tasks.indexWhere((t) => t.id == updated.id);
    if (idx >= 0) {
      _tasks[idx] = updated;
    }
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _clean(String raw) {
    const prefix = 'Exception: ';
    return raw.startsWith(prefix) ? raw.substring(prefix.length) : raw;
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
