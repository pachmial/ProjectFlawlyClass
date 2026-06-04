import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ZoomWebview extends StatefulWidget {
  const ZoomWebview({super.key});

  @override
  State<ZoomWebview> createState() => _ZoomWebviewState();
}

class _ZoomWebviewState extends State<ZoomWebview> {
  bool _init = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_init) return;
    _init = true;

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final link = args['link'] ?? '';

    if (link.isNotEmpty) {
      _bukaZoom(link);
    }
  }

  Future<void> _bukaZoom(String link) async {
    final uri = Uri.parse(link);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal membuka link zoom'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    // Balik ke halaman sebelumnya setelah buka browser
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}