class ProdukModel {
  final int id;
  final String nama;
  final String gambar;
  final double harga;
  final String deskripsi;
  final bool? tersedia;
  final DateTime createdAt;

  ProdukModel({
    required this.id,
    required this.nama,
    required this.gambar,
    required this.harga,
    required this.deskripsi,
    this.tersedia,
    required this.createdAt,
  });

  // Fungsi untuk mengubah data JSON/Map dari Supabase menjadi objek ProdukModel
  factory ProdukModel.fromJson(Map<String, dynamic> json) {
    // --- LOGIKA PERBAIKAN HARGA ---
    double hargaParsed = 0.0;
    if (json['harga'] != null) {
      String hargaString = json['harga'].toString();
      String hargaCleaned = hargaString.replaceAll('.', '');
      hargaParsed = double.tryParse(hargaCleaned) ?? 0.0;
    }
    // ----------------------------

    // --- PERKUAT PARSING ID ---
    int idParsed = 0;
    if (json['id'] != null) {
      // Ambil ID sebagai int jika memungkinkan, atau parse jika String
      idParsed = json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()) ?? 0;
    }
    // ----------------------------

    return ProdukModel(
      // Gunakan ID yang sudah diparsing
      id: idParsed,
      nama: json['nama'] as String? ?? 'Nama Tidak Diketahui',
      gambar: json['gambar'] as String? ?? '',
      harga: hargaParsed,
      deskripsi: json['deskripsi'] as String? ?? '',
      tersedia: json['tersedia'] as bool?,
      createdAt: json['created_at'] == null
          ? DateTime.now()
          : DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now(),
    );
  }

  get stok => null;

  // toJson tetap sama...
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'gambar': gambar,
      'harga': harga.toString(),
      'deskripsi': deskripsi,
      'tersedia': tersedia,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
