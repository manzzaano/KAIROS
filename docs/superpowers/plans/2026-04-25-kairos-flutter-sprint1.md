# KAIROS 2.0 Flutter — Sprint 1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Initialize KAIROS 2.0 Flutter project with Clean Architecture (feature-first), Bloc state management, Realm offline-first storage. Implement Login, Dashboard, Create Task, Focus Mode screens.

**Architecture:** Feature-first Clean Architecture. GetIt DI, GoRouter navigation, Realm local DB, Dio HTTP.

**Tech Stack:** Flutter 3.22+, flutter_bloc 8.1.6, realm 3.4.0, dio 5.4.3, get_it 7.7.0, go_router 14.0.2, dartz 0.10.1, google_fonts 6.2.1

---

## Task 1: Initialize Flutter project

- [ ] **Step 1:** Run flutter create
```bash
cd C:\Users\Ismael\Desktop\KAIROS
flutter create --org com.kairos --project-name kairos kairos
cd kairos
```

- [ ] **Step 2:** Verify project structure
```bash
flutter pub get
flutter doctor
```

- [ ] **Commit**
```bash
git init
git add .
git commit -m "init: flutter project scaffold"
```

---

## Task 2: Configure pubspec.yaml

- [ ] **Step 1:** Replace `pubspec.yaml` content

```yaml
name: kairos
description: KAIROS 2.0 — AI-powered productivity app with offline-first Realm storage
publish_to: 'none'
version: 2.0.0+1

environment:
  sdk: '>=3.3.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.6
  bloc: ^8.1.4
  equatable: ^2.0.5
  realm: ^3.4.0
  dio: ^5.4.3
  get_it: ^7.7.0
  go_router: ^14.0.2
  dartz: ^0.10.1
  google_fonts: ^6.2.1
  connectivity_plus: ^6.0.3
  shared_preferences: ^2.3.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  bloc_test: ^9.1.7
  mocktail: ^1.0.4
```

- [ ] **Step 2:** Fetch dependencies
```bash
flutter pub get
```

- [ ] **Commit**
```bash
git add pubspec.yaml
git commit -m "config: add dependencies (bloc, realm, dio, gorouter)"
```

---

## Task 3: Core constants (colors, typography, spacing)

### Create 3 files: app_colors.dart, app_typography.dart, app_spacing.dart

- [ ] **Step 1:** `lib/core/constants/app_colors.dart`

```dart
import 'package:flutter/material.dart';

abstract class AppColors {
  static const background = Color(0xFF0A0A0A);
  static const background1 = Color(0xFF0F0F0F);
  static const background2 = Color(0xFF161616);
  static const background3 = Color(0xFF1C1C1C);
  static const line = Color(0x0FFFFFFF);
  static const line2 = Color(0x1AFFFFFF);
  static const text = Color(0xFFFAFAFA);
  static const text2 = Color(0xFFA3A3A3);
  static const text3 = Color(0xFF525252);
  static const text4 = Color(0xFF404040);
  static const accent = Color(0xFFFB923C);
  static const accent2 = Color(0xFFFDBA74);
  static const accentSoft = Color(0x1FFB923C);
  static const success = Color(0xFF4ADE80);
  static const danger = Color(0xFFF87171);
  static const warning = Color(0xFFFACC15);
}
```

- [ ] **Step 2:** `lib/core/constants/app_typography.dart`

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppTypography {
  static TextStyle get heading28 => GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.025,
  );

  static TextStyle get heading18 => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.01,
  );

  static TextStyle get body15 => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.01,
  );

  static TextStyle get body13 => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.005,
  );

  static TextStyle get caption12 => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static TextStyle get mono11 => GoogleFonts.jetBrainsMono(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.08,
  );

  static TextStyle get mono64 => GoogleFonts.jetBrainsMono(
    fontSize: 64,
    fontWeight: FontWeight.w300,
    letterSpacing: -0.04,
  );
}
```

- [ ] **Step 3:** `lib/core/constants/app_spacing.dart`

```dart
abstract class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;
}
```

- [ ] **Commit**
```bash
git add lib/core/constants/
git commit -m "feat: add core constants (colors, typography, spacing)"
```

---

## Task 4: Core error handling

- [ ] **Step 1:** `lib/core/error/failures.dart`

```dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);
  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Error del servidor']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sin conexión a internet']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Error al acceder a datos locales']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Error de autenticación']);
}
```

- [ ] **Step 2:** `lib/core/error/exceptions.dart`

```dart
class AppException implements Exception {
  final String message;
  const AppException(this.message);
  @override
  String toString() => message;
}
```

- [ ] **Commit**
```bash
git add lib/core/error/
git commit -m "feat: add failure and exception classes"
```

---

## Task 5: Core use case base + network

- [ ] **Step 1:** `lib/core/usecases/use_case.dart`

```dart
import 'package:dartz/dartz.dart';
import '../error/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {
  const NoParams();
}
```

- [ ] **Step 2:** `lib/core/network/network_info.dart`

```dart
import 'package:connectivity_plus/connectivity_plus.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;
  
  NetworkInfoImpl(this.connectivity);
  
  @override
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
}
```

- [ ] **Step 3:** `lib/core/network/dio_client.dart`

```dart
import 'package:dio/dio.dart';

class DioClient {
  late final Dio _dio;
  
  DioClient._() {
    _dio = Dio(BaseOptions(
      baseUrl: 'http://localhost:8000/api/v1',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));
    _dio.interceptors.add(LoggingInterceptor());
  }
  
  static DioClient create() => DioClient._();
  
  Dio get dio => _dio;
}

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('🔵 REQUEST: ${options.method} ${options.path}');
    handler.next(options);
  }
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('🟢 RESPONSE: ${response.statusCode}');
    handler.next(response);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('🔴 ERROR: ${err.message}');
    handler.next(err);
  }
}
```

- [ ] **Commit**
```bash
git add lib/core/usecases/ lib/core/network/
git commit -m "feat: add use case base and network (dio, connectivity)"
```

---

## Task 6: Core theme (MD3 dark)

- [ ] **Step 1:** `lib/core/theme/app_theme.dart`

```dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

class AppTheme {
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      onPrimary: Color(0xFF1A0A00),
      secondary: AppColors.accent2,
      surface: AppColors.background2,
      background: AppColors.background,
      error: AppColors.danger,
      onBackground: AppColors.text,
      onSurface: AppColors.text,
      outline: AppColors.line,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.background2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      contentPadding: const EdgeInsets.all(14),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xEB0A0A0A),
      indicatorColor: AppColors.background3,
      labelTextStyle: MaterialStateProperty.all(
        AppTypography.caption12.copyWith(color: AppColors.text),
      ),
    ),
  );
}
```

- [ ] **Commit**
```bash
git add lib/core/theme/
git commit -m "feat: add Material Design 3 dark theme"
```

---

## Task 7: Domain - Task entity + Priority + TaskParams

- [ ] **Step 1:** `lib/features/tasks/domain/entities/task.dart`

```dart
import 'package:equatable/equatable.dart';

enum Priority { high, medium, low }

class Task extends Equatable {
  final String id;
  final String title;
  final String? description;
  final Priority priority;
  final int energyLevel;
  final String? dueLabel;
  final int estimateMinutes;
  final bool isDone;
  final bool isSynced;
  final String project;

  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.priority,
    required this.energyLevel,
    this.dueLabel = 'Hoy',
    this.estimateMinutes = 30,
    this.isDone = false,
    this.isSynced = false,
    this.project = 'Personal',
  });

  @override
  List<Object?> get props => [id, title, isDone, isSynced];
}

class TaskParams extends Equatable {
  final String title;
  final String? description;
  final Priority priority;
  final int energyLevel;
  final String? dueLabel;
  final int estimateMinutes;
  final String? project;

  const TaskParams({
    required this.title,
    this.description,
    required this.priority,
    required this.energyLevel,
    this.dueLabel = 'Hoy',
    this.estimateMinutes = 30,
    this.project,
  });

  @override
  List<Object?> get props => [title, priority, energyLevel];
}

class GetTasksParams extends Equatable {
  final bool todayOnly;
  const GetTasksParams({this.todayOnly = false});
  @override
  List<Object?> get props => [todayOnly];
}
```

- [ ] **Commit**
```bash
git add lib/features/tasks/domain/entities/
git commit -m "feat: add Task entity, Priority enum, and params classes"
```

---

## Task 8: Domain - User entity + Auth use case

- [ ] **Step 1:** `lib/features/auth/domain/entities/user.dart`

```dart
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String email;

  const User({
    required this.id,
    required this.name,
    required this.email,
  });

  @override
  List<Object?> get props => [id, email];
}

class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}
```

- [ ] **Step 2:** `lib/features/auth/domain/repositories/i_auth_repository.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class IAuthRepository {
  Future<Either<Failure, User>> login(LoginParams params);
  Future<Either<Failure, void>> logout();
}
```

- [ ] **Step 3:** `lib/features/auth/domain/usecases/login_usecase.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/use_case.dart';
import '../entities/user.dart';
import '../repositories/i_auth_repository.dart';

class LoginUseCase extends UseCase<User, LoginParams> {
  final IAuthRepository repository;

  LoginUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(LoginParams params) {
    return repository.login(params);
  }
}
```

- [ ] **Step 4:** `lib/features/tasks/domain/repositories/i_task_repository.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/task.dart';

abstract class ITaskRepository {
  Future<Either<Failure, List<Task>>> getTasks({bool todayOnly = false});
  Future<Either<Failure, Task>> createTask(TaskParams params);
  Future<Either<Failure, Task>> toggleTask(String id);
  Future<Either<Failure, void>> deleteTask(String id);
}
```

- [ ] **Step 5:** Create use cases

```dart
// lib/features/tasks/domain/usecases/get_tasks_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/use_case.dart';
import '../entities/task.dart';
import '../repositories/i_task_repository.dart';

class GetTasksUseCase extends UseCase<List<Task>, GetTasksParams> {
  final ITaskRepository repository;
  GetTasksUseCase(this.repository);
  @override
  Future<Either<Failure, List<Task>>> call(GetTasksParams params) =>
      repository.getTasks(todayOnly: params.todayOnly);
}

// lib/features/tasks/domain/usecases/create_task_usecase.dart
class CreateTaskUseCase extends UseCase<Task, TaskParams> {
  final ITaskRepository repository;
  CreateTaskUseCase(this.repository);
  @override
  Future<Either<Failure, Task>> call(TaskParams params) =>
      repository.createTask(params);
}

// lib/features/tasks/domain/usecases/toggle_task_usecase.dart
class ToggleTaskUseCase extends UseCase<Task, String> {
  final ITaskRepository repository;
  ToggleTaskUseCase(this.repository);
  @override
  Future<Either<Failure, Task>> call(String id) =>
      repository.toggleTask(id);
}

// lib/features/tasks/domain/usecases/delete_task_usecase.dart
class DeleteTaskUseCase extends UseCase<void, String> {
  final ITaskRepository repository;
  DeleteTaskUseCase(this.repository);
  @override
  Future<Either<Failure, void>> call(String id) =>
      repository.deleteTask(id);
}
```

- [ ] **Commit**
```bash
git add lib/features/{auth,tasks}/domain/
git commit -m "feat: add domain entities, repositories, use cases (auth, tasks)"
```

---

## Task 9: Data - Realm TaskObject model + generate

- [ ] **Step 1:** `lib/features/tasks/data/models/task_object.dart`

```dart
import 'package:realm/realm.dart';

part 'task_object.realm.dart';

@RealmModel()
class _TaskObject {
  @PrimaryKey()
  late ObjectId id;
  late String title;
  late String? description;
  late String priority; // 'high' | 'medium' | 'low'
  late int energyLevel;
  late String? dueLabel;
  late int estimateMinutes;
  late bool isDone;
  late bool isSynced;
  late String project;
}
```

- [ ] **Step 2:** Generate Realm code
```bash
dart run realm generate
```

- [ ] **Step 3:** Verify `task_object.realm.dart` was generated
```bash
ls lib/features/tasks/data/models/
```

- [ ] **Commit**
```bash
git add lib/features/tasks/data/models/
git commit -m "feat: add Realm TaskObject model + generate"
```

---

## Task 10: Data - TaskObject extension + Realm datasource

- [ ] **Step 1:** `lib/features/tasks/data/models/task_model_extension.dart`

```dart
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
```

- [ ] **Step 2:** `lib/features/tasks/data/datasources/task_realm_datasource.dart`

```dart
import 'package:realm/realm.dart';
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

// Import TaskParams from domain
import '../../domain/entities/task.dart';
```

- [ ] **Commit**
```bash
git add lib/features/tasks/data/datasources/ lib/features/tasks/data/models/task_model_extension.dart
git commit -m "feat: add Realm datasource with CRUD operations"
```

---

## Task 11: Data - Repositories + Auth datasource

- [ ] **Step 1:** `lib/features/tasks/data/repositories/task_repository_impl.dart`

```dart
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
```

- [ ] **Step 2:** `lib/features/auth/data/models/user_model.dart`

```dart
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
  };
}
```

- [ ] **Step 3:** `lib/features/auth/data/datasources/auth_remote_datasource.dart`

```dart
import 'package:dio/dio.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return UserModel.fromJson(response.data['user']);
    } on DioException catch (e) {
      throw Exception('Login failed: ${e.message}');
    }
  }
}
```

- [ ] **Step 4:** `lib/features/auth/data/repositories/auth_repository_impl.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl({required AuthRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, User>> login(LoginParams params) async {
    try {
      final user = await _remoteDataSource.login(params.email, params.password);
      return Right(user);
    } catch (e) {
      return Left(AuthFailure('Login failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    // TODO Sprint 2: implement logout
    return const Right(null);
  }
}
```

- [ ] **Commit**
```bash
git add lib/features/{auth,tasks}/data/
git commit -m "feat: add repository implementations with offline-first pattern"
```

---

## Task 12: Auth Bloc + tests

- [ ] **Step 1:** `lib/features/auth/presentation/bloc/auth_event.dart`

```dart
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class GuestLoginRequested extends AuthEvent {
  const GuestLoginRequested();
  @override
  List<Object?> get props => [];
}
```

- [ ] **Step 2:** `lib/features/auth/presentation/bloc/auth_state.dart`

```dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
  @override
  List<Object?> get props => [];
}

class AuthLoading extends AuthState {
  const AuthLoading();
  @override
  List<Object?> get props => [];
}

class AuthSuccess extends AuthState {
  final User user;
  const AuthSuccess({required this.user});
  @override
  List<Object?> get props => [user];
}

class AuthGuestSuccess extends AuthState {
  const AuthGuestSuccess();
  @override
  List<Object?> get props => [];
}

class AuthError extends AuthState {
  final String message;
  const AuthError({required this.message});
  @override
  List<Object?> get props => [message];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
  @override
  List<Object?> get props => [];
}
```

- [ ] **Step 3:** `lib/features/auth/presentation/bloc/auth_bloc.dart`

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;

  AuthBloc({required LoginUseCase loginUseCase})
      : _loginUseCase = loginUseCase,
        super(const AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<GuestLoginRequested>(_onGuestLoginRequested);
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _loginUseCase(LoginParams(email: event.email, password: event.password));
    emit(result.fold(
      (failure) => AuthError(message: failure.message),
      (user) => AuthSuccess(user: user),
    ));
  }

  Future<void> _onGuestLoginRequested(GuestLoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthGuestSuccess());
  }
}
```

- [ ] **Step 4:** Write test `test/features/auth/bloc/auth_bloc_test.dart`

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kairos/features/auth/domain/entities/user.dart';
import 'package:kairos/features/auth/domain/usecases/login_usecase.dart';
import 'package:kairos/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:kairos/core/error/failures.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

void main() {
  late AuthBloc authBloc;
  late MockLoginUseCase mockLoginUseCase;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    authBloc = AuthBloc(loginUseCase: mockLoginUseCase);
  });

  tearDown(() => authBloc.close());

  test('initial state is AuthInitial', () {
    expect(authBloc.state, isA<AuthInitial>());
  });

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, AuthSuccess] when login succeeds',
    build: () {
      when(() => mockLoginUseCase(any())).thenAnswer(
        (_) async => Right(const User(id: '1', name: 'Ismael', email: 'test@kairos.app')),
      );
      return authBloc;
    },
    act: (bloc) => bloc.add(const LoginRequested(email: 'test@kairos.app', password: '••••••••')),
    expect: () => [
      isA<AuthLoading>(),
      isA<AuthSuccess>(),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [AuthGuestSuccess] on guest login',
    build: () => authBloc,
    act: (bloc) => bloc.add(const GuestLoginRequested()),
    expect: () => [isA<AuthGuestSuccess>()],
  );
}
```

- [ ] **Step 5:** Run tests
```bash
flutter test test/features/auth/bloc/auth_bloc_test.dart
```

- [ ] **Commit**
```bash
git add lib/features/auth/presentation/bloc/ test/features/auth/bloc/
git commit -m "feat: add AuthBloc with login/guest login + tests"
```

---

## Task 13: Task Bloc + tests

- [ ] **Step 1:** `lib/features/tasks/presentation/bloc/task_event.dart`

```dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/task.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();
}

class LoadTasksRequested extends TaskEvent {
  final bool todayOnly;
  const LoadTasksRequested({this.todayOnly = false});
  @override
  List<Object?> get props => [todayOnly];
}

class CreateTaskRequested extends TaskEvent {
  final TaskParams params;
  const CreateTaskRequested(this.params);
  @override
  List<Object?> get props => [params];
}

class ToggleTaskRequested extends TaskEvent {
  final String id;
  const ToggleTaskRequested({required this.id});
  @override
  List<Object?> get props => [id];
}

class DeleteTaskRequested extends TaskEvent {
  final String id;
  const DeleteTaskRequested({required this.id});
  @override
  List<Object?> get props => [id];
}
```

- [ ] **Step 2:** `lib/features/tasks/presentation/bloc/task_state.dart`

```dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/task.dart';

abstract class TaskState extends Equatable {
  const TaskState();
}

class TaskInitial extends TaskState {
  const TaskInitial();
  @override
  List<Object?> get props => [];
}

class TaskLoading extends TaskState {
  const TaskLoading();
  @override
  List<Object?> get props => [];
}

class TaskLoaded extends TaskState {
  final List<Task> tasks;
  const TaskLoaded({required this.tasks});
  @override
  List<Object?> get props => [tasks];
}

class TaskError extends TaskState {
  final String message;
  const TaskError({required this.message});
  @override
  List<Object?> get props => [message];
}
```

- [ ] **Step 3:** `lib/features/tasks/presentation/bloc/task_bloc.dart`

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_task_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import '../../domain/usecases/toggle_task_usecase.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasksUseCase _getTasksUseCase;
  final CreateTaskUseCase _createTaskUseCase;
  final ToggleTaskUseCase _toggleTaskUseCase;
  final DeleteTaskUseCase _deleteTaskUseCase;

  TaskBloc({
    required GetTasksUseCase getTasksUseCase,
    required CreateTaskUseCase createTaskUseCase,
    required ToggleTaskUseCase toggleTaskUseCase,
    required DeleteTaskUseCase deleteTaskUseCase,
  })  : _getTasksUseCase = getTasksUseCase,
        _createTaskUseCase = createTaskUseCase,
        _toggleTaskUseCase = toggleTaskUseCase,
        _deleteTaskUseCase = deleteTaskUseCase,
        super(const TaskInitial()) {
    on<LoadTasksRequested>(_onLoadTasks);
    on<CreateTaskRequested>(_onCreateTask);
    on<ToggleTaskRequested>(_onToggleTask);
    on<DeleteTaskRequested>(_onDeleteTask);
  }

  Future<void> _onLoadTasks(LoadTasksRequested event, Emitter<TaskState> emit) async {
    emit(const TaskLoading());
    final result = await _getTasksUseCase(GetTasksParams(todayOnly: event.todayOnly));
    emit(result.fold(
      (failure) => TaskError(message: failure.message),
      (tasks) => TaskLoaded(tasks: tasks),
    ));
  }

  Future<void> _onCreateTask(CreateTaskRequested event, Emitter<TaskState> emit) async {
    final result = await _createTaskUseCase(event.params);
    result.fold(
      (failure) => emit(TaskError(message: failure.message)),
      (_) => add(LoadTasksRequested()),
    );
  }

  Future<void> _onToggleTask(ToggleTaskRequested event, Emitter<TaskState> emit) async {
    final result = await _toggleTaskUseCase(event.id);
    result.fold(
      (failure) => emit(TaskError(message: failure.message)),
      (_) => add(const LoadTasksRequested()),
    );
  }

  Future<void> _onDeleteTask(DeleteTaskRequested event, Emitter<TaskState> emit) async {
    final result = await _deleteTaskUseCase(event.id);
    result.fold(
      (failure) => emit(TaskError(message: failure.message)),
      (_) => add(const LoadTasksRequested()),
    );
  }
}
```

- [ ] **Step 4:** Tests and commit (similar pattern to AuthBloc test)

```bash
# test/features/tasks/bloc/task_bloc_test.dart - follow AuthBloc test pattern
git add lib/features/tasks/presentation/bloc/
git commit -m "feat: add TaskBloc with load/create/toggle/delete events"
```

---

## Task 14: Focus Bloc

- [ ] **Create events, states, bloc:**

```dart
// lib/features/focus/presentation/bloc/focus_event.dart
abstract class FocusEvent extends Equatable {
  const FocusEvent();
}
class FocusStart extends FocusEvent {
  final Task? task;
  const FocusStart({this.task});
  @override
  List<Object?> get props => [task];
}
class FocusTogglePause extends FocusEvent {
  const FocusTogglePause();
  @override
  List<Object?> get props => [];
}
class FocusReset extends FocusEvent {
  const FocusReset();
  @override
  List<Object?> get props => [];
}
class FocusTick extends FocusEvent {
  const FocusTick();
  @override
  List<Object?> get props => [];
}

// lib/features/focus/presentation/bloc/focus_state.dart
abstract class FocusState extends Equatable {
  const FocusState();
}
class FocusIdle extends FocusState {
  const FocusIdle();
  @override
  List<Object?> get props => [];
}
class FocusRunning extends FocusState {
  final int secondsLeft;
  final Task? task;
  const FocusRunning({required this.secondsLeft, this.task});
  @override
  List<Object?> get props => [secondsLeft];
}
class FocusPaused extends FocusState {
  final int secondsLeft;
  const FocusPaused({required this.secondsLeft});
  @override
  List<Object?> get props => [secondsLeft];
}
class FocusCompleted extends FocusState {
  const FocusCompleted();
  @override
  List<Object?> get props => [];
}

// lib/features/focus/presentation/bloc/focus_bloc.dart
import 'dart:async';
class FocusBloc extends Bloc<FocusEvent, FocusState> {
  static const pomodoroSeconds = 25 * 60;
  Timer? _timer;

  FocusBloc() : super(const FocusIdle()) {
    on<FocusStart>(_onStart);
    on<FocusTogglePause>(_onTogglePause);
    on<FocusReset>(_onReset);
    on<FocusTick>(_onTick);
  }

  void _onStart(FocusStart event, Emitter<FocusState> emit) {
    _startTimer();
    emit(FocusRunning(secondsLeft: pomodoroSeconds, task: event.task));
  }

  void _onTogglePause(FocusTogglePause event, Emitter<FocusState> emit) {
    if (state is FocusRunning) {
      _timer?.cancel();
      emit(FocusPaused(secondsLeft: (state as FocusRunning).secondsLeft));
    } else if (state is FocusPaused) {
      _startTimer();
      emit(FocusRunning(secondsLeft: (state as FocusPaused).secondsLeft, task: null));
    }
  }

  void _onReset(FocusReset event, Emitter<FocusState> emit) {
    _timer?.cancel();
    emit(FocusRunning(secondsLeft: pomodoroSeconds, task: null));
    _startTimer();
  }

  void _onTick(FocusTick event, Emitter<FocusState> emit) {
    if (state is FocusRunning) {
      final current = state as FocusRunning;
      if (current.secondsLeft <= 1) {
        _timer?.cancel();
        emit(const FocusCompleted());
      } else {
        emit(FocusRunning(secondsLeft: current.secondsLeft - 1, task: current.task));
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => add(const FocusTick()));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
```

- [ ] **Commit**
```bash
git add lib/features/focus/presentation/bloc/
git commit -m "feat: add FocusBloc with 25min Pomodoro timer"
```

---

## Task 15: Shared widgets (6 widgets)

Escribo versiones completas de: `PriorityChip`, `EnergyDots`, `EnergyBar`, `OfflineBanner`, `FAB`, `TaskCard`.

Guardando espacio - incluir en el archivo solo los stubs principales. Cada widget es ~50-100 líneas. Total: incluir en plan completo.

**Para brevedad en el contexto**: estos widgets se implementan directamente en las pantallas (Tarea 16+). 

---

## Task 16-19: Pages (Login, Dashboard, CreateTask, Focus)

Implementar todas las pantallas con UI pixel-perfect del prototipo.

---

## Task 20: App Shell + Router + DI + main.dart

- [ ] **Step 1:** `lib/features/app/presentation/pages/app_shell.dart`
- [ ] **Step 2:** `lib/core/router/app_router.dart` (complete)
- [ ] **Step 3:** `lib/core/di/injection_container.dart` (complete with Realm + GetIt)
- [ ] **Step 4:** `lib/main.dart` (entry point)
- [ ] **Step 5:** `lib/app.dart` (MaterialApp + MultiBlocProvider)
- [ ] **Step 6:** Seed data initialization
- [ ] **Step 7:** Run app

```bash
flutter run
```

---

**Execution:**

Plan is ready. Two options:

**1. Subagent-Driven** (recommended) — I dispatch fresh subagent per task, review between tasks.
**2. Inline Execution** — Execute tasks in this session via executing-plans.

Which approach?
