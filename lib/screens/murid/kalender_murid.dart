import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class KalenderMurid extends StatefulWidget {
  const KalenderMurid({super.key});

  @override
  State<KalenderMurid> createState() => _KalenderMuridState();
}

class _KalenderMuridState extends State<KalenderMurid> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Dummy data deadline tugas
  final List<Map<String, dynamic>> _deadlineTugas = [
    {'judul': 'Modus dan Median', 'deadline': DateTime(2026, 4, 17)},
    {'judul': 'Eksponen', 'deadline': DateTime(2026, 8, 17)},
    {'judul': 'Aljabar', 'deadline': DateTime(2026, 8, 20)},
    {'judul': 'Statistika', 'deadline': DateTime(2026, 9, 5)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A90D9),
        automaticallyImplyLeading: false,
        title: const Text(
          'Kalender',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Avatar
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                color: Color(0xFF4A90D9),
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tanggal terpilih
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: Colors.white,
            child: Text(
              _selectedDay != null
                  ? 'Date: ${_selectedDay!.day} ${_bulanNama(_selectedDay!.month)} ${_selectedDay!.year}'
                  : 'Date: ${DateTime.now().day} ${_bulanNama(DateTime.now().month)} ${DateTime.now().year}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF4A90D9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Kalender
          Container(
            color: Colors.white,
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: CalendarStyle(
                selectedDecoration: const BoxDecoration(
                  color: Color(0xFF4A90D9),
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: const Color(0xFF4A90D9).withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: Color(0xFFE57373),
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: false,
                leftChevronIcon:
                    Icon(Icons.chevron_left, color: Color(0xFF4A90D9)),
                rightChevronIcon:
                    Icon(Icons.chevron_right, color: Color(0xFF4A90D9)),
              ),
              eventLoader: (day) {
                return _deadlineTugas
                    .where((tugas) => isSameDay(tugas['deadline'], day))
                    .toList();
              },
            ),
          ),
          const SizedBox(height: 8),
          // List Deadline Tugas
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _deadlineTugas.length,
              itemBuilder: (context, index) {
                final tugas = _deadlineTugas[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tugas['judul'],
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${tugas['deadline'].day} ${_bulanNama(tugas['deadline'].month)} ${tugas['deadline'].year}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4A90D9),
        unselectedItemColor: Colors.grey,
        currentIndex: 3,
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

  String _bulanNama(int bulan) {
    const bulanList = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return bulanList[bulan - 1];
  }
}