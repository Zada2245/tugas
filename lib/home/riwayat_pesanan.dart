import 'package:flutter/material.dart';
import 'package:tugas/controllers/pesanan_controller.dart';
// PASTIKAN PATH INI BENAR: 'models' atau 'model'
import 'package:tugas/model/pesanan_model.dart';
import 'package:intl/intl.dart';
// 1. IMPORT HALAMAN DETAIL PESANAN
import 'package:tugas/home/detail_riwayat_pesanan.dart'; // Pastikan path ini benar

class RiwayatPesananPage extends StatefulWidget {
  final int? currentUserId; // Terima ID pengguna (int? karena bisa null)

  const RiwayatPesananPage({super.key, required this.currentUserId});

  @override
  State<RiwayatPesananPage> createState() => _RiwayatPesananPageState();
}

class _RiwayatPesananPageState extends State<RiwayatPesananPage> {
  final PesananController _pesananController = PesananController();
  late Future<List<PesananModel>> _ordersFuture;

  final dateFormatter = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    if (widget.currentUserId == null) {
      print("RiwayatPesananPage: User ID is null, cannot load orders.");
      _ordersFuture = Future.error('User ID tidak valid!');
    } else {
      _ordersFuture = _pesananController.fetchUserOrders(widget.currentUserId!);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pesanan Saya')),
      body: FutureBuilder<List<PesananModel>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Gagal memuat riwayat: ${snapshot.error}'),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Anda belum memiliki riwayat pesanan.'),
            );
          }

          final orders = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              _loadOrders();
            },
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final produk = order.produk;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  elevation: 2,
                  child: ListTile(
                    // <-- ListTile dibuat bisa diklik
                    contentPadding: const EdgeInsets.all(12),
                    leading: produk?.gambar != null && produk!.gambar.isNotEmpty
                        ? ClipRRect(
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
                          )
                        : Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[800],
                            child: const Icon(Icons.camera_alt, size: 30),
                          ),
                    title: Text(
                      produk?.nama ?? 'Produk Tidak Ditemukan',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'Tanggal: ${dateFormatter.format(order.createdAt)}',
                        ),
                        Text('Status: ${order.status.toUpperCase()}'),
                        Text(
                          'Total: ${currencyFormatter.format(order.totalHarga)}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        if (order.lokasiSewa != null &&
                            order.lokasiSewa!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              'Lokasi: ${order.lokasiSewa}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[400],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: const Icon(
                      Icons.chevron_right,
                    ), // Tambah ikon panah
                    // 2. TAMBAHKAN onTap DI SINI
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          // Arahkan ke OrderDetailPage dan kirim data 'order'
                          builder: (context) => OrderDetailPage(order: order),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
