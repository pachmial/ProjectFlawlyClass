import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ZoomWebview extends StatefulWidget {
  const ZoomWebview({super.key});

  @override
  State<ZoomWebview> createState() => _ZoomWebviewState();
}

class _ZoomWebviewState extends State<ZoomWebview> {
  String _link = '';
  bool _sudahBuka = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _link = args['link'] ?? '';

    // Langsung buka link di browser
    if (!_sudahBuka && _link.isNotEmpty) {
      _sudahBuka = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _bukaLink();
      });
    }
  }

  Future<void> _bukaLink() async {
    final uri = Uri.parse(_link);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    // Balik ke halaman sebelumnya setelah buka link
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6E4F7),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xFF4A90D9)),
            const SizedBox(height: 20),
            const Text(
              'Membuka Flawly Zoom...',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF1A2F5A),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Zoom akan terbuka di browser',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: _bukaLink,
              child: const Text('Buka Manual'),
            ),
          ],
        ),
      ),
    );
  }
}