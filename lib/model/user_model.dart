class UserModel {
  final String id; // HARUS String (uuid) untuk dicocokkan dengan auth.users
  final String username;
  final String? fullName;
  final String? phoneNumber;
  final DateTime updatedAt; // Sesuai dengan tabel 'profile' kita

  UserModel({
    required this.id,
    required this.username,
    this.fullName,
    this.phoneNumber,
    required this.updatedAt,
  });

  // Fungsi ini mengubah data JSON dari tabel 'profile' menjadi objek UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'] ?? '',
      fullName: json['full_name'], // Sesuaikan jika nama kolom beda
      phoneNumber: json['phone_numb'], // Ini nama kolom di tabel 'profile' Anda
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
