import 'package:flutter/material.dart';

class RoleScreen extends StatelessWidget {
  const RoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F4FD), Color(0xFF4A90D9)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Logo
                Image.asset('assets/images/l.png', width: 80),
                const SizedBox(height: 4),
                // Teks Flawly Class
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Flawly ',
                        style: TextStyle(
                          color: Color(0xFF4A90D9),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: 'Class',
                        style: TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // Gambar karakter
                SizedBox(
                  height: 220,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Positioned(
                        left: 20,
                        bottom: 0,
                        child: Image.asset(
                          'assets/images/guru2.png',
                          height: 160,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Positioned(
                        left: 110,
                        bottom: 0,
                        child: Image.asset(
                          'assets/images/siswa2.png',
                          height: 180,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Positioned(
                        right: 110,
                        bottom: 0,
                        child: Image.asset(
                          'assets/images/siswa1.png',
                          height: 180,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Positioned(
                        right: 20,
                        bottom: 0,
                        child: Image.asset(
                          'assets/images/guru1.png',
                          height: 160,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
                // Bagian bawah biru
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4A90D9),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(32, 40, 32, 48),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login-murid');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF4A90D9),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Login Sebagai Murid',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/role-guru');
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(
                                color: Colors.white, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Login Sebagai Guru',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}