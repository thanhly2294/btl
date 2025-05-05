import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'student/student_home.dart';
import 'teacher/teacher_home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String role = 'student'; // mặc định
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    final db = DatabaseHelper();
    await db.insertDummyAccounts(); // thêm SV & GV mẫu

    if (role == 'student') {
      final user = await db.loginStudent(username, password);
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => StudentHome(studentId: user['id'])),
        );
      } else {
        _showError();
      }
    } else {
      final user = await db.loginTeacher(username, password);
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => TeacherHome(teacherId: user['id'])),
        );
      } else {
        _showError();
      }
    }
  }

  void _showError() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Lỗi'),
          content: const Text('Sai tài khoản hoặc mật khẩu.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'))
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<String>(
              value: role,
              onChanged: (val) => setState(() => role = val!),
              items: const [
                DropdownMenuItem(value: 'student', child: Text('Sinh viên')),
                DropdownMenuItem(value: 'teacher', child: Text('Giảng viên')),
              ],
            ),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Tên đăng nhập'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mật khẩu'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: const Text('Đăng nhập'))
          ],
        ),
      ),
    );
  }
}
