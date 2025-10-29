class ProdukModel {
  final int id;
  final String nama;
  final String gambar;
  // Ubah tipe harga menjadi double agar bisa menangani angka besar/desimal
  final double harga;
  final String deskripsi;
  // 'tersedia' bisa null, jadi gunakan bool?
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
    // --- PERBAIKAN LOGIKA HARGA DI SINI ---
    double hargaParsed = 0.0; // Default value jika parsing gagal
    if (json['harga'] != null) {
      // 1. Ambil harga sebagai String (atau dynamic)
      String hargaString = json['harga'].toString();
      // 2. Hapus karakter non-numerik (seperti titik '.')
      String hargaCleaned = hargaString.replaceAll('.', '');
      // 3. Coba parse menjadi double
      hargaParsed = double.tryParse(hargaCleaned) ?? 0.0;
    }
    // ------------------------------------

    return ProdukModel(
      // Pastikan 'id' benar-benar int
      id: json['id'] as int? ?? 0,
      nama: json['nama'] as String? ?? 'Nama Tidak Diketahui',
      gambar: json['gambar'] as String? ?? '', // Beri default jika null
      // Gunakan harga yang sudah diparsing
      harga: hargaParsed,
      deskripsi: json['deskripsi'] as String? ?? '', // Beri default jika null
      // 'tersedia' bisa null di DB Anda, jadi baca sebagai bool?
      tersedia: json['tersedia'] as bool?,
      // Parse tanggal, beri default jika gagal
      createdAt: json['created_at'] == null
          ? DateTime.now()
          : DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now(),
    );
  }

  // toJson (jika Anda perlu mengirim data ke Supabase nanti)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'gambar': gambar,
      // Saat mengirim, mungkin perlu format kembali jika Supabase mengharapkan String
      'harga': harga.toString(), // Atau sesuaikan dengan tipe kolom DB
      'deskripsi': deskripsi,
      'tersedia': tersedia,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
