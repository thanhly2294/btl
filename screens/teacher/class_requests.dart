import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class ClassRequests extends StatefulWidget {
  final int classId;
  ClassRequests({required this.classId});

  @override
  _ClassRequestsState createState() => _ClassRequestsState();
}

class _ClassRequestsState extends State<ClassRequests> {
  List<Map<String, dynamic>> requests = [];

  void _loadRequests() async {
    final data = await DatabaseHelper.instance.getPendingRequests(widget.classId);
    setState(() => requests = data);
  }

  void _approveRequest(int requestId) async {
    await DatabaseHelper.instance.approveRequest(requestId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã phê duyệt yêu cầu')),
    );
    _loadRequests();
    Navigator.pop(context, true); // Trả về true để báo cần làm mới
  }

  void _rejectRequest(int requestId) async {
    await DatabaseHelper.instance.rejectRequest(requestId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã từ chối yêu cầu')),
    );
    _loadRequests();
    Navigator.pop(context, true); // Trả về true để báo cần làm mới
  }

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Yêu cầu tham gia lớp')),
      body: ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final r = requests[index];
          return ListTile(
            title: Text(r['name']),
            subtitle: Text(r['email']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.check, color: Colors.green),
                  onPressed: () => _approveRequest(r['id']),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red),
                  onPressed: () => _rejectRequest(r['id']),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}