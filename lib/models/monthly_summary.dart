class MonthlySummary {
  final String id;
  final String month; // Format: "YYYY-MM"
  final double totalIncome;
  final double totalExpenses;
  final double totalSavings;
  final double finalBalance;
  final DateTime createdAt;

  MonthlySummary({
    required this.id,
    required this.month,
    required this.totalIncome,
    required this.totalExpenses,
    required this.totalSavings,
    required this.finalBalance,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'month': month,
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'totalSavings': totalSavings,
      'finalBalance': finalBalance,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MonthlySummary.fromJson(Map<String, dynamic> json) {
    return MonthlySummary(
      id: json['id'],
      month: json['month'],
      totalIncome: json['totalIncome'],
      totalExpenses: json['totalExpenses'],
      totalSavings: json['totalSavings'],
      finalBalance: json['finalBalance'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Helper para obtener el nombre del mes formateado
  String get formattedMonth {
    final parts = month.split('-');
    final year = parts[0];
    final monthNum = int.parse(parts[1]);
    
    final monthNames = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    
    return '${monthNames[monthNum - 1]} $year';
  }

  // Calcular porcentaje de ahorro respecto a ingresos
  double get savingsPercentage {
    if (totalIncome == 0) return 0.0;
    return (totalSavings / totalIncome) * 100;
  }
}