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
    print('Loaded students for class ${widget.classModel.id}: $data');
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
      body: studentsWithGrades.isEmpty
          ? Center(child: Text('Chưa có sinh viên nào trong lớp này'))
          : ListView.builder(
        itemCount: studentsWithGrades.length,
        itemBuilder: (context, index) {
          final student = studentsWithGrades[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text('${student['name']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email: ${student['email']}'),
                  SizedBox(height: 4),
                  Text('Điểm quá trình: ${student['process_score']?.toStringAsFixed(2) ?? 'Chưa có'}'),
                  Text('Điểm khởi nghiệp: ${student['startup_score']?.toStringAsFixed(2) ?? 'Chưa có'}'),
                  Text('Điểm thi: ${student['exam_score']?.toStringAsFixed(2) ?? 'Chưa có'}'),
                  Text('Tổng điểm: ${student['total_score']?.toStringAsFixed(2) ?? 'Chưa có'}'),
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeStudent(student['id']),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GradeInput(
                    student: Student(
                      id: student['id'],
                      name: student['name'],
                      email: student['email'],
                      password: '', // Không cần password ở đây
                    ),
                    classModel: widget.classModel,
                  ),
                ),
              ).then((_) => _loadStudents()),
            ),
          );
        },
      ),
    );
  }
}