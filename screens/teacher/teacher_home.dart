import 'package:flutter/material.dart';
import 'create_class_screen.dart';
import 'class_detail_screen.dart';

class TeacherHome extends StatelessWidget {
  final int teacherId;

  const TeacherHome({super.key, required this.teacherId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trang giảng viên')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Xin chào, GV ID: $teacherId',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateClassScreen(teacherId: teacherId),
                  ),
                );
              },
              child: const Text('Tạo lớp học mới'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ClassDetailScreen(teacherId: teacherId),
                  ),
                );
              },
              child: const Text('Xem lớp học'),
            ),
          ],
        ),
      ),
    );
  }
}