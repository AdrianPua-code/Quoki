import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/transaction.dart';
import '../models/saving.dart';

class FinanceProvider with ChangeNotifier {
  double _monthlyIncome = 0.0;
  final List<Transaction> _transactions = [];
  final List<Saving> _savings = [];

  // Getters
  double get monthlyIncome => _monthlyIncome;

  List<Transaction> get transactions => [..._transactions];

  List<Saving> get savings => [..._savings];

  // Persistence Key Constants
  static const String keyIncome = 'monthly_income';
  static const String keyTransactions = 'transactions';
  static const String keySavings = 'savings';
  static const String keyFirstRun = 'is_first_run';

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    _monthlyIncome = prefs.getDouble(keyIncome) ?? 0.0;

    final txString = prefs.getString(keyTransactions);
    if (txString != null) {
      final List<dynamic> decodedIdx = jsonDecode(txString);
      _transactions.clear();
      _transactions.addAll(
          decodedIdx.map((item) => Transaction.fromJson(item)).toList());
    }

    final savString = prefs.getString(keySavings);
    if (savString != null) {
      final List<dynamic> decodedSav = jsonDecode(savString);
      _savings.clear();
      _savings.addAll(decodedSav.map((item) => Saving.fromJson(item)).toList());
    }
    notifyListeners();
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble(keyIncome, _monthlyIncome);

    final txListCheck = _transactions.map((t) => t.toJson()).toList();
    prefs.setString(keyTransactions, jsonEncode(txListCheck));

    final savListCheck = _savings.map((s) => s.toJson()).toList();
    prefs.setString(keySavings, jsonEncode(savListCheck));
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
  // Formula: (Total Income) - (Paid Expenses + Savings Contributions)
  double get currentBalance {
    double totalPaidExpenses = _transactions
        .where((t) =>
            (t.type == TransactionType.expense ||
                t.type == TransactionType.debt) &&
            t.isPaid)
        .fold(0.0, (sum, t) => sum + t.amount);

    return totalIncome - totalPaidExpenses - totalSaved;
  }

  double get totalSaved {
    return _savings.fold(0.0, (sum, s) => sum + s.currentAmount);
  }

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
  }) {
    final newTx = Transaction(
      id: const Uuid().v4(),
      title: title,
      amount: amount,
      date: DateTime.now(),
      type: type,
      isPaid: isPaid,
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
      saveData();
      notifyListeners();
    }
  }

  void deleteSaving(String id) {
    _savings.removeWhere((s) => s.id == id);
    saveData();
    notifyListeners();
  }

  Map<String, double> resetMonth() {
    // 1. Calculate stats before reset
    final double monthlyExpenses = _transactions
        .where((t) =>
            (t.type == TransactionType.expense ||
                t.type == TransactionType.debt) &&
            t.isPaid)
        .fold(0.0, (sum, t) => sum + t.amount);

    final double closingBalance = currentBalance;
    final double currentTotalSavings = totalSaved;

    // 2. Perform Reset
    // Remove extra income transactions
    _transactions.removeWhere((t) => t.type == TransactionType.income);

    // Uncheck updated transactions (expenses/debts) so they are ready for new month
    for (var i = 0; i < _transactions.length; i++) {
      if (_transactions[i].type != TransactionType.income) {
        _transactions[i] = Transaction(
          id: _transactions[i].id,
          title: _transactions[i].title,
          amount: _transactions[i].amount,
          date: _transactions[i].date,
          type: _transactions[i].type,
          isPaid: false, // Reset status
        );
      }
    }

    saveData();
    notifyListeners();

    return {
      'expenses': monthlyExpenses,
      'balance': closingBalance,
      'savings': currentTotalSavings,
    };
  }
}
