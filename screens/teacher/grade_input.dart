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
  final TextEditingController _processScoreController = TextEditingController();
  final TextEditingController _startupScoreController = TextEditingController();
  final TextEditingController _examScoreController = TextEditingController();

  void _saveGrade() async {
    final processScore = double.tryParse(_processScoreController.text);
    final startupScore = double.tryParse(_startupScoreController.text);
    final examScore = double.tryParse(_examScoreController.text);

    if (processScore != null && startupScore != null && examScore != null) {
      await DatabaseHelper.instance.insertOrUpdateGrade(
        studentId: widget.student.id!,
        classId: widget.classModel.id!,
        processScore: processScore,
        startupScore: startupScore,
        examScore: examScore,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lưu điểm thành công')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập điểm hợp lệ')),
      );
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
              controller: _processScoreController,
              decoration: InputDecoration(labelText: 'Điểm quá trình'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _startupScoreController,
              decoration: InputDecoration(labelText: 'Điểm khởi nghiệp'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _examScoreController,
              decoration: InputDecoration(labelText: 'Điểm thi'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveGrade,
              child: Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _processScoreController.dispose();
    _startupScoreController.dispose();
    _examScoreController.dispose();
    super.dispose();
  }
}