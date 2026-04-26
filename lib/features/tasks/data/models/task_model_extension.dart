import 'package:realm/realm.dart';
import '../../domain/entities/task.dart';
import 'task_object.dart';

extension TaskObjectExtension on TaskObject {
  Task toEntity() => Task(
    id: id.hexString,
    title: title,
    description: description,
    priority: Priority.values.firstWhere(
      (p) => p.name == priority,
      orElse: () => Priority.medium,
    ),
    energyLevel: energyLevel,
    dueLabel: dueLabel,
    estimateMinutes: estimateMinutes,
    isDone: isDone,
    isSynced: isSynced,
    project: project,
  );
}
