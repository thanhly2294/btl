import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import 'manage_student.dart';
import 'manage_teacher.dart';

class AdminHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text('Manage Students'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ManageStudents()),
                );
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text('Manage Teachers'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ManageTeachers()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
