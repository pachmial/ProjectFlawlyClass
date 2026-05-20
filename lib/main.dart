import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/splash_screen.dart';
import 'screens/role_screen.dart';
import 'screens/auth/login_murid.dart';
import 'screens/auth/login_guru.dart';
import 'screens/auth/role_guru_screen.dart';
import 'screens/auth/buat_kelas_screen.dart';
import 'screens/murid/dashboard_murid.dart';
import 'screens/murid/tugas_murid.dart';
import 'screens/murid/detail_tugas_murid.dart';
import 'screens/murid/submit_tugas_murid.dart';
import 'screens/murid/kalender_murid.dart';
import 'screens/guru/dashboard_guru.dart';
import 'screens/guru/tambah_tugas_guru.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://tdyhuabtzfhgpqvwbnuv.supabase.co',
    anonKey: 'sb_publishable_JSVAApitygMEQDa1viXlKw_y5fdHbwB',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flawly Class',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4A90D9)),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/role': (context) => const RoleScreen(),
        '/login-murid': (context) => const LoginMurid(),
        '/login-guru': (context) => const LoginGuru(),
        '/role-guru': (context) => const RoleGuruScreen(),
        '/buat-kelas': (context) => const BuatKelasScreen(), // ✅ hanya sekali
        '/dashboard-murid': (context) => const DashboardMurid(),
        '/tugas-murid': (context) => const TugasMurid(),
        '/detail-tugas-murid': (context) => const DetailTugasMurid(),
        '/submit-tugas-murid': (context) => const SubmitTugasMurid(),
        '/kalender-murid': (context) => const KalenderMurid(),
        '/dashboard-guru': (context) => const DashboardGuru(), // ✅ ditambahkan
        '/tambah-tugas': (context) => const TambahTugasGuru(),
      },
    );
  }
}