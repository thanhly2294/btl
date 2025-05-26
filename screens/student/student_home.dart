import 'package:flutter/material.dart';
import 'join_class.dart';
import 'view_grades.dart';
import 'edit_profile.dart';

class StudentHome extends StatelessWidget {
  final int studentId;
  StudentHome({required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trang chủ'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ElevatedButton(
              child: Text('Tham gia lớp học'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => JoinClass(studentId: studentId),
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              child: Text('Xem điểm'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ViewGrades(studentId: studentId),
                ),
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditStudentProfile(studentId: studentId),
            ),
          );
        },
        child: Icon(Icons.edit),
      ),
    );
  }
}