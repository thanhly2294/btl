import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class RequestStatus extends StatefulWidget {
  final int studentId;
  RequestStatus({required this.studentId});

  @override
  _RequestStatusState createState() => _RequestStatusState();
}

class _RequestStatusState extends State<RequestStatus> {
  List<Map<String, dynamic>> requests = [];

  void _loadRequests() async {
    final data = await DatabaseHelper.instance.getStudentRequests(widget.studentId);
    setState(() => requests = data);
  }

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Trạng thái yêu cầu')),
      body: ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final r = requests[index];
          return ListTile(
            title: Text(r['className']),
            subtitle: Text('Giảng viên: ${r['teacherName']}'),
            trailing: Text(
              r['status'],
              style: TextStyle(
                color: r['status'] == 'approved'
                    ? Colors.green
                    : r['status'] == 'pending'
                    ? Colors.orange
                    : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }
}