import 'package:flutter/material.dart';
import 'package:tugas/home/homepage.dart';
import 'package:tugas/login/register.dart';
// 1. IMPORT CONTROLLER DAN MODEL KITA
import 'package:tugas/controllers/user_controller.dart';
import 'package:tugas/model/user_model.dart'; // <-- PERBAIKAN 1: models (plural)
// <-- PERBAIKAN 2: Import constants.dart dihapus

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // 2. BUAT INSTANCE DARI USER CONTROLLER
  final UserController _userController = UserController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 3. UBAH FUNGSI _login UNTUK MEMANGGIL CONTROLLER
  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // Panggil controller untuk login
      final UserModel? user = await _userController.loginUser(email, password);

      // Cek apakah login berhasil (user tidak null)
      if (user != null) {
        // Login sukses, pindah ke HomePage
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  HomePage(currentUser: user), // <-- Kirim 'currentUser'
            ),
          );
        }
      } else {
        // Login gagal, tampilkan error
        if (mounted) {
          // <-- PERBAIKAN 3: Kode SnackBar dikembalikan ke sini
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Login gagal: Cek kembali email dan password Anda',
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (error) {
      // Tangani error yang tidak terduga
      if (mounted) {
        // <-- PERBAIKAN 3: Kode SnackBar dikembalikan ke sini
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${error.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Ikon Logo Kamera
                Icon(
                  Icons.camera_enhance,
                  size: 100,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),

                // 2. Nama Aplikasi
                Text(
                  'KAMERA RENTAL',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Login untuk melanjutkan',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.grey[400]),
                ),
                const SizedBox(height: 40),

                // 3. Text field Email
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // 4. Text field Password
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 24),

                // 5. Tombol Login
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _login,
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                const SizedBox(height: 16),

                // 6. Teks untuk Register
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ),
                    );
                  },
                  child: Text(
                    'Belum punya akun? Daftar di sini',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
