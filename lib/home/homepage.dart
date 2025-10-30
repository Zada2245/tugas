import 'package:flutter/material.dart';
import 'package:tugas/login/login.dart';
import 'package:tugas/controllers/produk_controller.dart';
// PASTIKAN PATH INI BENAR: 'models' atau 'model'
import 'package:tugas/model/produk_model.dart';
import 'package:tugas/model/user_model.dart'; // Import UserModel
import 'package:tugas/home/detail_page.dart';
import 'package:tugas/home/riwayat_pesanan.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  final UserModel currentUser;
  const HomePage({super.key, required this.currentUser});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // --- STATE BARU UNTUK SEARCH ---
  final TextEditingController _searchController = TextEditingController();
  List<ProdukModel> _allProduk = [];
  List<ProdukModel> _filteredProduk = [];
  // ---------------------------------

  final ProdukController _produkController = ProdukController();
  bool _isLoading = true;
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _ambilDataProduk();
    // Tambahkan listener untuk search bar
    _searchController.addListener(_filterProduk);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterProduk);
    _searchController.dispose();
    super.dispose();
  }

  // Fungsi untuk filter produk berdasarkan input search
  void _filterProduk() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredProduk = _allProduk; // Tampilkan semua jika search kosong
      } else {
        _filteredProduk = _allProduk.where((produk) {
          // Cari berdasarkan nama atau deskripsi
          final namaLower = produk.nama.toLowerCase();
          final deskripsiLower = produk.deskripsi.toLowerCase();
          return namaLower.contains(query) || deskripsiLower.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _ambilDataProduk() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final List<ProdukModel> data = await _produkController.getProduk();
      setState(() {
        _allProduk = data; // Simpan di list master
        _filteredProduk = data; // Tampilkan semua di awal
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rental Kamera'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Riwayat Pesanan',
            onPressed: () {
              if (widget.currentUser.id != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RiwayatPesananPage(
                      currentUserId: widget.currentUser.id,
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('User ID tidak ditemukan! Coba login ulang.'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
          ),
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
                      'Selamat Datang, ${widget.currentUser.username}!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // --- SEARCH BAR BARU ---
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Cari produk...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.1),
                      ),
                    ),
                  ),
                  // --- GRIDVIEW BARU ---
                  Expanded(
                    child: _filteredProduk.isEmpty
                        ? Center(
                            child: Text(
                              _allProduk.isEmpty
                                  ? 'Tidak ada produk tersedia.'
                                  : 'Produk tidak ditemukan.',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(12.0),
                            // Konfigurasi Grid 2 Kolom
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2, // 2 kolom
                                  crossAxisSpacing: 12.0, // Jarak horizontal
                                  mainAxisSpacing: 12.0, // Jarak vertikal
                                  childAspectRatio: 0.75, // Rasio P:L card
                                ),
                            itemCount: _filteredProduk.length,
                            itemBuilder: (context, index) {
                              final ProdukModel produk = _filteredProduk[index];
                              // Panggil card baru
                              return _buildProdukCard(produk);
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  // --- WIDGET CARD BARU UNTUK GRID ---
  Widget _buildProdukCard(ProdukModel produk) {
    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias, // Penting untuk rounded corner di gambar
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: () {
          print('Tapped on: ${produk.nama}');
          // Hilangkan fokus search bar saat pindah halaman
          FocusScope.of(context).unfocus();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailPage(
                produk: produk,
                currentUserId: widget.currentUser.id,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Produk dengan Animasi Hero
            Hero(
              tag: 'produk_${produk.id}', // Tag unik untuk animasi
              child: Image.network(
                produk.gambar,
                height: 150, // Tinggi gambar
                width: double.infinity, // Lebar penuh card
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
                    color: Colors.grey[800],
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 50),
                    ),
                  );
                },
              ),
            ),
            // Detail Teks di bawah gambar
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    produk.nama,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatter.format(produk.harga),
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
