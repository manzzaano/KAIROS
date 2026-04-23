import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/task.dart';

class TaskService {
  final SupabaseClient client;
  TaskService(this.client);

  String get _uid => client.auth.currentUser!.id;

  Future<List<Task>> fetchTasks({String status = 'all'}) async {
    var query = client.from('tasks').select();
    if (status == 'active') {
      query = query.eq('completed', false).eq('abandoned', false);
    } else if (status == 'completed') {
      query = query.eq('completed', true);
    } else if (status == 'abandoned') {
      query = query.eq('abandoned', true);
    }
    final data = await query.order('created_at', ascending: false);
    return (data as List)
        .map((e) => Task.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<Task> createTask({
    required String title,
    required int priority,
    required int energy,
    required int estimatedMinutes,
    double? latitude,
    double? longitude,
  }) async {
    final data = await client.from('tasks').insert({
      'user_id': _uid,
      'title': title,
      'priority': priority,
      'energy': energy,
      'estimated_minutes': estimatedMinutes,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    }).select().single();
    return Task.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<Task> completeTask(String taskId, int estimatedMinutes) async {
    final data = await client.from('tasks').update({
      'completed': true,
      'completed_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', taskId).select().single();
    await client.rpc('add_free_time',
        params: {'p_user_id': _uid, 'p_minutes': estimatedMinutes});
    return Task.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<Task> abandonTask(String taskId, int estimatedMinutes) async {
    final data = await client.from('tasks').update({
      'abandoned': true,
      'abandoned_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', taskId).select().single();
    await client.rpc('add_debt', params: {
      'p_user_id': _uid,
      'p_minutes': (estimatedMinutes * 1.5).toInt(),
    });
    return Task.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<void> deleteTask(String taskId) async {
    await client.from('tasks').delete().eq('id', taskId);
  }

  Future<Map<String, dynamic>> fetchDebt() async {
    final debtData = await client
        .from('productivity_debt')
        .select()
        .eq('user_id', _uid)
        .maybeSingle();

    final streakResult =
        await client.rpc('calculate_streak', params: {'p_user_id': _uid});

    final debt = (debtData as Map<String, dynamic>?) ??
        {'total_debt_minutes': 0, 'free_time_minutes': 0};

    return {
      ...debt,
      'streak_days': streakResult as int? ?? 0,
    };
  }

  Future<Map<String, dynamic>> payDebt(int minutesPaid) async {
    await client.rpc(
        'pay_debt', params: {'p_user_id': _uid, 'p_minutes': minutesPaid});
    return fetchDebt();
  }

  Future<Map<String, dynamic>> optimizeTasks(
      List<Map<String, dynamic>> tasks) async {
    final result = await client.functions
        .invoke('optimize-tasks', body: {'tasks': tasks});
    return Map<String, dynamic>.from(result.data as Map);
  }
}
