import 'package:flutter/material.dart';
import 'login.dart';
import 'collection.dart';
import 'attendance.dart'; // 导入考勤模块

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '表型数据采集',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      DashboardPage(onNavigate: _onItemTapped), // 首页/仪表板
      const CollectionPage(),
      const AttendancePage(), // 使用独立的考勤页面
      const ProfilePage(), // 个人中心
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // 支持4个以上的选项
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.science),
            label: '数据采集',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: '智能上传',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '个人中心',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  final Function(int)? onNavigate;

  const DashboardPage({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('表型采集系统'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('暂无新通知')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 欢迎信息
            Card(
              color: Colors.teal.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '欢迎回来，2025222009',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '今天是 ${DateTime.now().year}年${DateTime.now().month}月${DateTime.now().day}日',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 功能快捷入口
            const Text(
              '功能入口',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // 切换到数据采集页面
                      onNavigate?.call(1);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.science, size: 40, color: Colors.orange),
                          SizedBox(height: 8),
                          Text('数据采集', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('录制视频和照片', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // 切换到考勤上传页面
                      onNavigate?.call(2);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.access_time, size: 40, color: Colors.blue),
                          SizedBox(height: 8),
                          Text('智能上传', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('录制视频', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 统计信息
            const Text(
              '数据统计',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Icon(Icons.photo_library, color: Colors.green, size: 30),
                        const SizedBox(height: 8),
                        const Text('照片', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('156张', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                    Column(
                      children: [
                        const Icon(Icons.videocam, color: Colors.red, size: 30),
                        const SizedBox(height: 8),
                        const Text('视频', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('89个', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                    Column(
                      children: [
                        const Icon(Icons.note, color: Colors.purple, size: 30),
                        const SizedBox(height: 8),
                        const Text('备注', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('234条', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 快速提示
            Card(
              color: Colors.amber.shade50,
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.amber),
                        SizedBox(width: 8),
                        Text('使用提示', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text('• 数据采集：支持拍照、录像和添加备注'),
                    Text('• 智能上传：用户上传视频后，系统自动处理'),
                    Text('• 数据会自动保存到本地，重启应用后仍可查看'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人中心'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.teal,
                      child: Icon(Icons.person, size: 40, color: Colors.white),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('mingmi123', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('表型采集研究员'),
                        Text('版本: 3.0.21.15'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('设置'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('设置功能待实现')),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.help),
                    title: const Text('帮助'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('帮助功能待实现')),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('退出登录', style: TextStyle(color: Colors.red)),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
            const Spacer(),
            const Text(
              '技术支持:**表型生物技术研究中心',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
