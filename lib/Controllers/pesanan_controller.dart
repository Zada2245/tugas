// controllers/pesanan_controller.dart
// Controller ini HANYA bertugas membuat pesanan/sewa
import 'package:tugas/data/supabase_credentials.dart';

class PesananController {
  final _client = SupabaseCredentials.client;

  // Fungsi untuk menyewa produk
  Future<Map<String, dynamic>> sewaProduk({required int produkId}) async {
    try {
      // 1. Dapatkan ID pengguna yang sedang login
      final userId = _client.auth.currentUser?.id;

      if (userId == null) {
        return {
          'success': false,
          'message': 'Anda harus login terlebih dahulu',
        };
      }

      // 2. Asumsi Anda punya tabel 'pesanan'
      //    (id, created_at, produk_id, user_id, status)
      await _client.from('pesanan').insert({
        'produk_id': produkId,
        'user_id': userId,
        'status': 'disewa', // Status awal
      });

      return {'success': true, 'message': 'Produk berhasil disewa!'};
    } catch (error) {
      print('Error sewaProduk: $error');
      return {
        'success': false,
        'message': 'Gagal memproses pesanan: ${error.toString()}',
      };
    }
  }
}
