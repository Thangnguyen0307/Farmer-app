import 'dart:convert';

import 'package:farmrole/shared/types/Chat_Public_Model.dart';
import 'package:farmrole/shared/types/Chat_Room_Model.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._();
  static Database? _db;

  DBHelper._();
  factory DBHelper() => _instance;

  Future<Database> get db async {
    if (_db != null) return _db!;
    final path = join(await getDatabasesPath(), 'chat_app.db');
    _db = await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return _db!;
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE chat_messages (
        id TEXT PRIMARY KEY ,
        clientId TEXT UNIQUE,
        roomId TEXT,
        userId TEXT,
        fullName TEXT,
        avatar TEXT,
        message TEXT,
        imageUrl TEXT,
        createdAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE chat_rooms (
        roomId TEXT PRIMARY KEY,
        roomName TEXT,
        roomAvatar TEXT,
        mode TEXT,
        users TEXT,
        unreadCount INTEGER DEFAULT 0,
        hasNewMessage INTEGER DEFAULT 0,
        hasJoin INTEGER DEFAULT 0,
        userId TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        videoId TEXT,
        title TEXT,
        note TEXT,
        createdAt TEXT,
        unread INTEGER DEFAULT 1
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE chat_rooms ADD COLUMN unreadCount INTEGER DEFAULT 0',
      );
    }
    if (oldVersion < 3) {
      await db.execute(
        'ALTER TABLE chat_rooms ADD COLUMN hasNewMessage INTEGER DEFAULT 0',
      );
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE notifications (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          videoId TEXT,
          title TEXT,
          note TEXT,
          createdAt TEXT
        )
    ''');
    }
  }

  // ================== CHAT MESSAGES ==================
  Future<void> insertMessage(ChatMessage m) async {
    final database = await db;
    print("📩 [insertMessage] messageId=${m.id} | roomId=${m.roomId}");
    await database.insert(
      'chat_messages',
      m.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ChatMessage>> getMessages(String roomId) async {
    final database = await db;
    final rows = await database.query(
      'chat_messages',
      where: 'roomId = ?',
      whereArgs: [roomId],
      orderBy: 'createdAt ASC',
    );
    return rows.map((r) => ChatMessage.fromMap(r)).toList();
  }

  // ================== CHAT ROOMS ==================
  Future<void> insertRoom(ChatRoom room, String userId) async {
    final database = await db;
    final data = room.toMap();
    debugPrint('✅ insertRoom: unread=${room.unreadCount}');
    data['users'] = jsonEncode(
      room.users
          .map(
            (e) => {
              'userId': e.userId,
              'fullName': e.fullName,
              'avatar': e.avatar,
              'online': e.online,
            },
          )
          .toList(),
    );

    data['userId'] = userId;
    await database.insert(
      'chat_rooms',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertRoomPublic(ChatRoom room, String userId) async {
    final database = await db;
    final data = {
      'roomId': room.roomId,
      'roomName': room.roomName,
      'roomAvatar': room.roomAvatar,
      'hasJoin': 0,
      'userId': userId,
      'mode': room.mode,
    };

    data['userId'] = userId;
    await database.insert(
      'chat_rooms',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateRoom(ChatRoom room, String userId) async {
    final database = await db;
    final data = room.toMap();
    data['unreadCount'] = room.unreadCount;
    data['users'] = jsonEncode(
      room.users
          .map(
            (e) => {
              'userId': e.userId,
              'fullName': e.fullName,
              'avatar': e.avatar,
              'online': e.online,
            },
          )
          .toList(),
    );
    data['userId'] = userId;

    await database.update(
      'chat_rooms',
      data,
      where: 'roomId = ? AND userId = ?',
      whereArgs: [room.roomId, userId],
    );
  }

  Future<List<ChatRoom>> getAllRooms() async {
    final database = await db;
    final rows = await database.query('chat_rooms');
    return rows.map((r) => ChatRoom.fromMap(r)).toList();
  }

  Future<List<ChatRoom>> getRoomsByUser(String userId) async {
    final database = await db;
    final maps = await database.query(
      'chat_rooms',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return maps.map((e) => ChatRoom.fromMap(e)).toList();
  }

  Future<ChatRoom?> getRoomById(String roomId, String userId) async {
    final database = await db;
    final rows = await database.query(
      'chat_rooms',
      where: 'roomId = ? AND userId = ?',
      whereArgs: [roomId, userId],
    );
    if (rows.isEmpty) return null;
    return ChatRoom.fromMap(rows.first);
  }

  //xoa room
  Future<void> deleteRoom(String roomId) async {
    final database = await db;
    await database.delete(
      'chat_rooms',
      where: 'roomId = ?',
      whereArgs: [roomId],
    );
  }

  //ham kiểm tra hasJoin cua public room
  Future<bool> isRoomJoined(String roomId, String userId) async {
    final database = await db;
    final result = await database.query(
      'chat_rooms',
      where: 'roomId = ? AND userId = ? AND hasJoin = 1',
      whereArgs: [roomId, userId],
    );
    return result.isNotEmpty;
  }

  Future<void> setRoomHasJoin(String roomId, String userId) async {
    final database = await db;
    await database.update(
      'chat_rooms',
      {'hasJoin': 1},
      where: 'roomId = ? AND userId = ?',
      whereArgs: [roomId, userId],
    );
  }

  Future<Map<String, ChatMessage>> getLastMessagesForAllRooms() async {
    final database = await db;
    final result = await database.rawQuery('''
      SELECT * FROM chat_messages 
      WHERE id IN (
        SELECT MAX(id) FROM chat_messages GROUP BY roomId
      )
    ''');
    final Map<String, ChatMessage> map = {};
    for (final row in result) {
      final msg = ChatMessage.fromMap(row);
      map[msg.roomId!] = msg;
    }
    return map;
  }

  Future<ChatMessage?> getLastMessage(String roomId) async {
    final database = await db;
    final rows = await database.query(
      'chat_messages',
      where: 'roomId = ?',
      whereArgs: [roomId],
      orderBy: 'createdAt DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return ChatMessage.fromMap(rows.first);
  }

  Future<bool> hasMessages(String roomId) async {
    final dbClient = await db;
    final result = await dbClient.query(
      'chat_messages',
      where: 'roomId = ?',
      whereArgs: [roomId],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  // ================== UNREAD COUNT ==================
  Future<void> increaseUnread(String roomId) async {
    final database = await db;
    await database.rawUpdate(
      '''
      UPDATE chat_rooms 
      SET unreadCount = unreadCount + 1, hasNewMessage = 1
      WHERE roomId = ?
      ''',
      [roomId],
    );
  }

  // Future<void> updateRoomUnread(String roomId, int count) async {
  //   final database = await db;
  //   await database.update(
  //     'chat_rooms',
  //     {'unreadCount': count},
  //     where: 'roomId = ?',
  //     whereArgs: [roomId],
  //   );
  // }

  Future<void> setUnread(String roomId, int count) async {
    final dbClient = await db;
    await dbClient.update(
      'chat_rooms',
      {'unreadCount': count},
      where: 'roomId = ?',
      whereArgs: [roomId],
    );
  }

  Future<void> resetUnread(String roomId) async {
    final database = await db;
    await database.rawUpdate(
      '''
      UPDATE chat_rooms 
      SET unreadCount = 0, hasNewMessage = 0
      WHERE roomId = ?
      ''',
      [roomId],
    );
  }

  Future<int> getUnread(String roomId) async {
    final database = await db;
    final result = await database.query(
      'chat_rooms',
      columns: ['unread_count'],
      where: 'roomId = ?',
      whereArgs: [roomId],
    );

    if (result.isNotEmpty) {
      return result.first['unread_count'] as int;
    }
    return 0;
  }

  Future<void> setHasNewMessageTrue(String roomId) async {
    final database = await db;
    await database.update(
      'chat_rooms',
      {'hasNewMessage': 1},
      where: 'roomId = ?',
      whereArgs: [roomId],
    );
  }

  //Tinh tong cac thong bao moi
  Future<int> getTotalUnreadCount(String userId) async {
    final database = await db;
    final result = await database.rawQuery(
      '''
    SELECT SUM(unreadCount) as total 
    FROM chat_rooms 
    WHERE userId = ?
    ''',
      [userId],
    );

    final total = result.first['total'];
    return (total == null) ? 0 : total as int;
  }

  Future<Map<String, dynamic>?> getUserById(String userId) async {
    final database = await db;
    final rooms = await database.query('chat_rooms');

    for (final room in rooms) {
      final usersJson = room['users'] as String?;
      if (usersJson == null) continue;

      final List<dynamic> users = jsonDecode(usersJson);
      for (final u in users) {
        if (u['userId'] == userId) {
          return u;
        }
      }
    }

    return null;
  }

  // ================== NOTI ==================
  Future<void> insertNotification({
    required String videoId,
    required String title,
    required String note,
  }) async {
    final database = await db;
    await database.insert('notifications', {
      'videoId': videoId,
      'title': title,
      'note': note,
      'createdAt': DateTime.now().toIso8601String(),
      'unread': 1,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getAllNotifications() async {
    final database = await db;
    return await database.query('notifications', orderBy: 'createdAt DESC');
  }

  //tinh tong unread cua noti
  Future<int> getUnreadNotificationsCount() async {
    final database = await db;
    final result = await database.rawQuery('''
    SELECT COUNT(*) as count FROM notifications WHERE unread = 1
  ''');

    final count = result.first['count'];
    return (count == null) ? 0 : count as int;
  }

  //đánh dấu 1 noti là đã đọc rồi
  Future<void> markNotificationAsRead(int id) async {
    final database = await db;
    await database.update(
      'notifications',
      {'unread': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ================== UTILS ==================
  Future<void> deleteAllData() async {
    final database = await db;
    await database.delete('chat_rooms');
    await database.delete('chat_messages');
  }

  Future<void> deleteDatabaseFile() async {
    final path = join(await getDatabasesPath(), 'chat_app.db');
    await deleteDatabase(path);
  }
}
