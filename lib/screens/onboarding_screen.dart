import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/finance_provider.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 5;

  // Form controllers
  final _incomeController = TextEditingController();
  final List<TextEditingController> _expenseTitleControllers = [
    TextEditingController()
  ];
  final List<TextEditingController> _expenseAmountControllers = [
    TextEditingController()
  ];
  final List<bool> _expenseRecurring = [true];

  final List<TextEditingController> _debtTitleControllers = [
    TextEditingController()
  ];
  final List<TextEditingController> _debtAmountControllers = [
    TextEditingController()
  ];
  final List<TextEditingController> _debtInstallmentsControllers = [
    TextEditingController()
  ];
  final List<TextEditingController> _debtInstallmentAmountControllers = [
    TextEditingController()
  ];
  final List<bool> _debtHasInstallments = [false];

  final List<TextEditingController> _savingTitleControllers = [
    TextEditingController()
  ];
  final List<TextEditingController> _savingAmountControllers = [
    TextEditingController()
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _incomeController.dispose();
    for (var controller in _expenseTitleControllers) {
      controller.dispose();
    }
    for (var controller in _expenseAmountControllers) {
      controller.dispose();
    }
    for (var controller in _debtTitleControllers) {
      controller.dispose();
    }
    for (var controller in _debtAmountControllers) {
      controller.dispose();
    }
    for (var controller in _debtInstallmentsControllers) {
      controller.dispose();
    }
    for (var controller in _debtInstallmentAmountControllers) {
      controller.dispose();
    }
    for (var controller in _savingTitleControllers) {
      controller.dispose();
    }
    for (var controller in _savingAmountControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.backgroundColor,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header con progreso
              _buildProgressHeader(),

              // Contenido principal
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  itemCount: _totalPages,
                  itemBuilder: (context, index) {
                    switch (index) {
                      case 0:
                        return _buildWelcomePage();
                      case 1:
                        return _buildIncomePage();
                      case 2:
                        return _buildExpensesPage();
                      case 3:
                        return _buildDebtsPage();
                      case 4:
                        return _buildSavingsPage();
                      default:
                        return _buildWelcomePage();
                    }
                  },
                ),
              ),

              // Navegación inferior
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Indicador de progreso
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _totalPages,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: _currentPage == index ? 32 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? AppTheme.primaryColor
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Paso ${_currentPage + 1} de $_totalPages',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botón anterior
          _currentPage > 0
              ? TextButton(
                  onPressed: () => _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                  child: const Text('Anterior'),
                )
              : const SizedBox(width: 80),

          // Botón siguiente o completar
          _currentPage < _totalPages - 1
              ? ElevatedButton(
                  onPressed: () => _nextPage(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text('Siguiente'),
                )
              : ElevatedButton(
                  onPressed: () => _completeSetup(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text('Comenzar'),
                ),
        ],
      ),
    );
  }

  Widget _buildWelcomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          // Banner quokibanner responsivo
          LayoutBuilder(
            builder: (context, constraints) {
              final double imageHeight = constraints.maxWidth * 0.6;
              return Container(
                width: double.infinity,
                height: imageHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/images/quokibanner.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 60,
                          color: AppTheme.primaryColor,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 40),

          // Título principal
          Text(
            '¡Bienvenido a tu\nAsistente Financiero!',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 20),

          // Subtítulo
          Text(
            'Vamos a configurar tu perfil financiero para que puedas empezar a tomar el control de tus ahorros y gastos desde el primer día.',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 16,
              color: AppTheme.textLight,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 40),

          // Características destacadas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFeatureItem(
                  Icons.savings_rounded, 'Ahorros', AppTheme.primaryColor),
              _buildFeatureItem(
                  Icons.credit_card_rounded, 'Deudas', Colors.orange),
              _buildFeatureItem(
                  Icons.trending_up_rounded, 'Balance', AppTheme.accentColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildIncomePage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono y título
          const Icon(
            Icons.monetization_on_rounded,
            size: 48,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 16),

          Text(
            '¿Cuál es tu ingreso mensual?',
            style: GoogleFonts.nunito(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Este será tu ingreso base mensual. Podrás añadir ingresos extra cuando los tengas.',
            style: GoogleFonts.nunito(
              fontSize: 16,
              color: AppTheme.textLight,
            ),
          ),

          const SizedBox(height: 40),

          // Campo de ingreso
          Container(
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
            child: TextField(
              controller: _incomeController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 18),
              decoration: InputDecoration(
                labelText: 'Ingreso mensual base',
                hintText: 'Ej: 2500.00',
                prefixIcon: const Icon(Icons.attach_money,
                    color: AppTheme.primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(20),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Información adicional
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppTheme.primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Este monto servirá como base para calcular tu balance disponible cada mes.',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesPage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono y título
          const Icon(
            Icons.shopping_bag_rounded,
            size: 48,
            color: Colors.red,
          ),
          const SizedBox(height: 16),

          Text(
            '¿Cuáles son tus gastos principales?',
            style: GoogleFonts.nunito(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Agrega tus gastos mensuales recurrentes para tener un mejor control.',
            style: GoogleFonts.nunito(
              fontSize: 16,
              color: AppTheme.textLight,
            ),
          ),

          const SizedBox(height: 20),

          // Lista de gastos
          Expanded(
            child: ListView.builder(
              itemCount: _expenseTitleControllers.length,
              itemBuilder: (context, index) {
                return _buildExpenseItem(index);
              },
            ),
          ),

          // Botón para agregar más gastos
          TextButton.icon(
            onPressed: () => _addExpenseField(),
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Agregar otro gasto'),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseItem(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _expenseTitleControllers[index],
                  decoration: const InputDecoration(
                    labelText: 'Nombre del gasto',
                    hintText: 'Ej: Alquiler, Transporte',
                  ),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: _expenseAmountControllers[index],
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Monto',
                    hintText: '0.00',
                  ),
                ),
              ),
              if (index > 0)
                IconButton(
                  onPressed: () => _removeExpenseField(index),
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                ),
            ],
          ),
          CheckboxListTile(
            title: const Text('Es recurrente mensual'),
            subtitle: const Text('Se repetirá cada mes'),
            value: _expenseRecurring[index],
            onChanged: (val) =>
                setState(() => _expenseRecurring[index] = val ?? true),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildDebtsPage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono y título
          const Icon(
            Icons.credit_card_rounded,
            size: 48,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),

          Text(
            '¿Tienes deudas actuales?',
            style: GoogleFonts.nunito(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Agrega tus deudas para llevar un seguimiento detallado de tus pagos.',
            style: GoogleFonts.nunito(
              fontSize: 16,
              color: AppTheme.textLight,
            ),
          ),

          const SizedBox(height: 20),

          // Lista de deudas
          Expanded(
            child: ListView.builder(
              itemCount: _debtTitleControllers.length,
              itemBuilder: (context, index) {
                return _buildDebtItem(index);
              },
            ),
          ),

          // Botón para agregar más deudas
          TextButton.icon(
            onPressed: () => _addDebtField(),
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Agregar otra deuda'),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtItem(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _debtTitleControllers[index],
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la deuda',
                    hintText: 'Ej: Tarjeta de crédito, Préstamo personal',
                  ),
                ),
              ),
              if (index > 0)
                IconButton(
                  onPressed: () => _removeDebtField(index),
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _debtAmountControllers[index],
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Monto total de la deuda',
              hintText: '0.00',
            ),
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            title: const Text('Pagar en cuotas'),
            subtitle: const Text('Define número de cuotas y monto mensual'),
            value: _debtHasInstallments[index],
            onChanged: (val) =>
                setState(() => _debtHasInstallments[index] = val ?? false),
            contentPadding: EdgeInsets.zero,
          ),
          if (_debtHasInstallments[index]) ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _debtInstallmentsControllers[index],
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Número de cuotas',
                      hintText: 'Ej: 12',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _debtInstallmentAmountControllers[index],
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Monto por cuota',
                      hintText: '0.00',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSavingsPage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono y título
          const Icon(
            Icons.savings_rounded,
            size: 48,
            color: AppTheme.accentColor,
          ),
          const SizedBox(height: 16),

          Text(
            '¿Cuáles son tus metas de ahorro?',
            style: GoogleFonts.nunito(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Establece metas claras para motivarte a ahorrar y alcanzar tus objetivos.',
            style: GoogleFonts.nunito(
              fontSize: 16,
              color: AppTheme.textLight,
            ),
          ),

          const SizedBox(height: 20),

          // Lista de ahorros
          Expanded(
            child: ListView.builder(
              itemCount: _savingTitleControllers.length,
              itemBuilder: (context, index) {
                return _buildSavingItem(index);
              },
            ),
          ),

          // Botón para agregar más metas
          TextButton.icon(
            onPressed: () => _addSavingField(),
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Agregar otra meta'),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingItem(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _savingTitleControllers[index],
              decoration: const InputDecoration(
                labelText: 'Meta de ahorro',
                hintText: 'Ej: Vacaciones, Fondo de emergencia',
              ),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 120,
            child: TextField(
              controller: _savingAmountControllers[index],
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Meta',
                hintText: '0.00',
              ),
            ),
          ),
          if (index > 0)
            IconButton(
              onPressed: () => _removeSavingField(index),
              icon: const Icon(Icons.remove_circle, color: Colors.red),
            ),
        ],
      ),
    );
  }

  // Métodos para agregar/remover campos dinámicos
  void _addExpenseField() {
    setState(() {
      _expenseTitleControllers.add(TextEditingController());
      _expenseAmountControllers.add(TextEditingController());
      _expenseRecurring.add(true);
    });
  }

  void _removeExpenseField(int index) {
    setState(() {
      _expenseTitleControllers.removeAt(index);
      _expenseAmountControllers.removeAt(index);
      _expenseRecurring.removeAt(index);
    });
  }

  void _addDebtField() {
    setState(() {
      _debtTitleControllers.add(TextEditingController());
      _debtAmountControllers.add(TextEditingController());
      _debtInstallmentsControllers.add(TextEditingController());
      _debtInstallmentAmountControllers.add(TextEditingController());
      _debtHasInstallments.add(false);
    });
  }

  void _removeDebtField(int index) {
    setState(() {
      _debtTitleControllers.removeAt(index);
      _debtAmountControllers.removeAt(index);
      _debtInstallmentsControllers.removeAt(index);
      _debtInstallmentAmountControllers.removeAt(index);
      _debtHasInstallments.removeAt(index);
    });
  }

  void _addSavingField() {
    setState(() {
      _savingTitleControllers.add(TextEditingController());
      _savingAmountControllers.add(TextEditingController());
    });
  }

  void _removeSavingField(int index) {
    setState(() {
      _savingTitleControllers.removeAt(index);
      _savingAmountControllers.removeAt(index);
    });
  }

  void _nextPage() {
    // Validar página actual antes de avanzar
    if (!_validateCurrentPage()) return;

    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  bool _validateCurrentPage() {
    switch (_currentPage) {
      case 1: // Ingresos
        if (_incomeController.text.isEmpty ||
            double.tryParse(_incomeController.text) == null) {
          _showError('Por favor, ingresa un ingreso válido');
          return false;
        }
        return true;
      case 2: // Gastos
        for (int i = 0; i < _expenseTitleControllers.length; i++) {
          if (_expenseTitleControllers[i].text.isNotEmpty &&
              _expenseAmountControllers[i].text.isEmpty) {
            _showError('Completa el monto del gasto ${i + 1}');
            return false;
          }
        }
        return true;
      case 3: // Deudas
        for (int i = 0; i < _debtTitleControllers.length; i++) {
          if (_debtTitleControllers[i].text.isNotEmpty &&
              _debtAmountControllers[i].text.isEmpty) {
            _showError('Completa el monto de la deuda ${i + 1}');
            return false;
          }
        }
        return true;
      case 4: // Ahorros
        for (int i = 0; i < _savingTitleControllers.length; i++) {
          if (_savingTitleControllers[i].text.isNotEmpty &&
              _savingAmountControllers[i].text.isEmpty) {
            _showError('Completa el monto de la meta ${i + 1}');
            return false;
          }
        }
        return true;
      default:
        return true;
    }
  }

  void _completeSetup() {
    if (!_validateCurrentPage()) return;

    final provider = Provider.of<FinanceProvider>(context, listen: false);

    // 1. Establecer ingreso mensual
    final income = double.tryParse(_incomeController.text) ?? 0;
    provider.setMonthlyIncome(income);

    // 2. Agregar gastos
    for (int i = 0; i < _expenseTitleControllers.length; i++) {
      final title = _expenseTitleControllers[i].text.trim();
      final amount = double.tryParse(_expenseAmountControllers[i].text);

      if (title.isNotEmpty && amount != null && amount > 0) {
        provider.addTransaction(
          title: title,
          amount: amount,
          type: TransactionType.expense,
          isPaid: false,
        );
      }
    }

    // 3. Agregar deudas
    for (int i = 0; i < _debtTitleControllers.length; i++) {
      final title = _debtTitleControllers[i].text.trim();
      final amount = double.tryParse(_debtAmountControllers[i].text);

      if (title.isNotEmpty && amount != null && amount > 0) {
        if (_debtHasInstallments[i]) {
          final installments =
              int.tryParse(_debtInstallmentsControllers[i].text);
          final installmentAmount =
              double.tryParse(_debtInstallmentAmountControllers[i].text);

          if (installments != null &&
              installmentAmount != null &&
              installments > 1) {
            provider.addDebtWithInstallments(
              title: title,
              totalAmount: amount,
              totalInstallments: installments,
              installmentAmount: installmentAmount,
            );
          } else {
            provider.addTransaction(
              title: title,
              amount: amount,
              type: TransactionType.debt,
              isPaid: false,
            );
          }
        } else {
          provider.addTransaction(
            title: title,
            amount: amount,
            type: TransactionType.debt,
            isPaid: false,
          );
        }
      }
    }

    // 4. Agregar metas de ahorro
    for (int i = 0; i < _savingTitleControllers.length; i++) {
      final title = _savingTitleControllers[i].text.trim();
      final amount = double.tryParse(_savingAmountControllers[i].text);

      if (title.isNotEmpty && amount != null && amount > 0) {
        provider.addSaving(
          goalName: title,
          targetAmount: amount,
        );
      }
    }

    // 5. Completar onboarding
    provider.completeOnboarding();

    // Navegar a la pantalla principal
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
