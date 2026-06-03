import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_calendar/table_calendar.dart';

class KalenderMurid extends StatefulWidget {
  const KalenderMurid({super.key});

  @override
  State<KalenderMurid> createState() => _KalenderMuridState();
}

class _KalenderMuridState extends State<KalenderMurid> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Map<String, dynamic>> _deadlineTugas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _ambilDeadline();
  }

  Future<void> _ambilDeadline() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser!.id;

      // Ambil mapel_id yang diikuti murid
      final members = await supabase
          .from('class_members')
          .select('mapel_id')
          .eq('murid_id', userId);

      if ((members as List).isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final mapelIds = members.map((m) => m['mapel_id']).toList();

      // Ambil semua tugas dari mapel yang diikuti
      final tugasData = await supabase
          .from('tugas')
          .select('id, judul, deadline, mapel_id')
          .inFilter('mapel_id', mapelIds)
          .not('deadline', 'is', null)
          .order('deadline', ascending: true);

      final list = (tugasData as List).map((t) {
        DateTime? deadline;
        try {
          deadline = DateTime.parse(t['deadline']);
        } catch (_) {}
        return {
          'id': t['id'],
          'judul': t['judul'],
          'deadline': deadline,
        };
      }).where((t) => t['deadline'] != null).toList();

      setState(() {
        _deadlineTugas = List<Map<String, dynamic>>.from(list);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat deadline: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> _getTugasHariIni(DateTime day) {
    return _deadlineTugas.where((t) {
      final deadline = t['deadline'] as DateTime;
      return isSameDay(deadline, day);
    }).toList();
  }

  // Filter list berdasarkan hari yang dipilih, atau tampil semua jika tidak ada pilihan
  List<Map<String, dynamic>> get _filteredTugas {
    if (_selectedDay == null) return _deadlineTugas;
    final filtered = _deadlineTugas.where((t) {
      return isSameDay(t['deadline'] as DateTime, _selectedDay!);
    }).toList();
    return filtered.isEmpty ? _deadlineTugas : filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
        appBar: AppBar(
          backgroundColor: const Color(0xFF4A90D9),
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pushReplacementNamed(context, '/dashboard-murid'),
          ),
          title: const Text(
            'Kalender',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Color(0xFF4A90D9), size: 20),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Tanggal terpilih
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
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
                    selectedDayPredicate: (day) =>
                        isSameDay(_selectedDay, day),
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
                        color: const Color(0xFF4A90D9).withValues(alpha: 0.4),
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
                      leftChevronIcon: Icon(Icons.chevron_left,
                          color: Color(0xFF4A90D9)),
                      rightChevronIcon: Icon(Icons.chevron_right,
                          color: Color(0xFF4A90D9)),
                    ),
                    eventLoader: (day) => _getTugasHariIni(day),
                  ),
                ),
                const SizedBox(height: 8),
                // List Deadline
                Expanded(
                  child: _deadlineTugas.isEmpty
                      ? const Center(
                          child: Text(
                            'Belum ada tugas dengan deadline.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredTugas.length,
                          itemBuilder: (context, index) {
                            final tugas = _filteredTugas[index];
                            final deadline = tugas['deadline'] as DateTime;
                            final isLewat =
                                deadline.isBefore(DateTime.now());
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: isLewat
                                    ? Border.all(
                                        color: Colors.red.withValues(
                                            alpha: 0.3))
                                    : null,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      tugas['judul'],
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${deadline.day} ${_bulanNama(deadline.month)} ${deadline.year}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isLewat
                                          ? Colors.red
                                          : Colors.grey,
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

  String _bulanNama(int bulan) {
    const bulanList = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return bulanList[bulan - 1];
  }
}