import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import 'request_status.dart';

class JoinClass extends StatefulWidget {
  final int studentId;
  JoinClass({required this.studentId});

  @override
  _JoinClassState createState() => _JoinClassState();
}

class _JoinClassState extends State<JoinClass> {
  List<Map<String, dynamic>> approvedClasses = [];
  List<Map<String, dynamic>> pendingClasses = [];
  List<Map<String, dynamic>> availableClasses = [];

  void _loadClasses() async {
    final db = await DatabaseHelper.instance.database;

    final approvedData = await db.rawQuery('''
      SELECT c.id, c.name, cr.status 
      FROM classes c
      JOIN class_requests cr ON c.id = cr.classId
      WHERE cr.studentId = ? AND cr.status = 'approved'
    ''', [widget.studentId]);

    final pendingData = await db.rawQuery('''
      SELECT c.id, c.name, cr.status 
      FROM classes c
      JOIN class_requests cr ON c.id = cr.classId
      WHERE cr.studentId = ? AND cr.status = 'pending'
    ''', [widget.studentId]);

    final availableData = await db.rawQuery('''
      SELECT c.id, c.name
      FROM classes c
      WHERE c.id NOT IN (
        SELECT classId FROM class_requests 
        WHERE studentId = ?
      )
    ''', [widget.studentId]);

    setState(() {
      approvedClasses = List<Map<String, dynamic>>.from(approvedData);
      pendingClasses = List<Map<String, dynamic>>.from(pendingData);
      availableClasses = List<Map<String, dynamic>>.from(availableData);
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (approvedClasses.isNotEmpty) ...[
              _buildSectionHeader('Lớp đã tham gia'),
              ...approvedClasses.map((c) => _buildClassItem(c, isApproved: true)),
              SizedBox(height: 16),
            ],
            if (pendingClasses.isNotEmpty) ...[
              _buildSectionHeader('Đang chờ duyệt'),
              ...pendingClasses.map((c) => _buildClassItem(c, isPending: true)),
              SizedBox(height: 16),
            ],
            if (availableClasses.isNotEmpty) ...[
              _buildSectionHeader('Lớp có thể tham gia'),
              ...availableClasses.map((c) => _buildClassItem(c, canJoin: true)),
            ],
            if (approvedClasses.isEmpty && pendingClasses.isEmpty && availableClasses.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Không có lớp học nào hiện có'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue[800],
        ),
      ),
    );
  }

  Widget _buildClassItem(Map<String, dynamic> classData, {
    bool isApproved = false,
    bool isPending = false,
    bool canJoin = false,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        title: Text(
          'ID: ${classData['id']} - ${classData['name']}',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: isPending || isApproved
            ? Text('Trạng thái: ${classData['status']}')
            : null,
        trailing: canJoin
            ? IconButton(
          icon: Icon(Icons.send, color: Colors.blue),
          onPressed: () => _requestJoinClass(classData['id']),
        )
            : null,
        tileColor: isApproved
            ? Colors.green[50]
            : isPending
            ? Colors.orange[50]
            : null,
      ),
    );
  }
}
