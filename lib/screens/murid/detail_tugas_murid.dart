import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetailTugasMurid extends StatefulWidget {
  final String mapelId;
  final String mapelNama;

  const DetailTugasMurid({
    super.key,
    required this.mapelId,
    required this.mapelNama,
  });

  @override
  State<DetailTugasMurid> createState() => _DetailTugasMuridState();
}

class _DetailTugasMuridState extends State<DetailTugasMurid> {
  List<Map<String, dynamic>> _listTugas = [];
  bool _isLoading = true;
  int _selesai = 0;

  @override
  void initState() {
    super.initState();
    _loadTugas();
  }

  Future<void> _loadTugas() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser!.id;

      // Ambil semua tugas berdasarkan mapel_id
      final tugasData = await supabase
          .from('tugas')
          .select('id, judul, deadline')
          .eq('mapel_id', widget.mapelId)
          .order('created_at', ascending: true);

      // Ambil submissions murid ini
      final submissionData = await supabase
          .from('submissions')
          .select('tugas_id')
          .eq('murid_id', userId);

      final submittedIds =
          (submissionData as List).map((s) => s['tugas_id']).toSet();

      final list = (tugasData as List).map((t) {
        final sudahSelesai = submittedIds.contains(t['id']);
        return {
          'id': t['id'],
          'judul': t['judul'],
          'deadline': t['deadline'],
          'status': sudahSelesai ? 'Selesai' : 'Belum Selesai',
        };
      }).toList();

      setState(() {
        _listTugas = list;
        _selesai = list.where((t) => t['status'] == 'Selesai').length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat tugas: $e')),
        );
      }
    }
  }

  String _formatDeadline(String? deadline) {
    if (deadline == null) return '';
    try {
      final dt = DateTime.parse(deadline);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return deadline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A90D9),
        title: Text(
          widget.mapelNama,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$_selesai/${_listTugas.length}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _listTugas.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada tugas',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: _listTugas.length,
                  itemBuilder: (context, index) {
                    final tugas = _listTugas[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/submit-tugas-murid',
                          arguments: {
                            'tugas_id': tugas['id'],
                            'judul': tugas['judul'],
                            'status': tugas['status'],
                          },
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  tugas['status'] == 'Selesai'
                                      ? Icons.check_box
                                      : Icons.check_box_outline_blank,
                                  color: tugas['status'] == 'Selesai'
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tugas['judul'],
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF333333),
                                      ),
                                    ),
                                    if (tugas['deadline'] != null)
                                      Text(
                                        _formatDeadline(tugas['deadline']),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
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
              );
            }
          }