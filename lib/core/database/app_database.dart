import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static const _databaseName = 'bookshelf.db';
  static const _databaseVersion = 2;

  static const favouritesTable = 'favourites';
  static const searchCacheTable = 'search_cache';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _openDatabase();

    return _database!;
  }

  Future<Database> _openDatabase() async {
    final databasePath = await getDatabasesPath();

    final path = join(databasePath, _databaseName);

    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $favouritesTable (
        work_id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        authors TEXT NOT NULL,
        first_publish_year INTEGER,
        cover_id INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE $searchCacheTable (
       id INTEGER PRIMARY KEY AUTOINCREMENT,
        query TEXT NOT NULL,
        work_id TEXT NOT NULL,
        title TEXT NOT NULL,
        authors TEXT NOT NULL,
        first_publish_year INTEGER,
        cover_id INTEGER,
        position INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
       CREATE TABLE $searchCacheTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          query TEXT NOT NULL,
          work_id TEXT NOT NULL,
          title TEXT NOT NULL,
          authors TEXT NOT NULL,
          first_publish_year INTEGER,
          cover_id INTEGER,
          position INTEGER NOT NULL
        )
      ''');
    }
  }

  Future<void> close() async {
    final db = _database;

    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
