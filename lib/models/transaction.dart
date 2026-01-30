class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionType type;
  bool isPaid;

  // Propiedades específicas para deudas con cuotas
  final int? totalInstallments; // Total de cuotas (solo para deudas)
  final double? installmentAmount; // Monto por cuota (solo para deudas)
  int paidInstallments; // Cuotas pagadas (se preserva entre meses)
  double extraPayments; // Abonos extra acumulados (se preserva entre meses)

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    this.isPaid = false,
    this.totalInstallments,
    this.installmentAmount,
    this.paidInstallments = 0,
    this.extraPayments = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type.index,
      'isPaid': isPaid,
      'totalInstallments': totalInstallments,
      'installmentAmount': installmentAmount,
      'paidInstallments': paidInstallments,
      'extraPayments': extraPayments,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      title: json['title'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
      type: TransactionType.values[json['type']],
      isPaid: json['isPaid'] ?? false,
      totalInstallments: json['totalInstallments'],
      installmentAmount: json['installmentAmount']?.toDouble(),
      paidInstallments: json['paidInstallments'] ?? 0,
      extraPayments: json['extraPayments']?.toDouble() ?? 0.0,
    );
  }

  // Getter para verificar si es una deuda con cuotas
  bool get hasInstallments =>
      type == TransactionType.debt &&
      totalInstallments != null &&
      totalInstallments! > 1 &&
      installmentAmount != null;
}

enum TransactionType {
  income,
  expense,
  debt,
}
