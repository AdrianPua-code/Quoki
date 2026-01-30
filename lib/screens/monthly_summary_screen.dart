import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import '../models/monthly_summary.dart';
import '../theme/app_theme.dart';

class MonthlySummaryScreen extends StatelessWidget {
  const MonthlySummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen Mensual'),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      body: Consumer<FinanceProvider>(
        builder: (ctx, provider, child) {
          final summaries = List<MonthlySummary>.from(provider.monthlySummaries)
            ..sort((a, b) => b.month.compareTo(a.month));

          if (summaries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No hay historial mensual',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Usa "Iniciar Nuevo Mes" para generar tu primer resumen',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: summaries.length,
            itemBuilder: (ctx, index) {
              final summary = summaries[index];
              return _buildSummaryCard(context, summary);
            },
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, MonthlySummary summary) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header con mes y año
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.primaryColor.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.formattedMonth,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Balance Final',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Text(
                  NumberFormat.currency(symbol: '\$').format(summary.finalBalance),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          
          // Estadísticas
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Fila de estadísticas principales
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'Ingresos',
                        summary.totalIncome,
                        Icons.arrow_upward_rounded,
                        const Color(0xFF00C853),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 60,
                      color: Colors.grey.shade200,
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'Gastos',
                        summary.totalExpenses,
                        Icons.arrow_downward_rounded,
                        const Color(0xFFFF5252),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Fila de ahorros
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.accentColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.savings_rounded,
                        color: AppTheme.accentColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ahorros',
                              style: TextStyle(
                                color: AppTheme.accentColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              NumberFormat.currency(symbol: '\$').format(summary.totalSavings),
                              style: const TextStyle(
                                color: AppTheme.accentColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${summary.savingsPercentage.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Botón de eliminar
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('¿Eliminar Resumen?'),
                            content: Text('¿Estás seguro de que quieres eliminar el resumen de ${summary.formattedMonth}?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancelar'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  Provider.of<FinanceProvider>(context, listen: false)
                                      .deleteMonthlySummary(summary.id);
                                  Navigator.pop(ctx);
                                },
                                child: const Text('Eliminar'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Eliminar'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, double amount, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            NumberFormat.compactCurrency(symbol: '\$').format(amount),
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}