import 'package:tugas/data/supabase_credentials.dart';
import 'package:tugas/model/pesanan_model.dart'; // Import model pesanan
// Import model produk mungkin diperlukan jika ingin update stok
import 'package:tugas/model/produk_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PesananController {
  final _client = SupabaseCredentials.client;

  /// Fungsi untuk membuat pesanan baru (dipanggil dari OrderPage)
  Future<Map<String, dynamic>> createOrder({
    required int userId, // ID pengguna dari tabel profile (int8)
    required int produkId, // ID produk dari tabel produk (int8)
    required double totalHarga,
    required String lokasiSewa,
    int? produkStokSaatIni, // Tambahkan stok saat ini jika ingin update
    required DateTime tanggalKembali, // ✅ PASTIKAN PARAMETER INI ADA
  }) async {
    print(
      'PesananController: Creating order for user $userId, produk $produkId, price $totalHarga, location $lokasiSewa, kembali $tanggalKembali',
    );
    try {
      // Validasi Stok (jika ada)
      if (produkStokSaatIni != null && produkStokSaatIni <= 0) {
        print('PesananController: Stok habis validation failed.');
        return {'success': false, 'message': 'Stok produk habis!'};
      }

      // Data yang akan dimasukkan
      final Map<String, dynamic> orderData = {
        'user_id': userId,
        'produk_id': produkId,
        'total_harga': totalHarga,
        'lokasi_sewa': lokasiSewa,
        'status': 'disewa', // Pastikan nama kolom dan nilai sesuai
        'tanggal_kembali': tanggalKembali
            .toIso8601String(), // ✅ TAMBAHKAN DATA TANGGAL
      };
      print('PesananController: Data to insert: $orderData');

      // 1. Masukkan data ke tabel 'pesanan'
      print('PesananController: Executing insert into pesanan...');
      await _client.from('pesanan').insert(orderData);
      print('PesananController: Insert into pesanan successful.');

      // 2. Update stok (jika ada)
      if (produkStokSaatIni != null) {
        print('PesananController: Updating stock for produk $produkId...');
        final newStock = produkStokSaatIni - 1;
        final updateResponse = await _client
            .from('produk')
            .update({'stok': newStock}) // Pastikan nama kolom 'stok' benar
            .eq('id', produkId)
            .select(); // Optional: select() untuk verifikasi

        if (updateResponse.isEmpty) {
          print(
            'PesananController: Warning - Failed to update stock after order.',
          );
        } else {
          print('PesananController: Stock updated successfully to $newStock.');
        }
      } else {
        print('PesananController: Stock update skipped (stokSaatIni is null).');
      }

      return {'success': true, 'message': 'Pemesanan berhasil dibuat!'};
    } on PostgrestException catch (pgError) {
      // Tangkap error database
      print(
        'PesananController: Postgrest ERROR creating order: ${pgError.message}',
      );
      print(
        'PesananController: Code: ${pgError.code}, Details: ${pgError.details}, Hint: ${pgError.hint}',
      );
      return {
        'success': false,
        'message': 'Database error: ${pgError.message}',
      };
    } catch (e) {
      // Tangkap error lain
      print('PesananController: General ERROR creating order: $e');
      print('PesananController: Runtime type: ${e.runtimeType}');
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  // --- FUNGSI fetchUserOrders ---
  /// Fungsi untuk mengambil riwayat pesanan user (dipanggil dari RiwayatPesananPage)
  Future<List<PesananModel>> fetchUserOrders(int userId) async {
    print('PesananController: Fetching orders for user ID: $userId');
    try {
      // Query ke tabel 'pesanan', join dengan 'produk'
      final response = await _client
          .from('pesanan')
          .select('*, produk!inner(id, nama, gambar, harga, deskripsi, stok)')
          .eq('user_id', userId) // Filter berdasarkan ID pengguna
          .order('created_at', ascending: false); // Urutkan dari terbaru

      print('PesananController: Raw response received: $response');

      // Konversi hasil (List<dynamic>) menjadi List<PesananModel>
      final List<PesananModel> orders = response.map((item) {
        try {
          return PesananModel.fromJson(item as Map<String, dynamic>);
        } catch (e) {
          print(
            'PesananController: Error parsing order item $item - Error: $e',
          );
          // Melempar error agar bisa ditangkap di UI
          throw Exception('Gagal parsing data pesanan: $e');
        }
      }).toList();

      print('PesananController: Fetch successful. Count: ${orders.length}');
      return orders;
    } on PostgrestException catch (pgError) {
      print(
        'PesananController: Postgrest ERROR fetching orders: ${pgError.message}',
      );
      print('PesananController: Details: ${pgError.details}');
      return []; // Kembalikan list kosong jika error
    } catch (e) {
      print('PesananController: General ERROR fetching orders: $e');
      return []; // Kembalikan list kosong jika error
    }
  }
  // -----------------------------

  // Tambahkan fungsi lain jika perlu (misal: cancelOrder, updateOrderStatus)
}
