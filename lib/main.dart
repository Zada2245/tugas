import 'package:flutter/material.dart';
import 'package:tugas/login/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tugas/data/supabase_credentials.dart';
import 'package:intl/date_symbol_data_local.dart';

// ✅ 1. TAMBAHKAN IMPORT INI
import 'package:flutter_localizations/flutter_localizations.dart';

// 1. IMPORT TIMEZONE
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart'; // Package yang baru

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi format intl
  await initializeDateFormatting('id_ID', null);

  // 2. INISIALISASI DATABASE ZONA WAKTU
  tz.initializeTimeZones();
  try {
    // --- PERBAIKAN DI SINI ---
    // Ambil objek, lalu panggil .toString() untuk memaksa jadi String
    // Ini akan menangani TimezoneInfo atau String
    final String localTimeZone = (await FlutterTimezone.getLocalTimezone())
        .toString();
    // --------------------------

    print('Timezone Dideteksi: $localTimeZone'); // Log untuk debugging

    tz.setLocalLocation(tz.getLocation(localTimeZone));
  } catch (e) {
    print('Failed to get local timezone: $e');
    // Fallback ke zona waktu default (misal: Jakarta)
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
  }
  // ------------------------------------

  // Inisialisasi Supabase
  await Supabase.initialize(
    url: SupabaseCredentials.supabaseUrl,
    anonKey: SupabaseCredentials.supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kamera Rental',
      debugShowCheckedModeBanner: false,

      // ✅ 2. TAMBAHKAN BLOK INI UNTUK MEMPERBAIKI ERROR DATEPICKER
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'), // Bahasa Indonesia
        Locale('en', 'US'), // Bahasa Inggris (sebagai fallback)
      ],
      locale: const Locale('id', 'ID'),

      // -----------------------------------------------------
      theme: ThemeData.dark().copyWith(
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
      home: const LoginPage(),
    );
  }
}
