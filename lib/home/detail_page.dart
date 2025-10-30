import 'package:flutter/material.dart';
// PASTIKAN PATH INI BENAR: 'models' atau 'model'
import 'package:tugas/model/produk_model.dart';
import 'package:tugas/data/supabase_credentials.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
// PASTIKAN PATH INI BENAR:
import 'package:tugas/home/pesanan.dart';

class DetailPage extends StatefulWidget {
  final ProdukModel produk;
  // 1. PASTIKAN DetailPage MENERIMA currentUserId
  final int? currentUserId;

  const DetailPage({
    super.key,
    required this.produk,
    required this.currentUserId, // 2. BUAT INI REQUIRED
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  // Fungsi navigasi yang akan dipanggil
  void _navigateToOrderPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderPage(
          produk: widget.produk,
          // 3. KIRIM currentUserId KE OrderPage
          currentUserId: widget.currentUserId,
        ),
      ),
    );
  }

  void _showRentalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Pemesanan'),
          content: Text(
            'Anda akan melanjutkan ke halaman pemesanan untuk detail mata uang dan lokasi untuk ${widget.produk.nama}.',
          ),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog konfirmasi
                _navigateToOrderPage(); // Panggil fungsi navigasi
              },
              child: const Text('Lanjut Pemesanan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.produk.nama)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.network(
                widget.produk.gambar,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 250,
                    color: Colors.grey[800],
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 100,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.produk.nama,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              formatter.format(widget.produk.harga),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Deskripsi Produk',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.produk.deskripsi,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () => _showRentalDialog(context),
              child: const Text(
                'Sewa Sekarang',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
