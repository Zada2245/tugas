import 'package:flutter/material.dart';
import 'package:tugas/login/login.dart';
// 1. UBAH IMPORT: Kita tidak lagi pakai main.dart, tapi file credentials
import 'package:tugas/data/supabase_credentials.dart';

class HomePage extends StatefulWidget {
  final String username;
  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _dataProduk = []; // Defaultnya list kosong
  bool _isLoading = true; // Variable untuk status loading

  Future<void> _ambilDataProduk() async {
    try {
      // 2. UBAH CARA MEMANGGIL: Gunakan client dari SupabaseCredentials
      final List<dynamic> data = await SupabaseCredentials.client
          .from('produk')
          .select();

      setState(() {
        _dataProduk = data;
        _isLoading = false; // Loading selesai
      });
    } catch (error) {
      print('Error mengambil data: $error');
      setState(() {
        _isLoading = false; // Loading selesai walau error
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
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
        title: const Text('Halaman Utama'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      // 3. GUNAKAN 'body' UNTUK MENAMPILKAN DATA
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            ) // Tampilkan loading
          : Column(
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
                  child: Text('Daftar Produk:', style: TextStyle(fontSize: 18)),
                ),

                // 4. GUNAKAN ListView.builder UNTUK MENAMPILKAN LIST
                Expanded(
                  child: ListView.builder(
                    itemCount: _dataProduk.length, // Berapa banyak item
                    itemBuilder: (context, index) {
                      final produk = _dataProduk[index]; // Ambil 1 produk

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: ListTile(
                          leading: Image.network(
                            produk['gambar'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            // Error handling jika URL gambar bermasalah
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.broken_image, size: 50);
                            },
                          ),
                          title: Text(produk['nama']),
                          subtitle: Text(produk['deskripsi']),
                          trailing: Text(
                            'Rp ${produk['harga']}', // Tampilkan harga
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
