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
  final _formKey = GlobalKey<FormState>(); // Thêm key để kiểm tra form
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _role = 'student';
  String? _emailError;
  String? _passwordError;

  // Regex cho email (phải chứa @ và domain như .com, .edu, v.v.)
  final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  // Regex cho password (ít nhất 6 ký tự)
  final RegExp _passwordRegex = RegExp(r'^.{6,}$');

  void _login() async {
    if (_formKey.currentState!.validate()) {
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
        } else { // Teacher
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
  }

  void _showError() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Login Failed'),
        content: Text('Incorrect email or password.'),
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
    if (_formKey.currentState!.validate()) {
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
              SnackBar(content: Text('Student registered successfully')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Email already exists')),
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
              SnackBar(content: Text('Teacher registered successfully')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Email already exists')),
            );
          }
        }
      } catch (e) {
        print('Registration error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Sử dụng Form để kiểm tra validation
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  if (!_emailRegex.hasMatch(value)) {
                    return 'Nhập theo email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu';
                  }
                  if (!_passwordRegex.hasMatch(value)) {
                    return 'Mật khẩu cần 8 kí tự';
                  }
                  return null;
                },
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
                  child: Text('Đăng kí tài khoản ${_role == 'student' ? 'sinh viên' : 'giáo viên'}'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}