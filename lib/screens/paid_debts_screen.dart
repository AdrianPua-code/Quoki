import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/finance_provider.dart';
import '../models/transaction.dart';
import 'add_transaction_screen.dart';

class PaidDebtsScreen extends StatelessWidget {
  const PaidDebtsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    final paidDebts = provider.transactions
        .where((t) => t.type == TransactionType.debt && t.isPaid)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Deudas Pagadas')),
      body: paidDebts.isEmpty
          ? const Center(child: Text('No hay deudas pagadas.'))
          : ListView.builder(
              itemCount: paidDebts.length,
              itemBuilder: (ctx, index) {
                final tx = paidDebts[index];
                return Dismissible(
                  key: Key(tx.id),
                  background: Container(color: Colors.red),
                  onDismissed: (_) {
                    provider.deleteTransaction(tx.id);
                  },
                  child: Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => AddTransactionScreen(
                                    transactionToEdit: tx)));
                      },
                      leading: CircleAvatar(
                        backgroundColor: Colors.orange.withValues(alpha: 0.2),
                        child:
                            const Icon(Icons.credit_card, color: Colors.orange),
                      ),
                      title: Text(tx.title,
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text(tx.date.toString().split(' ')[0]),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            NumberFormat.currency(symbol: '\$')
                                .format(tx.amount),
                            style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          Checkbox(
                            value: tx.isPaid,
                            onChanged: (val) {
                              provider.toggleTransactionStatus(tx.id);
                              // It will automatically disappear from this list
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
