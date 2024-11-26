import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_list/models/task.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();

  static final String _tasksTableName = "tasks";
  static final String _tasksIdColumnName = "id";
  static final String _tasksContentColumnName = "content";
  static final String _tasksStatusColumnName = "status";
  static final String _idEquals = '$_tasksIdColumnName = ?';

  DatabaseService._constructor();

  Future<Database> get database async {
    _db ??= await getDatabase();
    return _db!;
  }

  static final createScripts = [
    '''
      CREATE TABLE $_tasksTableName (
        $_tasksIdColumnName INTEGER PRIMARY KEY AUTOINCREMENT,
        $_tasksContentColumnName TEXT NOT NULL,
        $_tasksStatusColumnName INTEGER DEFAULT 0
      )
    '''
  ];

  Future<Null> doCreate(Database db, int version) async {
    for (var i = 0; i < createScripts.length; i++) {
      await db.execute(createScripts[i]);
    }
  }

  Future<Null> doUpgrade(Database db, int oldVersion, int newVersion) async {
    for (var i = oldVersion - 1; i <= newVersion - 1; i++) {
      await db.execute(migrationScripts[i]);
    }
  }

  static final migrationScripts = [];

  Future<Database> getDatabase() async {
    final databasePath = join(await getDatabasesPath(), "master_dv.db");
    return await openDatabase(databasePath,
        onCreate: doCreate,
        onUpgrade: doUpgrade,
        version: migrationScripts.length + 1);
  }

  void addTask(
    String content,
  ) async {
    final db = await database;
    await db.insert(_tasksTableName, {_tasksContentColumnName: content});
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final data = await db.query(_tasksTableName);
    return data
        .map((e) => Task(
              id: e[_tasksIdColumnName] as int,
              status: e[_tasksContentColumnName] as int,
              content: e[_tasksStatusColumnName] as String,
            ))
        .toList();
  }

  void updateTaskStatus(int id, int status) async {
    assert(status == 1 || status == 0);
    final db = await database;
    await db.update(_tasksTableName, {_tasksStatusColumnName: status},
        where: _idEquals, whereArgs: [id]);
  }

  void deleteTask(int id) async {
    final db = await database;
    await db.delete(_tasksTableName, where: _idEquals, whereArgs: [id]);
  }
}
