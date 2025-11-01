import 'package:flutter/material.dart';
import 'package:tugas/login/login.dart';
import 'package:tugas/controllers/produk_controller.dart';
// PASTIKAN PATH INI BENAR: 'models' atau 'model'
import 'package:tugas/model/produk_model.dart';
import 'package:tugas/model/user_model.dart'; // Import UserModel
import 'package:tugas/home/detail_page.dart';
import 'package:tugas/home/riwayat_pesanan.dart';
import 'package:tugas/home/comment_page.dart';
import 'package:tugas/home/profile_page.dart';
import 'package:intl/intl.dart';

// --- PERUBAHAN: IMPORT FILE BARU ---
import 'package:tugas/home/saran_kesan_page.dart';
// ------------------------------------

// --- KELAS SaranKesanPage SUDAH DIHAPUS DARI SINI ---

class HomePage extends StatefulWidget {
  final UserModel currentUser;
  const HomePage({super.key, required this.currentUser});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // State untuk Bottom Navigation Bar
  int _selectedIndex = 0; // Index 0 adalah tab "Home"

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // (State dan logic untuk tab Home)
  final TextEditingController _searchController = TextEditingController();
  List<ProdukModel> _allProduk = [];
  List<ProdukModel> _filteredProduk = [];

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
    _searchController.addListener(_filterProduk);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterProduk);
    _searchController.dispose();
    super.dispose();
  }

  void _filterProduk() {
    // ... (Fungsi ini tidak berubah)
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredProduk = _allProduk;
      } else {
        _filteredProduk = _allProduk.where((produk) {
          final namaLower = produk.nama.toLowerCase();
          final deskripsiLower = produk.deskripsi.toLowerCase();
          return namaLower.contains(query) || deskripsiLower.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _ambilDataProduk() async {
    // ... (Fungsi ini tidak berubah)
    setState(() {
      _isLoading = true;
    });
    try {
      final List<ProdukModel> data = await _produkController.getProduk();
      setState(() {
        _allProduk = data;
        _filteredProduk = data;
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

  // --- AppBar Dinamis ---
  PreferredSizeWidget _buildAppBar() {
    // Tampilkan AppBar yang berbeda untuk setiap tab
    switch (_selectedIndex) {
      case 0: // Tab Home
        return AppBar(
          title: const Text('Rental Kamera'),
          automaticallyImplyLeading: false,
          actions: [
            // --- Tombol Komentar (Tetap) ---
            IconButton(
              icon: const Icon(Icons.comment_outlined),
              tooltip: 'Komentar Lokal',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CommentPage(
                      currentUsername: widget.currentUser.username,
                    ),
                  ),
                );
              },
            ),

            // --- Tombol Logout (Tetap) ---
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
        );
      case 1: // Tab Riwayat
        return AppBar(
          title: const Text('Riwayat Pesanan'),
          automaticallyImplyLeading: false,
        );
      case 2: // Tab Saran & Kesan
        return AppBar(
          title: const Text('Saran & Kesan'),
          automaticallyImplyLeading: false,
        );
      case 3: // Tab Profil
        return AppBar(
          title: const Text('Profil Saya'),
          automaticallyImplyLeading: false,
        );
      default:
        return AppBar(title: const Text('Rental Kamera'));
    }
  }

  // --- Widget untuk body Tab Home ---
  Widget _buildHomeTab() {
    return _isLoading
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
                // --- SEARCH BAR ---
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari kamera, lensa, dll...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                FocusScope.of(
                                  context,
                                ).unfocus(); // Tutup keyboard
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none, // Tanpa border
                      ),
                      filled: true,
                      fillColor: Theme.of(context).cardColor, // Warna card
                    ),
                  ),
                ),
                // --- GRIDVIEW ---
                Expanded(
                  child: _filteredProduk.isEmpty
                      ? Center(
                          child: Text(
                            _allProduk.isEmpty
                                ? 'Tidak ada produk tersedia.'
                                : 'Produk tidak ditemukan untuk "${_searchController.text}"',
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(12.0),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12.0,
                                mainAxisSpacing: 12.0,
                                childAspectRatio: 0.7,
                              ),
                          itemCount: _filteredProduk.length,
                          itemBuilder: (context, index) {
                            final ProdukModel produk = _filteredProduk[index];
                            return _buildProdukCard(produk);
                          },
                        ),
                ),
              ],
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    // --- Definisikan semua halaman/tab ---
    final List<Widget> _pages = <Widget>[
      // Tab 0: Home
      _buildHomeTab(), // Menggunakan method yang tadi dibuat
      // Tab 1: Riwayat
      RiwayatPesananPage(currentUserId: widget.currentUser.id),

      // Tab 2: Saran & Kesan (Menggunakan file yang di-import)
      SaranKesanPage(currentUser: widget.currentUser),

      // Tab 3: Profil
      ProfilePage(currentUser: widget.currentUser),
    ];

    // --- Scaffold utama ---
    return Scaffold(
      appBar: _buildAppBar(),
      body: IndexedStack(index: _selectedIndex, children: _pages),

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rate_review_outlined),
            activeIcon: Icon(Icons.rate_review),
            label: 'Saran',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,

        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Widget _buildProdukCard(ProdukModel produk) {
    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: () {
          print('Tapped on: ${produk.nama}');
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
            Hero(
              tag: 'produk_${produk.id}',
              child: Image.network(
                produk.gambar,
                height: 150,
                width: double.infinity,
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
                    maxLines: 2,
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
