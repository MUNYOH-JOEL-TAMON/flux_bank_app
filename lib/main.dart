import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flux_bank/firebase_options.dart';
import 'package:flux_bank/theme/app_theme.dart';
import 'package:flux_bank/navigation/app_router.dart';
import 'package:flux_bank/providers/auth_provider.dart';
import 'package:flux_bank/providers/banking_provider.dart';
import 'package:flux_bank/providers/quiz_provider.dart';

bool kFirebaseAvailable = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    kFirebaseAvailable = true;
  } catch (e) {
    debugPrint('Firebase not configured. Running in Demo Offline Mode.');
    kFirebaseAvailable = false;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, BankingProvider>(
          create: (_) => BankingProvider(),
          update: (_, auth, banking) => banking!..updateUser(auth.user),
        ),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
      ],
      child: const FluxApp(),
    ),
  );
}

class FluxApp extends StatelessWidget {
  const FluxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FLUX Bank',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      initialRoute: AppRouter.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
