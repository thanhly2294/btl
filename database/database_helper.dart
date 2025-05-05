import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'school.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE teachers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE classes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        teacher_id INTEGER,
        FOREIGN KEY (teacher_id) REFERENCES teachers(id)
      );
    ''');

    await db.execute('''
      CREATE TABLE class_students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        class_id INTEGER,
        student_id INTEGER,
        FOREIGN KEY (class_id) REFERENCES classes(id),
        FOREIGN KEY (student_id) REFERENCES students(id)
      );
    ''');

    await db.execute('''
      CREATE TABLE grades (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER,
        class_id INTEGER,
        score REAL,
        FOREIGN KEY (student_id) REFERENCES students(id),
        FOREIGN KEY (class_id) REFERENCES classes(id)
      );
    ''');
  }

  // Các hàm insert tài khoản mẫu (cho tiện đăng nhập)
  Future<void> insertDummyAccounts() async {
    final db = await database;

    await db.insert('students', {'username': 'sv1', 'password': '123'}, conflictAlgorithm: ConflictAlgorithm.ignore);
    await db.insert('teachers', {'username': 'gv1', 'password': '123'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<Map<String, dynamic>?> loginStudent(String username, String password) async {
    final db = await database;
    final res = await db.query('students',
        where: 'username = ? AND password = ?', whereArgs: [username, password]);
    return res.isNotEmpty ? res.first : null;
  }

  Future<Map<String, dynamic>?> loginTeacher(String username, String password) async {
    final db = await database;
    final res = await db.query('teachers',
        where: 'username = ? AND password = ?', whereArgs: [username, password]);
    return res.isNotEmpty ? res.first : null;
  }
}
