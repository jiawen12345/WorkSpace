import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/auth_provider.dart';
import 'app/theme.dart';
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider<AuthProvider>(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const RootPage(),
      ),
    );
  }
}

class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return auth.isLogin
        ? DashboardPage() // 
        : const LoginPage();
  }
}
