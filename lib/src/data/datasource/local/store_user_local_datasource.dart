import 'package:sqflite/sqflite.dart';
import '../local/database_helper.dart';
import '../../model/user_model.dart';

class StoreUserLocalDataSource {
  final DatabaseHelper _dbHelper;

  StoreUserLocalDataSource({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;


  ///! If user with same id exists, it will be replaced
  Future<void> storeUser(UserModel user) async {
    final db = await _dbHelper.database;
    await db.insert(
      'users',
      user.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }



  /// !If users with same id exist, they will be replaced
  Future<void> storeUsers(List<UserModel> users) async {
    final db = await _dbHelper.database;
    final batch = db.batch();

    for (final user in users) {
      batch.insert(
        'users',
        user.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }


  /// !Get a user by id
  Future<UserModel?> getUserById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return UserModel.fromJson(maps.first);
  }

  ///! Get all users from the database
  Future<List<UserModel>> getAllUsers() async {
    final db = await _dbHelper.database;
    final maps = await db.query('users', orderBy: 'id ASC');

    return maps.map((map) => UserModel.fromJson(map)).toList();
  }


}

