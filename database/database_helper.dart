import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import '../models/class_model.dart';
import '../models/grade.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('grades.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // Tăng version lên 2 do có thay đổi schema
      onCreate: _createDB,
      onUpgrade: _upgradeDB, // Thêm hàm upgrade cho phiên bản mới
    );
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE class_requests (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          studentId INTEGER,
          classId INTEGER,
          status TEXT DEFAULT 'pending',
          createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
          UNIQUE(studentId, classId)
        )
      ''');
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''CREATE TABLE students (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      email TEXT,
      password TEXT
    )''');

    await db.execute('''CREATE TABLE teachers (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      email TEXT,
      password TEXT
    )''');

    await db.execute('''CREATE TABLE classes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      teacherId INTEGER
    )''');

    await db.execute('''CREATE TABLE grades (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      studentId INTEGER,
      classId INTEGER,
      score REAL
    )''');

    await db.execute('''CREATE TABLE class_students (
      studentId INTEGER,
      classId INTEGER,
      PRIMARY KEY(studentId, classId)
    )''');

    await db.execute('''
      CREATE TABLE class_requests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        studentId INTEGER,
        classId INTEGER,
        status TEXT DEFAULT 'pending',
        createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(studentId, classId)
      )
    ''');

    // Chèn dữ liệu mặc định (giảng viên và sinh viên)
    await insertInitialData(db);
  }

  Future<void> insertInitialData(Database db) async {
    // Chèn giảng viên nếu chưa có
    final teacherExists = await db.query(
      'teachers',
      where: 'email = ?',
      whereArgs: ['gv@gmail.com'],
    );

    if (teacherExists.isEmpty) {
      await db.insert('teachers', {
        'name': 'GV Khoa CNTT',
        'email': 'gv@gmail.com',
        'password': '123',
      });
      print('Đã chèn giảng viên mẫu');
    }

    // Chèn sinh viên mẫu
    final students = [
      {'name': 'SV A', 'email': 'sva@gmail.com', 'password': '123'},
      {'name': 'SV B', 'email': 'svb@gmail.com', 'password': '123'},
      {'name': 'SV C', 'email': 'svc@gmail.com', 'password': '123'},
    ];

    for (var student in students) {
      final exists = await db.query(
        'students',
        where: 'email = ?',
        whereArgs: [student['email']],
      );
      if (exists.isEmpty) {
        await db.insert('students', student);
      }
    }

    print('Đã chèn dữ liệu mẫu thành công');
  }

  // Method to get classes by teacher
  Future<List<ClassModel>> getClassesByTeacher(int teacherId) async {
    final db = await database;
    final result = await db.query(
      'classes',
      where: 'teacherId = ?',
      whereArgs: [teacherId],
    );
    return result.map((classData) => ClassModel.fromMap(classData)).toList();
  }

  // Method to insert a new class
  Future<void> insertClass(ClassModel classModel) async {
    final db = await database;
    await db.insert('classes', {
      'name': classModel.name,
      'teacherId': classModel.teacherId,
    });
  }

  // Method to delete a class (cập nhật để xóa cả các liên kết)
  Future<void> deleteClass(int classId) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('class_students', where: 'classId = ?', whereArgs: [classId]);
      await txn.delete('grades', where: 'classId = ?', whereArgs: [classId]);
      await txn.delete('class_requests', where: 'classId = ?', whereArgs: [classId]);
      await txn.delete('classes', where: 'id = ?', whereArgs: [classId]);
    });
  }

  // Method to get grades by student
  Future<List<Map<String, dynamic>>> getGradesByStudent(int studentId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT classes.name AS className, grades.score AS grade
      FROM grades
      JOIN classes ON grades.classId = classes.id
      WHERE grades.studentId = ?
    ''', [studentId]);
    return result;
  }

  // Method to request joining a class
  Future<void> requestJoinClass(int studentId, int classId) async {
    final db = await database;
    // Kiểm tra xem đã có yêu cầu chưa
    final exists = await db.query(
      'class_requests',
      where: 'studentId = ? AND classId = ?',
      whereArgs: [studentId, classId],
    );

    if (exists.isEmpty) {
      await db.insert('class_requests', {
        'studentId': studentId,
        'classId': classId,
        'status': 'pending',
      });
    }
  }

  // Method to get pending requests for a class
  Future<List<Map<String, dynamic>>> getPendingRequests(int classId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT class_requests.id, students.id as studentId, students.name, students.email
      FROM class_requests
      JOIN students ON class_requests.studentId = students.id
      WHERE class_requests.classId = ? AND class_requests.status = 'pending'
    ''', [classId]);
  }

  // Method to approve a request
  Future<void> approveRequest(int requestId) async {
    final db = await database;
    await db.transaction((txn) async {
      // Lấy thông tin yêu cầu
      final request = await txn.query(
        'class_requests',
        where: 'id = ?',
        whereArgs: [requestId],
      );

      if (request.isNotEmpty) {
        final studentId = request.first['studentId'] as int;
        final classId = request.first['classId'] as int;

        // Cập nhật trạng thái yêu cầu
        await txn.update(
          'class_requests',
          {'status': 'approved'},
          where: 'id = ?',
          whereArgs: [requestId],
        );

        // Thêm sinh viên vào lớp
        await txn.insert('class_students', {
          'studentId': studentId,
          'classId': classId,
        });
      }
    });
  }

  // Method to reject a request
  Future<void> rejectRequest(int requestId) async {
    final db = await database;
    await db.update(
      'class_requests',
      {'status': 'rejected'},
      where: 'id = ?',
      whereArgs: [requestId],
    );
  }

  // Method to get student's pending requests
  Future<List<Map<String, dynamic>>> getStudentRequests(int studentId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT class_requests.id, classes.name as className, 
             teachers.name as teacherName, class_requests.status
      FROM class_requests
      JOIN classes ON class_requests.classId = classes.id
      JOIN teachers ON classes.teacherId = teachers.id
      WHERE class_requests.studentId = ?
    ''', [studentId]);
  }

  // Method to get all classes
  Future<List<ClassModel>> getAllClasses() async {
    final db = await database;
    final result = await db.query('classes');
    return result.map((classData) => ClassModel.fromMap(classData)).toList();
  }

  // Method to insert or update grade
  Future<void> insertOrUpdateGrade({
    required int studentId,
    required int classId,
    required double grade,
  }) async {
    final db = await database;

    // Check if the grade already exists for this student and class
    final existing = await db.query(
      'grades',
      where: 'studentId = ? AND classId = ?',
      whereArgs: [studentId, classId],
    );

    if (existing.isEmpty) {
      // If grade doesn't exist, insert a new record
      await db.insert('grades', {
        'studentId': studentId,
        'classId': classId,
        'score': grade,
      });
    } else {
      // If grade exists, update the existing record
      await db.update(
        'grades',
        {'score': grade},
        where: 'studentId = ? AND classId = ?',
        whereArgs: [studentId, classId],
      );
    }
  }

  // Method to get students by class
  Future<List<Map<String, dynamic>>> getStudentsByClass(int classId) async {
    final db = await database;
    final result = await db.rawQuery('''
    SELECT students.id, students.name, students.email, students.password
    FROM students
    JOIN class_students ON students.id = class_students.studentId
    WHERE class_students.classId = ?
  ''', [classId]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getStudentsWithGradesByClass(int classId) async {
    final db = await database;
    final data = await db.rawQuery('''
    SELECT students.id, students.name, students.email, students.password, 
           grades.score as grade
    FROM students
    JOIN class_students ON students.id = class_students.studentId
    LEFT JOIN grades ON students.id = grades.studentId AND grades.classId = ?
    WHERE class_students.classId = ?
  ''', [classId, classId]);
    return data;
  }

  Future<void> removeStudentFromClass(int studentId, int classId) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(
        'class_students',
        where: 'studentId = ? AND classId = ?',
        whereArgs: [studentId, classId],
      );
      await txn.delete(
        'grades',
        where: 'studentId = ? AND classId = ?',
        whereArgs: [studentId, classId],
      );
    });
  }
}