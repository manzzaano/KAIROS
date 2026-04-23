import 'package:flutter_test/flutter_test.dart';
import 'package:kairos/utils/debt_utils.dart';

void main() {
  group('analyzeDebtSeverity', () {
    test('retorna critical cuando ratio > 2', () {
      final result = analyzeDebtSeverity(
          totalDebtMinutes: 300, freeTimeMinutes: 100);
      expect(result['level'], 'critical');
    });

    test('retorna warning cuando ratio entre 1 y 2', () {
      final result = analyzeDebtSeverity(
          totalDebtMinutes: 150, freeTimeMinutes: 100);
      expect(result['level'], 'warning');
    });

    test('retorna healthy cuando ratio <= 1', () {
      final result = analyzeDebtSeverity(
          totalDebtMinutes: 50, freeTimeMinutes: 100);
      expect(result['level'], 'healthy');
    });

    test('no divide por cero cuando freeTime es 0', () {
      final result = analyzeDebtSeverity(
          totalDebtMinutes: 100, freeTimeMinutes: 0);
      expect(result['level'], 'critical');
    });
  });
}
