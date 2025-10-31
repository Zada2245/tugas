import 'package:flutter/material.dart';
import 'package:tugas/model/user_model.dart'; // Pastikan path ini benar

class SaranKesanPage extends StatelessWidget {
  final UserModel currentUser;
  const SaranKesanPage({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar sudah di-handle oleh _buildAppBar di home_page.dart
      // jadi tidak perlu AppBar di sini agar tidak duplikat.
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.rate_review_outlined,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              const Text(
                'Halo pak bagus sehat selalu yaaa pak',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                ' ${currentUser.username}.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
