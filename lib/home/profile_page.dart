import 'package:flutter/material.dart';
import 'package:tugas/login/login.dart';
// PASTIKAN PATH INI BENAR: 'models' atau 'model'
import 'package:tugas/model/user_model.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatelessWidget {
  final UserModel currentUser;

  const ProfilePage({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    // Formatter untuk tanggal (jika diperlukan)
    final DateFormat dateFormatter = DateFormat('dd MMM yyyy', 'id_ID');

    // Ambil inisial untuk Avatar
    String getInitials(String username) {
      if (username.isEmpty) return '?';
      // Ambil 2 huruf pertama jika ada spasi
      List<String> names = username.split(' ');
      String initials = '';
      int numToTake = names.length > 1 ? 2 : 1;
      for (var i = 0; i < numToTake; i++) {
        if (names[i].isNotEmpty) {
          initials += names[i][0].toUpperCase();
        }
      }
      return initials;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profil Saya')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- BAGIAN AVATAR DAN NAMA ---
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withAlpha(50),
              child: Text(
                getInitials(currentUser.username), // Gunakan username
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              // Tampilkan Nama Lengkap jika ada, jika tidak, tampilkan Username
              currentUser.fullName != null && currentUser.fullName!.isNotEmpty
                  ? currentUser.fullName!
                  : currentUser.username,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              currentUser.email, // Tampilkan email
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[400]),
            ),
            const Divider(height: 40),

            // --- BAGIAN DETAIL PROFIL ---
            _buildProfileDetailRow(
              context,
              icon: Icons.person_pin_outlined,
              label: 'Username',
              value: currentUser.username,
            ),
            _buildProfileDetailRow(
              context,
              icon: Icons.email_outlined,
              label: 'Email',
              value: currentUser.email,
            ),
            _buildProfileDetailRow(
              context,
              icon: Icons.badge_outlined,
              label: 'Nama Lengkap',
              // Tampilkan 'Belum diatur' jika kosong
              value: currentUser.fullName?.isNotEmpty ?? false
                  ? currentUser.fullName!
                  : 'Belum diatur',
            ),
            _buildProfileDetailRow(
              context,
              icon: Icons.phone_outlined,
              label: 'No. Handphone',
              value: currentUser.phoneNumber?.isNotEmpty ?? false
                  ? currentUser.phoneNumber!
                  : 'Belum diatur',
            ),
            _buildProfileDetailRow(
              context,
              icon: Icons.info_outline,
              label: 'User ID',
              value: currentUser.id.toString(), // Tampilkan ID
            ),
            if (currentUser.updatedAt != null)
              _buildProfileDetailRow(
                context,
                icon: Icons.calendar_today_outlined,
                label: 'Terakhir Update',
                value: dateFormatter.format(currentUser.updatedAt!),
              ),

            // --- TOMBOL LOGOUT ---
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                label: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.redAccent),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  // Kembali ke halaman login dan hapus semua halaman di atasnya
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (Route<dynamic> route) => false, // Hapus semua
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget untuk membuat baris detail profil
  Widget _buildProfileDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.grey[400]),
          const SizedBox(width: 16),
          Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[400])),
          const Spacer(), // Dorong nilai ke kanan
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
