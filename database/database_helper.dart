import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/class_model.dart';
import '../models/student.dart';
import '../models/teacher.dart';
import '../models/admin.dart';

// Singleton class to manage the SQLite database
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Initialize the database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('grade_management.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Create database tables
  Future<void> _createDB(Database db, int version) async {
    // Students table
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    // Teachers table
    await db.execute('''
      CREATE TABLE teachers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    // Admins table
    await db.execute('''
      CREATE TABLE admins (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    // Classes table
    await db.execute('''
      CREATE TABLE classes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        teacherId INTEGER NOT NULL,
        FOREIGN KEY (teacherId) REFERENCES teachers (id) ON DELETE CASCADE
      )
    ''');

    // Class requests table
    await db.execute('''
      CREATE TABLE class_requests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        studentId INTEGER NOT NULL,
        classId INTEGER NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        FOREIGN KEY (studentId) REFERENCES students (id) ON DELETE CASCADE,
        FOREIGN KEY (classId) REFERENCES classes (id) ON DELETE CASCADE
      )
    ''');

    // Grades table
    await db.execute('''
      CREATE TABLE grades (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        studentId INTEGER NOT NULL,
        classId INTEGER NOT NULL,
        process_score REAL,
        startup_score REAL,
        exam_score REAL,
        total_score REAL,
        FOREIGN KEY (studentId) REFERENCES students (id) ON DELETE CASCADE,
        FOREIGN KEY (classId) REFERENCES classes (id) ON DELETE CASCADE,
        UNIQUE(studentId, classId)
      )
    ''');

    // Insert default admin account
    await db.insert('admins', {
      'name': 'Admin',
      'email': 'admin@gmail.com',
      'password': 'admin123'
    });
  }

  // === Student Operations ===
  Future<int> insertStudent(Student student) async {
    final db = await database;
    return await db.insert('students', student.toMap());
  }

  Future<List<Student>> getAllStudents() async {
    final db = await database;
    final maps = await db.query('students');
    return List.generate(maps.length, (i) => Student.fromMap(maps[i]));
  }

  Future<int> updateStudent(Student student) async {
    final db = await database;
    return await db.update(
      'students',
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  Future<int> deleteStudent(int id) async {
    final db = await database;
    // Delete related class requests and grades
    await db.delete('class_requests', where: 'studentId = ?', whereArgs: [id]);
    await db.delete('grades', where: 'studentId = ?', whereArgs: [id]);
    return await db.delete('students', where: 'id = ?', whereArgs: [id]);
  }

  // === Teacher Operations ===
  Future<int> insertTeacher(Teacher teacher) async {
    final db = await database;
    return await db.insert('teachers', teacher.toMap());
  }

  Future<List<Teacher>> getAllTeachers() async {
    final db = await database;
    final maps = await db.query('teachers');
    return List.generate(maps.length, (i) => Teacher.fromMap(maps[i]));
  }

  Future<int> updateTeacher(Teacher teacher) async {
    final db = await database;
    return await db.update(
      'teachers',
      teacher.toMap(),
      where: 'id = ?',
      whereArgs: [teacher.id],
    );
  }

  Future<int> deleteTeacher(int id) async {
    final db = await database;
    // Delete related classes, class requests, and grades
    final classes = await db.query('classes', where: 'teacherId = ?', whereArgs: [id]);
    for (final classData in classes) {
      final classId = classData['id'] as int;
      await db.delete('class_requests', where: 'classId = ?', whereArgs: [classId]);
      await db.delete('grades', where: 'classId = ?', whereArgs: [classId]);
    }
    await db.delete('classes', where: 'teacherId = ?', whereArgs: [id]);
    return await db.delete('teachers', where: 'id = ?', whereArgs: [id]);
  }

  // === Admin Operations ===
  Future<Admin?> getAdminByEmail(String email) async {
    final db = await database;
    final maps = await db.query('admins', where: 'email = ?', whereArgs: [email]);
    if (maps.isNotEmpty) {
      return Admin.fromMap(maps.first);
    }
    return null;
  }

  // === Class Operations ===
  Future<int> insertClass(ClassModel classModel) async {
    final db = await database;
    return await db.insert('classes', classModel.toMap());
  }

  Future<List<ClassModel>> getClassesByTeacher(int teacherId) async {
    final db = await database;
    final maps = await db.query('classes', where: 'teacherId = ?', whereArgs: [teacherId]);
    return List.generate(maps.length, (i) => ClassModel.fromMap(maps[i]));
  }

  Future<List<ClassModel>> getAllClasses() async {
    final db = await database;
    final maps = await db.query('classes');
    return List.generate(maps.length, (i) => ClassModel.fromMap(maps[i]));
  }

  Future<int> deleteClass(int id) async {
    final db = await database;
    // Delete related class requests and grades
    await db.delete('class_requests', where: 'classId = ?', whereArgs: [id]);
    await db.delete('grades', where: 'classId = ?', whereArgs: [id]);
    return await db.delete('classes', where: 'id = ?', whereArgs: [id]);
  }

  // === Class Request Operations ===
  Future<int> requestJoinClass(int studentId, int classId) async {
    final db = await database;
    return await db.insert('class_requests', {
      'studentId': studentId,
      'classId': classId,
      'status': 'pending',
    });
  }

  Future<List<Map<String, dynamic>>> getPendingRequests(int classId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT cr.id, s.name, s.email 
      FROM class_requests cr
      JOIN students s ON cr.studentId = s.id
      WHERE cr.classId = ? AND cr.status = 'pending'
    ''', [classId]);
    print('Pending requests for class $classId: Count=${result.length}, Data=$result');
    return result;
  }

  Future<List<Map<String, dynamic>>> getStudentRequests(int studentId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT cr.id, c.name as className, t.name as teacherName, cr.status
      FROM class_requests cr
      JOIN classes c ON cr.classId = c.id
      JOIN teachers t ON c.teacherId = t.id
      WHERE cr.studentId = ?
    ''', [studentId]);
    print('Student requests for student $studentId: Count=${result.length}, Data=$result');
    return result;
  }

  Future<int> approveRequest(int requestId) async {
    final db = await database;
    // Update status to approved
    int updatedRows = await db.update(
      'class_requests',
      {'status': 'approved'},
      where: 'id = ?',
      whereArgs: [requestId],
    );

    if (updatedRows == 0) {
      print('Error: No rows updated for requestId $requestId');
      return 0;
    }

    // Fetch the approved request to get studentId and classId
    final request = await db.query(
      'class_requests',
      where: 'id = ?',
      whereArgs: [requestId],
    );

    if (request.isEmpty) {
      print('Error: Request not found for requestId $requestId');
      return 0;
    }

    final studentId = request.first['studentId'] as int;
    final classId = request.first['classId'] as int;
    print('Approved request: studentId=$studentId, classId=$classId, status=${request.first['status']}');

    // Ensure a grade record is created
    final existingGrade = await db.query(
      'grades',
      where: 'studentId = ? AND classId = ?',
      whereArgs: [studentId, classId],
    );
    if (existingGrade.isEmpty) {
      final gradeId = await db.insert('grades', {
        'studentId': studentId,
        'classId': classId,
        'process_score': 0.0,
        'startup_score': 0.0,
        'exam_score': 0.0,
        'total_score': 0.0,
      });
      print('Inserted grade record with id: $gradeId for studentId=$studentId, classId=$classId');
    } else {
      print('Grade record already exists for studentId=$studentId, classId=$classId');
    }
    return updatedRows;
  }

  Future<int> rejectRequest(int requestId) async {
    final db = await database;
    int updatedRows = await db.update(
      'class_requests',
      {'status': 'rejected'},
      where: 'id = ?',
      whereArgs: [requestId],
    );
    if (updatedRows == 0) {
      print('Error: No rows updated for requestId $requestId');
    }
    return updatedRows;
  }

  // === Grade Operations ===
  Future<int> insertOrUpdateGrade({
    required int studentId,
    required int classId,
    required double processScore,
    required double startupScore,
    required double examScore,
  }) async {
    final db = await database;
    final totalScore = (processScore + startupScore + examScore) / 3;

    final existing = await db.query(
      'grades',
      where: 'studentId = ? AND classId = ?',
      whereArgs: [studentId, classId],
    );

    if (existing.isNotEmpty) {
      return await db.update(
        'grades',
        {
          'process_score': processScore,
          'startup_score': startupScore,
          'exam_score': examScore,
          'total_score': totalScore,
        },
        where: 'studentId = ? AND classId = ?',
        whereArgs: [studentId, classId],
      );
    } else {
      return await db.insert('grades', {
        'studentId': studentId,
        'classId': classId,
        'process_score': processScore,
        'startup_score': startupScore,
        'exam_score': examScore,
        'total_score': totalScore,
      });
    }
  }

  Future<List<Map<String, dynamic>>> getGradesByStudent(int studentId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT g.process_score, g.startup_score, g.exam_score, g.total_score, c.name as className
      FROM grades g
      JOIN classes c ON g.classId = c.id
      WHERE g.studentId = ?
    ''', [studentId]);
    print('Grades for student $studentId: Count=${result.length}, Data=$result');
    return result;
  }

  Future<List<Map<String, dynamic>>> getStudentsWithGradesByClass(int classId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT s.id, s.name, s.email, s.password, g.process_score, g.startup_score, g.exam_score, g.total_score
      FROM students s
      JOIN class_requests cr ON s.id = cr.studentId
      LEFT JOIN grades g ON s.id = g.studentId AND g.classId = cr.classId
      WHERE cr.classId = ? AND cr.status = 'approved'
    ''', [classId]);
    print('Students with grades for class $classId: Count=${result.length}, Data=$result');
    return result;
  }

  Future<int> removeStudentFromClass(int studentId, int classId) async {
    final db = await database;
    await db.delete(
      'grades',
      where: 'studentId = ? AND classId = ?',
      whereArgs: [studentId, classId],
    );
    return await db.delete(
      'class_requests',
      where: 'studentId = ? AND classId = ?',
      whereArgs: [studentId, classId],
    );
  }

  // === Debug Utility ===
  Future<void> printAllData() async {
    final db = await database;
    print('==== DEBUG DATABASE ====');

    print('Students:');
    final students = await db.query('students');
    for (var s in students) {
      print(s);
    }

    print('\nTeachers:');
    final teachers = await db.query('teachers');
    for (var t in teachers) {
      print(t);
    }

    print('\nAdmins:');
    final admins = await db.query('admins');
    for (var a in admins) {
      print(a);
    }

    print('\nClasses:');
    final classes = await db.query('classes');
    for (var c in classes) {
      print(c);
    }

    print('\nClass Requests:');
    final requests = await db.query('class_requests');
    for (var r in requests) {
      print(r);
    }

    print('\nGrades:');
    final grades = await db.query('grades');
    for (var g in grades) {
      print(g);
    }

    print('=======================');
  }
}