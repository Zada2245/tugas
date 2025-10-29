import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseCredentials {
  // Ganti dengan URL Supabase Anda
  static const String supabaseUrl = 'https://ekysmgpqoluxhoeungre.supabase.co';

  // Ganti dengan ANON KEY Supabase Anda (yang public)
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVreXNtZ3Bxb2x1eGhvZXVuZ3JlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjExMDg1NTMsImV4cCI6MjA3NjY4NDU1M30.xv8RjcD8oUg5Odx8Dpgsn6ilh0s4edBBqqo_NKaIv2M'; // <-- PASTIKAN INI BENAR

  // Client Supabase yang bisa diakses dari mana saja
  // Penting: Ini hanya bisa diakses SETELAH Supabase.initialize dipanggil di main.dart
  static SupabaseClient get client => Supabase.instance.client;
}
