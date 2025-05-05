import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/class_model.dart';

class JoinClass extends StatefulWidget {
  final int studentId;
  JoinClass({required this.studentId});

  @override
  _JoinClassState createState() => _JoinClassState();
}

class _JoinClassState extends State<JoinClass> {
  List<ClassModel> classes = [];

  void _loadClasses() async {
    final data = await DatabaseHelper.instance.getAllClasses();
    setState(() => classes = data);
  }

  void _joinClass(int classId) async {
    await DatabaseHelper.instance.enrollStudent(widget.studentId, classId);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã tham gia lớp thành công')));
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
        title: Text('Tham gia lớp học'),
      ),
      body: ListView.builder(
        itemCount: classes.length,
        itemBuilder: (context, index) {
          final c = classes[index];
          return ListTile(
            title: Text(c.name),
            trailing: IconButton(
              icon: Icon(Icons.add, color: Colors.green),
              onPressed: () => _joinClass(c.id!),
            ),
          );
        },
      ),
    );
  }
}
