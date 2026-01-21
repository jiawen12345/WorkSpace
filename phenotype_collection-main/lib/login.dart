import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart'; // ← 改成你自己的主页

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _rememberPassword = true;
  bool _obscurePassword = true;
  bool _loading = false;

  /// =============================
  /// 初始化：加载记住的账号密码
  /// =============================
  @override
  void initState() {
    super.initState();
    _loadSavedAccount();
  }

  Future<void> _loadSavedAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool('remember_password') ?? false;

    if (remember) {
      _usernameController.text = prefs.getString('username') ?? '';
      _passwordController.text = prefs.getString('password') ?? '';
    }

    setState(() {
      _rememberPassword = remember;
    });
  }

  /// =============================
  /// 错误弹窗（成功不弹）
  /// =============================
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('提示'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// =============================
  /// 登录逻辑
  /// =============================
  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showErrorDialog('请输入账号和密码');
      return;
    }

    setState(() => _loading = true);

    try {
    print('➡️ 开始请求登录接口');
    print('➡️ username=$username');

      final response = await http.post(
        Uri.parse('http://61.155.111.202:18080/cprweb/pt/api/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );
      
    print('⬅️ 登录接口返回');
    print('⬅️ statusCode = ${response.statusCode}');
    print('⬅️ body = ${utf8.decode(response.bodyBytes)}');


      if (response.statusCode == 200) {
        final result = jsonDecode(utf8.decode(response.bodyBytes));

 
      if (result['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', result['token']); 

        await _handleRememberPassword(username, password);

          Navigator.pushReplacement(
           context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
       }
        else {
          _showErrorDialog(result['message'] ?? '登录失败');
        }
      }
       else {
        _showErrorDialog('服务器错误：${response.statusCode}');
      }
    } 
    catch (e) {
      _showErrorDialog('网络异常，请检查网络');
    } 
    finally {
      setState(() => _loading = false);
    }
  }

  /// =============================
  /// 记住密码处理
  /// =============================
  Future<void> _handleRememberPassword(
      String username, String password) async {
    final prefs = await SharedPreferences.getInstance();

    if (_rememberPassword) {
      await prefs.setBool('remember_password', true);
      await prefs.setString('username', username);
      await prefs.setString('password', password);
    } else {
      await prefs.remove('remember_password');
      await prefs.remove('username');
      await prefs.remove('password');
    }
  }

  /// =============================
  /// UI（完全保持你的样式）
  /// =============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8E8F0),
              Color(0xFFF5F5DC),
              Color(0xFFE6D7C3),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 60),

                /// Logo（不会消失）
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF4DB6AC), Color(0xFF00695C)],
                    ),
                  ),
                  child: const Icon(
                    Icons.account_circle,
                    size: 50,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 40),

                const Text(
                  '当前版本: 3.0.21.15',
                  style: TextStyle(color: Colors.red),
                ),

                const SizedBox(height: 40),

                /// 用户名
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    hintText: '请输入账号',
                    prefixIcon: Icon(Icons.person_outline),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                /// 密码
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: '请输入密码',
                    prefixIcon: const Icon(Icons.lock_outline),
                    filled: true,
                    fillColor: Colors.white,
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// 登录按钮（文字 + loading 共存）
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color.fromARGB(136, 228, 8, 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Text(
                          '登录',
                          style:
                              TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        if (_loading)
                          const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                /// 记住密码
                Row(
                  children: [
                    Checkbox(
                      value: _rememberPassword,
                      onChanged: (value) {
                        setState(() {
                          _rememberPassword = value ?? false;
                        });
                      },
                    ),
                    const Text('记住密码'),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        _showErrorDialog('忘记密码功能待实现');
                      },
                      child: const Text(
                        '忘记密码？',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
