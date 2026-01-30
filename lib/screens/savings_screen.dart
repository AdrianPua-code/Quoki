import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';

class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key});

  // Widget para mostrar la imagen de Quoki según el estado
  Widget _buildQuokiImage(BuildContext context, FinanceProvider provider) {
    String imagePath;
    String message;
    Color bgColor;

    if (provider.savings.isEmpty) {
      // No hay ahorros - Quoki triste
      imagePath = 'assets/images/quoki_Triste.png';
      message = 'No tienes metas de ahorro aún';
      bgColor = Colors.grey.shade100;
    } else if (provider.currentMonthSavings > 0) {
      // Hay depósitos este mes - Quoki musculoso
      imagePath = 'assets/images/QuokiMusculoso.png';
      message = '¡Genial! Estás ahorrando este mes';
      bgColor = Colors.green.withValues(alpha: 0.1);
    } else {
      // Hay metas pero sin dinero o completadas - Quoki normal sin fondo
      imagePath = 'assets/images/QuokiSinFondo.png';
      message = 'Tienes metas de ahorro establecidas';
      bgColor = Colors.blue.withValues(alpha: 0.1);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bgColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          // Imagen de Quoki
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.savings_rounded,
                      size: 60,
                      color: Colors.grey.shade400,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);

    // Simple dialog to add saving
    void showAddSavingDialog() {
      final nameController = TextEditingController();
      final targetController = TextEditingController();

      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: const Text('Nueva Meta de Ahorro'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                            labelText: 'Meta (ej. Vacaciones)',
                            prefixIcon: Icon(Icons.flag_rounded))),
                    const SizedBox(height: 16),
                    TextField(
                        controller: targetController,
                        decoration: const InputDecoration(
                            labelText: 'Monto Objetivo',
                            prefixIcon: Icon(Icons.monetization_on_rounded)),
                        keyboardType: TextInputType.number),
                  ],
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancelar')),
                  ElevatedButton(
                      onPressed: () {
                        final amount =
                            double.tryParse(targetController.text) ?? 0;
                        if (nameController.text.isNotEmpty && amount > 0) {
                          provider.addSaving(
                              goalName: nameController.text,
                              targetAmount: amount);
                          Navigator.pop(ctx);
                        }
                      },
                      child: const Text('Guardar')),
                ],
              ));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Ahorros')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showAddSavingDialog,
        icon: const Icon(Icons.add),
        label: const Text('Nueva Meta'),
      ),
      body: Column(
        children: [
          // Imagen de Quoki según el estado
          _buildQuokiImage(context, provider),
          
          // Lista de ahorros si existen
          if (provider.savings.isNotEmpty) ...[
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: provider.savings.length,
              itemBuilder: (ctx, index) {
                final saving = provider.savings[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        )
                      ]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.flag_rounded,
                                color: Colors.blue),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(saving.goalName,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded,
                                color: Colors.grey),
                            onPressed: () {
                              if (saving.currentAmount < saving.targetAmount) {
                                showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                          title: const Text('¿Eliminar Meta?'),
                                          content: const Text(
                                              'Aún no has completado esta meta. ¿Estás seguro de eliminarla?'),
                                          actions: [
                                            TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx),
                                                child: const Text('Cancelar')),
                                            ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.red),
                                                onPressed: () {
                                                  provider
                                                      .deleteSaving(saving.id);
                                                  Navigator.pop(ctx);
                                                },
                                                child: const Text('Eliminar',
                                                    style: TextStyle(
                                                        color: Colors.white))),
                                          ],
                                        ));
                              } else {
                                // Completed, delete directly
                                provider.deleteSaving(saving.id);
                              }
                            },
                          )
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            NumberFormat.compactCurrency(symbol: '\$')
                                .format(saving.currentAmount),
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ),
                          Text(
                            'de ${NumberFormat.compactCurrency(symbol: '\$').format(saving.targetAmount)}',
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: saving.progress,
                          backgroundColor: Colors.grey.shade100,
                          color: Colors.green,
                          minHeight: 16,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (ctx) {
                                      final amountController =
                                          TextEditingController();
                                      return AlertDialog(
                                        title: const Text('Retirar Fondos'),
                                        content: TextField(
                                          controller: amountController,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                              labelText: 'Monto',
                                              prefixIcon: Icon(
                                                  Icons.remove_circle_outline)),
                                        ),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx),
                                              child: const Text('Cancelar')),
                                          ElevatedButton(
                                              onPressed: () {
                                                final amount = double.tryParse(
                                                    amountController.text);
                                                if (amount != null &&
                                                    amount > 0) {
                                                  if (amount <=
                                                      saving.currentAmount) {
                                                    provider.updateSavingAmount(
                                                        saving.id, -amount);
                                                    Navigator.pop(ctx);
                                                  } else {
                                                    Navigator.pop(ctx);
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                            const SnackBar(
                                                                content: Text(
                                                                    'No puedes retirar más de lo ahorrado')));
                                                  }
                                                }
                                              },
                                              child: const Text('Retirar')),
                                        ],
                                      );
                                    });
                              },
                              icon: const Icon(Icons.remove, size: 18),
                              label: const Text('Retirar'),
                              style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: BorderSide(color: Colors.red.shade200),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (ctx) {
                                      final amountController =
                                          TextEditingController();
                                      return AlertDialog(
                                        title: const Text('Agregar Fondos'),
                                        content: TextField(
                                          controller: amountController,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                              labelText: 'Monto',
                                              prefixIcon: Icon(
                                                  Icons.add_circle_outline)),
                                        ),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx),
                                              child: const Text('Cancelar')),
                                          ElevatedButton(
                                              onPressed: () {
                                                final amount = double.tryParse(
                                                    amountController.text);
                                                if (amount != null &&
                                                    amount > 0) {
                                                  provider.updateSavingAmount(
                                                      saving.id, amount);
                                                  Navigator.pop(ctx);

                                                  // Check for completion
                                                  if (saving.currentAmount +
                                                          amount >=
                                                      saving.targetAmount) {
                                                    showDialog(
                                                        context: context,
                                                        builder: (ctx) =>
                                                            AlertDialog(
                                                              title: const Text(
                                                                  '¡Felicidades! 🎉'),
                                                              content: Text(
                                                                  'Has completado tu meta de ahorro: ${saving.goalName}'),
                                                              actions: [
                                                                TextButton(
                                                                    onPressed: () =>
                                                                        Navigator.pop(
                                                                            ctx),
                                                                    child: const Text(
                                                                        'Genial'))
                                                              ],
                                                            ));
                                                  }
                                                }
                                              },
                                              child: const Text('Agregar')),
                                        ],
                                      );
                                    });
                              },
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Agregar'),
                              style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12)),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
            ),
          ],
        ],
      ),
    );
  }
}
