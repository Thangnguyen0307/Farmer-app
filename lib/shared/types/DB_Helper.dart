import 'package:farmrole/shared/types/Chat_Room_Model.dart';
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
    _db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return _db!;
  }

  // ===================== CREATE TABLE =====================
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE chat_messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
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
        mode TEXT
      )
    ''');
  }

  // ===================== CHAT MESSAGE =====================
  Future<void> insertMessage(ChatMessage m) async {
    final database = await db;
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

  // ===================== CHAT ROOM =====================
  Future<void> insertRoom(ChatRoom room) async {
    final database = await db;
    await database.insert(
      'chat_rooms',
      room.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ChatRoom>> getAllRooms() async {
    final database = await db;
    final rows = await database.query('chat_rooms');
    return rows.map((r) => ChatRoom.fromMap(r)).toList();
  }

  Future<ChatRoom?> getRoomById(String roomId) async {
    final database = await db;
    final rows = await database.query(
      'chat_rooms',
      where: 'roomId = ?',
      whereArgs: [roomId],
    );
    if (rows.isEmpty) return null;
    return ChatRoom.fromMap(rows.first);
  }

  Future<void> deleteAllData() async {
    final database = await db;
    await database.delete('chat_rooms');
    await database.delete('chat_messages');
  }
}
