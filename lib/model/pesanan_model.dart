import 'package:tugas/model/produk_model.dart'; // Import model produk

class PesananModel {
  final int id;
  final int userId;
  final int produkId;
  final double totalHarga;
  final String status;
  final String? lokasiSewa;
  final DateTime createdAt; // Simpan sebagai DateTime
  final ProdukModel? produk;

  PesananModel({
    required this.id,
    required this.userId,
    required this.produkId,
    required this.totalHarga,
    required this.status,
    this.lokasiSewa,
    required this.createdAt,
    this.produk,
  });

  factory PesananModel.fromJson(Map<String, dynamic> json) {
    ProdukModel? parsedProduk;
    if (json['produk'] != null && json['produk'] is Map<String, dynamic>) {
      try {
        parsedProduk = ProdukModel.fromJson(
          json['produk'] as Map<String, dynamic>,
        );
      } catch (e) {
        print("Error parsing nested produk data: $e");
        parsedProduk = null;
      }
    } else if (json['produk'] == null) {
      print("Warning: 'produk' field is null in pesanan data.");
    } else {
      print("Warning: 'produk' field is not a Map: ${json['produk']}");
    }

    double hargaParsed = 0.0;
    if (json['total_harga'] != null) {
      hargaParsed = double.tryParse(json['total_harga'].toString()) ?? 0.0;
    }

    // --- PERBAIKAN PARSING WAKTU ---
    DateTime createdAtLocal = DateTime.now(); // Default jika parsing gagal
    if (json['created_at'] != null) {
      try {
        // 1. Parse string waktu dari Supabase (yang dalam UTC)
        DateTime createdAtUtc = DateTime.parse(json['created_at'].toString());
        // 2. Konversi ke zona waktu lokal perangkat
        createdAtLocal = createdAtUtc.toLocal();
      } catch (e) {
        print("Error parsing created_at: $e");
        // Biarkan menggunakan DateTime.now() sebagai fallback
      }
    }
    // -----------------------------

    return PesananModel(
      id: json['id'] as int? ?? 0,
      userId: _parseIntSafely(json['user_id']),
      produkId: _parseIntSafely(json['produk_id']),
      totalHarga: hargaParsed,
      status: json['status'] as String? ?? 'unknown',
      lokasiSewa: json['lokasi_sewa'] as String?,
      // Gunakan waktu yang sudah dikonversi ke lokal
      createdAt: createdAtLocal,
      produk: parsedProduk,
    );
  }

  static int _parseIntSafely(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}
