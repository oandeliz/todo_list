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

  static const initScript = ['Statement 1', 'Statement 2']; // Initialization script split into seperate statements
  static const migrationScripts = [
    'script 1',
    'script 2',
    'script 3',
  ];

  Future<Database> getDatabase() async {
    final databasaDirPath = await getDatabasesPath();
    final databasePath = join(databasaDirPath, "master_dv.db");
    final database =
        await openDatabase(databasePath, version: migrationScripts.length + 1, onCreate: (Database db, int version) async {
          initScript.forEach((script) async => await db.execute(script));
      db.execute('''
      CREATE TABLE $_tasksTableName (
        $_tasksIdColumnName INTEGER PRIMARY KEY AUTOINCREMENT,
        $_tasksContentColumnName TEXT NOT NULL,
        $_tasksStatusColumnName INTEGER DEFAULT 0
      )
      ''');
    });
    onUpgrade: (Database db, int oldVersion, int newVersion) async {
      for (var i = oldVersion - 1; i <= newVersion - 1; i++) {
        await db.execute(migrationScripts[i]);
      }
    };
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
  void deleteTask(int id) async {
    final db = await database;
    await db.delete(_tasksTableName,
        where: 'id = ?',
        whereArgs: [
          id,
        ]
    );
  }
  }
