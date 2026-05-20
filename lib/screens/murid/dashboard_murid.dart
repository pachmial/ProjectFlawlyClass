import 'package:flutter/material.dart';

class DashboardMurid extends StatelessWidget {
  const DashboardMurid({super.key});

  // Data dummy dulu sebelum koneksi database
  final List<Map<String, dynamic>> _mapel = const [
    {'nama': 'Matematika', 'warna': Color(0xFFE57373)},
    {'nama': 'PJOK', 'warna': Color(0xFF4A90D9)},
    {'nama': 'Sejarah', 'warna': Color(0xFFFFB74D)},
    {'nama': 'P.A.I', 'warna': Color(0xFF81C784)},
    {'nama': 'B.Sunda', 'warna': Color(0xFF9575CD)},
    {'nama': 'Kejuruan', 'warna': Color(0xFF4DB6AC)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF4A90D9),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat Datang',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Muhammad Desta',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      // Avatar
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          color: Color(0xFF4A90D9),
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Ask a Question...',
                        border: InputBorder.none,
                        icon: Icon(Icons.search, color: Colors.grey),
                      ),
                    ),
                  ),
                ],
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
                    icon: Icons.assignment,
                    label: 'Tugas\nAnda',
                    route: '/tugas-murid',
                  ),
                  _buildShortcut(
                    context,
                    icon: Icons.calendar_month,
                    label: 'Kalender',
                    route: '/kalender-murid',
                  ),
                  _buildShortcut(
                    context,
                    icon: Icons.person,
                    label: 'Akun\nAnda',
                    route: '/profil-murid',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Grid Mata Pelajaran
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.3,
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
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            mapel['nama'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4A90D9),
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Tugas Anda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_call),
            label: 'Flawly Zoom',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Kalender',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
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

  Widget _buildShortcut(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: const Color(0xFF4A90D9), size: 28),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}