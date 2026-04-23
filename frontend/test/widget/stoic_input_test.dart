import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kairos/widgets/stoic_input.dart';

void main() {
  group('StoicInput', () {
    testWidgets('renderiza con label', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: StoicInput(
            label: 'Email',
            controller: TextEditingController(),
          ),
        ),
      ));

      // StoicInput muestra el label en uppercase
      expect(find.text('EMAIL'), findsOneWidget);
    });

    testWidgets('acepta texto', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: StoicInput(
            label: 'Email',
            controller: controller,
          ),
        ),
      ));

      await tester.enterText(find.byType(TextField), 'test@example.com');
      expect(controller.text, 'test@example.com');
    });

    testWidgets('no lanza excepciones con obscure=true', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: StoicInput(
            label: 'Contraseña',
            controller: TextEditingController(),
            obscure: true,
          ),
        ),
      ));

      expect(tester.takeException(), isNull);
    });
  });
}
