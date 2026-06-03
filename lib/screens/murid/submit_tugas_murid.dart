import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubmitTugasMurid extends StatefulWidget {
  const SubmitTugasMurid({super.key});

  @override
  State<SubmitTugasMurid> createState() => _SubmitTugasMuridState();
}

class _SubmitTugasMuridState extends State<SubmitTugasMurid> {
  final _tautanController = TextEditingController();
  bool _isLoading = false;
  String _judulTugas = '';
  String _tugasId = '';
  String _status = 'Belum Dikerjakan';
  String _deadline = '';

  // File yang dipilih
  PlatformFile? _selectedFile;
  String? _uploadedFotoUrl;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _tugasId = args['tugas_id'] ?? '';
      _judulTugas = args['judul'] ?? '';
      _status = args['status'] ?? 'Belum Dikerjakan';
      _deadline = args['deadline'] ?? '';
       _loadExistingSubmission();
    }
  }

Future<void> _loadExistingSubmission() async {
  if (_tugasId.isEmpty) return;
  try {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser!.id;

    final data = await supabase
        .from('submissions')
        .select('tautan, foto_url')
        .eq('tugas_id', _tugasId)
        .eq('murid_id', userId)
        .maybeSingle();

    if (data != null && mounted) {
      setState(() {
        if (data['tautan'] != null) {
          _tautanController.text = data['tautan'];
        }
        if (data['foto_url'] != null) {
          _uploadedFotoUrl = data['foto_url'];
        }
      });
    }
  } catch (_) {}
}


  Future<void> _pilihFoto() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  Future<String?> _uploadFoto() async {
    if (_selectedFile == null || _selectedFile!.bytes == null) return null;

    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser!.id;
    final fileName =
        '$userId/${_tugasId}_${DateTime.now().millisecondsSinceEpoch}_${_selectedFile!.name}';

    await supabase.storage
        .from('tugas-submissions')
        .uploadBinary(fileName, _selectedFile!.bytes!);

    final url = supabase.storage
        .from('tugas-submissions')
        .getPublicUrl(fileName);

    return url;
  }

  Future<void> _submit() async {
    final adaFoto = _selectedFile != null;
    final adaTautan = _tautanController.text.trim().isNotEmpty;

    if (!adaFoto && !adaTautan) {
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

      // Upload foto jika ada
      String? fotoUrl;
      if (adaFoto) {
        fotoUrl = await _uploadFoto();
      }

      final existing = await supabase
          .from('submissions')
          .select('id')
          .eq('tugas_id', _tugasId)
          .eq('murid_id', userId)
          .maybeSingle();

      final data = {
        'tugas_id': _tugasId,
        'murid_id': userId,
        'tautan': adaTautan ? _tautanController.text.trim() : null,
        'foto_url': fotoUrl,
        'submitted_at': DateTime.now().toIso8601String(),
      };

      if (existing != null) {
        await supabase
            .from('submissions')
            .update(data)
            .eq('id', existing['id']);
      } else {
        await supabase.from('submissions').insert(data);
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
                const SizedBox(height: 8),
                const Text('•••',
                    style: TextStyle(color: Colors.grey, fontSize: 20)),
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
                      padding: const EdgeInsets.symmetric(vertical: 14),
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

  void _showPilihSubmisi() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tambahkan Tugasmu',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            // Tambahkan Foto
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  await _pilihFoto();
                },
                icon: Icon(
                  _selectedFile != null
                      ? Icons.check_circle
                      : Icons.add_photo_alternate,
                  color: _selectedFile != null
                      ? Colors.green
                      : const Color(0xFF4A90D9),
                ),
                label: Text(
                  _selectedFile != null
                      ? '${_selectedFile!.name}'
                      : 'Tambahkan Foto',
                  style: TextStyle(
                    color: _selectedFile != null
                        ? Colors.green
                        : const Color(0xFF4A90D9),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(
                    color: _selectedFile != null
                        ? Colors.green
                        : const Color(0xFF4A90D9),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Tambahkan Tautan
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showInputTautan();
                },
                icon: const Icon(Icons.link, color: Color(0xFF4A90D9)),
                label: Text(
                  _tautanController.text.isEmpty
                      ? 'Tambahkan Tautan'
                      : 'Tautan Ditambahkan ✓',
                  style: const TextStyle(color: Color(0xFF4A90D9)),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFF4A90D9)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Kirim Tugasmu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _submit();
                },
                icon: const Icon(Icons.send),
                label: const Text('Kirim Tugasmu',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90D9),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInputTautan() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Masukkan Tautan',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Link',
                style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: _tautanController,
              decoration: InputDecoration(
                hintText: 'Masukkan tautan',
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
                onPressed: () {
                  setState(() {});
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90D9),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('+ Kirim Tautanmu'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDeadline(String? deadline) {
    if (deadline == null || deadline.isEmpty) return '';
    try {
      final dt = DateTime.parse(deadline);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return deadline;
    }
  }

 bool get _sudahAda =>
    _selectedFile != null ||
    _tautanController.text.isNotEmpty ||
    _uploadedFotoUrl != null; 

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: const Color(0xFF4A90D9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A90D9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _judulTugas.isEmpty ? 'Detail Tugas' : _judulTugas,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              _status,
              style: TextStyle(
                color: _status == 'Selesai'
                    ? Colors.greenAccent
                    : Colors.white70,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _judulTugas,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A)),
                  ),
                  if (_deadline.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          'Deadline: ${_formatDeadline(_deadline)}',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                  if (_sudahAda) ...[
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    if (_uploadedFotoUrl != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _uploadedFotoUrl!,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    // Preview foto
                    if (_selectedFile != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          _selectedFile!.bytes!,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedFile!.name,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (_tautanController.text.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Row(
                        children: [
                          Icon(Icons.link,
                              color: Color(0xFF4A90D9), size: 16),
                          SizedBox(width: 6),
                          Text('Masukkan Tautan',
                              style: TextStyle(
                                  color: Color(0xFF4A90D9),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _tautanController.text,
                        style: const TextStyle(
                            color: Color(0xFF4A90D9), fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A90D9),
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text('+ Kirim Tugasmu',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const Spacer(),
          // Tombol Tambahkan Tugasmu
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showPilihSubmisi,
                icon: const Icon(Icons.add),
                label: Text(
                  _sudahAda ? 'Ubah Tugasmu' : 'Tambahkan Tugasmu',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF4A90D9),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tautanController.dispose();
    super.dispose();
  }
}