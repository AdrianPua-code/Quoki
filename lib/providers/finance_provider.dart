import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/transaction.dart';
import '../models/saving.dart';
import '../models/monthly_summary.dart';
import '../models/debt_payment.dart';
import '../models/user_setup.dart';

class FinanceProvider extends ChangeNotifier {
  double _monthlyIncome = 0.0;
  final List<Transaction> _transactions = [];
  final List<Saving> _savings = [];
  final List<DebtPayment> _debtPayments = [];
  final List<MonthlySummary> _monthlySummaries = [];
  double _currentMonthSavings = 0.0; // Track savings for current month only
  UserSetup? _userSetup;

  // Callback para cuando una deuda se completa
  Function(String)? onDebtCompleted;

  // Getters
  double get monthlyIncome => _monthlyIncome;

  List<Transaction> get transactions => List.unmodifiable(_transactions);

  List<Saving> get savings => List.unmodifiable(_savings);

  List<MonthlySummary> get monthlySummaries =>
      List.unmodifiable(_monthlySummaries);

  List<DebtPayment> get debtPayments => [..._debtPayments];

  UserSetup? get userSetup => _userSetup;

  // Persistence Key Constants
  static const String keyIncome = 'monthly_income';
  static const String keyTransactions = 'transactions';
  static const String keySavings = 'savings';
  static const String keyFirstRun = 'is_first_run';
  static const String keyMonthlySummaries = 'monthly_summaries';
  static const String keyDebtPayments = 'debt_payments';
  static const String keyUserSetup = 'user_setup';

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _monthlyIncome = prefs.getDouble('monthlyIncome') ?? 0.0;
    _currentMonthSavings = prefs.getDouble('currentMonthSavings') ?? 0.0;

    final txString = prefs.getString('transactions');
    if (txString != null) {
      final List<dynamic> txJson = jsonDecode(txString);
      _transactions.clear();
      _transactions.addAll(txJson.map((e) => Transaction.fromJson(e)));
    }

    final savingsString = prefs.getString('savings');
    if (savingsString != null) {
      final List<dynamic> savingsJson = jsonDecode(savingsString);
      _savings.clear();
      _savings.addAll(savingsJson.map((e) => Saving.fromJson(e)));
    }

    final summariesString = prefs.getString('monthlySummaries');
    if (summariesString != null) {
      final List<dynamic> summariesJson = jsonDecode(summariesString);
      _monthlySummaries.clear();
      _monthlySummaries
          .addAll(summariesJson.map((e) => MonthlySummary.fromJson(e)));
    }

    final debtPaymentsString = prefs.getString('debtPayments');
    if (debtPaymentsString != null) {
      final List<dynamic> debtPaymentsJson = jsonDecode(debtPaymentsString);
      _debtPayments.clear();
      _debtPayments
          .addAll(debtPaymentsJson.map((e) => DebtPayment.fromJson(e)));
    }

    final setupString = prefs.getString(keyUserSetup);
    if (setupString != null) {
      final setupJson = jsonDecode(setupString);
      _userSetup = UserSetup.fromJson(setupJson);
    }
    notifyListeners();
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('monthlyIncome', _monthlyIncome);
    await prefs.setDouble('currentMonthSavings', _currentMonthSavings);

    final txJson = _transactions.map((t) => t.toJson()).toList();
    await prefs.setString('transactions', jsonEncode(txJson));

    final savingsJson = _savings.map((s) => s.toJson()).toList();
    await prefs.setString('savings', jsonEncode(savingsJson));

    final summariesJson = _monthlySummaries.map((s) => s.toJson()).toList();
    await prefs.setString('monthlySummaries', jsonEncode(summariesJson));

    final debtPaymentsJson = _debtPayments.map((p) => p.toJson()).toList();
    await prefs.setString('debtPayments', jsonEncode(debtPaymentsJson));

    if (_userSetup != null) {
      prefs.setString(keyUserSetup, jsonEncode(_userSetup!.toJson()));
    }
  }

  Future<bool> checkFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyFirstRun) ?? true;
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyFirstRun, false);
    await saveData();
  }

  // Computed property: Current available balance
  // Formula: (Monthly Income or Total Income entries) - (Paid Expenses + Savings Contributions)
  // For simplicity based on prompt: "descontaran del ingreso" (deduct from income)
  double get totalIncome {
    double additionalIncome = _transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    return _monthlyIncome + additionalIncome;
  }

  // Computed property: Current available balance
  // Formula: (Total Income) - (Current Month Paid Expenses + Current Month Debt Payments + Savings Contributions)
  double get currentBalance {
    // 1. Solo gastos normales pagados (NO incluir deudas)
    double paidExpenses = _transactions
        .where((t) => t.type == TransactionType.expense && t.isPaid)
        .fold(0.0, (sum, t) => sum + t.amount);

    // 2. Deudas sin cuotas que están pagadas
    double paidSimpleDebts = _transactions
        .where((t) =>
            t.type == TransactionType.debt && !t.hasInstallments && t.isPaid)
        .fold(0.0, (sum, t) => sum + t.amount);

    // 3. Pagos de deudas con cuotas SOLO del mes actual (filtrar por mes y año actual)
    final now = DateTime.now();
    double currentMonthDebtPayments = _debtPayments
        .where((p) => p.date.month == now.month && p.date.year == now.year)
        .fold(0.0, (sum, p) => sum + p.amount);

    double totalDeductions =
        paidExpenses + paidSimpleDebts + currentMonthDebtPayments;

    // Restar solo ahorros del mes actual, no el total acumulado
    return totalIncome - totalDeductions - _currentMonthSavings;
  }

  double get totalSaved {
    return _savings.fold(0.0, (sum, s) => sum + s.currentAmount);
  }

  double get currentMonthSavings => _currentMonthSavings;

  // Setters / Actions
  void setMonthlyIncome(double amount) {
    _monthlyIncome = amount;
    saveData();
    notifyListeners();
  }

  void addTransaction({
    required String title,
    required double amount,
    required TransactionType type,
    bool isPaid = false,
    int? totalInstallments,
    double? installmentAmount,
  }) {
    final newTx = Transaction(
      id: const Uuid().v4(),
      title: title,
      amount: amount,
      date: DateTime.now(),
      type: type,
      isPaid: isPaid,
      totalInstallments: totalInstallments,
      installmentAmount: installmentAmount,
    );
    _transactions.add(newTx);
    saveData();
    notifyListeners();
  }

  void toggleTransactionStatus(String id) {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index != -1) {
      _transactions[index].isPaid = !_transactions[index].isPaid;
      saveData();
      notifyListeners();
    }
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    saveData();
    notifyListeners();
  }

  void updateTransaction({
    required String id,
    required String title,
    required double amount,
    required TransactionType type,
    int? totalInstallments,
    double? installmentAmount,
  }) {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index != -1) {
      final oldTx = _transactions[index];
      _transactions[index] = Transaction(
        id: oldTx.id,
        title: title,
        amount: amount,
        date: oldTx.date,
        type: type,
        isPaid: oldTx.isPaid,
        totalInstallments: totalInstallments ?? oldTx.totalInstallments,
        installmentAmount: installmentAmount ?? oldTx.installmentAmount,
      );
      saveData();
      notifyListeners();
    }
  }

  void addSaving(
      {required String goalName,
      required double targetAmount,
      double initialAmount = 0.0}) {
    final newSaving = Saving(
      id: const Uuid().v4(),
      goalName: goalName,
      targetAmount: targetAmount,
      currentAmount: initialAmount,
    );
    _savings.add(newSaving);
    saveData();
    notifyListeners();
  }

  void updateSavingAmount(String id, double amountToAdd) {
    final index = _savings.indexWhere((s) => s.id == id);
    if (index != -1) {
      _savings[index].currentAmount += amountToAdd;

      // Track current month savings (only for additions, not withdrawals)
      if (amountToAdd > 0) {
        _currentMonthSavings += amountToAdd;
      }

      saveData();
      notifyListeners();
    }
  }

  void deleteSaving(String id) {
    _savings.removeWhere((s) => s.id == id);
    saveData();
    notifyListeners();
  }

  void addMonthlySummary(MonthlySummary summary) {
    _monthlySummaries.add(summary);
    saveData();
    notifyListeners();
  }

  void deleteMonthlySummary(String id) {
    _monthlySummaries.removeWhere((s) => s.id == id);
    saveData();
    notifyListeners();
  }

  // Métodos específicos para gestión de deudas con cuotas
  void addDebtWithInstallments({
    required String title,
    required double totalAmount,
    required int totalInstallments,
    double? installmentAmount,
  }) {
    final monthlyInstallment =
        installmentAmount ?? (totalAmount / totalInstallments);

    final newDebt = Transaction(
      id: const Uuid().v4(),
      title: title,
      amount: totalAmount,
      date: DateTime.now(),
      type: TransactionType.debt,
      isPaid: false,
      totalInstallments: totalInstallments,
      installmentAmount: monthlyInstallment,
    );

    _transactions.add(newDebt);
    saveData();
    notifyListeners();
  }

  void addDebtPayment({
    required String transactionId,
    required double amount,
    required String paymentType, // 'regular' o 'extra'
  }) {
    final index = _transactions.indexWhere((t) => t.id == transactionId);
    if (index == -1 || !_transactions[index].hasInstallments) return;

    // Obtener el número de la siguiente cuota desde el Transaction
    final currentPaidInstallments = _transactions[index].paidInstallments;

    final newPayment = DebtPayment(
      id: const Uuid().v4(),
      transactionId: transactionId,
      amount: amount,
      date: DateTime.now(),
      installmentNumber:
          paymentType == 'regular' ? currentPaidInstallments + 1 : 0,
      paymentType: paymentType,
    );

    _debtPayments.add(newPayment);

    // Incrementar el contador de cuotas pagadas o acumular abono extra
    if (paymentType == 'regular') {
      _transactions[index].paidInstallments++;
    } else if (paymentType == 'extra') {
      _transactions[index].extraPayments += amount;
    }

    // Verificar si la deuda está completamente pagada
    _checkIfDebtIsFullyPaid(transactionId);

    saveData();
    notifyListeners();
  }

  List<DebtPayment> getPaymentsForDebt(String transactionId) {
    return _debtPayments
        .where((p) => p.transactionId == transactionId)
        .toList();
  }

  int getPaidInstallments(String transactionId) {
    final transaction = _transactions.firstWhere(
      (t) => t.id == transactionId,
      orElse: () => Transaction(
        id: '',
        title: '',
        amount: 0,
        date: DateTime.now(),
        type: TransactionType.expense,
      ),
    );
    return transaction.paidInstallments;
  }

  double getTotalPaidForDebt(String transactionId) {
    final transaction = _transactions.firstWhere(
      (t) => t.id == transactionId,
      orElse: () => Transaction(
        id: '',
        title: '',
        amount: 0,
        date: DateTime.now(),
        type: TransactionType.expense,
      ),
    );

    if (!transaction.hasInstallments) return 0.0;

    // Calcular total: cuotas regulares + abonos extra
    final regularPayments =
        transaction.paidInstallments * transaction.installmentAmount!;
    final extraPayments = transaction.extraPayments;

    return regularPayments + extraPayments;
  }

  bool isDebtFullyPaid(String transactionId) {
    final transaction = _transactions.firstWhere((t) => t.id == transactionId);
    if (!transaction.hasInstallments) return transaction.isPaid;

    // Verificar si el total pagado (cuotas + abonos extra) >= deuda total
    final totalPaid = getTotalPaidForDebt(transactionId);
    return totalPaid >= transaction.amount;
  }

  void _checkIfDebtIsFullyPaid(String transactionId) {
    if (isDebtFullyPaid(transactionId)) {
      final index = _transactions.indexWhere((t) => t.id == transactionId);
      if (index != -1) {
        // Verificar si ya estaba pagada para no emitir evento duplicado
        final wasAlreadyPaid = _transactions[index].isPaid;
        
        _transactions[index] = Transaction(
          id: _transactions[index].id,
          title: _transactions[index].title,
          amount: _transactions[index].amount,
          date: _transactions[index].date,
          type: _transactions[index].type,
          isPaid: true,
          totalInstallments: _transactions[index].totalInstallments,
          installmentAmount: _transactions[index].installmentAmount,
        );

        // Emitir evento solo si es la primera vez que se completa
        if (!wasAlreadyPaid) {
          onDebtCompleted?.call(transactionId);
        }
      }
    }
  }

  void updateDebtInstallments({
    required String transactionId,
    required int newTotalInstallments,
    required double newInstallmentAmount,
  }) {
    final index = _transactions.indexWhere((t) => t.id == transactionId);
    if (index != -1) {
      final oldTx = _transactions[index];
      _transactions[index] = Transaction(
        id: oldTx.id,
        title: oldTx.title,
        amount: newTotalInstallments * newInstallmentAmount,
        date: oldTx.date,
        type: oldTx.type,
        isPaid: false, // Resetear el estado de pago
        totalInstallments: newTotalInstallments,
        installmentAmount: newInstallmentAmount,
      );
      saveData();
      notifyListeners();
    }
  }

  // Métodos para manejar configuración del usuario
  void saveUserSetup(UserSetup setup) {
    _userSetup = setup;
    saveData();
    notifyListeners();
  }

  void completeOnboardingSetup(List<InitialExpense> expenses,
      List<InitialDebt> debts, List<InitialSaving> savings) {
    final setup = UserSetup(
      id: const Uuid().v4(),
      monthlyIncome: _monthlyIncome,
      mainExpenses: expenses,
      mainDebts: debts,
      savingsGoals: savings,
      createdAt: DateTime.now(),
    );
    saveUserSetup(setup);
  }

  Map<String, double> resetMonth() {
    // 1. Calculate stats before reset
    final now = DateTime.now();

    // Solo gastos normales y deudas SIN cuotas (las deudas con cuotas se cuentan en debtPayments)
    final double monthlyExpenses = _transactions
        .where((t) =>
            (t.type == TransactionType.expense ||
                (t.type == TransactionType.debt && !t.hasInstallments)) &&
            t.isPaid)
        .fold(0.0, (sum, t) => sum + t.amount);

    // Calculate payments from debt installments - ONLY for current month
    final double monthlyDebtPayments = _debtPayments
        .where((p) => p.date.month == now.month && p.date.year == now.year)
        .fold(0.0, (sum, p) => sum + p.amount);

    final double closingBalance = currentBalance;
    final double currentTotalSavings = totalSaved;
    final double currentTotalIncome = totalIncome;
    final double currentMonthSavingsAmount =
        _currentMonthSavings; // Save for summary

    // 2. Create Monthly Summary
    final currentMonth =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}';

    final monthlySummary = MonthlySummary(
      id: const Uuid().v4(),
      month: currentMonth,
      totalIncome: currentTotalIncome,
      totalExpenses: monthlyExpenses + monthlyDebtPayments,
      totalSavings: currentMonthSavingsAmount, // Use current month savings
      finalBalance: closingBalance,
      createdAt: now,
    );

    addMonthlySummary(monthlySummary);

    // 3. Perform Reset
    // Remove extra income transactions
    _transactions.removeWhere((t) => t.type == TransactionType.income);

    // Clear debt payments from current month (history is saved in monthly summary)
    // This ensures new month starts clean without previous month's payments
    _debtPayments.removeWhere(
        (p) => p.date.month == now.month && p.date.year == now.year);

    // Reset current month savings for new month
    _currentMonthSavings = 0.0;

    // Uncheck updated transactions (expenses/debts) so they are ready for new month
    // Preserve debt installment information and paid installments counter
    for (var i = 0; i < _transactions.length; i++) {
      if (_transactions[i].type != TransactionType.income) {
        _transactions[i] = Transaction(
          id: _transactions[i].id,
          title: _transactions[i].title,
          amount: _transactions[i].amount,
          date: _transactions[i].date,
          type: _transactions[i].type,
          isPaid: false, // Reset status for regular expenses
          totalInstallments:
              _transactions[i].totalInstallments, // Preserve installment info
          installmentAmount:
              _transactions[i].installmentAmount, // Preserve installment info
          paidInstallments:
              _transactions[i].paidInstallments, // Preserve paid count
          extraPayments:
              _transactions[i].extraPayments, // Preserve extra payments
        );
      }
    }

    saveData();
    notifyListeners();

    return {
      'expenses': monthlyExpenses + monthlyDebtPayments,
      'balance': closingBalance,
      'savings': currentTotalSavings,
    };
  }

  // Method to clear all app data (reset to initial state)
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();

    // Clear all relevant keys
    await prefs.remove(keyIncome);
    await prefs.remove(keyTransactions);
    await prefs.remove(keySavings);
    await prefs.remove(keyMonthlySummaries);
    await prefs.remove(keyDebtPayments);
    await prefs.remove(keyUserSetup);
    await prefs.remove(keyFirstRun); // Also reset first run flag

    // Reset all in-memory data
    _monthlyIncome = 0.0;
    _transactions.clear();
    _savings.clear();
    _monthlySummaries.clear();
    _debtPayments.clear();
    _userSetup = null;

    notifyListeners();
  }
}
