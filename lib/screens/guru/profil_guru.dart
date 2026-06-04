import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilGuru extends StatefulWidget {
  const ProfilGuru({super.key});

  @override
  State<ProfilGuru> createState() => _ProfilGuruState();
}

class _ProfilGuruState extends State<ProfilGuru> {
  Map<String, dynamic>? _dataGuru;
  bool _isLoading = true;
  bool _showDataDiri = false;

  @override
  void initState() {
    super.initState();
    _ambilData();
  }

  Future<void> _ambilData() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser!.id;

      final userData = await supabase
          .from('users')
          .select('nama, email')
          .eq('id', userId)
          .single();

      final kelasData = await supabase
          .from('kelas')
          .select('nama_kelas, nama_rombel, kode_kelas')
          .eq('guru_id', userId)
          .maybeSingle();

      setState(() {
        _dataGuru = {
          'nama': userData['nama'],
          'email': userData['email'],
          'nama_kelas': kelasData?['nama_kelas'] ?? '-',
          'nama_rombel': kelasData?['nama_rombel'] ?? '-',
          'kode_kelas': kelasData?['kode_kelas'] ?? '-',
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _keluarAkun() async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar Akun'),
        content: const Text('Apakah kamu yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (konfirmasi == true) {
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/role');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffA9C9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xffA9C9FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () =>
              Navigator.pushReplacementNamed(context, '/dashboard-guru'),
        ),
        title: const Text(
          'Profil Guru',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Avatar
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person,
                          size: 60, color: Color(0xFF4A90D9)),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _dataGuru?['nama'] ?? '',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _dataGuru?['email'] ?? '',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 24),

                    // Card info
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Data Diri toggle
                          GestureDetector(
                            onTap: () => setState(
                                () => _showDataDiri = !_showDataDiri),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Data Diri',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A2F5A),
                                  ),
                                ),
                                Icon(
                                  _showDataDiri
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                          if (_showDataDiri) ...[
                            const Divider(height: 20),
                            _buildInfoRow('Nama', _dataGuru?['nama'] ?? '-'),
                            _buildInfoRow(
                                'Mata Pelajaran', _dataGuru?['nama_kelas'] ?? '-'),
                            _buildInfoRow(
                                'Kelas', _dataGuru?['nama_rombel'] ?? '-'),
                            _buildInfoRow(
                                'Kode Kelas', _dataGuru?['kode_kelas'] ?? '-'),
                            _buildInfoRow('Sebagai', 'Guru'),
                          ],
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Tombol Keluar
                    GestureDetector(
                      onTap: _keluarAkun,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout, color: Colors.red, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Keluar akun',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 4,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/dashboard-guru');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/tugas-guru');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/zoom-guru');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/kalender-guru');
              break;
            case 4:
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(
              icon: Icon(Icons.assignment), label: 'Tugas'),
          BottomNavigationBarItem(
              icon: Icon(Icons.video_call), label: 'Flawly Zoom'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: 'Kalender'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Akun'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A2F5A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
