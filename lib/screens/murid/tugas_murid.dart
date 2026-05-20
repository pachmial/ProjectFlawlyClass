import 'package:flutter/material.dart';

class TugasMurid extends StatelessWidget {
  const TugasMurid({super.key});

  final List<Map<String, dynamic>> _daftarTugas = const [
    {
      'mapel': 'Matematika',
      'guru': 'Sri Haryani',
      'warna': Color(0xFFE57373),
    },
    {
      'mapel': 'B.Inggris',
      'guru': 'Tresna',
      'warna': Color(0xFF4A90D9),
    },
    {
      'mapel': 'Sejarah',
      'guru': 'Hari Setiawan',
      'warna': Color(0xFFFFB74D),
    },
    {
      'mapel': 'Rinca',
      'guru': 'Rinca',
      'warna': Color(0xFF81C784),
    },
    {
      'mapel': 'B.Sunda',
      'guru': 'Novita Wandasari',
      'warna': Color(0xFF9575CD),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A90D9),
        automaticallyImplyLeading: false,
        title: const Text(
          'Daftar Tugas Anda',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _daftarTugas.length,
        itemBuilder: (context, index) {
          final tugas = _daftarTugas[index];
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/detail-tugas-murid');
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: tugas['warna'],
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
                        tugas['mapel'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        tugas['guru'],
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
}