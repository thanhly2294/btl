import 'package:flutter/material.dart';
import '../../models/student.dart';
import '../../models/class_model.dart';
import '../../database/database_helper.dart';

class GradeInput extends StatefulWidget {
  final Student student;
  final ClassModel classModel;
  GradeInput({required this.student, required this.classModel});

  @override
  _GradeInputState createState() => _GradeInputState();
}

class _GradeInputState extends State<GradeInput> {
  final TextEditingController _gradeController = TextEditingController();

  void _saveGrade() async {
    final grade = double.tryParse(_gradeController.text);
    if (grade != null) {
      await DatabaseHelper.instance.insertOrUpdateGrade(
        studentId: widget.student.id!,
        classId: widget.classModel.id!,
        grade: grade,
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lưu điểm thành công')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nhập điểm cho ${widget.student.name}')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _gradeController,
              decoration: InputDecoration(labelText: 'Điểm'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveGrade,
              child: Text('Lưu'),
            )
          ],
        ),
      ),
    );
  }
}