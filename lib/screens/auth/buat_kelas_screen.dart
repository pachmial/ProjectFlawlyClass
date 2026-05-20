import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BuatKelasScreen extends StatefulWidget {
  const BuatKelasScreen({super.key});

  @override
  State<BuatKelasScreen> createState() => _BuatKelasScreenState();
}

class _BuatKelasScreenState extends State<BuatKelasScreen> {
  final _namaController = TextEditingController();
  final _mataPelajaranController = TextEditingController();
  final _kelasController = TextEditingController();
  final _sandiKelasController = TextEditingController();
  bool _isLoading = false;
  bool _obscureSandi = true;

  Future<void> _buatKelas() async {
    if (_namaController.text.isEmpty ||
        _mataPelajaranController.text.isEmpty ||
        _kelasController.text.isEmpty ||
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
      // Buat akun guru di Supabase Auth
      final email =
          '${_namaController.text.trim().replaceAll(' ', '').toLowerCase()}@flawlyclass.com';
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: _sandiKelasController.text.trim(),
      );

      if (response.user != null) {
        // Simpan data guru ke tabel users
        await Supabase.instance.client.from('users').insert({
          'id': response.user!.id,
          'nama': _namaController.text.trim(),
          'email': email,
          'role': 'guru',
          'kelas': _kelasController.text.trim(),
        });

        // Buat mata pelajaran
        await Supabase.instance.client.from('mata_pelajaran').insert({
          'nama': _mataPelajaranController.text.trim(),
          'guru_id': response.user!.id,
          'kelas': _kelasController.text.trim(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kelas berhasil dibuat!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacementNamed(context, '/dashboard-guru');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat kelas: $e'),
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
                        'Buat Kelas',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const Text(
                        'Ayoo buat kelas anda',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Nama Guru
                      TextField(
                        controller: _namaController,
                        decoration: InputDecoration(
                          hintText: 'Nama',
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Mata Pelajaran
                      TextField(
                        controller: _mataPelajaranController,
                        decoration: InputDecoration(
                          hintText: 'Mata Pelajaran',
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Kelas
                      TextField(
                        controller: _kelasController,
                        decoration: InputDecoration(
                          hintText: 'Kelas',
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Sandi Kelas
                      TextField(
                        controller: _sandiKelasController,
                        obscureText: _obscureSandi,
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
                              _obscureSandi
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setState(
                                () => _obscureSandi = !_obscureSandi),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Tombol Buat
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _buatKelas,
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
                                  'Buat',
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
    _namaController.dispose();
    _mataPelajaranController.dispose();
    _kelasController.dispose();
    _sandiKelasController.dispose();
    super.dispose();
  }
}