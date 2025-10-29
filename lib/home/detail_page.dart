import 'package:flutter/material.dart';
import 'package:tugas/model/produk_model.dart'; // Sesuaikan path jika perlu
import 'package:tugas/data/supabase_credentials.dart'; // Untuk akses client
import 'package:supabase_flutter/supabase_flutter.dart'; // Untuk User
import 'package:intl/intl.dart'; // <-- 1. IMPORT intl

class DetailPage extends StatefulWidget {
  // Ubah jadi StatefulWidget
  final ProdukModel produk;
  const DetailPage({super.key, required this.produk});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  // Buat State
  bool _isProcessing = false; // Status untuk proses sewa

  // 2. PINDAHKAN FORMATTER KE SINI
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  // Fungsi untuk menampilkan dialog konfirmasi
  void _showRentalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Penyewaan'),
          content: Text(
            'Anda yakin ingin menyewa ${widget.produk.nama}?',
          ), // Akses via widget.produk
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              onPressed: _isProcessing
                  ? null
                  : _handleSewa, // Panggil _handleSewa
              child: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Ya, Sewa Sekarang'),
            ),
          ],
        );
      },
    );
  }

  // Pisahkan logika sewa ke fungsi async
  Future<void> _handleSewa() async {
    setState(() {
      _isProcessing = true; // Mulai proses
    });
    Navigator.of(context).pop(); // Tutup dialog dulu

    try {
      // Dapatkan User ID (pastikan user sudah login)
      final User? user = SupabaseCredentials.client.auth.currentUser;
      if (user == null) {
        // Jika menggunakan sistem manual, user mungkin null, tangani di sini
        // Coba ambil ID dari UserModel jika ada, atau tampilkan error
        // Ini contoh jika Anda punya cara mengambil UserModel saat ini
        // final UserModel? currentUser = await getCurrentUserModel(); // Ganti dengan logika Anda
        // if (currentUser == null || currentUser.id == null) {
        throw Exception('User belum login atau ID tidak ditemukan!');
        // }
        // final userId = currentUser.id;

        // --- HAPUS BAGIAN INI JIKA SUDAH KEMBALI KE SUPABASE AUTH ---
        // Jika masih pakai Supabase Auth, baris di atas sudah cukup:
        // throw Exception('User belum login!');
      }

      // Masukkan data ke tabel 'pesanan'
      await SupabaseCredentials.client.from('pesanan').insert({
        'produk_id': widget.produk.id, // Akses via widget.produk
        // Pastikan Anda mendapatkan user ID yang benar
        'user_id': user?.id, // Gunakan user?.id jika user bisa null
        'status': 'disewa',
      });

      // Tampilkan notifikasi sukses
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Berhasil menyewa ${widget.produk.nama}!',
            ), // Akses via widget.produk
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      // Tampilkan notifikasi error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyewa: ${error.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      // Pastikan loading berhenti
      if (mounted) {
        setState(() {
          _isProcessing = false; // Selesai proses
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.produk.nama), // Akses via widget.produk
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.network(
                widget.produk.gambar, // Akses via widget.produk
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 250,
                    color: Colors.grey[800], // Warna background gelap
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 100,
                        color: Colors.grey, // Warna ikon
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.produk.nama, // Akses via widget.produk
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              // 3. GUNAKAN FORMATTER DI SINI
              formatter.format(widget.produk.harga), // Akses via widget.produk
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary, // Warna dari tema
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Deskripsi Produk',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.produk.deskripsi, // Akses via widget.produk
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).colorScheme.primary,
              // Hapus foregroundColor dari sini jika ingin coba cara TextStyle
              // foregroundColor: Colors.white,
            ),
            onPressed: () => _showRentalDialog(context), // Panggil dialog
            child: const Text(
              'Sewa Sekarang',
              // PERBAIKAN ALTERNATIF: Tambahkan warna di TextStyle
              style: TextStyle(
                fontSize: 18,
                color: Color.fromARGB(255, 16, 16, 16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
