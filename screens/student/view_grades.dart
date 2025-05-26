import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/class_model.dart';

class ViewGrades extends StatefulWidget {
  final int studentId;
  ViewGrades({required this.studentId});

  @override
  _ViewGradesState createState() => _ViewGradesState();
}

class _ViewGradesState extends State<ViewGrades> {
  List<Map<String, dynamic>> grades = [];

  void _loadGrades() async {
    final data = await DatabaseHelper.instance.getGradesByStudent(widget.studentId);
    setState(() => grades = data);
  }

  @override
  void initState() {
    super.initState();
    _loadGrades();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Xem điểm')),
      body: ListView.builder(
        itemCount: grades.length,
        itemBuilder: (context, index) {
          final g = grades[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              title: Text('Lớp: ${g['className']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Điểm quá trình: ${g['process_score']?.toString() ?? 'Chưa có'}'),
                  Text('Điểm khởi nghiệp: ${g['startup_score']?.toString() ?? 'Chưa có'}'),
                  Text('Điểm thi: ${g['exam_score']?.toString() ?? 'Chưa có'}'),
                  Text('Tổng điểm: ${g['total_score']?.toString() ?? 'Chưa có'}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}