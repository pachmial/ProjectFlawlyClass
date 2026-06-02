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
      _showSnackbar('Semua field harus diisi!', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final email = '${_nisnController.text.trim()}@flawlyclass.com';

      // 1. Login ke Supabase Auth
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: _sandiAkunController.text.trim(),
      );

      if (response.user == null) throw Exception('Login gagal');

      // 2. Cari kelas berdasarkan kode_kelas yang diinput
      final kelasData = await Supabase.instance.client
          .from('kelas')
          .select('id, mata_pelajaran')
          .eq('kode_kelas', _sandiKelasController.text.trim().toUpperCase())
          .maybeSingle();

      if (kelasData == null) {
        await Supabase.instance.client.auth.signOut();
        _showSnackbar('Kode kelas tidak ditemukan!', Colors.red);
        setState(() => _isLoading = false);
        return;
      }

      // 3. Cari mapel_id berdasarkan nama mata pelajaran di kelas itu
      final mapelData = await Supabase.instance.client
          .from('mata_pelajaran')
          .select('id')
          .eq('nama', kelasData['mata_pelajaran'])
          .maybeSingle();

      if (mapelData == null) {
        await Supabase.instance.client.auth.signOut();
        _showSnackbar('Mata pelajaran tidak ditemukan!', Colors.red);
        setState(() => _isLoading = false);
        return;
      }

      // 4. Cek sudah join belum
      final sudahJoin = await Supabase.instance.client
          .from('class_members')
          .select('id')
          .eq('mapel_id', mapelData['id'])
          .eq('murid_id', response.user!.id)
          .maybeSingle();

      // 5. Kalau belum join, insert ke class_members
      if (sudahJoin == null) {
        await Supabase.instance.client.from('class_members').insert({
          'mapel_id': mapelData['id'],
          'murid_id': response.user!.id,
        });
      }

      // 6. Masuk ke dashboard
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard-murid');
      }
    } on AuthException catch (e) {
      print('AUTH ERROR: ${e.message} | code: ${e.statusCode}');
      _showSnackbar(e.message, Colors.red);
    } catch (e) {
      print('OTHER ERROR: $e');
      if (mounted) _showSnackbar('NISN atau sandi salah!', Colors.red);
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
                    const Text('Masuk',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('Masuk ke akun kamu',
                        style:
                            TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _nisnController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'NISN',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _sandiAkunController,
                      obscureText: _obscureSandi,
                      decoration: InputDecoration(
                        hintText: 'Sandi akun',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureSandi
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () =>
                              setState(() => _obscureSandi = !_obscureSandi),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _sandiKelasController,
                      textCapitalization: TextCapitalization.characters,
                      obscureText: _obscureSandiKelas,
                      decoration: InputDecoration(
                        hintText: 'Kode kelas',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureSandiKelas
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () => setState(() =>
                              _obscureSandiKelas = !_obscureSandiKelas),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
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
                            : const Text('Masuk',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, '/daftar-murid'),
                      child: const Text(
                        'Belum punya akun? Daftar',
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

  @override
  void dispose() {
    _nisnController.dispose();
    _sandiAkunController.dispose();
    _sandiKelasController.dispose();
    super.dispose();
  }
}