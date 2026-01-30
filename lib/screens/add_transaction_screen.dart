import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import '../models/transaction.dart';

class AddTransactionScreen extends StatefulWidget {
  final Transaction? transactionToEdit;

  const AddTransactionScreen({super.key, this.transactionToEdit});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  TransactionType _selectedType = TransactionType.expense;

  @override
  void initState() {
    super.initState();
    if (widget.transactionToEdit != null) {
      _titleController.text = widget.transactionToEdit!.title;
      _amountController.text = widget.transactionToEdit!.amount.toString();
      _selectedType = widget.transactionToEdit!.type;
    }
  }

  void _submitData() {
    if (_titleController.text.isEmpty || _amountController.text.isEmpty) return;

    final enteredTitle = _titleController.text;
    final enteredAmount = double.tryParse(_amountController.text);

    if (enteredAmount == null || enteredAmount <= 0) return;

    if (widget.transactionToEdit == null) {
      Provider.of<FinanceProvider>(context, listen: false).addTransaction(
        title: enteredTitle,
        amount: enteredAmount,
        type: _selectedType,
      );
    } else {
      Provider.of<FinanceProvider>(context, listen: false).updateTransaction(
        id: widget.transactionToEdit!.id,
        title: enteredTitle,
        amount: enteredAmount,
        type: _selectedType,
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transactionToEdit == null
            ? 'Agregar Transacción'
            : 'Editar Transacción'),
        actions: [
          if (widget.transactionToEdit != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('¿Eliminar Transacción?'),
                    content: const Text('Esta acción no se puede deshacer.'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancelar')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        onPressed: () {
                          Provider.of<FinanceProvider>(context, listen: false)
                              .deleteTransaction(widget.transactionToEdit!.id);
                          Navigator.pop(ctx); // Close Dialog
                          Navigator.pop(ctx); // Close Screen
                        },
                        child: const Text('Eliminar',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
            )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Monto'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            DropdownButton<TransactionType>(
              value: _selectedType,
              items: TransactionType.values.map((type) {
                String label;
                switch (type) {
                  case TransactionType.income:
                    label = 'INGRESO';
                    break;
                  case TransactionType.expense:
                    label = 'GASTO';
                    break;
                  case TransactionType.debt:
                    label = 'DEUDA';
                    break;
                }
                return DropdownMenuItem(
                  value: type,
                  child: Text(label),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedType = val);
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _submitData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(widget.transactionToEdit == null
                  ? 'Agregar'
                  : 'Guardar Cambios'),
            )
          ],
        ),
      ),
    );
  }
}
