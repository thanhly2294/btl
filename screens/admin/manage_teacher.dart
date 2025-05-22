import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/teacher.dart';

class ManageTeachers extends StatefulWidget {
  @override
  _ManageTeachersState createState() => _ManageTeachersState();
}

class _ManageTeachersState extends State<ManageTeachers> {
  List<Teacher> teachers = [];

  @override
  void initState() {
    super.initState();
    _loadTeachers();
  }

  void _loadTeachers() async {
    final data = await DatabaseHelper.instance.getAllTeachers();
    setState(() => teachers = data);
  }

  void _deleteTeacher(int id) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa giảng viên này? Tất cả lớp học và dữ liệu liên quan cũng sẽ bị xóa.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deleteTeacher(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xóa giảng viên và tất cả dữ liệu liên quan')),
      );
      _loadTeachers();
    }
  }

  void _editTeacher(Teacher teacher) async {
    final nameController = TextEditingController(text: teacher.name);
    final emailController = TextEditingController(text: teacher.email);
    final passwordController = TextEditingController(text: teacher.password);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit Teacher'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: 'Name')),
            TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final updatedTeacher = Teacher(
                id: teacher.id,
                name: nameController.text,
                email: emailController.text,
                password: passwordController.text,
              );
              await DatabaseHelper.instance.updateTeacher(updatedTeacher);
              _loadTeachers();
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Teachers')),
      body: ListView.builder(
        itemCount: teachers.length,
        itemBuilder: (context, index) {
          final teacher = teachers[index];
          return ListTile(
            title: Text(teacher.name),
            subtitle: Text(teacher.email),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _editTeacher(teacher),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteTeacher(teacher.id!),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}