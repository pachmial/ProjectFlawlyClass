import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardMurid extends StatefulWidget {
  const DashboardMurid({super.key});

  @override
  State<DashboardMurid> createState() => _DashboardMuridState();
}

class _DashboardMuridState extends State<DashboardMurid> {
  String _namaMurid = '';

  final List<Map<String, dynamic>> _mapel = const [
    {'nama': 'MATEMATIKA', 'warna': Color(0xFFE8714A)},
    {'nama': 'PJOK', 'warna': Color(0xFF4A8FA8)},
    {'nama': 'SEJARAH', 'warna': Color(0xFFE8A84A)},
    {'nama': 'P.A.I', 'warna': Color(0xFF4AAF7A)},
    {'nama': 'B.Sunda', 'warna': Color(0xFF9B6ED4)},
    {'nama': 'Kejuruan', 'warna': Color(0xFF2D3748)},
  ];

  @override
  void initState() {
    super.initState();
    _ambilNama();
  }

  Future<void> _ambilNama() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final data = await Supabase.instance.client
        .from('murid')
        .select('nama')
        .eq('id', user.id)
        .single();

    if (mounted) {
      setState(() => _namaMurid = data['nama'] ?? '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6E4F7),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selamat Datang',
                        style: TextStyle(
                          color: Color(0xFF3A5A8A),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _namaMurid.isEmpty ? 'Memuat...' : _namaMurid,
                        style: const TextStyle(
                          color: Color(0xFF1A2F5A),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Image.asset(
                    'assets/images/l.png',
                    width: 130,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.school,
                        color: Color(0xFF4A90D9),
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Ask a Question',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    border: InputBorder.none,
                    suffixIcon: Icon(Icons.search, color: Colors.grey),
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

// Shortcut Icons
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      _buildShortcut(
        context,
        imagePath: 'assets/images/Vector-1.png', // buku = tugas
        label: 'Tugas Anda',
        route: '/tugas-murid',
      ),
      _buildShortcut(
        context,
        imagePath: 'assets/images/Vector-2.png', // kalender
        label: 'Kalender',
        route: '/kalender-murid',
      ),
      _buildShortcut(
        context,
        imagePath: 'assets/images/Vector-3.png', // akun
        label: 'Akun Anda',
        route: '/profil-murid',
      ),
    ],
  ),
),

            const SizedBox(height: 20),

            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.15,
                ),
                itemCount: _mapel.length,
                itemBuilder: (context, index) {
                  final mapel = _mapel[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/detail-mapel-murid');
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: mapel['warna'],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -15,
                            right: -15,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -20,
                            right: 20,
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                mapel['nama'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
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
        backgroundColor: const Color.fromARGB(255, 159, 204, 255),
        currentIndex: 0, // ✅ hardcode 0, tidak pakai variabel
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_rounded),
            label: 'Tugas Anda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_call_rounded),
            label: 'Flawly Zoom',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_rounded),
            label: 'Kalender',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Akun',
          ),
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

// Ganti fungsi _buildShortcut jadi ini:
Widget _buildShortcut(
  BuildContext context, {
  required String imagePath,
  required String label,
  required String route,
}) {
  return GestureDetector(
    onTap: () => Navigator.pushNamed(context, route),
    child: Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: ColorFiltered(
            colorFilter: const ColorFilter.mode(
              Color(0xFF4A90D9), // warna biru
              BlendMode.srcIn,
            ),
            child: Image.asset(imagePath),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF1A2F5A),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}
}