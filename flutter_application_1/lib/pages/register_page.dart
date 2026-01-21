import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../widgets/input_field.dart';
import '../widgets/validation_row.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  String password = '';

  bool hasUpper = false;
  bool hasNumber = false;
  bool lengthOk = false;

  void onPasswordChange(String v) {
    setState(() {
      password = v;
      hasUpper = RegExp(r'[A-Z]').hasMatch(v);
      hasNumber = RegExp(r'\d').hasMatch(v);
      lengthOk = v.length >= 8;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: AppColors.bgWhite,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
                offset: Offset(0, 10),
              )
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '用户注册',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                /// 用户名
                InputField(
                  hint: '用户名',
                  validator: (v) {
                    if (v == null || v.isEmpty) return '用户名不能为空';
                    if (v.length < 4) return '至少 4 位';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                /// 密码
                InputField(
                  hint: '密码',
                  obscureText: true,
                  onChanged: onPasswordChange,
                  error: password.isNotEmpty && !lengthOk,
                  success: lengthOk && hasUpper && hasNumber,
                ),

                const SizedBox(height: 12),

                /// 校验提示（红 / 绿）
                ValidationRow(text: '至少 8 位字符', ok: lengthOk),
                ValidationRow(text: '包含大写字母', ok: hasUpper),
                ValidationRow(text: '包含数字', ok: hasNumber),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate() &&
                          lengthOk &&
                          hasUpper &&
                          hasNumber) {
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('注册'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
