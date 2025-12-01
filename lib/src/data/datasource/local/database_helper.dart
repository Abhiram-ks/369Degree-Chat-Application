import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError(
        'Database is not supported on web platform. '
        'Use web-compatible storage solution instead.',
      );
    }
    if (_database != null) return _database!;
    _database = await _initDB('users.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (kIsWeb) {
      throw UnsupportedError('Database initialization is not supported on web.');
    }
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE users (
        id $idType,
        fullName $textType,
        email $textType,
        avatarUrl $textType
      )
    ''');

    await db.execute('''
      CREATE TABLE messages (
        id $idType AUTOINCREMENT,
        userId $integerType,
        message $textType,
        date $textType,
        isCurrentUser $integerType,
        status $textType
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      const integerType = 'INTEGER NOT NULL';
      const textType = 'TEXT NOT NULL';
      
      await db.execute('''
        CREATE TABLE IF NOT EXISTS messages (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId $integerType,
          message $textType,
          date $textType,
          isCurrentUser $integerType,
          status $textType
        )
      ''');
    }
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}

