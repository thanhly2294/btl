// database/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/class_model.dart';
import '../models/student.dart';
import '../models/teacher.dart';
import '../models/admin.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

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

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE teachers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE admins (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE classes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        teacherId INTEGER NOT NULL,
        FOREIGN KEY (teacherId) REFERENCES teachers (id) ON DELETE CASCADE
      )
    ''');

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

    await db.execute('''
      CREATE TABLE grades (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        studentId INTEGER NOT NULL,
        classId INTEGER NOT NULL,
        score REAL,
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

  // Student methods
  Future<int> insertStudent(Student student) async {
    final db = await instance.database;
    return await db.insert('students', student.toMap());
  }

  Future<List<Student>> getAllStudents() async {
    final db = await instance.database;
    final maps = await db.query('students');
    return List.generate(maps.length, (i) => Student.fromMap(maps[i]));
  }

  Future<int> deleteStudent(int id) async {
    final db = await instance.database;

    await db.delete(
      'class_requests',
      where: 'studentId = ?',
      whereArgs: [id],
    );

    await db.delete(
      'grades',
      where: 'studentId = ?',
      whereArgs: [id],
    );

    return await db.delete('students', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateStudent(Student student) async {
    final db = await instance.database;
    return await db.update(
      'students',
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  Future<int> insertTeacher(Teacher teacher) async {
    final db = await instance.database;
    return await db.insert('teachers', teacher.toMap());
  }

  Future<List<Teacher>> getAllTeachers() async {
    final db = await instance.database;
    final maps = await db.query('teachers');
    return List.generate(maps.length, (i) => Teacher.fromMap(maps[i]));
  }

  Future<int> deleteTeacher(int id) async {
    final db = await instance.database;

    // 1. Lấy tất cả lớp học của giảng viên này
    final classes = await db.query(
      'classes',
      where: 'teacherId = ?',
      whereArgs: [id],
    );

    // 2. Với mỗi lớp học, xóa tất cả dữ liệu liên quan
    for (final classData in classes) {
      final classId = classData['id'] as int;

      // Xóa tất cả yêu cầu tham gia lớp
      await db.delete(
        'class_requests',
        where: 'classId = ?',
        whereArgs: [classId],
      );

      // Xóa tất cả điểm số
      await db.delete(
        'grades',
        where: 'classId = ?',
        whereArgs: [classId],
      );
    }

    // 3. Xóa tất cả lớp học của giảng viên
    await db.delete(
      'classes',
      where: 'teacherId = ?',
      whereArgs: [id],
    );

    // 4. Cuối cùng xóa giảng viên
    return await db.delete('teachers', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateTeacher(Teacher teacher) async {
    final db = await instance.database;
    return await db.update(
      'teachers',
      teacher.toMap(),
      where: 'id = ?',
      whereArgs: [teacher.id],
    );
  }

  // Admin methods
  Future<Admin?> getAdminByEmail(String email) async {
    final db = await instance.database;
    final maps = await db.query(
      'admins',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return Admin.fromMap(maps.first);
    }
    return null;
  }

  // Class methods
  Future<int> insertClass(ClassModel classModel) async {
    final db = await instance.database;
    return await db.insert('classes', classModel.toMap());
  }

  Future<List<ClassModel>> getClassesByTeacher(int teacherId) async {
    final db = await instance.database;
    final maps = await db.query('classes', where: 'teacherId = ?', whereArgs: [teacherId]);
    return List.generate(maps.length, (i) => ClassModel.fromMap(maps[i]));
  }

  Future<List<ClassModel>> getAllClasses() async {
    final db = await instance.database;
    final maps = await db.query('classes');
    return List.generate(maps.length, (i) => ClassModel.fromMap(maps[i]));
  }

  Future<int> deleteClass(int id) async {
    final db = await instance.database;

    // Xóa tất cả yêu cầu tham gia lớp liên quan
    await db.delete(
      'class_requests',
      where: 'classId = ?',
      whereArgs: [id],
    );

    // Xóa tất cả điểm số liên quan
    await db.delete(
      'grades',
      where: 'classId = ?',
      whereArgs: [id],
    );

    // Cuối cùng xóa lớp học
    return await db.delete('classes', where: 'id = ?', whereArgs: [id]);
  }

  // Class request methods
  Future<int> requestJoinClass(int studentId, int classId) async {
    final db = await instance.database;
    return await db.insert('class_requests', {
      'studentId': studentId,
      'classId': classId,
      'status': 'pending'
    });
  }

  Future<List<Map<String, dynamic>>> getPendingRequests(int classId) async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT cr.id, s.name, s.email 
      FROM class_requests cr
      JOIN students s ON cr.studentId = s.id
      WHERE cr.classId = ? AND cr.status = 'pending'
    ''', [classId]);
  }

  Future<List<Map<String, dynamic>>> getStudentRequests(int studentId) async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT cr.id, c.name as className, t.name as teacherName, cr.status
      FROM class_requests cr
      JOIN classes c ON cr.classId = c.id
      JOIN teachers t ON c.teacherId = t.id
      WHERE cr.studentId = ?
    ''', [studentId]);
  }

  Future<int> approveRequest(int requestId) async {
    final db = await instance.database;
    // First update the request status
    await db.update(
      'class_requests',
      {'status': 'approved'},
      where: 'id = ?',
      whereArgs: [requestId],
    );

    // Then get the request details
    final request = await db.query(
      'class_requests',
      where: 'id = ?',
      whereArgs: [requestId],
    );

    if (request.isNotEmpty) {
      final studentId = request.first['studentId'] as int;
      final classId = request.first['classId'] as int;

      // Insert a default grade record
      return await db.insert('grades', {
        'studentId': studentId,
        'classId': classId,
        'score': 0.0,
      });
    }
    return 0;
  }

  Future<int> rejectRequest(int requestId) async {
    final db = await instance.database;
    return await db.update(
      'class_requests',
      {'status': 'rejected'},
      where: 'id = ?',
      whereArgs: [requestId],
    );
  }

  // Grade methods
  Future<int> insertOrUpdateGrade({required int studentId, required int classId, required double grade}) async {
    final db = await instance.database;
    final existing = await db.query(
      'grades',
      where: 'studentId = ? AND classId = ?',
      whereArgs: [studentId, classId],
    );

    if (existing.isNotEmpty) {
      return await db.update(
        'grades',
        {'score': grade},
        where: 'studentId = ? AND classId = ?',
        whereArgs: [studentId, classId],
      );
    } else {
      return await db.insert('grades', {
        'studentId': studentId,
        'classId': classId,
        'score': grade,
      });
    }
  }

  Future<List<Map<String, dynamic>>> getGradesByStudent(int studentId) async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT g.score as grade, c.name as className
      FROM grades g
      JOIN classes c ON g.classId = c.id
      WHERE g.studentId = ?
    ''', [studentId]);
  }

  Future<List<Map<String, dynamic>>> getStudentsWithGradesByClass(int classId) async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT s.id, s.name, s.email, s.password, g.score as grade
      FROM students s
      JOIN class_requests cr ON s.id = cr.studentId
      LEFT JOIN grades g ON s.id = g.studentId AND g.classId = ?
      WHERE cr.classId = ? AND cr.status = 'approved'
    ''', [classId, classId]);
  }

  Future<int> removeStudentFromClass(int studentId, int classId) async {
    final db = await instance.database;
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

  Future<void> printAllData() async {
    final db = await instance.database;
    print('==== DEBUG DATABASE ====');

    // Print all students
    final students = await db.query('students');
    print('Students:');
    students.forEach(print);

    // Print all teachers
    final teachers = await db.query('teachers');
    print('\nTeachers:');
    teachers.forEach(print);

    // Print all admins
    final admins = await db.query('admins');
    print('\nAdmins:');
    admins.forEach(print);

    // Print all classes
    final classes = await db.query('classes');
    print('\nClasses:');
    classes.forEach(print);

    // Print all class requests
    final requests = await db.query('class_requests');
    print('\nClass Requests:');
    requests.forEach(print);

    // Print all grades
    final grades = await db.query('grades');
    print('\nGrades:');
    grades.forEach(print);

    print('=======================');
  }
}