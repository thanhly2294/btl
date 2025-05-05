import 'package:flutter/material.dart';
import '../../models/class_model.dart';
import '../../database/database_helper.dart';
import 'grade_input.dart';
import '../../models/student.dart';

class StudentList extends StatefulWidget {
  final ClassModel classModel;
  StudentList({required this.classModel});

  @override
  _StudentListState createState() => _StudentListState();
}

class _StudentListState extends State<StudentList> {
  List<Map<String, dynamic>> studentsWithGrades = [];

  void _loadStudents() async {
    final data = await DatabaseHelper.instance
        .getStudentsWithGradesByClass(widget.classModel.id!);
    setState(() {
      studentsWithGrades = data;
    });
  }

  void _removeStudent(int studentId) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận'),
        content: Text('Bạn có chắc chắn muốn xóa sinh viên này khỏi lớp học?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.removeStudentFromClass(
        studentId,
        widget.classModel.id!,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xóa sinh viên khỏi lớp học')),
      );
      _loadStudents();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Danh sách sinh viên - ${widget.classModel.name}')),
      body: ListView.builder(
        itemCount: studentsWithGrades.length,
        itemBuilder: (context, index) {
          final student = studentsWithGrades[index];
          return ListTile(
            title: Text(student['name']),
            subtitle: Text('Email: ${student['email']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Điểm: ${student['grade']?.toString() ?? 'Chưa có'}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: student['grade'] != null ? Colors.blue : Colors.grey,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeStudent(student['id']),
                ),
              ],
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GradeInput(
                  student: Student(
                    id: student['id'],
                    name: student['name'],
                    email: student['email'],
                    password: student['password'],
                  ),
                  classModel: widget.classModel,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}