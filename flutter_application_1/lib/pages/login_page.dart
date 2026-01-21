import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/auth_provider.dart';
import 'register_page.dart';
import '../widgets/input_field.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                blurRadius: 20,
                color: Colors.black12,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '表型采集',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              const InputField(hint: '账号'),
              const SizedBox(height: 16),
              const InputField(hint: '密码', obscureText: true),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<AuthProvider>().login('mock-token');
                  },
                  child: const Text('登入'),
                ),
              ),

              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RegisterPage(),
                    ),
                  );
                },
                child: const Text('注册账号'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
