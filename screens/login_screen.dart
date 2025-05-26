import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'student/student_home.dart';
import 'teacher/teacher_home.dart';
import 'admin/admin_home.dart';

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

    try {
      if (_role == 'admin') {
        final admin = await DatabaseHelper.instance.getAdminByEmail(email);
        if (admin != null && admin.password == password) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => AdminHome()),
          );
        } else {
          _showError();
        }
      } else if (_role == 'student') {
        final result = await db.query(
          'students',
          where: 'email = ? AND password = ?',
          whereArgs: [email, password],
        );

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
      } else {
        final result = await db.query(
          'teachers',
          where: 'email = ? AND password = ?',
          whereArgs: [email, password],
        );

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
      print('Login error: $e');
      _showError();
    }
  }

  void _showError() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Đăng nhập thất bại'),
        content: Text('Email hoặc mật khẩu không đúng.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          )
        ],
      ),
    );
  }

  void _register() async {
    final db = await DatabaseHelper.instance.database;
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = email.split('@')[0];

    try {
      if (_role == 'student') {
        final exists = await db.query('students', where: 'email = ?', whereArgs: [email]);
        if (exists.isEmpty) {
          await db.insert('students', {
            'name': name,
            'email': email,
            'password': password
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đăng ký sinh viên thành công')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Email đã tồn tại')),
          );
        }
      } else if (_role == 'teacher') {
        final exists = await db.query('teachers', where: 'email = ?', whereArgs: [email]);
        if (exists.isEmpty) {
          await db.insert('teachers', {
            'name': name,
            'email': email,
            'password': password
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đăng ký giảng viên thành công')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Email đã tồn tại')),
          );
        }
      }
    } catch (e) {
      print('Registration error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng ký thất bại')),
      );
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
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Mật khẩu'),
              obscureText: true,
            ),
            DropdownButton<String>(
              value: _role,
              onChanged: (value) => setState(() => _role = value!),
              items: [
                DropdownMenuItem(value: 'student', child: Text('Sinh viên')),
                DropdownMenuItem(value: 'teacher', child: Text('Giảng viên')),
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Đăng nhập'),
            ),
            if (_role != 'admin')
              TextButton(
                onPressed: _register,
                child: Text('Đăng ký tài khoản ${_role == 'student' ? 'sinh viên' : 'giáo viên'}'),
              ),
          ],
        ),
      ),
    );
  }
}