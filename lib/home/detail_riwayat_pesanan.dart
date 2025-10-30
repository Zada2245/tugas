import 'package:flutter/material.dart';
import 'package:tugas/model/pesanan_model.dart'; // Sesuaikan path jika perlu
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Import package QR

class OrderDetailPage extends StatelessWidget {
  final PesananModel order;

  const OrderDetailPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    // Formatter yang sama dari halaman riwayat
    final dateFormatter = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final produk = order.produk; // Ambil data produk

    // Data unik untuk QR Code (contoh: ID Pesanan)
    // Pastikan ID unik dan bisa diverifikasi oleh sistem Anda
    final qrData = 'ORDER_ID:${order.id}';

    return Scaffold(
      appBar: AppBar(title: Text('Detail Pesanan #${order.id}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Bagian QR Code ---
            Center(
              child: Column(
                children: [
                  Text(
                    'Pindai QR Code ini saat pengambilan:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(10), // Padding di sekitar QR
                    decoration: BoxDecoration(
                      color: Colors.white, // Latar belakang putih untuk QR
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: QrImageView(
                      data: qrData, // Data yang di-encode
                      version: QrVersions.auto,
                      size: 200.0, // Ukuran QR Code
                      gapless: false, // Beri sedikit margin
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    qrData, // Tampilkan data QR di bawahnya
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            const Divider(height: 40),

            // --- Bagian Detail Produk ---
            if (produk != null) // Tampilkan jika data produk ada
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    produk.gambar,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, st) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[800],
                      child: const Icon(Icons.broken_image, size: 30),
                    ),
                  ),
                ),
                title: Text(
                  produk.nama,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Text('ID Produk: ${produk.id}'),
              )
            else
              const ListTile(
                // Fallback jika produk tidak ditemukan
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.error_outline, size: 40),
                title: Text('Detail Produk Tidak Tersedia'),
              ),
            const Divider(height: 30),

            // --- Bagian Detail Pesanan Lainnya ---
            _buildDetailRow(
              Icons.calendar_today_outlined,
              'Tanggal Pesan:',
              dateFormatter.format(order.createdAt),
            ),
            _buildDetailRow(
              Icons.local_shipping_outlined,
              'Status:',
              order.status.toUpperCase(),
            ),
            _buildDetailRow(
              Icons.payment_outlined,
              'Total Harga:',
              currencyFormatter.format(order.totalHarga),
            ),
            if (order.lokasiSewa != null && order.lokasiSewa!.isNotEmpty)
              _buildDetailRow(
                Icons.location_on_outlined,
                'Lokasi Ambil:',
                order.lokasiSewa!,
              ),

            // Anda bisa tambahkan detail lain jika perlu (misal: ID User)
            // _buildDetailRow(Icons.person_outline, 'User ID:', order.userId.toString()),
          ],
        ),
      ),
    );
  }

  // Helper widget untuk membuat baris detail
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[400]),
          const SizedBox(width: 12),
          Text(
            '$label ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[400],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
