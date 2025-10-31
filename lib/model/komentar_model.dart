// Sesuaikan path ke helper Anda jika berbeda
import 'package:tugas/services/Database_Helper.dart';

class CommentModel {
  final int? id; // ID bisa null saat membuat data baru
  final String text;
  final DateTime createdAt;
  final String username; // <-- 1. TAMBAHKAN FIELD USERNAME

  CommentModel({
    this.id,
    required this.text,
    required this.createdAt,
    required this.username, // <-- 2. TAMBAHKAN DI CONSTRUCTOR
  });

  // Konversi dari Map (data dari SQLite) menjadi objek CommentModel
  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map[DatabaseHelper.columnId],
      text: map[DatabaseHelper.columnText],
      createdAt: DateTime.parse(map[DatabaseHelper.columnCreatedAt]),
      username: map[DatabaseHelper.columnUsername], // <-- 3. AMBIL DARI MAP
    );
  }

  // Konversi dari objek CommentModel menjadi Map (untuk disimpan ke SQLite)
  Map<String, dynamic> toMap() {
    return {
      // ID tidak perlu dimasukkan saat insert, akan dibuat otomatis
      DatabaseHelper.columnText: text,
      DatabaseHelper.columnCreatedAt: createdAt.toIso8601String(),
      DatabaseHelper.columnUsername: username, // <-- 4. SIMPAN KE MAP
    };
  }
}
