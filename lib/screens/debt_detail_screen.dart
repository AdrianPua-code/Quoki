import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import '../models/transaction.dart';
import '../models/debt_payment.dart';
import '../theme/app_theme.dart';

class DebtDetailScreen extends StatefulWidget {
  final Transaction debt;

  const DebtDetailScreen({super.key, required this.debt});

  @override
  State<DebtDetailScreen> createState() => _DebtDetailScreenState();
}

class _DebtDetailScreenState extends State<DebtDetailScreen> {
  final _extraPaymentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Registrar callback para cuando la deuda se complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<FinanceProvider>(context, listen: false);
      provider.onDebtCompleted = _onDebtCompleted;
    });
  }

  @override
  void dispose() {
    _extraPaymentController.dispose();
    // Limpiar callback
    final provider = Provider.of<FinanceProvider>(context, listen: false);
    provider.onDebtCompleted = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    final payments = provider.getPaymentsForDebt(widget.debt.id);
    final paidInstallments = provider.getPaidInstallments(widget.debt.id);
    final totalPaid = provider.getTotalPaidForDebt(widget.debt.id);
    final isFullyPaid = provider.isDebtFullyPaid(widget.debt.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.debt.title),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta de resumen de la deuda
            _buildDebtSummaryCard(paidInstallments, totalPaid, isFullyPaid),

            const SizedBox(height: 24),

            // Sección de acciones
            if (!isFullyPaid) ...[
              _buildActionsSection(paidInstallments),
              const SizedBox(height: 24),
            ],

            // Sección de pagos realizados
            _buildPaymentsList(payments, totalPaid),

            const SizedBox(height: 24),

            // Botones de gestión
            _buildManagementButtons(isFullyPaid),
          ],
        ),
      ),
    );
  }

  Widget _buildDebtSummaryCard(
      int paidInstallments, double totalPaid, bool isFullyPaid) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF9800), Color(0xFFFF6B00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9800).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Resumen de Deuda',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isFullyPaid)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'PAGADA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (widget.debt.hasInstallments) ...[
            _buildSummaryRow('Total Deuda:', widget.debt.amount),
            _buildSummaryRow('Monto por Cuota:', widget.debt.installmentAmount!),
            _buildSummaryRow('Cuotas Pagadas:', '$paidInstallments / ${widget.debt.totalInstallments}'),
            _buildSummaryRow('Total Pagado:', totalPaid),
            _buildSummaryRow('Saldo Restante:', (widget.debt.amount - totalPaid)),
            _buildSummaryRow('Cuotas Pendientes:', '${widget.debt.totalInstallments! - paidInstallments}'),
          ] else ...[
            _buildSummaryRow('Total Deuda:', widget.debt.amount),
            _buildSummaryRow(
                'Estado:', widget.debt.isPaid ? 'Pagada' : 'Pendiente'),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          Text(
            value is double
                ? NumberFormat.currency(symbol: '\$').format(value)
                : value.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(int paidInstallments) {
    if (!widget.debt.hasInstallments) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Acciones Rápidas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Pagar cuota regular
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _payRegularInstallment(),
              icon: const Icon(Icons.payment_rounded),
              label: Text(
                'Pagar Cuota ${paidInstallments + 1}',
                style: const TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Abono extra
          TextField(
            controller: _extraPaymentController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Monto de Abono Extra',
              hintText: 'Ej: 50.00',
              prefixIcon: Icon(Icons.add_circle_outline),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _payExtraInstallment(),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text(
                'Hacer Abono Extra',
                style: TextStyle(fontSize: 16),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.accentColor,
                side: const BorderSide(color: AppTheme.accentColor),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsList(List<DebtPayment> payments, double totalPaid) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Historial de Pagos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Total: ${NumberFormat.currency(symbol: '\$').format(totalPaid)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (payments.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_rounded,
                    size: 48,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No hay pagos registrados',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: payments.length,
              itemBuilder: (ctx, index) {
                final payment = payments[index];
                return _buildPaymentItem(payment);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentItem(DebtPayment payment) {
    Color paymentColor = payment.paymentType == 'regular'
        ? AppTheme.primaryColor
        : AppTheme.accentColor;

    String paymentType = payment.paymentType == 'regular'
        ? 'Cuota ${payment.installmentNumber}'
        : 'Abono Extra';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: paymentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: paymentColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                paymentType,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: paymentColor,
                ),
              ),
              Text(
                DateFormat('dd MMM yyyy').format(payment.date),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          Text(
            NumberFormat.currency(symbol: '\$').format(payment.amount),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: paymentColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementButtons(bool isFullyPaid) {
    return Column(
      children: [
        if (isFullyPaid)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showReopenDialog(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(
                'Reabrir Deuda',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          )
        else if (widget.debt.hasInstallments)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showModifyInstallmentsDialog(),
              icon: const Icon(Icons.edit_rounded),
              label: const Text(
                'Modificar Cuotas',
                style: TextStyle(fontSize: 16),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                side: const BorderSide(color: Colors.orange),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _payRegularInstallment() {
    final provider = Provider.of<FinanceProvider>(context, listen: false);
    provider.addDebtPayment(
      transactionId: widget.debt.id,
      amount: widget.debt.installmentAmount!,
      paymentType: 'regular',
    );

    _showSuccessSnackBar('Cuota pagada exitosamente');
  }

  void _payExtraInstallment() {
    final amount = double.tryParse(_extraPaymentController.text);
    if (amount == null || amount <= 0) {
      _showErrorSnackBar('Ingrese un monto válido para el abono');
      return;
    }

    final provider = Provider.of<FinanceProvider>(context, listen: false);
    provider.addDebtPayment(
      transactionId: widget.debt.id,
      amount: amount,
      paymentType: 'extra',
    );

    _extraPaymentController.clear();
    _showSuccessSnackBar('Abono registrado exitosamente');
  }

  void _showModifyInstallmentsDialog() {
    final installmentsController =
        TextEditingController(text: widget.debt.totalInstallments.toString());
    final amountController = TextEditingController(
        text: widget.debt.installmentAmount!.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Modificar Plan de Cuotas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: installmentsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nuevo número de cuotas',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nuevo monto por cuota',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final newInstallments = int.tryParse(installmentsController.text);
              final newAmount = double.tryParse(amountController.text);

              if (newInstallments != null &&
                  newAmount != null &&
                  newInstallments > 1 &&
                  newAmount > 0) {
                Provider.of<FinanceProvider>(context, listen: false)
                    .updateDebtInstallments(
                  transactionId: widget.debt.id,
                  newTotalInstallments: newInstallments,
                  newInstallmentAmount: newAmount,
                );
                Navigator.pop(ctx);
                _showSuccessSnackBar('Plan de cuotas modificado');
              } else {
                _showErrorSnackBar('Valores inválidos');
              }
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  void _showReopenDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reabrir Deuda'),
        content: const Text(
            '¿Estás seguro de que quieres reabrir esta deuda? Podrás seguir haciendo pagos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<FinanceProvider>(context, listen: false)
                  .updateDebtInstallments(
                transactionId: widget.debt.id,
                newTotalInstallments: widget.debt.totalInstallments!,
                newInstallmentAmount: widget.debt.installmentAmount!,
              );
              Navigator.pop(ctx);
              _showSuccessSnackBar('Deuda reabierta');
            },
            child: const Text('Reabrir'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onDebtCompleted(String transactionId) {
    if (transactionId == widget.debt.id) {
      _showCongratulationsDialog();
    }
  }

  void _showCongratulationsDialog() {
    final provider = Provider.of<FinanceProvider>(context, listen: false);
    final paidInstallments = provider.getPaidInstallments(widget.debt.id);
    final totalPaid = provider.getTotalPaidForDebt(widget.debt.id);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.celebration_rounded,
                size: 40,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '¡FELICIDADES!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Has pagado completamente tu deuda',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.debt.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '$paidInstallments cuotas pagadas',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    NumberFormat.currency(symbol: '\$').format(totalPaid),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(); // Volver a pantalla anterior
            },
            child: const Text('Salir'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _showDeleteConfirmationDialog();
            },
            child: const Text('Eliminar Deuda'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar Deuda Completada?'),
        content: Text('¿Estás seguro de que quieres eliminar "${widget.debt.title}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final provider = Provider.of<FinanceProvider>(context, listen: false);
              provider.deleteTransaction(widget.debt.id);
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
              _showSuccessSnackBar('Deuda eliminada exitosamente');
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
