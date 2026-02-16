import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:todo_list/modelos/frases.dart';
import 'tarea.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _db;

  AppDatabase._init();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB('todo_app.db');
    return _db!;
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
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        time TEXT NOT NULL,
        completed INTEGER NOT NULL,
        completedDate TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE phrases (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        text TEXT NOT NULL,
        author TEXT NOT NULL
      )
    ''');

    await db.insert('phrases', {
      'text': 'Haz lo que puedas, con lo que tienes, dondequiera que estés.',
      'author': 'Theodore Roosevelt'
    });

    await db.insert('phrases', {
      'text': 'No mires al reloj, haz lo que él hace: sigue moviéndote',
      'author': 'Sam Levenson'
    });

    await db.insert('phrases', {
      'text': 'Quien tiene un porqué para vivir, encontrará casi siempre el cómo',
      'author': 'Nietzsche'
    });
  }


  Future<List<Task>> getTasks() async {
    final db = await instance.database;
    final result = await db.query('tasks');
    return result.map((e) => Task.fromMap(e)).toList();
  }

  Future<List<Task>> getTasksCompletedToday() async {
    final db = await instance.database;

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    final result = await db.query(
      'tasks',
      where: 'completed = 1 AND completedDate >= ?',
      whereArgs: [startOfDay.toIso8601String()],
      orderBy: 'completedDate DESC',
    );

    return result.map((e) => Task.fromMap(e)).toList();
  }

  Future<List<Task>> getLatestCompletedTasks() async {
    final db = await instance.database;

    final result = await db.query(
      'tasks',
      where: 'completed = 1',
      orderBy: 'completedDate DESC',
      limit: 4,
    );

    return result.map((e) => Task.fromMap(e)).toList();
  }

  Future<List<Task>> getClosestPendingTasks() async {
    final db = await instance.database;

    final result = await db.query(
      'tasks',
      where: 'completed = 0',
      orderBy: 'time ASC',
      limit: 4,
    );

    return result.map((e) => Task.fromMap(e)).toList();
  }


  Future<int> insertTask(Task task) async {
    final db = await instance.database;
    return db.insert('tasks', task.toMap());
  }

  Future<int> updateTask(Task task) async {
    final db = await instance.database;
    return db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<Phrase?> getRandomPhrase() async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT * FROM phrases ORDER BY RANDOM() LIMIT 1');
    
    if (result.isEmpty) return null;
    return Phrase.fromMap(result.first);
  }
}


