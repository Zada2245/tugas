import 'package:flutter/material.dart';
// 1. IMPORT CONTROLLER
import 'package:tugas/controllers/user_controller.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // 2. TAMBAHKAN CONTROLLER UNTUK SEMUA FIELD
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  // 3. BUAT INSTANCE DARI USER CONTROLLER
  final UserController _userController = UserController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // 4. UBAH FUNGSI _signUp UNTUK MEMANGGIL CONTROLLER
  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Ambil semua data dari form
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final username = _usernameController.text.trim();
      final fullName = _fullNameController.text.trim();
      final phone = _phoneController.text.trim();

      // Panggil controller untuk mendaftar
      final Map<String, dynamic> result = await _userController.registerUser(
        email: email,
        password: password,
        username: username,
        fullName: fullName,
        phoneNumber: phone, // <-- PERBAIKAN: Diubah dari phoneNumb
      );

      // Cek apakah registrasi berhasil
      if (result['success'] == true) {
        // Registrasi sukses
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']), // Pesan sukses dari controller
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // Kembali ke halaman login
        }
      } else {
        // Registrasi gagal, tampilkan error dari controller
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']), // Pesan error dari controller
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (error) {
      // Tangani error yang tidak terduga
      if (mounted) {
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
      // Tambahkan AppBar agar bisa kembali
      appBar: AppBar(
        title: const Text('Buat Akun Baru'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Text field Email
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // 2. Text field Username
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Text field Nama Lengkap
                TextField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 16),

                // 4. Text field No HP
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'No. Handphone',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                // 5. Text field Password
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password (min. 6 karakter)',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 24),

                // 6. Tombol Daftar
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _signUp,
                        child: const Text(
                          'Daftar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                const SizedBox(height: 16),

                // 7. Tombol untuk kembali ke Login (sudah ada di AppBar)
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Kembali
                  },
                  child: Text(
                    'Sudah punya akun? Login di sini',
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
