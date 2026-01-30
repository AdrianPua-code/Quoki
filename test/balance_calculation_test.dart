import 'package:flutter_test/flutter_test.dart';
import 'package:finance_app/providers/finance_provider.dart';
import 'package:finance_app/models/transaction.dart';

void main() {
  group('Balance Calculation Tests', () {
    late FinanceProvider provider;

    setUp(() {
      provider = FinanceProvider();
    });

    test('Balance should include debt payments in deductions', () {
      // Arrange
      provider.setMonthlyIncome(3000.0);
      
      // Add a debt with installments
      provider.addDebtWithInstallments(
        title: 'Tarjeta de crédito',
        totalAmount: 1200.0,
        totalInstallments: 12,
        installmentAmount: 100.0,
      );
      
      // Get the debt transaction
      final debt = provider.transactions.firstWhere((t) => t.hasInstallments);
      
      // Act - Make a payment
      provider.addDebtPayment(
        transactionId: debt.id,
        amount: 100.0,
        paymentType: 'regular',
      );
      
      // Assert
      // Income: 3000.0
      // Debt Payment: 100.0  
      // Expected Balance: 3000 - 100 = 2900
      expect(provider.currentBalance, 2900.0);
    });

    test('Balance should handle extra debt payments', () {
      // Arrange
      provider.setMonthlyIncome(3000.0);
      
      provider.addDebtWithInstallments(
        title: 'Préstamo',
        totalAmount: 600.0,
        totalInstallments: 6,
        installmentAmount: 100.0,
      );
      
      final debt = provider.transactions.firstWhere((t) => t.hasInstallments);
      
      // Act - Make regular payment + extra payment
      provider.addDebtPayment(
        transactionId: debt.id,
        amount: 100.0,
        paymentType: 'regular',
      );
      
      provider.addDebtPayment(
        transactionId: debt.id,
        amount: 50.0,
        paymentType: 'extra',
      );
      
      // Assert
      // Income: 3000.0
      // Regular Payment: 100.0
      // Extra Payment: 50.0
      // Total Deductions: 150.0
      // Expected Balance: 3000 - 150 = 2850
      expect(provider.currentBalance, 2850.0);
    });

    test('Balance should mix old debts and installment debts correctly', () {
      // Arrange
      provider.setMonthlyIncome(3000.0);
      
      // Add old-style debt (marked as paid)
      provider.addTransaction(
        title: 'Deuda vieja',
        amount: 200.0,
        type: TransactionType.debt,
        isPaid: true,
      );
      
      // Add new installment debt
      provider.addDebtWithInstallments(
        title: 'Deuda nueva',
        totalAmount: 600.0,
        totalInstallments: 6,
        installmentAmount: 100.0,
      );
      
      final newDebt = provider.transactions.firstWhere((t) => t.hasInstallments);
      
      // Make payment on new debt
      provider.addDebtPayment(
        transactionId: newDebt.id,
        amount: 100.0,
        paymentType: 'regular',
      );
      
      // Assert
      // Income: 3000.0
      // Old Debt Paid: 200.0
      // New Debt Payment: 100.0
      // Total Deductions: 300.0
      // Expected Balance: 3000 - 300 = 2700
      expect(provider.currentBalance, 2700.0);
    });
  });
}