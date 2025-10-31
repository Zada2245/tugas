import 'package:flutter/material.dart';
// Sesuaikan path ke file helper dan model Anda
import 'package:tugas/services/Database_Helper.dart';
import 'package:tugas/model/komentar_model.dart';
import 'package:intl/intl.dart';

class CommentPage extends StatefulWidget {
  final String currentUsername;

  const CommentPage({super.key, required this.currentUsername});

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final TextEditingController _commentController = TextEditingController();

  // Gunakan FutureBuilder untuk memuat data
  late Future<List<CommentModel>> _commentsFuture;
  final DateFormat _formatter = DateFormat('dd MMM yyyy, HH:mm');

  @override
  void initState() {
    super.initState();
    // Muat komentar saat halaman dibuka
    _loadComments();
  }

  // Fungsi untuk memuat atau memuat ulang komentar
  void _loadComments() {
    setState(() {
      _commentsFuture = _dbHelper.getComments();
    });
  }

  // Fungsi untuk menambah komentar baru
  Future<void> _addComment() async {
    if (_commentController.text.isEmpty) {
      return; // Jangan simpan komentar kosong
    }

    try {
      // Buat objek komentar baru
      final newComment = CommentModel(
        text: _commentController.text,
        createdAt: DateTime.now(),
        username: widget.currentUsername,
      );

      // Simpan ke database SQLite
      await _dbHelper.createComment(newComment);

      // Kosongkan textfield
      _commentController.clear();
      // Muat ulang daftar komentar
      _loadComments();

      // Sembunyikan keyboard
      FocusScope.of(context).unfocus();
    } catch (e) {
      print("Error saving comment: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan komentar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Fungsi untuk menghapus komentar
  Future<void> _deleteComment(int id) async {
    try {
      await _dbHelper.deleteComment(id);
      // Muat ulang daftar komentar
      _loadComments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Komentar dihapus.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("Error deleting comment: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Komentar Lokal')),
      body: Column(
        children: [
          // Bagian 1: Daftar Komentar
          Expanded(
            child: FutureBuilder<List<CommentModel>>(
              future: _commentsFuture,
              builder: (context, snapshot) {
                // Saat loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // Jika error
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                // Jika data kosong
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada komentar.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                // Jika data ada
                final comments = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 6.0,
                        horizontal: 8.0,
                      ),
                      child: ListTile(
                        title: Text(comment.text),
                        subtitle: Text(
                          'Ditulis pada: ${_formatter.format(comment.createdAt.toLocal())}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                        // Tombol Hapus
                        trailing: IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: Colors.red[300],
                          ),
                          onPressed: () => _deleteComment(comment.id!),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Garis pemisah
          const Divider(height: 1),

          // Bagian 2: Input Komentar Baru
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Tulis komentar Anda...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.1),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.send),
                  onPressed: _addComment, // Panggil fungsi tambah
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
          // Beri padding agar tidak mentok keyboard
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}
