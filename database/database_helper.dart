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
      version: 1,
      onCreate: _createDB,
    );
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

  // Method to delete a class
  Future<void> deleteClass(int classId) async {
    final db = await database;
    await db.delete('classes', where: 'id = ?', whereArgs: [classId]);
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

  // Method to enroll a student into a class
  Future<void> enrollStudent(int studentId, int classId) async {
    final db = await database;
    // Kiểm tra xem sinh viên đã tham gia lớp này chưa
    final exists = await db.query(
      'class_students',
      where: 'studentId = ? AND classId = ?',
      whereArgs: [studentId, classId],
    );

    if (exists.isEmpty) {
      await db.insert('class_students', {
        'studentId': studentId,
        'classId': classId,
      });
      print('Đã thêm sinh viên $studentId vào lớp $classId');
    } else {
      print('Sinh viên $studentId đã có trong lớp $classId');
    }
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

  // Thêm vào database_helper.dart
  Future<void> removeStudentFromClass(int studentId, int classId) async {
    final db = await database;
    await db.delete(
      'class_students',
      where: 'studentId = ? AND classId = ?',
      whereArgs: [studentId, classId],
    );
  }
}
