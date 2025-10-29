import 'package:flutter/material.dart';
import 'package:tugas/login/login.dart';
import 'package:tugas/controllers/produk_controller.dart';
import 'package:tugas/model/produk_model.dart'; // Pastikan path ini benar
import 'package:tugas/home/detail_page.dart';
import 'package:intl/intl.dart'; // <-- 1. IMPORT intl

class HomePage extends StatefulWidget {
  final String username;
  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ProdukModel> _dataProduk = [];
  final ProdukController _produkController = ProdukController();
  bool _isLoading = true;

  // 2. BUAT FORMATTER UNTUK RUPIAH
  final formatter = NumberFormat.currency(
    locale: 'id_ID', // Locale Indonesia
    symbol: 'Rp ', // Simbol Rupiah
    decimalDigits: 0, // Hilangkan angka di belakang koma jika nol
  );

  Future<void> _ambilDataProduk() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final List<ProdukModel> data = await _produkController.getProduk();
      setState(() {
        _dataProduk = data;
        _isLoading = false;
      });
    } catch (error) {
      print('Error mengambil data produk: $error');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat produk: ${error.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _ambilDataProduk();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rental Kamera'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _ambilDataProduk,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Selamat Datang, ${widget.username}!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Daftar Produk:',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  Expanded(
                    child: _dataProduk.isEmpty
                        ? const Center(
                            child: Text('Tidak ada produk tersedia.'),
                          )
                        : ListView.builder(
                            itemCount: _dataProduk.length,
                            itemBuilder: (context, index) {
                              final ProdukModel produk = _dataProduk[index];

                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8.0,
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: ListTile(
                                  leading: Image.network(
                                    produk.gambar,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 60,
                                        height: 60,
                                        color: Colors.grey[800],
                                        child: const Icon(
                                          Icons.broken_image,
                                          size: 40,
                                        ),
                                      );
                                    },
                                  ),
                                  title: Text(produk.nama),
                                  subtitle: Text(
                                    produk.deskripsi,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: Text(
                                    // 3. GUNAKAN FORMATTER DI SINI
                                    formatter.format(produk.harga),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  onTap: () {
                                    print('Tapped on: ${produk.nama}');
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DetailPage(produk: produk),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
