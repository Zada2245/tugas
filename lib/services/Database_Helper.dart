import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
// Sesuaikan path ke model Anda
import 'package:tugas/model/komentar_model.dart';

class DatabaseHelper {
  // Nama database
  static const _databaseName = "KomentarLokal.db";
  static const _databaseVersion = 1; // Versi tetap 1, kita akan install ulang

  // Nama tabel dan kolom
  static const table = 'comments';
  static const columnId = '_id';
  static const columnText = 'text';
  static const columnCreatedAt = 'createdAt';
  static const columnUsername = 'username'; // <-- 1. KOLOM BARU

  // Singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // 2. TAMBAHKAN KOLOM USERNAME KE PERINTAH SQL
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnText TEXT NOT NULL,
            $columnCreatedAt TEXT NOT NULL,
            $columnUsername TEXT NOT NULL 
          )
          ''');
  }

  // --- FUNGSI CRUD (TIDAK PERLU DIUBAH) ---
  // Fungsi create, get, delete akan otomatis bekerja
  // karena kita akan update Model-nya

  // 1. CREATE (Membuat komentar baru)
  Future<int> createComment(CommentModel comment) async {
    Database db = await instance.database;
    // toMap() dari CommentModel akan otomatis menyertakan username
    return await db.insert(table, comment.toMap());
  }

  // 2. READ (Mengambil semua komentar)
  Future<List<CommentModel>> getComments() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      table,
      orderBy: '$columnCreatedAt DESC',
    );

    // fromMap() dari CommentModel akan otomatis mengambil username
    return List.generate(maps.length, (i) {
      return CommentModel.fromMap(maps[i]);
    });
  }

  // 3. DELETE (Hapus komentar berdasarkan ID)
  Future<int> deleteComment(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
}
