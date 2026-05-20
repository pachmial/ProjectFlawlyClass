import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardGuru extends StatefulWidget {
  const DashboardGuru({super.key});

  @override
  State<DashboardGuru> createState() => _DashboardGuruState();
}

class _DashboardGuruState extends State<DashboardGuru> {
  String _namaGuru = '';
  List<Map<String, dynamic>> _kelasList = [];
  bool _isLoading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser!.id;

      final userData = await supabase
          .from('users')
          .select('nama')
          .eq('id', userId)
          .single();

      final kelasData = await supabase
          .from('kelas')
          .select()
          .eq('guru_id', userId);

      if (mounted) {
        setState(() {
          _namaGuru = userData['nama'] ?? '';
          _kelasList = List<Map<String, dynamic>>.from(kelasData);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffA9C9FF),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "Tugas"),
          BottomNavigationBarItem(icon: Icon(Icons.video_call), label: "Flowly Zoom"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "Kalender"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Akun"),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    const Text(
                      "Selamat Datang",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _namaGuru,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // MENU BOX
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Apa yang ingin di tambahkan ?",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 20),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                                GestureDetector(
                                onTap: () => Navigator.pushNamed(context, '/tambah-tugas'),
                                child: _menuItem(Icons.menu_book_rounded, "Tambahkan\nTugas"),
                                ),
                                _menuItem(Icons.calendar_month, "Kalender"),
                                _menuItem(Icons.person, "Akun Anda"),
                            ],
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // SECTION TUGAS
                    const Text(
                      "Lihat Tugas Sebelumnya ?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Expanded(
                      child: _kelasList.isEmpty
                          ? const Center(
                              child: Text(
                                'Belum ada kelas.\nBuat kelas pertama Anda!',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 15,
                                mainAxisSpacing: 15,
                                childAspectRatio: 1.1,
                              ),
                              itemCount: _kelasList.length,
                              itemBuilder: (context, index) {
                                final kelas = _kelasList[index];
                                return _kelasCard(
                                  kelas['nama_kelas'] ?? '',
                                  kelas['mata_pelajaran'] ?? '',
                                  kelas['kode_kelas'] ?? '',
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _menuItem(IconData icon, String title) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: const Color(0xffA9C9FF),
            borderRadius: BorderRadius.circular(35),
          ),
          child: Icon(icon, size: 32, color: const Color(0xFF1A1A1A)),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _kelasCard(String namaKelas, String mapel, String kodeKelas) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            namaKelas,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            mapel,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xffA9C9FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Kode: $kodeKelas',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A4A8A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}