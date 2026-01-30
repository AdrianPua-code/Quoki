import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import '../models/transaction.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  final _incomeController = TextEditingController();
  final _expenseNameController = TextEditingController();
  final _expenseAmountController = TextEditingController();

  final List<Map<String, dynamic>> _initialExpenses = [];

  int _currentPage = 0;

  void _addExpense() {
    final name = _expenseNameController.text;
    final amount = double.tryParse(_expenseAmountController.text);

    if (name.isNotEmpty && amount != null && amount > 0) {
      setState(() {
        _initialExpenses.add({'title': name, 'amount': amount});
        _expenseNameController.clear();
        _expenseAmountController.clear();
      });
    }
  }

  void _removeExpense(int index) {
    setState(() {
      _initialExpenses.removeAt(index);
    });
  }

  void _finishOnboarding() async {
    final provider = Provider.of<FinanceProvider>(context, listen: false);

    // 1. Set Income
    final income = double.tryParse(_incomeController.text) ?? 0.0;
    provider.setMonthlyIncome(income);

    // 2. Add Fixed Expenses
    for (var exp in _initialExpenses) {
      provider.addTransaction(
        title: exp['title'],
        amount: exp['amount'],
        type: TransactionType.expense,
      );
    }

    // 3. Mark Onboarding as Complete (logic to be added in provider)
    await provider.completeOnboarding();

    // 4. Navigate to Home
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                physics:
                    const NeverScrollableScrollPhysics(), // Force navigation via buttons
                children: [
                  _buildIncomeStep(),
                  _buildExpensesStep(),
                ],
              ),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeStep() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.attach_money, size: 80, color: Colors.deepPurple),
          const SizedBox(height: 20),
          const Text(
            '¡Bienvenido!',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Para empezar, dinos cuál es tu ingreso mensual aproximado.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          TextField(
            controller: _incomeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              prefixText: '\$ ',
              labelText: 'Ingreso Mensual',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesStep() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.list_alt, size: 80, color: Colors.deepPurple),
          const SizedBox(height: 20),
          const Text(
            'Gastos Fijos',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Añade tus gastos recurrentes (Alquiler, Luz, Internet, etc).',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                  flex: 2,
                  child: TextField(
                      controller: _expenseNameController,
                      decoration: const InputDecoration(labelText: 'Nombre'))),
              const SizedBox(width: 10),
              Expanded(
                  flex: 1,
                  child: TextField(
                      controller: _expenseAmountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Monto'))),
              IconButton(
                  onPressed: _addExpense,
                  icon: const Icon(Icons.add_circle, color: Colors.deepPurple)),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: _initialExpenses.length,
              itemBuilder: (ctx, index) {
                final item = _initialExpenses[index];
                return ListTile(
                  dense: true,
                  title: Text(item['title']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('\$${item['amount']}'),
                      IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.red, size: 20),
                          onPressed: () => _removeExpense(index)),
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            TextButton(
              onPressed: () {
                _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease);
              },
              child: const Text('Atrás'),
            )
          else
            const SizedBox.shrink(),
          ElevatedButton(
            onPressed: () {
              if (_currentPage == 0) {
                if (_incomeController.text.isNotEmpty) {
                  _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease);
                }
              } else {
                _finishOnboarding();
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            child: Text(_currentPage == 0 ? 'Siguiente' : 'Finalizar'),
          ),
        ],
      ),
    );
  }
}
