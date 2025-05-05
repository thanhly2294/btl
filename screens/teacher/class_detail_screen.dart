import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import 'enter_grades_screen.dart';

class ClassDetailScreen extends StatefulWidget {
  final int teacherId;

  const ClassDetailScreen({super.key, required this.teacherId});

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  List<Map<String, dynamic>> _classes = [];

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    final db = await DatabaseHelper().database;
    final result = await db.query('classes', where: 'teacher_id = ?', whereArgs: [widget.teacherId]);
    setState(() {
      _classes = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lớp học của tôi')),
      body: ListView.builder(
        itemCount: _classes.length,
        itemBuilder: (context, index) {
          final cls = _classes[index];
          return ListTile(
            title: Text(cls['name']),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EnterGradesScreen(classId: cls['id']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}