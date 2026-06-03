import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';

class ZoomGuru extends StatefulWidget {
  const ZoomGuru({super.key});

  @override
  State<ZoomGuru> createState() => _ZoomGuruState();
}

class _ZoomGuruState extends State<ZoomGuru> {
  List<Map<String, dynamic>> _mapelList = [];
  List<Map<String, dynamic>> _sessionList = [];
  bool _isLoading = true;
  bool _isBuatLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  String _buatKodeRoom() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }

  Future<void> _loadData() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser!.id;

      // Ambil mapel yang diajar guru ini
      final mapelData = await supabase
          .from('mata_pelajaran')
          .select('id, nama, kelas')
          .eq('guru_id', userId);

      // Ambil sesi zoom yang pernah dibuat
      final sessionData = await supabase
          .from('zoom_sessions')
          .select('*')
          .eq('guru_id', userId)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _mapelList = List<Map<String, dynamic>>.from(mapelData);
          _sessionList = List<Map<String, dynamic>>.from(sessionData);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _buatSesi(String mapelId, String judulSesi) async {
    setState(() => _isBuatLoading = true);
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser!.id;
      final kodeRoom = _buatKodeRoom();

      // Link Jitsi pakai kode room
      final linkZoom = 'https://meet.jit.si/flawlyclass-$kodeRoom';

      await supabase.from('zoom_sessions').insert({
        'mapel_id': mapelId,
        'guru_id': userId,
        'link_zoom': linkZoom,
        'kode_room': kodeRoom,
        'jadwal': DateTime.now().toIso8601String(),
        'jam_mulai': TimeOfDay.now().format(context),
      });

      if (mounted) {
        Navigator.pop(context); // tutup dialog
        _loadData(); // refresh list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sesi zoom berhasil dibuat!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isBuatLoading = false);
    }
  }

  void _showBuatSesiDialog() {
    String? selectedMapelId;
    final judulController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Buat Sesi Zoom',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Kode room akan otomatis dibuat',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 20),

              // Pilih Mapel
              const Text('Mata Pelajaran',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text('Pilih mata pelajaran'),
                    value: selectedMapelId,
                    items: _mapelList.map((mapel) {
                      return DropdownMenuItem<String>(
                        value: mapel['id'].toString(),
                        child: Text(mapel['nama']),
                      );
                    }).toList(),
                    onChanged: (val) =>
                        setModalState(() => selectedMapelId = val),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Judul sesi (opsional)
              const Text('Judul Sesi (opsional)',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: judulController,
                decoration: InputDecoration(
                  hintText: 'Contoh: Diskusi Bab 3',
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isBuatLoading
                      ? null
                      : () {
                          if (selectedMapelId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Pilih mata pelajaran dulu!'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }
                          _buatSesi(
                              selectedMapelId!, judulController.text.trim());
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90D9),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isBuatLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Buat Sesi',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailSesi(Map<String, dynamic> sesi) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Detail Sesi Zoom',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Kode Room
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEDF3FB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text('Kode Room',
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 8),
                  Text(
                    sesi['kode_room'] ?? '-',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A90D9),
                      letterSpacing: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                          ClipboardData(text: sesi['kode_room'] ?? ''));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Kode disalin!')),
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.copy, size: 14, color: Colors.grey),
                        SizedBox(width: 4),
                        Text('Salin kode',
                            style:
                                TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tombol Masuk Zoom
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final link = sesi['link_zoom'] ?? '';
                  if (link.isNotEmpty) {
                    Navigator.pop(context);
                    // Buka link zoom di browser
                    _bukaZoom(link);
                  }
                },
                icon: const Icon(Icons.video_call),
                label: const Text('Masuk ke Zoom',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90D9),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Tombol Bagikan Link
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Clipboard.setData(
                      ClipboardData(text: sesi['link_zoom'] ?? ''));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Link zoom disalin!')),
                  );
                },
                icon: const Icon(Icons.share),
                label: const Text('Salin Link Zoom'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF4A90D9),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _bukaZoom(String link) {
    // Navigasi ke halaman webview zoom
    Navigator.pushNamed(context, '/zoom-webview', arguments: {'link': link});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6E4F7),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Flawly Zoom',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A2F5A),
                        ),
                      ),
                      Text(
                        'Kelola sesi zoom kamu',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                  const Icon(Icons.video_call_rounded,
                      size: 36, color: Color(0xFF4A90D9)),
                ],
              ),
            ),

            // Tombol Buat Sesi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _mapelList.isEmpty ? null : _showBuatSesiDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Buat Sesi Zoom Baru',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90D9),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // List Sesi
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _sessionList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.video_call_outlined,
                                  size: 64, color: Colors.grey),
                              SizedBox(height: 12),
                              Text(
                                'Belum ada sesi zoom',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 16),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Tekan tombol di atas untuk membuat sesi',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 13),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _sessionList.length,
                          itemBuilder: (context, index) {
                            final sesi = _sessionList[index];
                            final tanggal = sesi['jadwal'] != null
                                ? DateTime.parse(sesi['jadwal'])
                                : DateTime.now();
                            return GestureDetector(
                              onTap: () => _showDetailSesi(sesi),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEDF3FB),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.video_call,
                                          color: Color(0xFF4A90D9)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Kode: ${sesi['kode_room'] ?? '-'}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Color(0xFF1A2F5A),
                                            ),
                                          ),
                                          Text(
                                            '${tanggal.day}/${tanggal.month}/${tanggal.year} • ${sesi['jam_mulai'] ?? ''}',
                                            style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.arrow_forward_ios,
                                        size: 14, color: Colors.grey),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4A90D9),
        unselectedItemColor: Colors.grey,
        currentIndex: 2,
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
}
