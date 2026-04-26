import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/i_task_repository.dart';
import '../datasources/task_realm_datasource.dart';

class TaskRepositoryImpl implements ITaskRepository {
  final TaskRealmDataSource _realmDataSource;
  final NetworkInfo _networkInfo;

  TaskRepositoryImpl({
    required TaskRealmDataSource realmDataSource,
    required NetworkInfo networkInfo,
  })  : _realmDataSource = realmDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<Task>>> getTasks({bool todayOnly = false}) async {
    try {
      final objects = _realmDataSource.getTasks(todayOnly: todayOnly);
      return Right(objects.map((o) => o.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Task>> createTask(TaskParams params) async {
    try {
      final object = _realmDataSource.createTask(params);
      if (await _networkInfo.isConnected) {
        // TODO Sprint 3: sync to backend via FastAPI
      }
      return Right(object.toEntity());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Task>> toggleTask(String id) async {
    try {
      _realmDataSource.toggleTask(id);
      final updated = _realmDataSource.getTasks().firstWhere((t) => t.id.hexString == id);
      return Right(updated.toEntity());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(String id) async {
    try {
      _realmDataSource.deleteTask(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
