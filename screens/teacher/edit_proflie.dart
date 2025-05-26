import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/teacher.dart';

class EditTeacherProfile extends StatefulWidget {
  final int teacherId;
  EditTeacherProfile({required this.teacherId});

  @override
  _EditTeacherProfileState createState() => _EditTeacherProfileState();
}

class _EditTeacherProfileState extends State<EditTeacherProfile> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late Teacher _currentTeacher;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _loadTeacherData();
  }

  void _loadTeacherData() async {
    final db = await DatabaseHelper.instance.database;
    final teacherData = await db.query(
      'teachers',
      where: 'id = ?',
      whereArgs: [widget.teacherId],
    );

    if (teacherData.isNotEmpty) {
      setState(() {
        _currentTeacher = Teacher.fromMap(teacherData.first);
        _nameController.text = _currentTeacher.name;
        _emailController.text = _currentTeacher.email;
        _passwordController.text = _currentTeacher.password;
      });
    }
  }

  void _updateProfile() async {
    final updatedTeacher = Teacher(
      id: widget.teacherId,
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );

    await DatabaseHelper.instance.updateTeacher(updatedTeacher);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cập nhật thông tin thành công')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sửa thông tin cá nhân')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              enabled: false,
              decoration: InputDecoration(
                labelText: 'ID',
                hintText: widget.teacherId.toString(),
              ),
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Tên'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Mật khẩu'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProfile,
              child: Text('Lưu thay đổi'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}