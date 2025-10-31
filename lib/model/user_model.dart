class UserModel {
  final int? id;
  final String username;
  final String email;
  final String? fullName;
  final String? phoneNumber; // Nama variabel di Flutter tetap 'phoneNumber'
  final String passwordHash;
  final DateTime? updatedAt;

  UserModel({
    this.id,
    required this.username,
    required this.email,
    this.fullName,
    this.phoneNumber,
    required this.passwordHash,
    this.updatedAt,
  });

  // Fungsi ini mengubah data JSON/Map dari Supabase menjadi objek UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int?,
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String?,

      // --- PERBAIKAN DI SINI ---
      // Nama kolom di database Anda adalah 'phone_number'
      phoneNumber:
          json['phone_number'] as String?, // <-- Diubah ke 'phone_number'

      // -------------------------
      passwordHash: json['password_hash'] as String? ?? '',
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.tryParse(json['updated_at'].toString()),
    );
  }

  // toJson (jika Anda perlu mengirim data ke Supabase nanti)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber, // <-- Diubah ke 'phone_number'
      'password_hash': passwordHash,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
