import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/class_model.dart';
import 'request_status.dart';

class JoinClass extends StatefulWidget {
  final int studentId;
  JoinClass({required this.studentId});

  @override
  _JoinClassState createState() => _JoinClassState();
}

class _JoinClassState extends State<JoinClass> {
  List<ClassModel> classes = [];
  List<Map<String, dynamic>> requests = [];

  void _loadClasses() async {
    final data = await DatabaseHelper.instance.getAllClasses();
    final reqs = await DatabaseHelper.instance.getStudentRequests(widget.studentId);
    setState(() {
      classes = data;
      requests = reqs;
    });
  }

  void _requestJoinClass(int classId) async {
    await DatabaseHelper.instance.requestJoinClass(widget.studentId, classId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã gửi yêu cầu tham gia lớp. Chờ giảng viên phê duyệt.')),
    );
    _loadClasses();
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
        actions: [
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RequestStatus(studentId: widget.studentId),
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: classes.length,
        itemBuilder: (context, index) {
          final c = classes[index];
          final request = requests.firstWhere(
                (r) => r['className'] == c.name,
            orElse: () => {},
          );

          return ListTile(
            title: Text(c.name),
            subtitle: request.isNotEmpty
                ? Text('Trạng thái: ${request['status']}')
                : null,
            trailing: request.isEmpty
                ? IconButton(
              icon: Icon(Icons.send, color: Colors.blue),
              onPressed: () => _requestJoinClass(c.id!),
            )
                : null,
          );
        },
      ),
    );
  }
}