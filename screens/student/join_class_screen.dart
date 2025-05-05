import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class JoinClassScreen extends StatefulWidget {
  final int studentId;

  const JoinClassScreen({super.key, required this.studentId});

  @override
  State<JoinClassScreen> createState() => _JoinClassScreenState();
}

class _JoinClassScreenState extends State<JoinClassScreen> {
  List<Map<String, dynamic>> _classes = [];

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    final db = await DatabaseHelper().database;
    final result = await db.rawQuery('''
      SELECT * FROM classes WHERE id NOT IN (
        SELECT class_id FROM class_students WHERE student_id = ?
      )
    ''', [widget.studentId]);
    setState(() {
      _classes = result;
    });
  }

  Future<void> _joinClass(int classId) async {
    final db = await DatabaseHelper().database;
    await db.insert('class_students', {
      'student_id': widget.studentId,
      'class_id': classId,
    });
    _loadClasses();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã tham gia lớp.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tham gia lớp học')),
      body: ListView.builder(
        itemCount: _classes.length,
        itemBuilder: (context, index) {
          final cls = _classes[index];
          return ListTile(
            title: Text(cls['name']),
            trailing: ElevatedButton(
              onPressed: () => _joinClass(cls['id']),
              child: const Text('Tham gia'),
            ),
          );
        },
      ),
    );
  }
}
