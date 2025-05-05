import 'package:flutter/material.dart';
import 'class_management.dart';

class TeacherHome extends StatelessWidget {
  final int teacherId;
  TeacherHome({required this.teacherId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trang chủ Giảng viên'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          )
        ],
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('Quản lý lớp học'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ClassManagement(teacherId: teacherId),
              ),
            );
          },
        ),
      ),
    );
  }
}
