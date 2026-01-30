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
  final _installmentsController = TextEditingController();
  final _installmentAmountController = TextEditingController();
  TransactionType _selectedType = TransactionType.expense;
  bool _hasInstallments = false;

  @override
  void initState() {
    super.initState();
    if (widget.transactionToEdit != null) {
      _titleController.text = widget.transactionToEdit!.title;
      _amountController.text = widget.transactionToEdit!.amount.toString();
      _selectedType = widget.transactionToEdit!.type;
      _hasInstallments = widget.transactionToEdit!.hasInstallments;
      if (_hasInstallments) {
        _installmentsController.text = widget.transactionToEdit!.totalInstallments.toString();
        _installmentAmountController.text = widget.transactionToEdit!.installmentAmount!.toStringAsFixed(2);
      }
    }
  }

  void _submitData() {
    if (_titleController.text.isEmpty || _amountController.text.isEmpty) return;

    final enteredTitle = _titleController.text;
    final enteredAmount = double.tryParse(_amountController.text);

    if (enteredAmount == null || enteredAmount <= 0) return;

    // Validación específica para deudas con cuotas
    if (_selectedType == TransactionType.debt && _hasInstallments) {
      final installments = int.tryParse(_installmentsController.text);
      final installmentAmount = double.tryParse(_installmentAmountController.text);

      if (installments == null || installments <= 1) {
        _showErrorDialog('Debes especificar al menos 2 cuotas para activar el plan de pagos.');
        return;
      }

      if (installmentAmount == null || installmentAmount <= 0) {
        _showErrorDialog('Debes especificar un monto válido para cada cuota.');
        return;
      }

      if (widget.transactionToEdit == null) {
        Provider.of<FinanceProvider>(context, listen: false).addDebtWithInstallments(
          title: enteredTitle,
          totalAmount: enteredAmount,
          totalInstallments: installments,
          installmentAmount: installmentAmount,
        );
      } else {
        Provider.of<FinanceProvider>(context, listen: false).updateTransaction(
          id: widget.transactionToEdit!.id,
          title: enteredTitle,
          amount: enteredAmount,
          type: _selectedType,
          totalInstallments: installments,
          installmentAmount: installmentAmount,
        );
      }
    } else {
      // Para transacciones normales o deudas sin cuotas
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
    }

    Navigator.of(context).pop();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
                if (val != null) {
                  setState(() => _selectedType = val);
                  // Si el tipo no es deuda, desactivar cuotas
                  if (val != TransactionType.debt) {
                    _hasInstallments = false;
                  }
                }
              },
            ),
            
            // Opción de cuotas solo para deudas
            if (_selectedType == TransactionType.debt) ...[
              const SizedBox(height: 20),
              CheckboxListTile(
                title: const Text('¿Pagar en cuotas?'),
                subtitle: const Text('Activa para definir número de cuotas y monto mensual'),
                value: _hasInstallments,
                onChanged: (val) {
                  setState(() {
                    _hasInstallments = val ?? false;
                    if (!_hasInstallments) {
                      _installmentsController.clear();
                      _installmentAmountController.clear();
                    }
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
            ],
            
            // Campos de cuotas
            if (_selectedType == TransactionType.debt && _hasInstallments) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _installmentsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Número de Cuotas',
                        hintText: 'Ej: 12',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _installmentAmountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Monto por Cuota',
                        hintText: 'Ej: 100.00',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Total a pagar: \$${((_installmentsController.text.isNotEmpty ? int.tryParse(_installmentsController.text) ?? 1 : 1) * (_installmentAmountController.text.isNotEmpty ? double.tryParse(_installmentAmountController.text) ?? 0 : 0)).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
            
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
