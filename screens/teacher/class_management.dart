import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/class_model.dart';
import 'student_list.dart';
import 'class_requests.dart';

class ClassManagement extends StatefulWidget {
  final int teacherId;
  ClassManagement({required this.teacherId});

  @override
  _ClassManagementState createState() => _ClassManagementState();
}

class _ClassManagementState extends State<ClassManagement> {
  List<ClassModel> classes = [];

  void _loadClasses() async {
    final data = await DatabaseHelper.instance.getClassesByTeacher(widget.teacherId);
    setState(() => classes = data);
  }

  void _addClass() async {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Thêm lớp học'),
        content: TextField(controller: controller, decoration: InputDecoration(labelText: 'Tên lớp')),
        actions: [
          TextButton(
            onPressed: () async {
              final name = controller.text;
              if (name.isNotEmpty) {
                await DatabaseHelper.instance.insertClass(
                    ClassModel(name: name, teacherId: widget.teacherId));
                Navigator.pop(context);
                _loadClasses();
              }
            },
            child: Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _deleteClass(int classId) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận xóa lớp'),
        content: Text('Bạn có chắc chắn muốn xóa lớp học này? Tất cả dữ liệu liên quan sẽ bị xóa.'),
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
      await DatabaseHelper.instance.deleteClass(classId);
      _loadClasses();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý lớp học'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addClass,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: classes.length,
        itemBuilder: (context, index) {
          final c = classes[index];
          return ListTile(
            title: Text(c.name),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.group_add),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ClassRequests(classId: c.id!),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteClass(c.id!),
                ),
              ],
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StudentList(classModel: c),
              ),
            ),
          );
        },
      ),
    );
  }
}