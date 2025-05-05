import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class CreateClassScreen extends StatefulWidget {
  final int teacherId;

  const CreateClassScreen({super.key, required this.teacherId});

  @override
  State<CreateClassScreen> createState() => _CreateClassScreenState();
}

class _CreateClassScreenState extends State<CreateClassScreen> {
  final TextEditingController _nameController = TextEditingController();

  Future<void> _createClass() async {
    final db = await DatabaseHelper().database;
    await db.insert('classes', {
      'name': _nameController.text,
      'teacher_id': widget.teacherId,
    });
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tạo lớp thành công.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tạo lớp mới')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Tên lớp'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createClass,
              child: const Text('Tạo lớp'),
            ),
          ],
        ),
      ),
    );
  }
}