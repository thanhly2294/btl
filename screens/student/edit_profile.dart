import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/student.dart';

class EditStudentProfile extends StatefulWidget {
  final int studentId;
  EditStudentProfile({required this.studentId});

  @override
  _EditStudentProfileState createState() => _EditStudentProfileState();
}

class _EditStudentProfileState extends State<EditStudentProfile> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late Student _currentStudent;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _loadStudentData();
  }

  void _loadStudentData() async {
    final db = await DatabaseHelper.instance.database;
    final studentData = await db.query(
      'students',
      where: 'id = ?',
      whereArgs: [widget.studentId],
    );

    if (studentData.isNotEmpty) {
      setState(() {
        _currentStudent = Student.fromMap(studentData.first);
        _nameController.text = _currentStudent.name;
        _emailController.text = _currentStudent.email;
        _passwordController.text = _currentStudent.password;
      });
    }
  }

  void _updateProfile() async {
    final updatedStudent = Student(
      id: widget.studentId,
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );

    await DatabaseHelper.instance.updateStudent(updatedStudent);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile updated successfully')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProfile,
              child: Text('Save Changes'),
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