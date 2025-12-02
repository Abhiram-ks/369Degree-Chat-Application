import 'dart:async';
import 'package:sqflite/sqflite.dart';
import '../local/database_helper.dart';
import '../../model/message_model.dart';

class MessageLocalDataSource {
  final DatabaseHelper _dbHelper;
  final Map<int, StreamController<List<MessageModel>>> _streamControllers = {};

  MessageLocalDataSource({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  /// !Store a message in the database
  Future<int> storeMessage(MessageModel message) async {
    final db = await _dbHelper.database;
    final id = await db.insert(
      'messages',
      message.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    // !Notify stream listeners
    _notifyStreamListeners(message.userId);
    
    return id;
  }

  /// !Get all messages for a specific user
  Future<List<MessageModel>> getMessagesByUserId(int userId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'messages',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date ASC',
    );

    return maps.map((map) => MessageModel.fromJson(map)).toList();
  }

  /// !Stream of messages for a specific user
  Stream<List<MessageModel>> watchMessagesByUserId(int userId) {
    if (!_streamControllers.containsKey(userId) || 
        _streamControllers[userId]!.isClosed) {
      _streamControllers[userId] = StreamController<List<MessageModel>>.broadcast();
    }
    
    getMessagesByUserId(userId).then((messages) {
      if (_streamControllers.containsKey(userId) && 
          !_streamControllers[userId]!.isClosed) {
        _streamControllers[userId]!.add(messages);
      }
    });
    
    return _streamControllers[userId]!.stream;
  }

  ///! Update message status
  Future<void> updateMessageStatus(int messageId, String status) async {
    final db = await _dbHelper.database;
    await db.update(
      'messages',
      {'status': status},
      where: 'id = ?',
      whereArgs: [messageId],
    );
    
    //!Find userId from message and notify
    final message = await db.query(
      'messages',
      where: 'id = ?',
      whereArgs: [messageId],
      limit: 1,
    );
    if (message.isNotEmpty) {
      final userId = message.first['userId'] as int;
      _notifyStreamListeners(userId);
    }
  }

  void _notifyStreamListeners(int userId) {
    getMessagesByUserId(userId).then((messages) {
      if (_streamControllers.containsKey(userId) && 
          !_streamControllers[userId]!.isClosed) {
        _streamControllers[userId]!.add(messages);
      }
    });
  }

  void dispose() {
    for (final controller in _streamControllers.values) {
      controller.close();
    }
    _streamControllers.clear();
  }
}

