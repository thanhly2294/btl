import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;

    // Kiểm tra và chèn dữ liệu mẫu
    final teachers = await db.query('teachers', limit: 1);
    if (teachers.isEmpty) {
      await dbHelper.insertInitialData(db);  // Đã đổi tên hàm
      debugPrint('✅ Dữ liệu mẫu đã được khởi tạo');
    }

    runApp(const GradeManagementApp());
  } catch (e) {
    debugPrint('❌ Lỗi khởi tạo: $e');
    runApp(const ErrorApp());
  }
}

class GradeManagementApp extends StatelessWidget {
  const GradeManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản Lý Điểm CNTT',
      theme: ThemeData(primarySwatch: Colors.blue),
      home:  LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        home: Scaffold(
        body: Center(child: Text('Không thể khởi động ứng dụng')),
        )
    );
  }
}