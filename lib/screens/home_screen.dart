import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import '../models/transaction.dart';
import '../widgets/summary_card.dart';
import 'add_transaction_screen.dart';
import 'savings_screen.dart';
import 'paid_debts_screen.dart';
import 'monthly_summary_screen.dart';
import 'debt_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    final balance = provider.currentBalance;
    final monthlyIncome = provider.monthlyIncome;
    final totalIncome = provider.totalIncome;
    // Calculate total expenses for display in card (based on transactions marked as expense)
    final expenses = provider.transactions
        .where((t) =>
            t.type == TransactionType.expense || t.type == TransactionType.debt)
        .fold(0.0, (sum, t) {
      if (t.hasInstallments) {
        return sum + t.installmentAmount!;
      }
      return sum + t.amount;
    });

    // Filter transactions to show: all except paid debts
    final displayTransactions = provider.transactions
        .where((t) => t.type != TransactionType.debt || !t.isPaid)
        .toList();

    return Scaffold(
      // Background color handled by theme
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_month_rounded,
                      size: 48, color: Colors.white),
                  SizedBox(height: 10),
                  Text('Menú',
                      style: TextStyle(color: Colors.white, fontSize: 24)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.history_rounded),
              title: const Text('Resumen Mensual'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const MonthlySummaryScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh_rounded),
              title: const Text('Iniciar Nuevo Mes'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('¿Iniciar Nuevo Mes?'),
                    content: const Text(
                        'Esto reiniciará tus gastos y eliminará ingresos extra. Ahorros se mantienen. ¿Estás seguro?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancelar')),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx); // Close confirmation
                          final stats = provider.resetMonth();

                          // Show Summary Dialog
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Resumen del Mes'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Gastos Totales: ${NumberFormat.currency(symbol: '\$').format(stats['expenses'])}'),
                                  const SizedBox(height: 8),
                                  Text(
                                      'Balance Final: ${NumberFormat.currency(symbol: '\$').format(stats['balance'])}'),
                                  const SizedBox(height: 8),
                                  Text(
                                      'Ahorro Total: ${NumberFormat.currency(symbol: '\$').format(stats['savings'])}'),
                                  const SizedBox(height: 20),
                                  if ((stats['savings'] ?? 0) > 0)
                                    const Center(
                                      child: Column(
                                        children: [
                                          Icon(Icons.emoji_events_rounded,
                                              color: Colors.amber, size: 40),
                                          SizedBox(height: 8),
                                          Text(
                                            '¡Felicidades por ahorrar este mes! 🎉',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green),
                                          ),
                                        ],
                                      ),
                                    )
                                ],
                              ),
                              actions: [
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('¡Genial!'),
                                )
                              ],
                            ),
                          );
                        },
                        child: const Text('Confirmar'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Mis Finanzas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, size: 28),
            tooltip: 'Deudas Pagadas',
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const PaidDebtsScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.savings_rounded, size: 28),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SavingsScreen()));
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddTransactionScreen()));
        },
        label: const Text('Agregar'),
        icon: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SummaryCard(
              balance: balance,
              income: totalIncome,
              expenses: expenses,
              onIncomeTap: () {
                showDialog(
                  context: context,
                  // Dialog theme handles shape
                  builder: (ctx) {
                    final incomeController =
                        TextEditingController(text: monthlyIncome.toString());
                    return AlertDialog(
                      title: const Text('Editar Ingreso Mensual Base'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Este es tu ingreso fijo mensual. Los ingresos extra se suman automáticamente.',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: incomeController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Nuevo Ingreso Base'),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancelar')),
                        ElevatedButton(
                            onPressed: () {
                              final newIncome =
                                  double.tryParse(incomeController.text);
                              if (newIncome != null && newIncome >= 0) {
                                provider.setMonthlyIncome(newIncome);
                                Navigator.pop(ctx);
                              }
                            },
                            child: const Text('Guardar')),
                      ],
                    );
                  },
                );
              },
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Transacciones',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            if (displayTransactions.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_rounded,
                          size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text('No hay transacciones activas',
                          style: TextStyle(color: Colors.grey.shade400)),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayTransactions.length,
                itemBuilder: (ctx, index) {
                  final tx = displayTransactions[index];
                  return Dismissible(
                    key: Key(tx.id),
                    background: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(20)),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.red),
                    ),
                    onDismissed: (_) {
                      provider.deleteTransaction(tx.id);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4))
                          ]),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        onTap: () {
                          if (tx.type == TransactionType.debt &&
                              tx.hasInstallments) {
                            // Para deudas con cuotas, ir a pantalla de detalles
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DebtDetailScreen(debt: tx),
                              ),
                            );
                          } else {
                            // Para otras transacciones, ir a edición normal
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddTransactionScreen(
                                  transactionToEdit: tx,
                                ),
                              ),
                            );
                          }
                        },
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor:
                              _getColorForType(tx.type).withValues(alpha: 0.2),
                          child: Icon(
                            _getIconForType(tx.type, tx.hasInstallments),
                            color: _getColorForType(tx.type),
                            size: 24,
                          ),
                        ),
                        title: Text(tx.title,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(DateFormat('MMM d, y').format(tx.date),
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                            if (tx.hasInstallments) ...[
                              const SizedBox(height: 2),
                              Consumer<FinanceProvider>(
                                builder: (ctx, provider, child) {
                                  final paidInstallments =
                                      provider.getPaidInstallments(tx.id);
                                  final totalInstallments =
                                      tx.totalInstallments!;
                                  return Text(
                                    '$paidInstallments/$totalInstallments cuotas pagadas',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color:
                                          paidInstallments == totalInstallments
                                              ? Colors.green
                                              : Colors.orange,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              NumberFormat.currency(symbol: '\$').format(
                                  tx.hasInstallments
                                      ? tx.installmentAmount!
                                      : tx.amount),
                              style: TextStyle(
                                  color: _getColorForType(tx.type),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16),
                            ),
                            if (tx.type == TransactionType.debt &&
                                tx.hasInstallments)
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey.shade400,
                              )
                            else if (tx.type != TransactionType.income)
                              Transform.scale(
                                scale: 1.2,
                                child: Checkbox(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5)),
                                  activeColor: Colors.grey.shade400,
                                  value: tx.isPaid,
                                  onChanged: (val) {
                                    provider.toggleTransactionStatus(tx.id);
                                  },
                                ),
                              )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Color _getColorForType(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return const Color(0xFF00C853);
      case TransactionType.expense:
        return const Color(0xFFFF5252);
      case TransactionType.debt:
        return const Color(0xFFFF9800);
    }
  }

  IconData _getIconForType(TransactionType type,
      [bool hasInstallments = false]) {
    switch (type) {
      case TransactionType.income:
        return Icons.arrow_upward_rounded;
      case TransactionType.expense:
        return Icons.shopping_bag_rounded;
      case TransactionType.debt:
        return hasInstallments
            ? Icons.payment_rounded
            : Icons.credit_card_rounded;
    }
  }
}
