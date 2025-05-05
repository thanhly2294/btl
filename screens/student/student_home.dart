import 'package:flutter/material.dart';
import 'join_class_screen.dart';
import 'view_grades_screen.dart';

class StudentHome extends StatelessWidget {
  final int studentId;

  const StudentHome({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang sinh viên'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Xin chào, SV ID: $studentId',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => JoinClassScreen(studentId: studentId),
                  ),
                );
              },
              child: const Text('Tham gia lớp học'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ViewGradesScreen(studentId: studentId),
                  ),
                );
              },
              child: const Text('Xem điểm'),
            ),
          ],
        ),
      ),
    );
  }
}