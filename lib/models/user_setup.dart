class UserSetup {
  final String id;
  final double monthlyIncome;
  final List<InitialExpense> mainExpenses;
  final List<InitialDebt> mainDebts;
  final List<InitialSaving> savingsGoals;
  final DateTime createdAt;

  UserSetup({
    required this.id,
    required this.monthlyIncome,
    required this.mainExpenses,
    required this.mainDebts,
    required this.savingsGoals,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'monthlyIncome': monthlyIncome,
      'mainExpenses': mainExpenses.map((e) => e.toJson()).toList(),
      'mainDebts': mainDebts.map((d) => d.toJson()).toList(),
      'savingsGoals': savingsGoals.map((s) => s.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserSetup.fromJson(Map<String, dynamic> json) {
    return UserSetup(
      id: json['id'],
      monthlyIncome: json['monthlyIncome'],
      mainExpenses: (json['mainExpenses'] as List)
          .map((e) => InitialExpense.fromJson(e))
          .toList(),
      mainDebts: (json['mainDebts'] as List)
          .map((d) => InitialDebt.fromJson(d))
          .toList(),
      savingsGoals: (json['savingsGoals'] as List)
          .map((s) => InitialSaving.fromJson(s))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class InitialExpense {
  final String title;
  final double amount;
  final bool isRecurring;

  InitialExpense({
    required this.title,
    required this.amount,
    required this.isRecurring,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'amount': amount,
      'isRecurring': isRecurring,
    };
  }

  factory InitialExpense.fromJson(Map<String, dynamic> json) {
    return InitialExpense(
      title: json['title'],
      amount: json['amount'],
      isRecurring: json['isRecurring'],
    );
  }
}

class InitialDebt {
  final String title;
  final double totalAmount;
  final int? totalInstallments;
  final double? installmentAmount;

  InitialDebt({
    required this.title,
    required this.totalAmount,
    this.totalInstallments,
    this.installmentAmount,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'totalAmount': totalAmount,
      'totalInstallments': totalInstallments,
      'installmentAmount': installmentAmount,
    };
  }

  factory InitialDebt.fromJson(Map<String, dynamic> json) {
    return InitialDebt(
      title: json['title'],
      totalAmount: json['totalAmount'],
      totalInstallments: json['totalInstallments'],
      installmentAmount: json['installmentAmount']?.toDouble(),
    );
  }

  bool get hasInstallments => totalInstallments != null && totalInstallments! > 1;
}

class InitialSaving {
  final String goalName;
  final double targetAmount;

  InitialSaving({
    required this.goalName,
    required this.targetAmount,
  });

  Map<String, dynamic> toJson() {
    return {
      'goalName': goalName,
      'targetAmount': targetAmount,
    };
  }

  factory InitialSaving.fromJson(Map<String, dynamic> json) {
    return InitialSaving(
      goalName: json['goalName'],
      targetAmount: json['targetAmount'],
    );
  }
}