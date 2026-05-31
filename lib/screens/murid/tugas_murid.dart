import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TugasMurid extends StatefulWidget {
  const TugasMurid({super.key});

  @override
  State<TugasMurid> createState() => _TugasMuridState();
}

class _TugasMuridState extends State<TugasMurid> {
  List<Map<String, dynamic>> _daftarMapel = [];
  bool _isLoading = true;

  final List<Color> _warnaPalette = const [
    Color(0xFFE57373),
    Color(0xFF4A90D9),
    Color(0xFFFFB74D),
    Color(0xFF81C784),
    Color(0xFF9575CD),
    Color(0xFF4DB6AC),
    Color(0xFFF06292),
  ];

  @override
  void initState() {
    super.initState();
    _ambilMapel();
  }

  Future<void> _ambilMapel() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser!.id;

      // Ambil mapel_id yang diikuti murid
      final members = await supabase
          .from('class_members')
          .select('mapel_id')
          .eq('murid_id', userId);

      if (members.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final mapelIds = (members as List).map((m) => m['mapel_id']).toList();

      // Ambil detail mapel beserta nama guru
      final mapelData = await supabase
          .from('mata_pelajaran')
          .select('id, nama, guru_id')
          .inFilter('id', mapelIds);

      // Ambil nama guru
      final guruIds =
          (mapelData as List).map((m) => m['guru_id']).toSet().toList();

      final guruData = await supabase
          .from('users')
          .select('id, nama')
          .inFilter('id', guruIds);

      final guruMap = {
        for (var g in (guruData as List)) g['id']: g['nama']
      };

      final list = mapelData.map((m) => {
            'id': m['id'],
            'nama': m['nama'],
            'guru': guruMap[m['guru_id']] ?? 'Guru',
          }).toList();

      setState(() {
        _daftarMapel = List<Map<String, dynamic>>.from(list);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A90D9),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Daftar Tugas Anda',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _daftarMapel.isEmpty
              ? const Center(
                  child: Text(
                    'Belum join kelas apapun.\nMinta kode kelas dari guru kamu!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _daftarMapel.length,
                  itemBuilder: (context, index) {
                    final mapel = _daftarMapel[index];
                    final warna = _warnaPalette[index % _warnaPalette.length];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/detail-mapel-murid',
                          arguments: {
                            'mapel_id': mapel['id'],
                            'nama': mapel['nama'],
                          },
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: warna,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mapel['nama'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  mapel['guru'],
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(Icons.arrow_forward_ios,
                                color: Colors.white, size: 16),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4A90D9),
        unselectedItemColor: Colors.grey,
        currentIndex: 1,
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
}