import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginMurid extends StatefulWidget {
  const LoginMurid({super.key});

  @override
  State<LoginMurid> createState() => _LoginMuridState();
}

class _LoginMuridState extends State<LoginMurid> {
  final _nisnController = TextEditingController();
  final _sandiAkunController = TextEditingController();
  final _sandiKelasController = TextEditingController();
  bool _isLoading = false;
  bool _obscureSandi = true;
  bool _obscureSandiKelas = true;

  Future<void> _login() async {
    if (_nisnController.text.isEmpty ||
        _sandiAkunController.text.isEmpty ||
        _sandiKelasController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua field harus diisi!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Login pakai format nisn@flawlyclass.com
      final email = '${_nisnController.text.trim()}@flawlyclass.com';
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: _sandiAkunController.text.trim(),
      );

      if (response.user != null && mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard-murid');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('NISN atau sandi salah!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4A90D9),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Logo
            const Icon(Icons.school, size: 60, color: Colors.white),
            const SizedBox(height: 8),
            const Text(
              'Flawly Class',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            // Form Card
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Masuk',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const Text(
                        'Masuk ke akun kamu',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 28),
                      // NISN
                      TextField(
                        controller: _nisnController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'NISN',
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Sandi Akun
                      TextField(
                        controller: _sandiAkunController,
                        obscureText: _obscureSandi,
                        decoration: InputDecoration(
                          hintText: 'Sandi akun',
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureSandi
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setState(
                                () => _obscureSandi = !_obscureSandi),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Sandi Kelas
                      TextField(
                        controller: _sandiKelasController,
                        obscureText: _obscureSandiKelas,
                        decoration: InputDecoration(
                          hintText: 'Sandi kelas',
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureSandiKelas
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setState(
                                () => _obscureSandiKelas = !_obscureSandiKelas),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Tombol Masuk
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A90D9),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text(
                                  'Masuk',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nisnController.dispose();
    _sandiAkunController.dispose();
    _sandiKelasController.dispose();
    super.dispose();
  }
}