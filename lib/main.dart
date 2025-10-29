import 'package:flutter/material.dart';
import 'package:tugas/login/login.dart'; // Halaman login Anda
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tugas/data/supabase_credentials.dart'; // Import credentials

Future<void> main() async {
  // Pastikan Flutter siap
  WidgetsFlutterBinding.ensureInitialized();

  // ---- INISIALISASI SUPABASE ----
  // Ambil URL dan Key dari file credentials
  await Supabase.initialize(
    url: SupabaseCredentials.supabaseUrl,
    anonKey: SupabaseCredentials.supabaseAnonKey,
  );
  // -----------------------------

  runApp(const MyApp());
}

// Ambil instance client setelah inisialisasi (bisa juga diakses via SupabaseCredentials.client)
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kamera Rental',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        // ... (Tema Anda sudah benar) ...
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
      // Kita mulai dari LoginPage, logika cek login ada di controller/view
      home: const LoginPage(),
    );
  }
}
