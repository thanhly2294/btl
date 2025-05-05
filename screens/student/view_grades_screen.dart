import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class ViewGradesScreen extends StatelessWidget {
  final int studentId;

  const ViewGradesScreen({super.key, required this.studentId});

  Future<List<Map<String, dynamic>>> _loadGrades() async {
    final db = await DatabaseHelper().database;
    return await db.rawQuery('''
      SELECT classes.name as class_name, grades.score FROM grades
      JOIN classes ON grades.class_id = classes.id
      WHERE grades.student_id = ?
    ''', [studentId]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Điểm của bạn')),
      body: FutureBuilder(
        future: _loadGrades(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final grades = snapshot.data!;
          if (grades.isEmpty) {
            return const Center(child: Text('Chưa có điểm nào.'));
          }
          return ListView.builder(
            itemCount: grades.length,
            itemBuilder: (context, index) {
              final item = grades[index];
              return ListTile(
                title: Text(item['class_name']),
                subtitle: Text('Điểm: ${item['score']}'),
              );
            },
          );
        },
      ),
    );
  }
}