import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/auth_provider.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          TextButton(
            onPressed: () {
              context.read<AuthProvider>().logout();
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
      body: const Center(
        child: Text(
          'Login Success 🎉',
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
