class DebtPayment {
  final String id;
  final String transactionId; // ID de la transacción de deuda
  final double amount;
  final DateTime date;
  final int installmentNumber; // Número de cuota (1, 2, 3...)
  final String paymentType; // 'regular' o 'extra' (abono)

  DebtPayment({
    required this.id,
    required this.transactionId,
    required this.amount,
    required this.date,
    required this.installmentNumber,
    required this.paymentType,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transactionId': transactionId,
      'amount': amount,
      'date': date.toIso8601String(),
      'installmentNumber': installmentNumber,
      'paymentType': paymentType,
    };
  }

  factory DebtPayment.fromJson(Map<String, dynamic> json) {
    return DebtPayment(
      id: json['id'],
      transactionId: json['transactionId'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
      installmentNumber: json['installmentNumber'],
      paymentType: json['paymentType'],
    );
  }
}