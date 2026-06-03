import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubmitTugasMurid extends StatefulWidget {
  const SubmitTugasMurid({super.key});

  @override
  State<SubmitTugasMurid> createState() => _SubmitTugasMuridState();
}

class _SubmitTugasMuridState extends State<SubmitTugasMurid> {
  final _tautanController = TextEditingController();
  bool _fotoTerpilih = false;
  bool _isLoading = false;
  String _judulTugas = '';
  String _tugasId = '';
  String _status = 'Belum Dikerjakan';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _tugasId = args['tugas_id'] ?? '';
      _judulTugas = args['judul'] ?? '';
      _status = args['status'] ?? 'Belum Dikerjakan';
    }
  }

  Future<void> _submit() async {
    if (!_fotoTerpilih && _tautanController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tambahkan foto atau tautan dulu!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser!.id;

      // Cek apakah sudah pernah submit
      final existing = await supabase
          .from('submissions')
          .select('id')
          .eq('tugas_id', _tugasId)
          .eq('murid_id', userId)
          .maybeSingle();

      if (existing != null) {
        // Update submission yang ada
        await supabase.from('submissions').update({
          'tautan': _tautanController.text.trim(),
          'submitted_at': DateTime.now().toIso8601String(),
        }).eq('id', existing['id']);
      } else {
        // Insert submission baru
        await supabase.from('submissions').insert({
          'tugas_id': _tugasId,
          'murid_id': userId,
          'tautan': _tautanController.text.trim(),
          'submitted_at': DateTime.now().toIso8601String(),
        });
      }

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Tugas Berhasil Dikirimkan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90D9),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Kembali ke halaman Tugas'),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim tugas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A90D9),
        title: Text(
          _judulTugas.isEmpty ? 'Detail Tugas' : _judulTugas,
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              _status,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tombol Tambahkan Foto
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() => _fotoTerpilih = true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Foto dipilih!')),
                  );
                },
                icon: Icon(
                  _fotoTerpilih
                      ? Icons.check_circle
                      : Icons.add_photo_alternate,
                  color:
                      _fotoTerpilih ? Colors.green : const Color(0xFF4A90D9),
                ),
                label: Text(
                  _fotoTerpilih ? 'Foto Terpilih' : 'Tambahkan Foto',
                  style: TextStyle(
                    color: _fotoTerpilih
                        ? Colors.green
                        : const Color(0xFF4A90D9),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: _fotoTerpilih
                        ? Colors.green
                        : const Color(0xFF4A90D9),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Tombol Tambahkan Tautan
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) => Padding(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 20,
                        bottom:
                            MediaQuery.of(context).viewInsets.bottom + 20,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Masukkan Tautan',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _tautanController,
                            decoration: InputDecoration(
                              hintText: 'https://...',
                              filled: true,
                              fillColor: const Color(0xFFF5F5F5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4A90D9),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text('Simpan Tautan'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.link, color: Color(0xFF4A90D9)),
                label: Text(
                  _tautanController.text.isEmpty
                      ? 'Tambahkan Tautan'
                      : 'Tautan Ditambahkan',
                  style: const TextStyle(color: Color(0xFF4A90D9)),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFF4A90D9)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const Spacer(),
            // Tombol Submit
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90D9),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Kirim Tugasmu',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tautanController.dispose();
    super.dispose();
  }
}