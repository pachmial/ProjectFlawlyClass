import 'package:flutter/material.dart';

class DetailTugasMurid extends StatelessWidget {
  const DetailTugasMurid({super.key});

  final List<Map<String, dynamic>> _listTugas = const [
    {'judul': 'Modus dan Median', 'status': 'Belum Selesai'},
    {'judul': 'Statistika', 'status': 'Belum Selesai'},
    {'judul': 'Matriks', 'status': 'Belum Selesai'},
    {'judul': 'Algoritma', 'status': 'Belum Selesai'},
    {'judul': 'Aljabar', 'status': 'Belum Selesai'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A90D9),
        title: const Text(
          'Matematika',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Progress tugas
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '3/5',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _listTugas.length,
        itemBuilder: (context, index) {
          final tugas = _listTugas[index];
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/submit-tugas-murid');
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tugas['judul'],
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF333333),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: tugas['status'] == 'Belum Selesai'
                          ? const Color(0xFFFFEEEE)
                          : const Color(0xFFEEFFEE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tugas['status'],
                      style: TextStyle(
                        fontSize: 11,
                        color: tugas['status'] == 'Belum Selesai'
                            ? Colors.red
                            : Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      // Tombol Tambahkan Tugasmu
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/submit-tugas-murid');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A90D9),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Tambahkan Tugasmu',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}