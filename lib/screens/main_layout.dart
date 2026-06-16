import 'package:flutter/material.dart';
import 'dashboard/dashboard_screen.dart';
import 'bulan/bulan_screen.dart';
import 'refleksi/refleksi_screen.dart';
import 'export/export_screen.dart';
import 'scan/scan_page.dart';
import '../theme_manager.dart'; // ubah mode gelap

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
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        final Color currentBg = ThemeColors.getBgBeige(isDarkMode); // ubah mode gelap
        final Color currentCardBg = ThemeColors.getCardBg(isDarkMode); // ubah mode gelap
        final Color currentPrimaryBrown = ThemeColors.getPrimaryBrown(isDarkMode); // ubah mode gelap

        return Scaffold(
          backgroundColor: currentBg,
          // IndexedStack menahan state halaman agar tidak reload dari nol saat pindah tab
          body: IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
          bottomNavigationBar: Container(
            height: 80,
            decoration: BoxDecoration(
              color: currentCardBg, // ubah mode gelap
              border: Border(top: BorderSide(color: isDarkMode ? const Color(0xFF3E3B39) : Colors.black.withValues(alpha:0.05))) // ubah mode gelap
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home_outlined, 'BERANDA', 0, currentPrimaryBrown), // ubah mode gelap
                _buildNavItem(Icons.calendar_month_outlined, 'BULAN', 1, currentPrimaryBrown), // ubah mode gelap
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
                        color: currentPrimaryBrown, // ubah mode gelap
                        borderRadius: BorderRadius.circular(18), 
                        boxShadow: isDarkMode ? [] : [BoxShadow(color: currentPrimaryBrown.withValues(alpha:0.3), blurRadius: 10, offset: const Offset(0, 5))] // ubah mode gelap
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
                _buildNavItem(Icons.bar_chart, 'REFLEKSI', 3, currentPrimaryBrown), // ubah mode gelap
                _buildNavItem(Icons.ios_share, 'EXPORT', 4, currentPrimaryBrown), // ubah mode gelap
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, Color currentPrimaryBrown) {
    bool isActive = _selectedIndex == index;
    final isDarkMode = isDarkModeNotifier.value; // ubah mode gelap
    final Color itemColor = isActive 
        ? currentPrimaryBrown 
        : (isDarkMode ? Colors.white60 : textGray); // ubah mode gelap

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: itemColor, size: 26),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: itemColor, fontSize: 9, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}