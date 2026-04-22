import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'storage_service.dart';

class ApiClient {
  static final String _baseUrl =
      dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000/api/v1';
  static const Duration _connectTimeout = Duration(seconds: 10);
  static const Duration _receiveTimeout = Duration(seconds: 10);
  static const Duration _sendTimeout = Duration(seconds: 10);
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;

  ApiClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: _connectTimeout,
      receiveTimeout: _receiveTimeout,
      sendTimeout: _sendTimeout,
      contentType: 'application/json',
      responseType: ResponseType.json,
    ));

    _log(
        'ApiClient init · baseUrl=$_baseUrl · connect=$_connectTimeout · recv=$_receiveTimeout');

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await StorageService().getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        _log(
            '→ ${options.method} ${options.uri} · timeout=${options.connectTimeout}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        _log('← ${response.statusCode} ${response.requestOptions.uri}');
        handler.next(response);
      },
      onError: (err, handler) {
        _log('✗ ${err.type} · ${err.requestOptions.uri} · ${err.message}');
        handler.next(err);
      },
    ));
  }

  void _log(String msg) => print('[ApiClient] $msg');

  String _extractError(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map && data['detail'] is String) {
      return data['detail'] as String;
    }
    return e.message ?? fallback;
  }

  Future<Response<dynamic>> _postWithRetry(
    String path,
    Map<String, dynamic> body,
    String label,
  ) async {
    DioException? last;
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        _log('[$label] intento $attempt/$_maxRetries → $_baseUrl$path');
        final resp = await dio.post(path, data: body);
        _log('[$label] OK intento $attempt · ${resp.statusCode}');
        return resp;
      } on DioException catch (e) {
        last = e;
        _log('[$label] FALLO intento $attempt · ${e.type} · ${e.message}');
        final shouldRetry = _isRetryable(e) && attempt < _maxRetries;
        if (!shouldRetry) break;
        await Future.delayed(_retryDelay);
      }
    }
    throw last!;
  }

  bool _isRetryable(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode ?? 0;
        return code >= 500 && code < 600;
      default:
        return false;
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _postWithRetry(
        '/auth/login',
        {'email': email, 'password': password},
        'login',
      );
      if (response.statusCode != 200) {
        throw Exception('Inicio de sesión falló: ${response.statusCode}');
      }
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(_extractError(e, 'Inicio de sesión falló'));
    }
  }

  Future<Map<String, dynamic>> register(
      String email, String username, String password) async {
    try {
      final response = await _postWithRetry(
        '/auth/register',
        {'email': email, 'username': username, 'password': password},
        'register',
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Registro falló: ${response.statusCode}');
      }
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(_extractError(e, 'Registro falló'));
    }
  }

  Future<Map<String, dynamic>> oauthLogin(
      String provider, String idToken) async {
    try {
      final response = await _postWithRetry(
        '/auth/$provider',
        {'id_token': idToken},
        'oauth-$provider',
      );
      if (response.statusCode != 200) {
        throw Exception('Inicio con $provider falló: ${response.statusCode}');
      }
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(_extractError(e, 'Inicio con $provider falló'));
    }
  }

  Future<Map<String, dynamic>> createTask({
    required String title,
    required int priority,
    required int energy,
    required int estimatedMinutes,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final body = <String, dynamic>{
        'title': title,
        'priority': priority,
        'energy': energy,
        'estimated_minutes': estimatedMinutes,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      };
      final response = await _postWithRetry('/tasks/create', body, 'create-task');
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Crear tarea falló: ${response.statusCode}');
      }
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(_extractError(e, 'Crear tarea falló'));
    }
  }

  // ─── Tasks CRUD ─────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getTasksList({String status = 'all'}) async {
    try {
      _log('[list-tasks] GET /tasks/list?status=$status');
      final resp = await dio.get('/tasks/list', queryParameters: {'status': status});
      _log('[list-tasks] OK · ${resp.statusCode}');
      return Map<String, dynamic>.from(resp.data);
    } on DioException catch (e) {
      throw Exception(_extractError(e, 'Listar tareas falló'));
    }
  }

  Future<Map<String, dynamic>> getTask(int taskId) async {
    try {
      _log('[get-task] GET /tasks/$taskId');
      final resp = await dio.get('/tasks/$taskId');
      _log('[get-task] OK · ${resp.statusCode}');
      return Map<String, dynamic>.from(resp.data);
    } on DioException catch (e) {
      throw Exception(_extractError(e, 'Obtener tarea falló'));
    }
  }

  Future<Map<String, dynamic>> completeTask(int taskId) async {
    try {
      _log('[complete-task] PUT /tasks/$taskId/complete');
      final resp = await dio.put('/tasks/$taskId/complete', data: {});
      _log('[complete-task] OK · ${resp.statusCode}');
      return Map<String, dynamic>.from(resp.data);
    } on DioException catch (e) {
      throw Exception(_extractError(e, 'Completar tarea falló'));
    }
  }

  Future<Map<String, dynamic>> abandonTask(int taskId) async {
    try {
      _log('[abandon-task] PUT /tasks/$taskId/abandon');
      final resp = await dio.put('/tasks/$taskId/abandon', data: {});
      _log('[abandon-task] OK · ${resp.statusCode}');
      return Map<String, dynamic>.from(resp.data);
    } on DioException catch (e) {
      throw Exception(_extractError(e, 'Abandonar tarea falló'));
    }
  }

  Future<void> deleteTask(int taskId) async {
    try {
      _log('[delete-task] DELETE /tasks/$taskId');
      await dio.delete('/tasks/$taskId');
      _log('[delete-task] OK');
    } on DioException catch (e) {
      throw Exception(_extractError(e, 'Eliminar tarea falló'));
    }
  }

  // ─── Debt ────────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getProductivityDebt() async {
    try {
      _log('[get-debt] GET /tasks/debt');
      final resp = await dio.get('/tasks/debt');
      _log('[get-debt] OK · ${resp.statusCode}');
      return Map<String, dynamic>.from(resp.data);
    } on DioException catch (e) {
      throw Exception(_extractError(e, 'Obtener deuda falló'));
    }
  }

  Future<Map<String, dynamic>> payDebt(int minutesPaid) async {
    try {
      final resp = await _postWithRetry(
        '/tasks/debt/pay',
        {'minutes_paid': minutesPaid},
        'pay-debt',
      );
      return Map<String, dynamic>.from(resp.data);
    } on DioException catch (e) {
      throw Exception(_extractError(e, 'Pagar deuda falló'));
    }
  }

  // ─── Geofence ────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> validateZone(
    int taskId, {
    required double userLatitude,
    required double userLongitude,
  }) async {
    try {
      final resp = await _postWithRetry(
        '/tasks/$taskId/validate-zone',
        {'user_latitude': userLatitude, 'user_longitude': userLongitude},
        'validate-zone-$taskId',
      );
      return Map<String, dynamic>.from(resp.data);
    } on DioException catch (e) {
      throw Exception(_extractError(e, 'Validar zona falló'));
    }
  }

  // ─── Confessional ────────────────────────────────────────────────────────────

  Stream<String> getReflectionStream() async* {
    try {
      _log('[reflect] POST /confessional/reflect (stream)');
      final response = await dio.post<ResponseBody>(
        '/confessional/reflect',
        options: Options(
          responseType: ResponseType.stream,
          headers: {'Accept': 'text/event-stream'},
        ),
      );

      final buffer = StringBuffer();

      await for (final bytes in response.data!.stream) {
        buffer.write(utf8.decode(bytes, allowMalformed: true));

        final text = buffer.toString();
        buffer.clear();

        int searchFrom = 0;
        while (true) {
          final idx = text.indexOf('\n\n', searchFrom);
          if (idx == -1) {
            buffer.write(text.substring(searchFrom));
            break;
          }
          final message = text.substring(searchFrom, idx);
          searchFrom = idx + 2;

          for (final line in message.split('\n')) {
            if (!line.startsWith('data: ')) continue;
            final raw = line.substring(6).trim();
            if (raw.isEmpty) continue;
            try {
              final data = jsonDecode(raw) as String;
              if (data == '[DONE]') return;
              yield data;
            } catch (_) {
              if (raw != '[DONE]') yield raw;
            }
          }
        }
      }
    } on DioException catch (e) {
      throw Exception(_extractError(e, 'Streaming reflexión falló'));
    }
  }

  Future<Map<String, dynamic>> getDebtSeverity() async {
    try {
      _log('[debt-severity] GET /confessional/debt-severity');
      final resp = await dio.get('/confessional/debt-severity');
      _log('[debt-severity] OK · ${resp.statusCode}');
      return Map<String, dynamic>.from(resp.data);
    } on DioException catch (e) {
      throw Exception(_extractError(e, 'Obtener severidad de deuda falló'));
    }
  }

  // ─── Optimize (Gemini) ───────────────────────────────────────────────────────

  Future<Map<String, dynamic>> optimizeTasks(
      List<Map<String, dynamic>> tasks) async {
    try {
      final response = await _postWithRetry(
        '/tasks/optimize',
        {'tasks': tasks},
        'optimize',
      );
      if (response.statusCode != 200) {
        throw Exception('Optimización falló: ${response.statusCode}');
      }
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(_extractError(e, 'Optimización falló'));
    }
  }
}
