import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ZoomMurid extends StatefulWidget {
  const ZoomMurid({super.key});

  @override
  State<ZoomMurid> createState() => _ZoomMuridState();
}

class _ZoomMuridState extends State<ZoomMurid> {
  List<Map<String, dynamic>> _sessionList = [];
  bool _isLoading = true;
  bool _isJoinLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSesi();
  }

  Future<void> _loadSesi() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser!.id;

      // Ambil mapel yang diikuti murid
      final members = await supabase
          .from('class_members')
          .select('mapel_id')
          .eq('murid_id', userId);

      if ((members as List).isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final mapelIds = members.map((m) => m['mapel_id']).toList();

      // Ambil sesi zoom dari mapel yang diikuti
      final sessionData = await supabase
          .from('zoom_sessions')
          .select('*')
          .inFilter('mapel_id', mapelIds)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _sessionList = List<Map<String, dynamic>>.from(sessionData);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _joinDenganKode(String kode) async {
    setState(() => _isJoinLoading = true);
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser!.id;

      // Cari sesi berdasarkan kode
      final sesiData = await supabase
          .from('zoom_sessions')
          .select('*')
          .eq('kode_room', kode.toUpperCase().trim())
          .maybeSingle();

      if (sesiData == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kode room tidak ditemukan!'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Daftarkan murid ke sesi
      await supabase.from('zoom_peserta').upsert({
        'session_id': sesiData['id'],
        'murid_id': userId,
      });

      if (mounted) {
        Navigator.pop(context); // tutup dialog
        // Buka zoom
        Navigator.pushNamed(context, '/zoom-webview',
            arguments: {'link': sesiData['link_zoom']});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal join: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isJoinLoading = false);
    }
  }

  void _showJoinDialog() {
    final kodeController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
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
            const Text('Join Flawly Zoom',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Masukkan kode room dari gurumu',
                style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 20),
            TextField(
              controller: kodeController,
              textCapitalization: TextCapitalization.characters,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8),
              maxLength: 6,
              decoration: InputDecoration(
                hintText: 'XXXXXX',
                hintStyle: TextStyle(
                    color: Colors.grey.shade300,
                    fontSize: 24,
                    letterSpacing: 8),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                counterText: '',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isJoinLoading
                    ? null
                    : () {
                        if (kodeController.text.trim().length < 6) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Masukkan 6 digit kode!'),
                                backgroundColor: Colors.orange),
                          );
                          return;
                        }
                        _joinDenganKode(kodeController.text);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90D9),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isJoinLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Masuk ke Zoom',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
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
                        'Ikuti sesi zoom gurumu',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                  const Icon(Icons.video_call_rounded,
                      size: 36, color: Color(0xFF4A90D9)),
                ],
              ),
            ),

            // Tombol Join dengan Kode
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showJoinDialog,
                  icon: const Icon(Icons.login),
                  label: const Text('Join dengan Kode Room',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold)),
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

            // Label
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Sesi Zoom Tersedia',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1A2F5A),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

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
                              Text('Belum ada sesi zoom',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 16)),
                              SizedBox(height: 4),
                              Text('Tunggu gurumu membuat sesi',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 13)),
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
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/zoom-webview',
                                  arguments: {'link': sesi['link_zoom']},
                                );
                              },
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
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: const Text('Join',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold)),
                                    ),
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
}
