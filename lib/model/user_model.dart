class UserModel {
  final int? id;
  final String username;
  final String email;
  final String? fullName;
  final String? phoneNumber;
  final String passwordHash; // Nama field tetap passwordHash
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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int?,
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String?,
      phoneNumber:
          json['phone_numb'] as String?, // Sesuaikan jika nama kolom DB beda
      // PERBAIKAN FINAL DI SINI: Gunakan key 'password_hash'
      passwordHash: json['password_hash'] as String? ?? '', // <-- Harus '_hash'
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.tryParse(json['updated_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'full_name': fullName,
      // Sesuaikan 'phone_numb' jika nama kolom DB beda
      'phone_number': phoneNumber,
      // Nama key di sini harus cocok dengan kolom DB
      'password_hash': passwordHash, // <-- Pastikan ini juga benar
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
