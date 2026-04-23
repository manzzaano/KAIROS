import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

const _fallback =
    'La deuda no es condena, sino medida de lo que aún puedes dar. '
    'Epicteto diría: solo controlas tu esfuerzo presente, no el pasado acumulado. '
    'Hoy, completa una tarea pequeña. Un paso honesto vale más que mil promesas.';

class ReflectionService {
  final SupabaseClient _client;
  final String _functionsBaseUrl;

  ReflectionService({SupabaseClient? client, String? functionsBaseUrl})
      : _client = client ?? Supabase.instance.client,
        _functionsBaseUrl = functionsBaseUrl ??
            '${dotenv.env['SUPABASE_URL']!}/functions/v1';

  Stream<String> streamReflection({
    required int totalDebtMinutes,
    required int streakDays,
    required int sessionsCompleted,
    required int recentAbandons,
  }) async* {
    final session = _client.auth.currentSession;
    if (session == null) return;

    final request = http.Request(
      'POST',
      Uri.parse('$_functionsBaseUrl/debt-reflection'),
    );
    request.headers['Authorization'] = 'Bearer ${session.accessToken}';
    request.headers['Content-Type'] = 'application/json';
    request.body = jsonEncode({
      'total_debt_minutes': totalDebtMinutes,
      'streak_days': streakDays,
      'sessions_completed': sessionsCompleted,
      'recent_abandons': recentAbandons,
    });

    try {
      final streamedResponse = await http.Client().send(request);
      final buffer = StringBuffer();

      await for (final chunk
          in streamedResponse.stream.transform(utf8.decoder)) {
        buffer.write(chunk);
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
            try {
              final data =
                  jsonDecode(line.substring(6)) as Map<String, dynamic>;
              final t = data['text'] as String?;
              if (t != null && t.isNotEmpty) yield t;
            } catch (_) {}
          }
        }
      }
    } catch (_) {
      yield _fallback;
    }
  }
}
