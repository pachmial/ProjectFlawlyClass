import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BuatKelasScreen extends StatefulWidget {
  const BuatKelasScreen({super.key});

  @override
  State<BuatKelasScreen> createState() => _BuatKelasScreenState();
}

class _BuatKelasScreenState extends State<BuatKelasScreen> {
<<<<<<< HEAD
  final _namaGuruController = TextEditingController();
  final _namaKelasController = TextEditingController();
  final _namaRombelController = TextEditingController();
=======
  final _namaController = TextEditingController();
  final _mataPelajaranController = TextEditingController();
  final _kelasController = TextEditingController();
>>>>>>> 1fe73cd6518a9085b8fc5fd7785a7986dffc1c37
  final _sandiKelasController = TextEditingController();
  bool _isLoading = false;
  bool _obscureSandi = true;

<<<<<<< HEAD
Future<void> _buatKelas() async {
  if (_namaGuruController.text.isEmpty ||
      _namaKelasController.text.isEmpty ||
      _namaRombelController.text.isEmpty ||
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
    final supabase = Supabase.instance.client;
    final nama = _namaGuruController.text.trim();
    final sandi = _sandiKelasController.text.trim();

    // Step 1: Daftar akun baru di Supabase Auth
    // Email dibuat dari nama (tanpa spasi) supaya unik
    final email = '${nama.toLowerCase().replaceAll(' ', '_')}@flawlyclass.com';

    final authResponse = await supabase.auth.signUp(
      email: email,
      password: sandi,
    );

    if (authResponse.user == null) throw Exception('Gagal membuat akun');

    final userId = authResponse.user!.id;

    // Step 2: Insert profil guru ke tabel users
    await supabase.from('users').insert({
      'id': userId,
      'nama': nama,
      'email': email,
      'role': 'guru',
    });

    // Step 3: Insert kelas baru
    await supabase.from('kelas').insert({
      'guru_id': userId,
      'nama_kelas': _namaRombelController.text.trim(),
      'mata_pelajaran': _namaKelasController.text.trim(),
      'kode_kelas': _generateKodeKelas(),
      'created_at': DateTime.now().toIso8601String(),
    });


// BARU - logout dulu, baru ke halaman role guru
await supabase.auth.signOut();

if (mounted) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Kelas berhasil dibuat! Silakan masuk.'),
      backgroundColor: Colors.green,
    ),
  );
  Navigator.pushReplacementNamed(context, '/login-guru');
}
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuat kelas: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}
  // Generate kode kelas acak 6 karakter
  String _generateKodeKelas() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(6, (i) => chars[(random + i * 7) % chars.length])
        .join();
=======
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
>>>>>>> 1fe73cd6518a9085b8fc5fd7785a7986dffc1c37
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
<<<<<<< HEAD
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 28),

                      // Nama Guru
                      TextField(
                        controller: _namaGuruController,
                        decoration: InputDecoration(
                          hintText: 'Nama Guru',
=======
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
>>>>>>> 1fe73cd6518a9085b8fc5fd7785a7986dffc1c37
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
<<<<<<< HEAD

                      // Mata Pelajaran
                      TextField(
                        controller: _namaKelasController,
=======
                      // Mata Pelajaran
                      TextField(
                        controller: _mataPelajaranController,
>>>>>>> 1fe73cd6518a9085b8fc5fd7785a7986dffc1c37
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
<<<<<<< HEAD

                      // Nama Rombel/Kelas
                      TextField(
                        controller: _namaRombelController,
                        decoration: InputDecoration(
                          hintText: 'Nama Kelas (contoh: 11 PPLG 2)',
=======
                      // Kelas
                      TextField(
                        controller: _kelasController,
                        decoration: InputDecoration(
                          hintText: 'Kelas',
>>>>>>> 1fe73cd6518a9085b8fc5fd7785a7986dffc1c37
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
<<<<<<< HEAD

=======
>>>>>>> 1fe73cd6518a9085b8fc5fd7785a7986dffc1c37
                      // Sandi Kelas
                      TextField(
                        controller: _sandiKelasController,
                        obscureText: _obscureSandi,
                        decoration: InputDecoration(
<<<<<<< HEAD
                          hintText: 'Sandi Kelas',
=======
                          hintText: 'Sandi kelas',
>>>>>>> 1fe73cd6518a9085b8fc5fd7785a7986dffc1c37
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
<<<<<<< HEAD
                            icon: Icon(_obscureSandi
                                ? Icons.visibility_off
                                : Icons.visibility),
=======
                            icon: Icon(
                              _obscureSandi
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
>>>>>>> 1fe73cd6518a9085b8fc5fd7785a7986dffc1c37
                            onPressed: () => setState(
                                () => _obscureSandi = !_obscureSandi),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
<<<<<<< HEAD

=======
>>>>>>> 1fe73cd6518a9085b8fc5fd7785a7986dffc1c37
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
<<<<<<< HEAD

                      // Tombol kembali
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Sudah punya kelas? Masuk',
                            style: TextStyle(color: Color(0xFF4A90D9)),
                          ),
                        ),
                      ),
=======
>>>>>>> 1fe73cd6518a9085b8fc5fd7785a7986dffc1c37
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
<<<<<<< HEAD
    _namaGuruController.dispose();
    _namaKelasController.dispose();
    _namaRombelController.dispose();
=======
    _namaController.dispose();
    _mataPelajaranController.dispose();
    _kelasController.dispose();
>>>>>>> 1fe73cd6518a9085b8fc5fd7785a7986dffc1c37
    _sandiKelasController.dispose();
    super.dispose();
  }
}