import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:msib_johan/core/provider/data_provider.dart';
import 'package:msib_johan/features/login%20&%20regis/login_page.dart';
import 'package:msib_johan/features/wallet/expenses_page.dart';
import 'package:msib_johan/features/wallet/homepage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadToken();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: Scaffold(body: HomePage()),
      home: Scaffold(
        body: globalToken == '' ? LoginScreen() : HomePage(),
      ),
      initialRoute: '/',
      routes: {
        '/login': (context) => LoginScreen(),
        '/homepage': (context) => HomePage(),
        '/expenses': (context) => ExpensesPage(),
      },
    );
  }
}
