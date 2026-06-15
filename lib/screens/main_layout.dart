import 'package:flutter/material.dart';
import 'dashboard/dashboard_screen.dart';
import 'bulan/bulan_screen.dart';
import 'refleksi/refleksi_screen.dart';
import 'export/export_screen.dart';
import 'scan/scan_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final Color primaryBrown = const Color(0xFF7A5B4C);
  final Color textGray = const Color(0xFF8B8B8B);
  
  int _selectedIndex = 0;

  // Daftar halaman yang akan ditukar-tukar di dalam Layout
  // Daftar halaman yang akan ditukar-tukar di dalam Layout (diubah menjadi getter)
  List<Widget> get _pages => [
    DashboardScreen(
      onTabChanged: (int index) {
        _onItemTapped(index); // Akan mengubah tab aktif sesuai angka yang dikirim dari Beranda
      },
    ), 
    const BulanScreen(), // Index 1: Bulan
    const ScanPage(), // Index 2: Scan
    const RefleksiScreen(), // Index 3: Refleksi
    const ExportScreen(), // Index 4: Export
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF8),
      // IndexedStack menahan state halaman agar tidak reload dari nol saat pindah tab
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // Komponen Navigasi Bawah (Dipindah ke sini agar global)
  Widget _buildBottomNavigationBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.black.withValues(alpha:0.05)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_outlined, 'BERANDA', 0),
          _buildNavItem(Icons.calendar_month_outlined, 'BULAN', 1),
          // Tombol SCAN khusus di tengah
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ScanPage()),
              );
            },
            child: Transform.translate(
              offset: const Offset(0, -15),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: primaryBrown, 
                  borderRadius: BorderRadius.circular(18), 
                  boxShadow: [BoxShadow(color: primaryBrown.withValues(alpha:0.3), blurRadius: 10, offset: const Offset(0, 5))]
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.qr_code_scanner, color: Colors.white, size: 24),
                    SizedBox(height: 4),
                    Text('SCAN', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
          _buildNavItem(Icons.bar_chart, 'REFLEKSI', 3),
          _buildNavItem(Icons.ios_share, 'EXPORT', 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? primaryBrown : textGray, size: 26),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: isActive ? primaryBrown : textGray, fontSize: 9, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}