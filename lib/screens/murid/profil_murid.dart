import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilMurid extends StatefulWidget {
  const ProfilMurid({super.key});

  @override
  State<ProfilMurid> createState() => _ProfilMuridState();
}

class _ProfilMuridState extends State<ProfilMurid> {
  Map<String, dynamic>? _dataMurid;
  List<Map<String, dynamic>> _mapelList = [];
  bool _isLoading = true;
  bool _showDataDiri = false;
  bool _showDaftarTugas = false;
  String? _fotoProfilUrl;
  bool _uploadingFoto = false;

  @override
  void initState() {
    super.initState();
    _ambilData();
  }

  Future<void> _ambilData() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser!.id;

      final muridData = await supabase
          .from('murid')
          .select('nama, nisn, foto_url')
          .eq('id', userId)
          .single();

      final members = await supabase
          .from('class_members')
          .select('mapel_id')
          .eq('murid_id', userId);

      List<Map<String, dynamic>> mapelList = [];

      if ((members as List).isNotEmpty) {
        final mapelIds = members.map((m) => m['mapel_id']).toList();

        final mapelData = await supabase
            .from('mata_pelajaran')
            .select('id, nama, kelas')
            .inFilter('id', mapelIds);

        for (final mapel in (mapelData as List)) {
          final tugasTotal = await supabase
              .from('tugas')
              .select('id')
              .eq('mapel_id', mapel['id']);

          final tugasSelesai = await supabase
              .from('submissions')
              .select('id')
              .eq('murid_id', userId)
              .inFilter(
                  'tugas_id',
                  (tugasTotal as List).map((t) => t['id']).toList());

          mapelList.add({
            'id': mapel['id'],
            'nama': mapel['nama'],
            'kelas': mapel['kelas'] ?? '',
            'total': (tugasTotal).length,
            'selesai': (tugasSelesai as List).length,
          });
        }
      }

      String kelas = '';
      if (mapelList.isNotEmpty) {
        kelas = mapelList.first['kelas'] ?? '';
      }

      setState(() {
        _dataMurid = {
          'nama': muridData['nama'],
          'nisn': muridData['nisn'],
          'kelas': kelas,
        };
        _fotoProfilUrl = muridData['foto_url'];
        _mapelList = mapelList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pilihDanCropFoto() async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) return;

    setState(() => _uploadingFoto = true);

    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser!.id;
    final fileName = '$userId/profil_${DateTime.now().millisecondsSinceEpoch}.jpg';

    await supabase.storage
        .from('foto-profil')
        .uploadBinary(fileName, file.bytes!,
            fileOptions: const FileOptions(upsert: true));

    final url = supabase.storage
        .from('foto-profil')
        .getPublicUrl(fileName);

    await supabase
        .from('murid')
        .update({'foto_url': url})
        .eq('id', userId);

    setState(() {
      _fotoProfilUrl = url;
      _uploadingFoto = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto profil berhasil diperbarui!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    setState(() => _uploadingFoto = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal upload foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

Future<void> _tambahKelas(String kodeKelas) async {
  try {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser!.id;

    final kelasData = await supabase
        .from('kelas')
        .select('id, mata_pelajaran')
        .eq('kode_kelas', kodeKelas.toUpperCase())
        .maybeSingle();

    if (kelasData == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kode kelas tidak ditemukan!'),
              backgroundColor: Colors.red),
        );
      }
      return;
    }

    final mapelData = await supabase
        .from('mata_pelajaran')
        .select('id')
        .eq('nama', kelasData['mata_pelajaran'])
        .maybeSingle();

    if (mapelData == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mata pelajaran tidak ditemukan!'),
              backgroundColor: Colors.red),
        );
      }
      return;
    }

    final sudahJoin = await supabase
        .from('class_members')
        .select('id')
        .eq('mapel_id', mapelData['id'])
        .eq('murid_id', userId)
        .maybeSingle();

    if (sudahJoin != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kamu sudah bergabung di kelas ini!'),
              backgroundColor: Colors.orange),
        );
      }
      return;
    }

    await supabase.from('class_members').insert({
      'mapel_id': mapelData['id'],
      'murid_id': userId,
    });

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎉 Berhasil bergabung ke kelas!'),
            backgroundColor: Colors.green),
      );
      _ambilData();
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal bergabung: $e'),
            backgroundColor: Colors.red),
      );
    }
  }
}

  void _showTambahKelasDialog() {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tambahkan Kelas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Masukkan kode kelas dari gurumu',
                style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'Masukkan kode Kelas',
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (controller.text.trim().isEmpty) return;
                  _tambahKelas(controller.text.trim());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90D9),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Bergabung',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _keluarAkun() async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  // Header dengan avatar
                  Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Container(
                        height: 180,
                        width: double.infinity,
                        color: const Color(0xFFD6E4F7),
                      ),
                      Positioned(
                        top: 16,
                        left: 16,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios,
                              color: Color(0xFF4A90D9)),
                          onPressed: () => Navigator.pushReplacementNamed(
                              context, '/dashboard-murid'),
                        ),
                      ),
                      // Avatar dengan tombol kamera
                      Positioned(
                        top: 16,
                        child: GestureDetector(
                          onTap: _uploadingFoto ? null : _pilihDanCropFoto,
                          child: Stack(
                            children: [
                              Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF4A90D9),
                                    width: 3,
                                  ),
                                ),
                                child: _uploadingFoto
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                          color: Color(0xFF4A90D9),
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : ClipOval(
                                        child: _fotoProfilUrl != null
                                            ? Image.network(
                                                _fotoProfilUrl!,
                                                width: 110,
                                                height: 110,
                                                fit: BoxFit.cover,
                                                errorBuilder: (c, e, s) =>
                                                    const Icon(Icons.person,
                                                        size: 60,
                                                        color: Color(
                                                            0xFF4A90D9)),
                                              )
                                            : const Icon(Icons.person,
                                                size: 60,
                                                color: Color(0xFF4A90D9)),
                                      ),
                              ),
                              // Tombol kamera di pojok kanan bawah
                              Positioned(
                                bottom: 2,
                                right: 2,
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4A90D9),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 2),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 6,
                        child: Text(
                          _dataMurid?['nama'] ?? '',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A2F5A),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Menu buttons
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
                            _buildInfoCard(
                                'Nama', _dataMurid?['nama'] ?? '-'),
                            _buildInfoCard(
                                'Kelas', _dataMurid?['kelas'] ?? '-'),
                            _buildInfoCard(
                                'NISN', _dataMurid?['nisn'] ?? '-'),
                            _buildInfoCard('Sebagai', 'Murid'),
                          ],

                          const SizedBox(height: 12),

                          // Daftar Tugas
                          _buildMenuButton(
                            label: 'Daftar Tugas',
                            onTap: () => setState(
                                () => _showDaftarTugas = !_showDaftarTugas),
                            trailing: Icon(
                              _showDaftarTugas
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: Colors.grey,
                            ),
                          ),
                          if (_showDaftarTugas)
                            ..._mapelList.map((mapel) => Container(
                                  margin: const EdgeInsets.only(
                                      left: 8, right: 8, bottom: 8),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEDF3FB),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        mapel['nama'],
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF1A2F5A),
                                        ),
                                      ),
                                      Text(
                                        '${mapel['selesai']}/${mapel['total']}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF4A90D9),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                )),

                          const SizedBox(height: 12),

                          // Tambahkan Kelas
                          _buildMenuButton(
                            label: 'Tambahkan Kelas',
                            icon: Icons.add_circle_outline,
                            onTap: _showTambahKelasDialog,
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
              icon: Icon(Icons.menu_book_rounded), label: 'Tugas Anda'),
          BottomNavigationBarItem(
              icon: Icon(Icons.video_call_rounded), label: 'Flawly Zoom'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_rounded), label: 'Kalender'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded), label: 'Akun'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/dashboard-murid');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/tugas-murid');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/zoom-murid');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/kalender-murid');
              break;
            case 4:
              Navigator.pushReplacementNamed(context, '/profil-murid');
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
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