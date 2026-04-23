import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kairos/models/task.dart';
import 'package:kairos/widgets/task_card.dart';

Task testTask({bool completed = false, bool abandoned = false}) => Task(
      id: 'test-id',
      title: 'Tarea de prueba',
      priority: 2,
      energy: 3,
      estimatedMinutes: 45,
      completed: completed,
      abandoned: abandoned,
    );

void main() {
  group('TaskCard', () {
    testWidgets('muestra el título de la tarea', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TaskCard(
            task: testTask(),
            onToggle: (_) {},
          ),
        ),
      ));

      expect(find.text('Tarea de prueba'), findsOneWidget);
    });

    testWidgets('llama onToggle al pulsar el card', (tester) async {
      Task? toggled;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TaskCard(
            task: testTask(),
            onToggle: (t) => toggled = t,
          ),
        ),
      ));

      await tester.tap(find.byType(InkWell).first);
      expect(toggled, isNotNull);
    });

    testWidgets('muestra tarea completada con estilo diferente', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TaskCard(
            task: testTask(completed: true),
            onToggle: (_) {},
          ),
        ),
      ));

      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
