import 'package:tugas/data/supabase_credentials.dart';
// PASTIKAN PATH INI BENAR: 'models' atau 'model'
import 'package:tugas/model/produk_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import SupabaseClient

class ProdukController {
  final SupabaseClient _client = SupabaseCredentials.client;

  // Fungsi untuk mengambil semua produk
  Future<List<ProdukModel>> getProduk() async {
    try {
      // 1. Ambil data mentah (List<dynamic>, biasanya List<Map<String, dynamic>>)
      final List<dynamic> response = await _client
          .from('produk') // Pastikan nama tabel benar
          .select();

      // 2. LAKUKAN KONVERSI DI SINI:
      // Ubah setiap Map di dalam list menjadi objek ProdukModel
      final List<ProdukModel> produkList = response
          .map((item) => ProdukModel.fromJson(item as Map<String, dynamic>))
          .toList();

      // 3. Kembalikan list yang sudah dikonversi
      return produkList;
    } catch (e) {
      print('Error fetching produk: $e');
      // Kembalikan list kosong atau lempar error lagi
      return []; // Atau: throw Exception('Gagal mengambil produk: $e');
    }
  }

  // Kamu bisa tambahkan fungsi lain di sini (misal: getProdukById, addProduk, dll.)
}
