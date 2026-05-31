import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilGuru extends StatefulWidget {
  const ProfilGuru({super.key});

  @override
  State<ProfilGuru> createState() => _ProfilGuruState();
}

class _ProfilGuruState extends State<ProfilGuru> {
  Map<String, dynamic>? _dataGuru;
  List<Map<String, dynamic>> _kelasList = [];
  bool _isLoading = true;
  bool _showDataDiri = false;
  bool _showDaftarKelas = false;

  @override
  void initState() {
    super.initState();
    _ambilData();
  }

  Future<void> _ambilData() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser!.id;
      final email = supabase.auth.currentUser?.email ?? '';

      // Ambil data guru dari tabel users
      final userData = await supabase
          .from('users')
          .select('nama')
          .eq('id', userId)
          .single();

      // Ambil daftar mata pelajaran yang diajar guru ini
      final mapelData = await supabase
          .from('mata_pelajaran')
          .select('id, nama, kelas')
          .eq('guru_id', userId);

      List<Map<String, dynamic>> kelasList = [];
      for (final mapel in (mapelData as List)) {
        // Hitung jumlah murid di kelas ini
        final muridCount = await supabase
            .from('class_members')
            .select('id')
            .eq('mapel_id', mapel['id']);

        // Hitung jumlah tugas di kelas ini
        final tugasCount = await supabase
            .from('tugas')
            .select('id')
            .eq('mapel_id', mapel['id']);

        kelasList.add({
          'id': mapel['id'],
          'nama': mapel['nama'],
          'kelas': mapel['kelas'] ?? '',
          'jumlah_murid': (muridCount as List).length,
          'jumlah_tugas': (tugasCount as List).length,
        });
      }

      setState(() {
        _dataGuru = {
          'nama': userData['nama'] ?? '',
          'email': email,
        };
        _kelasList = kelasList;
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
      backgroundColor: const Color(0xFFD6E4F7),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  // Header dengan avatar guru
                  Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Container(
                        height: 160,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD6E4F7),
                        ),
                      ),
                      Positioned(
                        top: 16,
                        left: 16,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios,
                              color: Color(0xFF4A90D9)),
                          onPressed: () => Navigator.pushReplacementNamed(
                              context, '/dashboard-guru'),
                        ),
                      ),
                      Positioned(
                        top: 20,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFF4A90D9), width: 3),
                          ),
                          child: const Icon(Icons.school,
                              size: 50, color: Color(0xFF4A90D9)),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        child: Column(
                          children: [
                            Text(
                              _dataGuru?['nama'] ?? '',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A2F5A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4A90D9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Guru',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Menu
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),

                          // Data Diri
                          _buildMenuButton(
                            label: 'Data Diri',
                            onTap: () => setState(
                                () => _showDataDiri = !_showDataDiri),
                            trailing: Icon(
                              _showDataDiri
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: Colors.grey,
                            ),
                          ),
                          if (_showDataDiri) ...[
                            _buildInfoCard('Nama', _dataGuru?['nama'] ?? '-'),
                            _buildInfoCard('Email', _dataGuru?['email'] ?? '-'),
                            _buildInfoCard('Sebagai', 'Guru'),
                          ],

                          const SizedBox(height: 12),

                          // Daftar Kelas yang Diajar
                          _buildMenuButton(
                            label: 'Kelas yang Diajar',
                            onTap: () => setState(
                                () => _showDaftarKelas = !_showDaftarKelas),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_kelasList.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4A90D9),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${_kelasList.length}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                const SizedBox(width: 6),
                                Icon(
                                  _showDaftarKelas
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                          if (_showDaftarKelas)
                            _kelasList.isEmpty
                                ? Container(
                                    margin: const EdgeInsets.only(
                                        left: 8, right: 8, bottom: 8),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEDF3FB),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Belum ada kelas yang diajar',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                  )
                                : Column(
                                    children: _kelasList
                                        .map((kelas) => Container(
                                              margin: const EdgeInsets.only(
                                                  left: 8,
                                                  right: 8,
                                                  bottom: 8),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 12),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFEDF3FB),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        kelas['nama'],
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color:
                                                              Color(0xFF1A2F5A),
                                                        ),
                                                      ),
                                                      if ((kelas['kelas'] as String)
                                                          .isNotEmpty)
                                                        Text(
                                                          'Kelas ${kelas['kelas']}',
                                                          style: const TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors.grey),
                                                        ),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          const Icon(
                                                              Icons.people,
                                                              size: 14,
                                                              color: Color(
                                                                  0xFF4A90D9)),
                                                          const SizedBox(
                                                              width: 4),
                                                          Text(
                                                            '${kelas['jumlah_murid']} murid',
                                                            style: const TextStyle(
                                                              fontSize: 12,
                                                              color: Color(
                                                                  0xFF4A90D9),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          const Icon(
                                                              Icons.assignment,
                                                              size: 14,
                                                              color:
                                                                  Colors.grey),
                                                          const SizedBox(
                                                              width: 4),
                                                          Text(
                                                            '${kelas['jumlah_tugas']} tugas',
                                                            style: const TextStyle(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .grey),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ))
                                        .toList(),
                                  ),

                          const Spacer(),

                          // Keluar Akun
                          GestureDetector(
                            onTap: _keluarAkun,
                            child: Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.logout,
                                      color: Colors.red, size: 18),
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
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4A90D9),
        unselectedItemColor: Colors.grey,
        currentIndex: 4,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: 'Beranda'),
          BottomNavigationBarItem(
              icon: Icon(Icons.assignment), label: 'Tugas'),
          BottomNavigationBarItem(
              icon: Icon(Icons.video_call), label: 'Flawly Zoom'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: 'Kalender'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded), label: 'Akun'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/dashboard-guru');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/tambah-tugas');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/zoom-guru');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/kalender-guru');
              break;
            case 4:
              Navigator.pushReplacementNamed(context, '/profil-guru');
              break;
          }
        },
      ),
    );
  }

  Widget _buildMenuButton({
    required String label,
    required VoidCallback onTap,
    IconData? icon,
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFB8D0ED),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: const Color(0xFF1A2F5A), size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A2F5A),
                  ),
                ),
              ],
            ),
            trailing ??
                const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF3FB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A2F5A),
            ),
          ),
        ],
      ),
    );
  }
}
