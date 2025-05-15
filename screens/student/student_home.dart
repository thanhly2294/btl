import 'package:flutter/material.dart';
import 'join_class.dart';
import 'view_grades.dart';
import 'request_status.dart';

class StudentHome extends StatelessWidget {
  final int studentId;
  StudentHome({required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trang chủ Sinh viên'),
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
              child: Text('Tham gia lớp học'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => JoinClass(studentId: studentId),
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text('Xem trạng thái yêu cầu'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RequestStatus(studentId: studentId),
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text('Xem điểm'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ViewGrades(studentId: studentId),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}