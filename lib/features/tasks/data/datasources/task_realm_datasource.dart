import 'package:realm/realm.dart';
import '../../domain/entities/task.dart';
import '../models/task_object.dart';
import '../models/task_model_extension.dart';

abstract class TaskRealmDataSource {
  List<TaskObject> getTasks({bool todayOnly = false});
  TaskObject createTask(TaskParams params);
  void toggleTask(String id);
  void deleteTask(String id);
}

class TaskRealmDataSourceImpl implements TaskRealmDataSource {
  final Realm _realm;
  TaskRealmDataSourceImpl(this._realm);

  @override
  List<TaskObject> getTasks({bool todayOnly = false}) {
    try {
      if (todayOnly) {
        return _realm.query<TaskObject>("dueLabel BEGINSWITH 'Hoy'").toList();
      }
      return _realm.all<TaskObject>().toList();
    } catch (e) {
      throw Exception('Failed to get tasks: $e');
    }
  }

  @override
  TaskObject createTask(TaskParams params) {
    late TaskObject obj;
    try {
      _realm.write(() {
        obj = _realm.add(TaskObject(
          ObjectId(),
          params.title,
          priority: params.priority.name,
          energyLevel: params.energyLevel,
          estimateMinutes: params.estimateMinutes,
          isDone: false,
          isSynced: false,
          project: params.project ?? 'Personal',
          description: params.description,
          dueLabel: params.dueLabel,
        ));
      });
      return obj;
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }

  @override
  void toggleTask(String id) {
    try {
      final objectId = ObjectId.fromHexString(id);
      final obj = _realm.find<TaskObject>(objectId);
      if (obj != null) {
        _realm.write(() {
          obj.isDone = !obj.isDone;
          obj.isSynced = false;
        });
      }
    } catch (e) {
      throw Exception('Failed to toggle task: $e');
    }
  }

  @override
  void deleteTask(String id) {
    try {
      final objectId = ObjectId.fromHexString(id);
      final obj = _realm.find<TaskObject>(objectId);
      if (obj != null) {
        _realm.write(() => _realm.delete(obj));
      }
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }
}
