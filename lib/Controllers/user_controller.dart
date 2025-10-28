import 'package:tugas/data/supabase_credentials.dart';
import 'package:tugas/model/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserController {
  // Ambil client dari file credentials Anda
  final SupabaseClient _client = SupabaseCredentials.client;

  /// Login: Menggunakan Supabase Auth (Aman)
  /// Mengembalikan UserModel jika sukses, null jika gagal.
  Future<UserModel?> loginUser(String email, String password) async {
    try {
      // 1. Panggil Supabase Auth untuk login (Aman)
      // Ini akan mengecek ke "brankas" auth.users
      final authResponse = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = authResponse.user;
      if (user == null) return null; // Gagal login

      // 2. Ambil data profil dari tabel 'profile' kita
      final profileRes = await _client
          .from('profile') // Nama tabel 'profile' Anda
          .select()
          .eq('id', user.id)
          .single(); // Ambil satu baris

      // 3. Kembalikan data sebagai UserModel
      return UserModel.fromJson(profileRes);
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  /// Register: Menggunakan Supabase Auth (Aman)
  /// Mengembalikan Map { success: bool, message: String }
  Future<Map<String, dynamic>> registerUser({
    required String username, // Sesuai tabel 'profile' kita
    required String email,
    required String password,
    String? fullName, // Opsional
    String? phoneNumber, // Opsional
  }) async {
    try {
      // validasi minimal
      if (username.trim().isEmpty ||
          email.trim().isEmpty ||
          password.trim().isEmpty) {
        return {
          'success': false,
          'message': 'Username, email, dan password wajib diisi',
        };
      }
      if (password.length < 6) {
        return {'success': false, 'message': 'Password minimal 6 karakter'};
      }

      // 1. Panggil Supabase Auth untuk daftar (Aman)
      // Password akan di-enkripsi otomatis oleh Supabase
      final authResponse = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          // Kirim data ini ke Trigger SQL kita
          'username': username,
          'full_name': fullName,
          'phone_numb': phoneNumber, // Sesuaikan dengan nama kolom Anda
        },
      );

      if (authResponse.user == null) {
        return {
          'success': false,
          'message': 'Gagal mendaftar di Supabase Auth',
        };
      }

      // 2. Trigger SQL akan otomatis menangani pembuatan baris di tabel 'profile'.
      // (Kita perlu perbarui Trigger-nya agar bisa menyimpan data tambahan ini)

      return {'success': true, 'message': 'Registrasi berhasil'};
    } on AuthException catch (authErr) {
      print('Register Auth error: ${authErr.message}');
      return {'success': false, 'message': 'Auth error: ${authErr.message}'};
    } catch (e) {
      print('Register error: $e');
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }
}
