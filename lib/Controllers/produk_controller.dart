import 'package:tugas/data/supabase_credentials.dart';
// PASTIKAN PATH INI BENAR SESUAI FOLDER ANDA ('models' atau 'model')
import 'package:tugas/model/produk_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import SupabaseClient

class ProdukController {
  final SupabaseClient _client = SupabaseCredentials.client;

  // Fungsi untuk mengambil semua produk
  Future<List<ProdukModel>> getProduk() async {
    print('ProdukController: Memulai getProduk...'); // <-- LOG 1
    try {
      // 1. Ambil data mentah
      print(
        'ProdukController: Mengambil data dari tabel produk...',
      ); // <-- LOG 2
      final List<dynamic> response = await _client
          .from('produk') // Pastikan nama tabel 'produk' sudah benar
          .select();
      print(
        'ProdukController: Data mentah diterima: $response',
      ); // <-- LOG 3: Lihat data mentahnya

      if (response.isEmpty) {
        print(
          'ProdukController: Respon data mentah kosong.',
        ); // <-- LOG 4: Jika kosong
        return []; // Kembalikan list kosong jika tidak ada data
      }

      // 2. LAKUKAN KONVERSI
      print(
        'ProdukController: Memulai konversi ke ProdukModel...',
      ); // <-- LOG 5
      final List<ProdukModel> produkList = response
          .map((item) {
            try {
              // Cetak setiap item sebelum konversi
              // print('ProdukController: Mengonversi item: $item');
              return ProdukModel.fromJson(item as Map<String, dynamic>);
            } catch (e) {
              // Tangkap error jika konversi GAGAL untuk satu item
              print(
                'ProdukController: ERROR konversi item $item - Error: $e',
              ); // <-- LOG 6: Error konversi
              // Anda bisa memilih untuk mengabaikan item yang error atau menghentikan proses
              // return null; // Jika ingin mengabaikan
              throw Exception(
                'Gagal konversi item: $e',
              ); // Jika ingin menghentikan & menampilkan error
            }
          })
          // .where((produk) => produk != null) // Hapus filter ini jika Anda melempar exception di atas
          .toList();

      print(
        'ProdukController: Konversi berhasil. Jumlah produk: ${produkList.length}',
      ); // <-- LOG 7: Sukses
      // 3. Kembalikan list yang sudah dikonversi
      return produkList;
    } on PostgrestException catch (pgError) {
      // Tangkap error spesifik dari Supabase (misal: RLS salah, tabel tidak ada)
      print(
        'ProdukController: Postgrest ERROR: ${pgError.message}',
      ); // <-- LOG 8: Error database
      print('ProdukController: Postgrest Details: ${pgError.details}');
      print('ProdukController: Postgrest Hint: ${pgError.hint}');
      return []; // Kembalikan list kosong saat error
    } catch (e) {
      // Tangkap error umum lainnya
      print(
        'ProdukController: General ERROR fetching produk: $e',
      ); // <-- LOG 9: Error umum
      return []; // Kembalikan list kosong saat error
    }
  }
}
