import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';


class TugasGuru extends StatefulWidget {
  const TugasGuru({super.key});

  @override
  State<TugasGuru> createState() => _TugasGuruState();
}

class _TugasGuruState extends State<TugasGuru> {
  List<Map<String, dynamic>> _tugasList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTugas();
  }

  Future<void> _loadTugas() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser!.id;

      final tugasData = await supabase
          .from('tugas')
          .select('id, judul, deadline, mata_pelajaran(nama)')
          .eq('guru_id', userId)
          .order('created_at', ascending: false);

      setState(() {
        _tugasList = List<Map<String, dynamic>>.from(tugasData);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _formatDeadline(String? deadline) {
    if (deadline == null) return '-';
    try {
      final dt = DateTime.parse(deadline);
      return '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}';
    } catch (_) {
      return deadline;
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
          'Daftar Tugas',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tugasList.isEmpty
              ? const Center(
                  child: Text('Belum ada tugas.',
                      style: TextStyle(color: Colors.white)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _tugasList.length,
                  itemBuilder: (context, index) {
                    final tugas = _tugasList[index];
                    final mapelNama =
                        tugas['mata_pelajaran']?['nama'] ?? '-';
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailTugasGuru(
                              tugasId: tugas['id'],
                              judulTugas: tugas['judul'],
                              mapelNama: mapelNama,
                            ),
                          ),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tugas['judul'] ?? '-',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Color(0xFF1A1A1A),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    mapelNama,
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 13),
                                  ),
                                  Text(
                                    'Deadline: ${_formatDeadline(tugas['deadline'])}',
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios,
                                size: 16, color: Colors.grey),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/dashboard-guru');
              break;
            case 1:
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
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(
              icon: Icon(Icons.assignment), label: 'Tugas'),
          BottomNavigationBarItem(
              icon: Icon(Icons.video_call), label: 'Flawly Zoom'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: 'Kalender'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Akun'),
        ],
      ),
    );
  }
}

// ============================================================
// HALAMAN DETAIL TUGAS: Daftar murid + status pengumpulan
// ============================================================

class DetailTugasGuru extends StatefulWidget {
  final String tugasId;
  final String judulTugas;
  final String mapelNama;

  const DetailTugasGuru({
    super.key,
    required this.tugasId,
    required this.judulTugas,
    required this.mapelNama,
  });

  @override
  State<DetailTugasGuru> createState() => _DetailTugasGuruState();
}

class _DetailTugasGuruState extends State<DetailTugasGuru> {
  List<Map<String, dynamic>> _daftarMurid = [];
  bool _isLoading = true;

  void _lihatFotoFullscreen(String url) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.download, color: Colors.white),
              onPressed: () => _bukaUrl(url),
            ),
          ],
        ),
        body: InteractiveViewer(
          minScale: 0.5,
          maxScale: 5.0,
          child: Center(
            child: Image.network(
              url,
              fit: BoxFit.contain,
              errorBuilder: (c, e, s) => const Text(
                'Gagal memuat foto',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

void _bukaUrl(String url) async {
  try {
    // ignore: deprecated_member_use
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuka: $e')),
      );
    }
  }
}

  @override
  void initState() {
    super.initState();
    _loadDaftarMurid();
  }

  Future<void> _loadDaftarMurid() async {
    try {
      final supabase = Supabase.instance.client;

      // Ambil mapel_id dari tugas ini
      final tugasData = await supabase
          .from('tugas')
          .select('mapel_id')
          .eq('id', widget.tugasId)
          .single();

      final mapelId = tugasData['mapel_id'];

      // Ambil semua murid yang join kelas ini
      final members = await supabase
          .from('class_members')
          .select('murid_id')
          .eq('mapel_id', mapelId);

      if ((members as List).isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final muridIds = members.map((m) => m['murid_id']).toList();

      // Ambil data murid dari tabel murid
      final muridData = await supabase
          .from('murid')
          .select('id, nama, nisn')
          .inFilter('id', muridIds);

      // Ambil submissions untuk tugas ini
      final submissions = await supabase
          .from('submissions')
          .select('murid_id, submitted_at, tautan, foto_url, sudah_diperiksa')
          .eq('tugas_id', widget.tugasId);

      final submissionMap = {
        for (var s in (submissions as List)) s['murid_id']: s
      };

      final list = (muridData as List).map((m) {
        final sub = submissionMap[m['id']];
        return {
          'id': m['id'],
          'nama': m['nama'],
          'nisn': m['nisn'],
          'sudah_kumpul': sub != null,
          'submitted_at': sub?['submitted_at'],
          'tautan': sub?['tautan'],
          'foto_url': sub?['foto_url'],
          'sudah_diperiksa': sub?['sudah_diperiksa'] ?? false,
          'submission_id': sub != null ? sub['murid_id'] : null,
        };
      }).toList();

      // Urutkan: sudah kumpul dulu
      list.sort((a, b) {
        if (a['sudah_kumpul'] && !b['sudah_kumpul']) return -1;
        if (!a['sudah_kumpul'] && b['sudah_kumpul']) return 1;
        return 0;
      });

      setState(() {
        _daftarMurid = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _tandaiDiperiksa(String muridId) async {
    try {
      await Supabase.instance.client
          .from('submissions')
          .update({'sudah_diperiksa': true})
          .eq('tugas_id', widget.tugasId)
          .eq('murid_id', muridId);

      setState(() {
        final index = _daftarMurid.indexWhere((m) => m['id'] == muridId);
        if (index != -1) {
          _daftarMurid[index]['sudah_diperiksa'] = true;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Tugas sudah ditandai diperiksa!'),
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
    }
  }

  String _formatTanggal(String? tanggal) {
    if (tanggal == null) return '00 - 00 - 0000';
    try {
      final dt = DateTime.parse(tanggal);
      return '${dt.day.toString().padLeft(2, '0')} - ${dt.month.toString().padLeft(2, '0')} - ${dt.year}';
    } catch (_) {
      return '00 - 00 - 0000';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffD6E4F7),
      appBar: AppBar(
        backgroundColor: const Color(0xffA9C9FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daftar Siswa ${widget.mapelNama}',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
            Text(
              widget.judulTugas,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _daftarMurid.isEmpty
              ? const Center(
                  child: Text('Belum ada murid yang bergabung.',
                      style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _daftarMurid.length,
                  itemBuilder: (context, index) {
                    final murid = _daftarMurid[index];
                    final sudahKumpul = murid['sudah_kumpul'] as bool;
                    final sudahDiperiksa = murid['sudah_diperiksa'] as bool;

                    return GestureDetector(
                      onTap: sudahKumpul
                          ? () {
                              _showDetailSubmission(murid);
                            }
                          : null,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            // Kotak centang
                            GestureDetector(
                              onTap: sudahKumpul && !sudahDiperiksa
                                  ? () => _tandaiDiperiksa(murid['id'])
                                  : null,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: sudahDiperiksa
                                      ? Colors.green
                                      : sudahKumpul
                                          ? Colors.orange.shade100
                                          : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: sudahDiperiksa
                                        ? Colors.green
                                        : sudahKumpul
                                            ? Colors.orange
                                            : Colors.grey.shade400,
                                    width: 2,
                                  ),
                                ),
                                child: sudahDiperiksa
                                    ? const Icon(Icons.check,
                                        color: Colors.white, size: 20)
                                    : sudahKumpul
                                        ? const Icon(Icons.hourglass_top,
                                            color: Colors.orange, size: 18)
                                        : null,
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Nama murid
                            Expanded(
                              child: Text(
                                murid['nama'] ?? '-',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                            ),

                            // Status kanan
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _formatTanggal(murid['submitted_at']),
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.grey),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  sudahKumpul
                                      ? sudahDiperiksa
                                          ? 'Sudah Diperiksa'
                                          : 'Sudah Mengerjakan'
                                      : 'Belum Mengerjakan',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: sudahKumpul
                                        ? sudahDiperiksa
                                            ? Colors.green
                                            : Colors.orange
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _showDetailSubmission(Map<String, dynamic> murid) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              murid['nama'],
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Dikumpulkan: ${_formatTanggal(murid['submitted_at'])}',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),
           // Tambahkan ini sebelum bagian tautan
if (murid['foto_url'] != null && murid['foto_url'].isNotEmpty) ...[
  const Text('Foto tugas:',
      style: TextStyle(fontWeight: FontWeight.w600)),
  const SizedBox(height: 8),
  GestureDetector(
    onTap: () {
      Navigator.pop(context);
      _lihatFotoFullscreen(murid['foto_url']);
    },
    child: Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            murid['foto_url'],
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) => const Text(
              'Gagal memuat foto',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
        Positioned(
          right: 8,
          bottom: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.fullscreen, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text('Perbesar', style: TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          ),
        ),
      ],
    ),
  ),
  const SizedBox(height: 8),


  
  // Tombol Download
  SizedBox(
    width: double.infinity,
    child: OutlinedButton.icon(
      onPressed: () {
        // Buka URL foto di browser baru untuk download
        final url = murid['foto_url'];
        _bukaUrl(url);
      },
      icon: const Icon(Icons.download, color: Color(0xFF4A90D9)),
      label: const Text('Download Foto', style: TextStyle(color: Color(0xFF4A90D9))),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFF4A90D9)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    ),
  ),
  const SizedBox(height: 16),
],

// Tautan tugas
if (murid['tautan'] != null && murid['tautan'].toString().isNotEmpty) ...[
  const Text('Tautan tugas:',
      style: TextStyle(fontWeight: FontWeight.w600)),
  const SizedBox(height: 4),
  Row(
    children: [
      Expanded(
        child: Text(
          murid['tautan'],
          style: const TextStyle(
              color: Color(0xFF4A90D9), fontSize: 13),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      IconButton(
        icon: const Icon(Icons.copy, size: 18, color: Color(0xFF4A90D9)),
        onPressed: () {
          Clipboard.setData(ClipboardData(text: murid['tautan']));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tautan disalin!')),
          );
        },
      ),
      IconButton(
        icon: const Icon(Icons.open_in_browser, size: 18, color: Color(0xFF4A90D9)),
        onPressed: () => _bukaUrl(murid['tautan']),
      ),
    ],
  ),
  const SizedBox(height: 16),
],
const SizedBox(height: 16),
if (!(murid['sudah_diperiksa'] as bool))

            if (!(murid['sudah_diperiksa'] as bool))
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _tandaiDiperiksa(murid['id']);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Tandai Sudah Diperiksa',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Sudah Diperiksa',
                        style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}