import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import 'package:sqflite/sqflite.dart';
class EnterGradesScreen extends StatefulWidget {
  final int classId;

  const EnterGradesScreen({super.key, required this.classId});

  @override
  State<EnterGradesScreen> createState() => _EnterGradesScreenState();
}

class _EnterGradesScreenState extends State<EnterGradesScreen> {
  List<Map<String, dynamic>> _students = [];
  final TextEditingController _scoreController = TextEditingController();
  int? _selectedStudentId;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final db = await DatabaseHelper().database;
    final result = await db.rawQuery('''
      SELECT students.id, students.name FROM students
      JOIN class_students ON students.id = class_students.student_id
      WHERE class_students.class_id = ?
    ''', [widget.classId]);
    setState(() {
      _students = result;
    });
  }

  Future<void> _assignGrade() async {
    if (_selectedStudentId == null || _scoreController.text.isEmpty) return;
    final db = await DatabaseHelper().database;
    await db.insert('grades', {
      'student_id': _selectedStudentId,
      'class_id': widget.classId,
      'score': _scoreController.text,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã nhập điểm.')),
    );
    _scoreController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nhập điểm cho sinh viên')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<int>(
              hint: const Text('Chọn sinh viên'),
              value: _selectedStudentId,
              items: _students.map((s) {
                return DropdownMenuItem<int>(
                  value: s['id'],
                  child: Text(s['name'] ?? 'Sinh viên không tên'),
                );
              }).toList(),
              onChanged: (value) => setState(() {
                _selectedStudentId = value;
              }),
            ),
            TextField(
              controller: _scoreController,
              decoration: const InputDecoration(labelText: 'Điểm'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _assignGrade,
              child: const Text('Nhập điểm'),
            ),
          ],
        ),
      ),
    );
  }
}