import 'package:flutter/material.dart';
import 'package:tugas/model/pesanan_model.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

class OrderDetailPage extends StatelessWidget {
  final PesananModel order;

  const OrderDetailPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final produk = order.produk;

    // QR Code
    final qrData = 'ORDER_ID:${order.id}';

    // Hitung jumlah hari sewa
    int jumlahHari = 1;
    if (order.tanggalKembali != null) {
      jumlahHari = order.tanggalKembali!.difference(order.createdAt).inDays;
      if (jumlahHari < 1) jumlahHari = 1;
    }

    // Total harga berdasarkan jumlah hari
    double hargaPerHari = produk?.harga ?? order.totalHarga;
    double totalHargaSewa = hargaPerHari * jumlahHari;

    return Scaffold(
      appBar: AppBar(title: Text('Detail Pesanan #${order.id}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // QR Code
            Center(
              child: Column(
                children: [
                  Text(
                    'Pindai QR Code ini saat pengambilan:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                      data: qrData,
                      version: QrVersions.auto,
                      size: 200.0,
                      gapless: false,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    qrData,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            const Divider(height: 40),

            // Detail Produk
            if (produk != null)
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
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.error_outline, size: 40),
                title: Text('Detail Produk Tidak Tersedia'),
              ),
            const Divider(height: 30),

            // Detail Pesanan
            _buildDetailRow(
              Icons.calendar_today_outlined,
              'Tanggal Pesan:',
              dateFormatter.format(order.createdAt),
            ),
            if (order.tanggalKembali != null)
              _buildDetailRow(
                Icons.calendar_today_outlined,
                'Tanggal Kembali:',
                dateFormatter.format(order.tanggalKembali!),
              ),
            _buildDetailRow(
              Icons.calendar_month,
              'Lama Sewa:',
              '$jumlahHari hari',
            ),
            // Harga per hari
            _buildDetailRow(
              Icons.attach_money,
              'Harga per Hari:',
              currencyFormatter.format(hargaPerHari),
            ),
            // Total harga sewa
            _buildDetailRow(
              Icons.payment,
              'Total Harga Sewa:',
              currencyFormatter.format(totalHargaSewa),
            ),
            _buildDetailRow(
              Icons.local_shipping_outlined,
              'Status:',
              order.status.toUpperCase(),
            ),
            if (order.lokasiSewa != null && order.lokasiSewa!.isNotEmpty)
              _buildDetailRow(
                Icons.location_on_outlined,
                'Lokasi Ambil:',
                order.lokasiSewa!,
              ),
          ],
        ),
      ),
    );
  }

  // Helper untuk baris detail
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
