import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kairos/widgets/debt_severity_card.dart';

void main() {
  group('DebtSeverityCard', () {
    testWidgets('renderiza con datos críticos', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: DebtSeverityCard(severity: {
            'level': 'critical',
            'color': 'error600',
            'message': 'Deuda crítica',
            'total_debt_minutes': 300,
          }),
        ),
      ));

      await tester.pump();
      expect(find.byType(DebtSeverityCard), findsOneWidget);
    });

    testWidgets('renderiza con datos healthy', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: DebtSeverityCard(severity: {
            'level': 'healthy',
            'color': 'neutral50',
            'message': 'En balance',
            'total_debt_minutes': 30,
          }),
        ),
      ));

      await tester.pump();
      expect(find.byType(DebtSeverityCard), findsOneWidget);
    });

    testWidgets('muestra minutos de deuda formateados', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: DebtSeverityCard(severity: {
            'level': 'warning',
            'color': 'neutral400',
            'message': 'Deuda considerable',
            'total_debt_minutes': 90,
          }),
        ),
      ));

      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('90 minutos de deuda acumulada'), findsOneWidget);
    });
  });
}
