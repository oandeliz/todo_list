import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService{
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();

  final String _tasksTableName = "tasks";
  final String _tasksIdColumnName = "id";
  final String _tasksContentColumnName = "content";
  final String _tasksStatusColumnName = "status";

  DatabaseService._constructor();

  Future<Database> get database async {
  if (_db != null) return _db!;
  _db = await getDatabase();
  return _db!;
  }

  Future<Database> getDatabase() async {
    final databasaDirPath = await getDatabasesPath();
    final databasePath = join(databasaDirPath, "master_dv.db");
    final database = await openDatabase(
        databasePath,
      version: 1,
      onCreate: (db, version) {
      db.execute(''''
      CREATE TABLE _tasksTableName (
        $_tasksIdColumnName INTEGER PRIMARY KEY,
        $_tasksContentColumnName TEXT NOT NULL,
        $_tasksStatusColumnName TEXT NOT NULL,
      )
      ''');
      }
    );
    return database;
  }

  void addTask(String content,) async {
    final db = await database;
    await db.insert(_tasksTableName, {
    _tasksContentColumnName: content,
      _tasksStatusColumnName: 0,
    });
  }
  //function to read and retrieve data



}