import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'student/student_home.dart';
import 'teacher/teacher_home.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _role = 'student';

  void _login() async {
    final db = await DatabaseHelper.instance.database;
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    print('Đăng nhập với email: $email và mật khẩu: $password');

    try {
      if (_role == 'student') {
        final result = await db.query(
          'students',
          where: 'email = ? AND password = ?',
          whereArgs: [email, password],
        );

        print('Kết quả đăng nhập sinh viên: $result');

        if (result.isNotEmpty) {
          final student = result.first;
          final studentId = student['id'] as int?;
          if (studentId != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => StudentHome(studentId: studentId),
              ),
            );
          } else {
            _showError();
          }
        } else {
          _showError();
        }
      } else { // Giảng viên
        final result = await db.query(
          'teachers',
          where: 'email = ? AND password = ?',
          whereArgs: [email, password],
        );

        print('Kết quả đăng nhập giảng viên: $result');

        if (result.isNotEmpty) {
          final teacher = result.first;
          final teacherId = teacher['id'] as int?;
          if (teacherId != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => TeacherHome(teacherId: teacherId),
              ),
            );
          } else {
            _showError();
          }
        } else {
          _showError();
        }
      }
    } catch (e) {
      print('Lỗi khi đăng nhập: $e');
      _showError();
    }
  }



  void _showError() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Đăng nhập thất bại'),
          content: Text('Sai email hoặc mật khẩu.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text('OK'))
          ],
        ));
  }

  void _registerStudent() async {
    final db = await DatabaseHelper.instance.database;
    final email = _emailController.text;
    final password = _passwordController.text;
    final name = email.split('@')[0];

    final exists = await db.query('students', where: 'email = ?', whereArgs: [email]);
    if (exists.isEmpty) {
      await db.insert('students', {'name': name, 'email': email, 'password': password});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đăng ký thành công')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Email đã tồn tại')));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Đăng nhập')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: _passwordController, decoration: InputDecoration(labelText: 'Mật khẩu'), obscureText: true),
            DropdownButton<String>(
              value: _role,
              onChanged: (value) => setState(() => _role = value!),
              items: [
                DropdownMenuItem(value: 'student', child: Text('Sinh viên')),
                DropdownMenuItem(value: 'teacher', child: Text('Giảng viên')),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: Text('Đăng nhập')),
            if (_role == 'student')
              TextButton(onPressed: _registerStudent, child: Text('Đăng ký tài khoản sinh viên')),
          ],
        ),
      ),
    );
  }
}
