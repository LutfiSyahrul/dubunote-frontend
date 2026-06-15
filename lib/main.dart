import 'package:flutter/material.dart';
import 'screens/splash/splash_screen.dart'; 
import 'screens/main_layout.dart'; 
import 'screens/scan/scan_detail_page.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DubuNote',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7A5B4C)), // Saya sesuaikan ke warna cokelat DubuNote
        useMaterial3: true,
      ),
      home: const SplashScreen(), 
      
      routes: {
        // Rute untuk kembali ke halaman utama (Dashboard/Beranda)
        '/home': (context) => const MainLayout(), 
        
        // Rute untuk membuka halaman Review Detail Scan
        '/scan-detail': (context) => const ScanDetailPage(),
      },
    );
  }
}