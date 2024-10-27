import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_list/models/task.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();

  final String _tasksTableName = "tasks";
  final String _tasksIdColumnName = "id";
  final String _tasksContentColumnName = "content";
  final String _tasksStatusColumnName = "status";

  DatabaseService._constructor();

  Future<Database> get database async {
    _db ??= await getDatabase();
    return _db!;
  }

  Future<Database> getDatabase() async {
    final databasaDirPath = await getDatabasesPath();
    final databasePath = join(databasaDirPath, "master_dv.db");
    final database =
        await openDatabase(databasePath, version: 1, onCreate: (db, version) {
      db.execute('''
      CREATE TABLE $_tasksTableName (
        $_tasksIdColumnName INTEGER PRIMARY KEY AUTOINCREMENT,
        $_tasksContentColumnName TEXT NOT NULL,
        $_tasksStatusColumnName INTEGER DEFAULT 0
      )
      ''');
    });
    return database;
  }

  void addTask(
    String content,
  ) async {
    final db = await database;
    await db.insert(_tasksTableName, {
      _tasksContentColumnName: content
    });
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final data = await db.query(_tasksTableName);
    return data
        .map((e) => Task(
              id: e["id"] as int,
              status: e["status"] as int,
              content: e["content"] as String,
            ))
        .toList();
  }
  void updateTaskStatus(int id, int status) async {
    final db = await database;
    await db.update(_tasksTableName, {
    _tasksStatusColumnName:status
    },
      where: 'id = ?',
      whereArgs: [
        id,
      ]
    );
  }
  }
