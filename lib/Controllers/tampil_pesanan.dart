import 'package:tugas/data/supabase_credentials.dart';
import 'package:tugas/model/pesanan_model.dart'; // Import model pesanan
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
    int? produkStokSaatIni,
  }) async {
    print(
      // <-- LOG 1: Memulai fungsi
      'PesananController: Attempting createOrder for user $userId, produk $produkId, price $totalHarga, location $lokasiSewa',
    );
    try {
      // Validasi Stok (jika ada)
      if (produkStokSaatIni != null && produkStokSaatIni <= 0) {
        print(
          'PesananController: Stok habis validation failed.',
        ); // <-- LOG 2: Stok habis
        return {'success': false, 'message': 'Stok produk habis!'};
      }

      // Data yang akan dimasukkan
      final Map<String, dynamic> orderData = {
        'user_id': userId,
        'produk_id': produkId,
        'total_harga': totalHarga,
        'lokasi_sewa': lokasiSewa,
        'status': 'disewa', // Pastikan nama kolom dan nilai sesuai
      };
      print(
        'PesananController: Data to insert: $orderData',
      ); // <-- LOG 3: Data siap

      // 1. Masukkan data ke tabel 'pesanan'
      print(
        'PesananController: Executing insert into pesanan...',
      ); // <-- LOG 4: Sebelum insert
      await _client.from('pesanan').insert(orderData);
      print(
        'PesananController: Insert into pesanan successful.',
      ); // <-- LOG 5: Setelah insert

      // 2. Update stok (jika ada)
      if (produkStokSaatIni != null) {
        print(
          'PesananController: Updating stock for produk $produkId...',
        ); // <-- LOG 6: Sebelum update stok
        final newStock = produkStokSaatIni - 1;
        final updateResponse = await _client
            .from('produk')
            .update({'stok': newStock}) // Pastikan nama kolom 'stok' benar
            .eq('id', produkId)
            .select(); // Optional: select() untuk verifikasi

        if (updateResponse.isEmpty) {
          print(
            'PesananController: Warning - Failed to update stock after order.',
          ); // <-- LOG 7: Gagal update stok
        } else {
          print(
            'PesananController: Stock updated successfully to $newStock.',
          ); // <-- LOG 8: Sukses update stok
        }
      } else {
        print(
          'PesananController: Stock update skipped (stokSaatIni is null).',
        ); // <-- LOG 9: Skip update stok
      }

      return {'success': true, 'message': 'Pemesanan berhasil dibuat!'};
    } on PostgrestException catch (pgError) {
      // Tangkap error database
      print(
        'PesananController: Postgrest ERROR creating order: ${pgError.message}',
      ); // <-- LOG 10: Error DB
      print(
        'PesananController: Code: ${pgError.code}, Details: ${pgError.details}, Hint: ${pgError.hint}',
      );
      return {
        'success': false,
        'message': 'Database error: ${pgError.message}',
      };
    } catch (e) {
      // Tangkap error lain
      print(
        'PesananController: General ERROR creating order: $e',
      ); // <-- LOG 11: Error umum
      print('PesananController: Runtime type: ${e.runtimeType}');
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  // --- Fungsi fetchUserOrders tetap sama ---
  Future<List<PesananModel>> fetchUserOrders(int userId) async {
    print('PesananController: Fetching orders for user ID: $userId');
    try {
      final response = await _client
          .from('pesanan')
          .select('*, produk!inner(id, nama, gambar, harga, deskripsi, stok)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      print('PesananController: Raw response received: $response');

      final List<PesananModel> orders = response.map((item) {
        try {
          return PesananModel.fromJson(item as Map<String, dynamic>);
        } catch (e) {
          print(
            'PesananController: Error parsing order item $item - Error: $e',
          );
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
      return [];
    } catch (e) {
      print('PesananController: General ERROR fetching orders: $e');
      return [];
    }
  }
}
