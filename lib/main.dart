import 'package:flutter/material.dart';
import 'package:tugas/login/login.dart'; // Pastikan path ini benar
import 'package:supabase_flutter/supabase_flutter.dart';

// --- BAGIAN KONEKSI PENTING ---
// URL dan Key ini HARUS BENAR.
// Saya sudah mengisinya dengan key Anda dari riwayat chat kita.
const String supabaseUrl = 'https://ekysmgpqoluxhoeungre.supabase.co';
const String supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVreXNtZ3Bxb2x1eGhvZXVuZ3JlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjExMDg1NTMsImV4cCI6MjA3NjY4NDU1M30.xv8RjcD8oUg5Odx8Dpgsn6ilh0s4edBBqqo_NKaIv2M';

// ---------------------------------

Future<void> main() async {
  // 1. Pastikan Flutter siap
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inisialisasi Supabase
  // Error 'Anonymous sign-in' terjadi jika 'anonKey' ini salah atau kosong.
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  // 3. Jalankan Aplikasi
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kamera Rental',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        // Tema Anda sudah diatur dengan baik di sini
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.black.withOpacity(0.2),
        ),
      ),
      // Aplikasi dimulai di LoginPage
      home: const LoginPage(),
    );
  }
}
