import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kairos/widgets/reflection_display.dart';

void main() {
  group('ReflectionDisplay', () {
    testWidgets('muestra texto cuando tiene contenido', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ReflectionDisplay(
            text: 'Epicteto diría que el control es tuyo.',
            isStreaming: false,
          ),
        ),
      ));

      await tester.pump();
      expect(
          find.text('Epicteto diría que el control es tuyo.'), findsOneWidget);
    });

    testWidgets('muestra placeholder cuando texto vacío y no streaming',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: const ReflectionDisplay(
            text: '',
            isStreaming: false,
          ),
        ),
      ));

      await tester.pump();
      expect(find.textContaining('GENERAR REFLEXIÓN'), findsOneWidget);
    });

    testWidgets('no lanza excepciones durante streaming', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: const ReflectionDisplay(
            text: 'Texto parcial...',
            isStreaming: true,
          ),
        ),
      ));

      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
