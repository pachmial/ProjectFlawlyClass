import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DaftarMurid extends StatefulWidget {
  const DaftarMurid({super.key});

  @override
  State<DaftarMurid> createState() => _DaftarMuridState();
}

class _DaftarMuridState extends State<DaftarMurid> {
  final _namaController = TextEditingController();
  final _nisnController = TextEditingController();
  final _sandiAkunController = TextEditingController();
  final _konfirmasiSandiController = TextEditingController();
  bool _isLoading = false;
  bool _obscureSandi = true;
  bool _obscureKonfirmasi = true;

  Future<void> _daftar() async {
    if (_namaController.text.isEmpty ||
        _nisnController.text.isEmpty ||
        _sandiAkunController.text.isEmpty ||
        _konfirmasiSandiController.text.isEmpty) {
      _showSnackbar('Semua field harus diisi!', Colors.red);
      return;
    }

    if (!RegExp(r'^\d+$').hasMatch(_nisnController.text.trim())) {
      _showSnackbar('NISN hanya boleh berisi angka!', Colors.red);
      return;
    }

    if (_sandiAkunController.text != _konfirmasiSandiController.text) {
      _showSnackbar('Konfirmasi sandi tidak cocok!', Colors.red);
      return;
    }

    if (_sandiAkunController.text.length < 6) {
      _showSnackbar('Sandi minimal 6 karakter!', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final nisn = _nisnController.text.trim();
      final email = '$nisn@flawlyclass.com';

      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: _sandiAkunController.text.trim(),
      );

      if (response.user == null) throw Exception('Registrasi gagal');

      await Supabase.instance.client.from('murid').insert({
        'id': response.user!.id,
        'nisn': nisn,
        'nama': _namaController.text.trim(),
      });

      if (mounted) {
        _showSnackbar('Akun berhasil dibuat! Silakan masuk.', Colors.green);
        Navigator.pushReplacementNamed(context, '/login-murid');
      }
    } on AuthException catch (e) {
      _showSnackbar(e.message, Colors.red);
    } catch (e) {
      _showSnackbar('Terjadi kesalahan. Coba lagi.', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackbar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Image.asset(
                'assets/images/l.png',
                width: 250,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.school, size: 80, color: Color(0xFF4A90D9),
                ),
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90D9),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('Daftar',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('Buat akun murid baru',
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 20),
                    _buildTextField(
                        controller: _namaController, hint: 'Nama lengkap'),
                    const SizedBox(height: 12),
                    _buildTextField(
                        controller: _nisnController,
                        hint: 'NISN',
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _sandiAkunController,
                      hint: 'Sandi akun',
                      obscure: _obscureSandi,
                      onToggleObscure: () =>
                          setState(() => _obscureSandi = !_obscureSandi),
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _konfirmasiSandiController,
                      hint: 'Konfirmasi sandi akun',
                      obscure: _obscureKonfirmasi,
                      onToggleObscure: () => setState(
                          () => _obscureKonfirmasi = !_obscureKonfirmasi),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _daftar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF4A90D9),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Color(0xFF4A90D9))
                            : const Text('Daftar',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacementNamed(
                          context, '/login-murid'),
                      child: const Text(
                        'Sudah punya akun? Masuk',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    VoidCallback? onToggleObscure,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: onToggleObscure != null
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: onToggleObscure,
              )
            : null,
      ),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nisnController.dispose();
    _sandiAkunController.dispose();
    _konfirmasiSandiController.dispose();
    super.dispose();
  }
}