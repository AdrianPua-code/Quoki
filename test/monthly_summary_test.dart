import 'package:flutter_test/flutter_test.dart';
import 'package:finance_app/models/monthly_summary.dart';

void main() {
  group('Monthly Summary Tests', () {
    setUp(() {
      // Inicialización para tests
    });

    test('MonthlySummary formattedMonth should work correctly', () {
      final summary = MonthlySummary(
        id: 'test',
        month: '2024-03',
        totalIncome: 1000.0,
        totalExpenses: 500.0,
        totalSavings: 200.0,
        finalBalance: 300.0,
        createdAt: DateTime.now(),
      );

      expect(summary.formattedMonth, 'Marzo 2024');
    });

    test('MonthlySummary savingsPercentage should work correctly', () {
      final summary = MonthlySummary(
        id: 'test',
        month: '2024-03',
        totalIncome: 1000.0,
        totalExpenses: 500.0,
        totalSavings: 200.0,
        finalBalance: 300.0,
        createdAt: DateTime.now(),
      );

      expect(summary.savingsPercentage, 20.0);
    });

    test('MonthlySummary savingsPercentage should handle zero income', () {
      final summary = MonthlySummary(
        id: 'test',
        month: '2024-03',
        totalIncome: 0.0,
        totalExpenses: 500.0,
        totalSavings: 200.0,
        finalBalance: -300.0,
        createdAt: DateTime.now(),
      );

      expect(summary.savingsPercentage, 0.0);
    });
  });
}