import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/finance_provider.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Clear all data to test from scratch
  final provider = FinanceProvider();
  //await provider.clearAllData();
  await provider.loadData();
  final isFirstRun = await provider.checkFirstRun();

  runApp(MyApp(provider: provider, isFirstRun: isFirstRun));
}

class MyApp extends StatelessWidget {
  final FinanceProvider provider;
  final bool isFirstRun;

  const MyApp({super.key, required this.provider, required this.isFirstRun});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: provider,
      child: MaterialApp(
        title: 'Finance App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: isFirstRun ? const OnboardingScreen() : const HomeScreen(),
      ),
    );
  }
}
