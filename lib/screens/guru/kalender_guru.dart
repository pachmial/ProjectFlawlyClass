import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_calendar/table_calendar.dart';

class KalenderGuru extends StatefulWidget {
  const KalenderGuru({super.key});

  @override
  State<KalenderGuru> createState() => _KalenderGuruState();
}

class _KalenderGuruState extends State<KalenderGuru> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Map<String, dynamic>> _deadlineTugas = [];
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

      final tugasRaw = await supabase
          .from('tugas')
          .select('id, judul, deadline, mapel_id')
          .eq('guru_id', userId)
          .order('deadline', ascending: true);

      final List<Map<String, dynamic>> result = [];

      for (final t in (tugasRaw as List)) {
        DateTime? deadline;
        try {
          deadline = DateTime.parse(t['deadline'].toString());
        } catch (_) {}

        String namaMapel = '';
        final mapelId = t['mapel_id'];
        if (mapelId != null) {
          try {
            final mapelRaw = await supabase
                .from('mata_pelajaran')
                .select('nama')
                .eq('id', mapelId)
                .maybeSingle();
            if (mapelRaw != null) {
              namaMapel = (mapelRaw['nama'] ?? '').toString();
            }
          } catch (_) {}
        }

        result.add({
          'id': (t['id'] ?? '').toString(),
          'judul': (t['judul'] ?? '').toString(),
          'nama_mapel': namaMapel,
          'deadline': deadline,
        });
      }

      if (mounted) {
        setState(() {
          _deadlineTugas = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat tugas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _bulanNama(int bulan) {
    const bulanList = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return bulanList[bulan - 1];
  }

  String _formatTanggal(DateTime? dt) {
    if (dt == null) return '-';
    return '${dt.day} ${_bulanNama(dt.month)} ${dt.year}';
  }

  List _getTugasForDay(DateTime day) {
    return _deadlineTugas.where((t) {
      final dl = t['deadline'] as DateTime?;
      if (dl == null) return false;
      return dl.year == day.year &&
          dl.month == day.month &&
          dl.day == day.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final tugasTampil = _selectedDay != null
        ? _deadlineTugas.where((t) {
            final dl = t['deadline'] as DateTime?;
            if (dl == null) return false;
            return dl.year == _selectedDay!.year &&
                dl.month == _selectedDay!.month &&
                dl.day == _selectedDay!.day;
          }).toList()
        : _deadlineTugas;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SafeArea(
        child: Column(
          children: [

            // ── CUSTOM APP BAR ──
            Container(
              color: const Color(0xFF4A90D9),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Tombol back
                  GestureDetector(
                    onTap: () => Navigator.pushReplacementNamed(
                        context, '/dashboard-guru'),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Judul
                  const Expanded(
                    child: Text(
                      'Kalender',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  // Avatar guru
                      Container(
                width:80,
                height: 60,
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                ),
                  child: Image.asset(
                    'assets/images/l.png',
                    fit: BoxFit.contain,
                  ),
              ),  
              ],
               ),
                 ),

            // ── TANGGAL TERPILIH ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Date: ${_formatTanggal(_selectedDay ?? DateTime.now())}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4A90D9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_selectedDay != null)
                    GestureDetector(
                      onTap: () =>
                          setState(() => _selectedDay = null),
                      child: const Text(
                        'Lihat Semua',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── KALENDER ──
            Container(
              color: Colors.white,
              child: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                          child: CircularProgressIndicator()),
                    )
                  : TableCalendar(
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
                      onPageChanged: (focusedDay) {
                        setState(() => _focusedDay = focusedDay);
                      },
                      calendarFormat: CalendarFormat.month,
                      availableCalendarFormats: const {
                        CalendarFormat.month: 'Month',
                      },
                      calendarStyle: CalendarStyle(
                        selectedDecoration: const BoxDecoration(
                          color: Color(0xFF4A90D9),
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: const Color(0xFF4A90D9)
                              .withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        markerDecoration: const BoxDecoration(
                          color: Color(0xFFE57373),
                          shape: BoxShape.circle,
                        ),
                        outsideDaysVisible: true,
                        weekendTextStyle: const TextStyle(
                          color: Color(0xFFE57373),
                        ),
                      ),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: false,
                        leftChevronIcon: Icon(
                          Icons.chevron_left,
                          color: Color(0xFF4A90D9),
                          size: 28,
                        ),
                        rightChevronIcon: Icon(
                          Icons.chevron_right,
                          color: Color(0xFF4A90D9),
                          size: 28,
                        ),
                        titleTextStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      daysOfWeekStyle: const DaysOfWeekStyle(
                        weekdayStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                        weekendStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE57373),
                        ),
                      ),
                      eventLoader: _getTugasForDay,
                    ),
            ),

            const SizedBox(height: 8),

            // ── LIST TUGAS ──
            Expanded(
              child: tugasTampil.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.assignment_outlined,
                              size: 48,
                              color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            _selectedDay != null
                                ? 'Tidak ada tugas di tanggal ini'
                                : 'Belum ada tugas',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: tugasTampil.length,
                      itemBuilder: (context, index) {
                        final tugas = tugasTampil[index];
                        final deadline =
                            tugas['deadline'] as DateTime?;
                        return Container(
                          margin:
                              const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tugas['judul'].toString(),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight:
                                            FontWeight.w600,
                                        color: Color(0xFF1A1A1A),
                                      ),
                                      maxLines: 1,
                                      overflow:
                                          TextOverflow.ellipsis,
                                    ),
                                    if (tugas['nama_mapel'] !=
                                        '') ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        tugas['nama_mapel']
                                            .toString(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatTanggal(deadline),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            // ── BOTTOM NAV ──
            BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color(0xFF4A90D9),
              unselectedItemColor: Colors.grey,
              currentIndex: 3,
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.home_rounded),
                    label: 'Beranda'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.assignment_outlined),
                    label: 'Tugas'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.video_call_outlined),
                    label: 'Flawly Zoom'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_month),
                    label: 'Kalender'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    label: 'Akun'),
              ],
              onTap: (index) {
                switch (index) {
                  case 0:
                    Navigator.pushReplacementNamed(
                        context, '/dashboard-guru');
                    break;
                  case 1:
                    Navigator.pushReplacementNamed(
                        context, '/tugas-guru');
                    break;
                  case 2:
                    Navigator.pushReplacementNamed(
                        context, '/zoom-guru');
                    break;
                  case 3:
                    break;
                  case 4:
                    Navigator.pushReplacementNamed(
                        context, '/profil-guru');
                    break;
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}