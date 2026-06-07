import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/state/finance_provider.dart';
import 'features/splash/presentation/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => FinanceProvider(),
      child: const KwartaKoApp(),
    ),
  );
}

class KwartaKoApp extends StatelessWidget {
  const KwartaKoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KwartaKo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
