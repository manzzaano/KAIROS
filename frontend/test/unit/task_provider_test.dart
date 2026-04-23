import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kairos/models/task.dart';
import 'package:kairos/providers/task_provider.dart';
import 'package:kairos/services/task_service.dart';

class MockTaskService extends Mock implements TaskService {}

Task fakeTask({String id = '1', String title = 'Test task'}) => Task(
      id: id,
      title: title,
      priority: 1,
      energy: 3,
      estimatedMinutes: 30,
    );

void main() {
  late MockTaskService mockService;
  late TaskProvider provider;

  setUp(() {
    mockService = MockTaskService();
    provider = TaskProvider(service: mockService);
  });

  group('fetchTasks', () {
    test('carga tareas correctamente', () async {
      final tasks = [fakeTask(id: '1'), fakeTask(id: '2')];
      when(() => mockService.fetchTasks(status: any(named: 'status')))
          .thenAnswer((_) async => tasks);

      await provider.fetchTasks();

      expect(provider.tasks.length, 2);
      expect(provider.error, isNull);
      expect(provider.isLoading, isFalse);
    });

    test('sets error on exception', () async {
      when(() => mockService.fetchTasks(status: any(named: 'status')))
          .thenThrow(Exception('Network error'));

      await provider.fetchTasks();

      expect(provider.error, contains('Network error'));
      expect(provider.tasks, isEmpty);
      expect(provider.isLoading, isFalse);
    });
  });

  group('createTask', () {
    test('añade tarea al inicio de la lista', () async {
      final newTask = fakeTask(id: 'new-1', title: 'Nueva tarea');
      when(() => mockService.createTask(
            title: any(named: 'title'),
            priority: any(named: 'priority'),
            energy: any(named: 'energy'),
            estimatedMinutes: any(named: 'estimatedMinutes'),
          )).thenAnswer((_) async => newTask);

      await provider.createTask(
        title: 'Nueva tarea',
        priority: 2,
        energy: 3,
        estimatedMinutes: 45,
      );

      expect(provider.tasks.first.id, 'new-1');
      expect(provider.tasks.first.title, 'Nueva tarea');
    });
  });

  group('completeTask', () {
    test('actualiza tarea en lista y recarga deuda', () async {
      final original = fakeTask(id: 'task-1');
      final completed = Task(
        id: 'task-1',
        title: 'Test task',
        priority: 1,
        energy: 3,
        estimatedMinutes: 30,
        completed: true,
        completedAt: DateTime.now(),
      );
      final debt = {
        'total_debt_minutes': 0,
        'free_time_minutes': 30,
        'streak_days': 1,
      };

      when(() => mockService.fetchTasks(status: any(named: 'status')))
          .thenAnswer((_) async => [original]);
      when(() => mockService.completeTask(any(), any()))
          .thenAnswer((_) async => completed);
      when(() => mockService.fetchDebt()).thenAnswer((_) async => debt);

      await provider.fetchTasks();
      await provider.completeTask('task-1');

      expect(provider.tasks.first.completed, isTrue);
      expect(provider.debtTotalMinutes, 0);
    });
  });

  group('fetchDebt', () {
    test('carga datos de deuda con streak', () async {
      when(() => mockService.fetchDebt()).thenAnswer((_) async => {
            'total_debt_minutes': 120,
            'free_time_minutes': 60,
            'streak_days': 5,
          });

      await provider.fetchDebt();

      expect(provider.debtTotalMinutes, 120);
      expect(provider.streakDays, 5);
      expect(provider.debtHours, 2);
    });
  });

  group('computeDailyStats', () {
    test('retorna 7 días con completed y abandoned counts', () async {
      when(() => mockService.fetchTasks(status: any(named: 'status')))
          .thenAnswer((_) async => [
                Task(
                  id: '1',
                  title: 'T',
                  priority: 1,
                  energy: 1,
                  estimatedMinutes: 10,
                  completed: true,
                  completedAt: DateTime.now(),
                ),
              ]);
      await provider.fetchTasks();

      final stats = provider.computeDailyStats();
      expect(stats.length, 7);
      expect(stats.last['completed'], 1);
    });
  });
}
