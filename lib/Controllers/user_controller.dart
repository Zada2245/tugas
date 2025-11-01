import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:tugas/data/supabase_credentials.dart';
import 'package:tugas/model/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserController {
  final SupabaseClient _client = SupabaseCredentials.client;

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<UserModel?> loginUser(String email, String password) async {
    print('Attempting login for email: $email');
    try {
      print('Calling Supabase signInWithPassword...');

      final profileRes = await _client
          .from('profile')
          .select()
          .eq('email', email)
          .maybeSingle();

      if (profileRes == null) {
        print('Login error: Email tidak ditemukan');
        return null;
      }
      print('Profile fetched for login: $profileRes');

      final storedUser = UserModel.fromJson(profileRes);
      final inputPasswordHash = _hashPassword(password);

      print(
        'Comparing input hash: $inputPasswordHash with stored hash: ${storedUser.passwordHash}',
      );
      if (inputPasswordHash == storedUser.passwordHash) {
        print(
          'Login successful, returning UserModel for: ${storedUser.username}',
        );
        return storedUser;
      } else {
        print('Login error: Password salah');
        return null;
      }
    } on AuthException catch (authErr) {
      print(
        'Login Auth error caught (unexpected in manual mode): ${authErr.message}',
      );
      return null;
    } catch (e) {
      print('Login general error caught: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> registerUser({
    required String username,
    required String email,
    required String password,
    String? fullName,
    String? phoneNumber,
  }) async {
    try {
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

      final existing = await _client
          .from('profile')
          .select('id')
          .eq('email', email)
          .maybeSingle();

      if (existing != null) {
        return {'success': false, 'message': 'Email sudah terdaftar'};
      }

      final passwordHash = _hashPassword(password);

      await _client.from('profile').insert({
        'username': username,
        'email': email,
        'full_name': fullName,
        // PERBAIKAN DI SINI:
        'phone_number': phoneNumber,
        'password_hash': passwordHash,
      });

      return {'success': true, 'message': 'Registrasi berhasil'};
    } on PostgrestException catch (pgErr) {
      print('Register PG error: ${pgErr.message}');
      String detail = pgErr.details?.toString() ?? '';
      return {
        'success': false,
        'message': 'Database error: ${pgErr.message} $detail',
      };
    } catch (e) {
      print('Register general error: $e');
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }
}
