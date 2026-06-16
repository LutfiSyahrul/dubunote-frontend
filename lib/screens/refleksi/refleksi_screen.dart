import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../profile/profile_screen.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme_manager.dart'; // ubah mode gelap

class RefleksiScreen extends StatefulWidget {
  const RefleksiScreen({super.key});

  @override
  State<RefleksiScreen> createState() => _RefleksiScreenState();
}

class _RefleksiScreenState extends State<RefleksiScreen> with SingleTickerProviderStateMixin {
  // ubah mode gelap - warna dasar menggunakan theme manager global
  Color get bgBeige => ThemeColors.getBgBeige(isDarkModeNotifier.value);
  Color get primaryBrown => ThemeColors.getPrimaryBrown(isDarkModeNotifier.value);
  Color get textGray => ThemeColors.getSubTextColor(isDarkModeNotifier.value);
  
  bool _isLoading = true;

  // Variabel Penampung Data Dinamis
  int _totalHariIni = 0;
  int _totalKemarin = 0;
  int _totalBulanIni = 0;
  int _totalBulanLalu = 0;
  int _totalTahunIni = 0;
  
  // Persentase
  double _persenHarian = 0;
  double _persenBulanan = 0;

  List<double> _grafikTahunan = List.filled(12, 0.0);

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    
    _tarikDataRefleksi();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }
  

  /// --- FUNGSI TARIK DATA DARI NODE.JS ---
  Future<void> _tarikDataRefleksi() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId != null) {
        // Kalkulasi waktu dari Flutter (Anti meleset)
        DateTime now = DateTime.now();
        DateTime yesterday = now.subtract(const Duration(days: 1));
        DateTime lastMonth = DateTime(now.year, now.month - 1, now.day);
        
        String tglHariIni = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
        String tglKemarin = "${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}";

        // URL tembakan penuh data
        String url = 'http://10.0.2.2:3000/api/transaksi/refleksi/$userId?'
            'tgl_hari_ini=$tglHariIni&tgl_kemarin=$tglKemarin&'
            'bulan_ini=${now.month}&tahun_ini=${now.year}&'
            'bulan_lalu=${lastMonth.month}&tahun_lalu=${lastMonth.year}';

        final res = await http.get(Uri.parse(url));
        
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          
          setState(() {
            _totalHariIni = double.tryParse(data['total_hari_ini'].toString())?.toInt() ?? 0;
            _totalKemarin = double.tryParse(data['total_kemarin'].toString())?.toInt() ?? 0;
            _totalBulanIni = double.tryParse(data['total_bulan_ini'].toString())?.toInt() ?? 0;
            _totalBulanLalu = double.tryParse(data['total_bulan_lalu'].toString())?.toInt() ?? 0;
            _totalTahunIni = double.tryParse(data['total_tahun_ini'].toString())?.toInt() ?? 0;
            
            _persenHarian = _totalKemarin == 0 ? (_totalHariIni > 0 ? 100.0 : 0.0) : ((_totalHariIni - _totalKemarin) / _totalKemarin) * 100;
            _persenBulanan = _totalBulanLalu == 0 ? (_totalBulanIni > 0 ? 100.0 : 0.0) : ((_totalBulanIni - _totalBulanLalu) / _totalBulanLalu) * 100;

            if (data['grafik_tahunan'] != null) {
              _grafikTahunan = List.filled(12, 0.0);
              List<dynamic> grafikData = data['grafik_tahunan'];
              for (var item in grafikData) {
                 int bln = int.tryParse(item['bulan'].toString()) ?? 1;
                 double total = double.tryParse(item['total'].toString()) ?? 0.0;
                 if (bln >= 1 && bln <= 12) {
                    _grafikTahunan[bln - 1] = total;
                 }
              }
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Gagal narik data refleksi: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _animController.forward();
      }
    }
  }

  String _formatRupiah(int angka) {
    return angka.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  @override
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return Scaffold(
          backgroundColor: bgBeige,
          appBar: _buildAppBar(),
          body: _isLoading 
            ? Center(child: CircularProgressIndicator(color: primaryBrown))
            : FadeTransition(
                opacity: _fadeAnimation,
                // --- FITUR PULL-TO-REFRESH ---
                child: RefreshIndicator(
                  onRefresh: _tarikDataRefleksi, 
                  color: primaryBrown,
                  backgroundColor: isDarkMode ? const Color(0xFF292524) : Colors.white, // ubah mode gelap
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(), // Wajib agar bisa ditarik
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Text('Refleksi Keuangan', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : const Color(0xFF1E1E1E), letterSpacing: -0.5)), // ubah mode gelap
                        const SizedBox(height: 8),
                        Text('Wawasan mendalam mengenai perjalanan finansial\nAnda.', style: TextStyle(color: textGray, fontSize: 14, height: 1.5)),
                        const SizedBox(height: 30),

                        _buildInsightCard(),
                        const SizedBox(height: 20),
                        _buildDailySummaryCard(),
                        const SizedBox(height: 20),
                        _buildMonthlySummaryCard(),
                        const SizedBox(height: 20),
                        _buildYearlyProjectionCard(),
                        const SizedBox(height: 100), // Spasi Navbar
                      ],
                    ),
                  ),
                ), 
              ),
        );
      }
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: bgBeige,
      elevation: 0,
      centerTitle: true,
      title: Text('DubuNote', style: TextStyle(color: primaryBrown, fontWeight: FontWeight.bold, fontSize: 22, letterSpacing: -0.5)),
      actions: [
        IconButton(
          icon: Icon(Icons.account_circle, color: primaryBrown, size: 30),
          onPressed: () {
            // KODE UNTUK PINDAH KE HALAMAN PROFIL<<<
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
        ),
        const SizedBox(width: 10),
      ],
      automaticallyImplyLeading: false,
    );
  }

  Widget _buildInsightCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: primaryBrown, borderRadius: BorderRadius.circular(25)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb, color: Colors.white, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Wawasan Hari Ini', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  'Pengeluaran harian Anda menunjukkan tren penurunan yang positif. Pertahankan pola konsumsi ini untuk mencapai target tabungan bulanan Anda lebih cepat. Terus pantau pengeluaran kecil yang sering terabaikan.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13, height: 1.5),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDailySummaryCard() {
    final isDark = isDarkModeNotifier.value; // ubah mode gelap
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF292524) : Colors.white, // ubah mode gelap
        borderRadius: BorderRadius.circular(25),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, spreadRadius: 2)], // ubah mode gelap
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ringkasan Harian', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)), // ubah mode gelap
              Icon(Icons.calendar_month_outlined, color: textGray, size: 20),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Hari Ini', style: TextStyle(color: textGray, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 5),
                  Text('Rp ${_formatRupiah(_totalHariIni)}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)), // ubah mode gelap
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Kemarin', style: TextStyle(color: textGray, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 5),
                  Text('Rp ${_formatRupiah(_totalKemarin)}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black54)), // ubah mode gelap
                ],
              ),
            ],
          ),
          
        ],
      ),
    );
  }

  Widget _buildMonthlySummaryCard() {
    final isDark = isDarkModeNotifier.value; // ubah mode gelap
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF292524) : Colors.white, // ubah mode gelap
        borderRadius: BorderRadius.circular(25),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, spreadRadius: 2)], // ubah mode gelap
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ringkasan Bulanan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)), // ubah mode gelap
              Icon(Icons.calendar_month_outlined, color: textGray, size: 20),
            ],
          ),
          const SizedBox(height: 20),
          Text('Pengeluaran Bulan Ini', style: TextStyle(color: textGray, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 5),
          Row(
            children: [
              Text('Rp ${_formatRupiah(_totalBulanIni)}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)), // ubah mode gelap
              
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Bulan Lalu', style: TextStyle(color: textGray, fontSize: 12, fontWeight: FontWeight.w600)),
              Text('Rp ${_formatRupiah(_totalBulanLalu)}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87)), // ubah mode gelap
            ],
          ),
          const SizedBox(height: 10),
          // Progress Bar
          Stack(
            children: [
              Container(height: 6, width: double.infinity, decoration: BoxDecoration(color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10))), // ubah mode gelap
              Container(height: 6, width: MediaQuery.of(context).size.width * 0.7, decoration: BoxDecoration(color: primaryBrown, borderRadius: BorderRadius.circular(10))),
            ],
          )
        ],
      ),
    );
  }

 Widget _buildYearlyProjectionCard() {
    final isDark = isDarkModeNotifier.value; // ubah mode gelap
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF292524) : Colors.white, // ubah mode gelap
        borderRadius: BorderRadius.circular(25),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, spreadRadius: 2)], // ubah mode gelap
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Proyeksi Tahunan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)), // ubah mode gelap
              Icon(Icons.show_chart, color: textGray, size: 20),
            ],
          ),
          const SizedBox(height: 20),
          Text('Total Pengeluaran Tahun Berjalan', style: TextStyle(color: textGray, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 5),
          Text('Rp ${_formatRupiah(_totalTahunIni)}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)), // ubah mode gelap
          const SizedBox(height: 25),
          
          // --- GRAFIK DINAMIS 12 BULAN CERDAS ---
          LayoutBuilder(
            builder: (context, constraints) {
              double maxPengeluaran = 1.0; 
              for (double val in _grafikTahunan) {
                if (val > maxPengeluaran) maxPengeluaran = val;
              }

              // Ambil data bulan saat ini di HP user
              int currentMonth = DateTime.now().month;

              return Container(
                height: 120, // Kunci utama biar grafik gak gepeng
                padding: const EdgeInsets.only(top: 20),
                decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1A17) : const Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(15)), // ubah mode gelap
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  
                  // Gunakan asMap().entries agar kita tahu ini tiang bulan ke-berapa
                  children: _grafikTahunan.asMap().entries.map((entry) {
                    int index = entry.key;
                    double val = entry.value;

                    double factor = val / maxPengeluaran;
                    double pixelHeight = factor * 100; // Kalkulasi tinggi aktual
                    if (pixelHeight < 4) pixelHeight = 4; // Minimal kelihatan 4px
                    
                    // Logika Highlight: Cek apakah tiang ini adalah bulan saat ini
                    bool isCurrentMonth = (index + 1) == currentMonth;

                    return _buildBarSolid(pixelHeight, isCurrentMonth);
                  }).toList(),
                ),
              );
            }
          ),

          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Jan', style: TextStyle(color: textGray, fontSize: 10, fontWeight: FontWeight.bold)),
              Text('Apr', style: TextStyle(color: textGray, fontSize: 10, fontWeight: FontWeight.bold)),
              Text('Jul', style: TextStyle(color: textGray, fontSize: 10, fontWeight: FontWeight.bold)),
              Text('Okt', style: TextStyle(color: textGray, fontSize: 10, fontWeight: FontWeight.bold)),
              Text('Des', style: TextStyle(color: textGray, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  // Desain balok dengan tinggi statis dan highlight bulan berjalan
  Widget _buildBarSolid(double pixelHeight, bool isCurrentMonth) {
    return Container(
      height: pixelHeight,
      width: 14, // Lebar dikecilkan jadi 14px agar 12 balok muat dengan rapi
      decoration: BoxDecoration(
        // JIKA BULAN INI: Cokelat Solid. JIKA BULAN LAIN: Cokelat Pudar
        color: isCurrentMonth ? primaryBrown : primaryBrown.withValues(alpha: 0.25),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4), 
          topRight: Radius.circular(4)
        ),
      ),
    );
  }

}