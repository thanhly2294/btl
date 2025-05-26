import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/student.dart';

class ManageStudents extends StatefulWidget {
  @override
  _ManageStudentsState createState() => _ManageStudentsState();
}

class _ManageStudentsState extends State<ManageStudents> {
  List<Student> students = [];

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  void _loadStudents() async {
    final data = await DatabaseHelper.instance.getAllStudents();
    setState(() => students = data);
  }

  void _deleteStudent(int id) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa sinh viên này? Tất cả dữ liệu liên quan (lớp học, điểm số) cũng sẽ bị xóa.'),
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
      await DatabaseHelper.instance.deleteStudent(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xóa sinh viên và tất cả dữ liệu liên quan')),
      );
      _loadStudents();
    }
  }

  void _editStudent(Student student) async {
    final nameController = TextEditingController(text: student.name);
    final emailController = TextEditingController(text: student.email);
    final passwordController = TextEditingController(text: student.password);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Sửa thông tin sinh viên'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              enabled: false,
              decoration: InputDecoration(
                labelText: 'ID',
                hintText: student.id.toString(),
              ),
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Tên'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Mật khẩu'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              final updatedStudent = Student(
                id: student.id,
                name: nameController.text,
                email: emailController.text,
                password: passwordController.text,
              );
              await DatabaseHelper.instance.updateStudent(updatedStudent);
              _loadStudents();
              Navigator.pop(context);
            },
            child: Text('Lưu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quản lý sinh viên')),
      body: ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];
          return ListTile(
            title: Text('ID: ${student.id} - ${student.name}'),
            subtitle: Text(student.email),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _editStudent(student),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteStudent(student.id!),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
