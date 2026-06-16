import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../profile/profile_screen.dart';
import 'package:share_plus/share_plus.dart';

import 'package:flutter/material.dart';
import '../../theme_manager.dart'; // ubah mode gelap

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> with SingleTickerProviderStateMixin {
  // ubah mode gelap - warna dasar menggunakan theme manager global
  Color get bgBeige => ThemeColors.getBgBeige(isDarkModeNotifier.value);
  Color get primaryBrown => ThemeColors.getPrimaryBrown(isDarkModeNotifier.value);
  Color get textGray => ThemeColors.getSubTextColor(isDarkModeNotifier.value);
  Color get cardBg => isDarkModeNotifier.value ? const Color(0xFF1E1A17) : const Color(0xFFF5F5F5);

  // --- 1. VARIABEL STATE UNTUK DATA DINAMIS ---
  String _selectedRentang = 'Bulanan'; 
  String _selectedFormat = 'PDF';
  String _selectedKategori = 'Semua Kategori';
  DateTime _selectedDate = DateTime.now(); 
  bool _isDownloading = false;
  bool _isSharing = false;

  final List<String> _kategoriList = [
    'Semua Kategori',
    'Makan & Minuman',
    'Transport',
    'Belanja',
    'Lainnya'
  ];

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward(); 
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // FUNGSI REFRESH 
  Future<void> _refreshState() async {
    // Memberikan jeda animasi loading sebentar
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {
        // Me-reset semua pilihan kembali ke bawaan awal
        _selectedDate = DateTime.now();
        _selectedRentang = 'Bulanan';
        _selectedKategori = 'Semua Kategori';
        _selectedFormat = 'PDF';
      });
    }
  }

  // 2. FUNGSI UNTUK MENGUBAH TAMPILAN TANGGAL 
  String _getDisplayDate() {
    List<String> bulan = ["Jan", "Feb", "Mar", "Apr", "Mei", "Jun", "Jul", "Agt", "Sep", "Okt", "Nov", "Des"];
    if (_selectedRentang == 'Harian') {
      return "${_selectedDate.day} ${bulan[_selectedDate.month - 1]} ${_selectedDate.year}";
    } else if (_selectedRentang == 'Bulanan') {
      return "${bulan[_selectedDate.month - 1]} ${_selectedDate.year}";
    } else {
      return "${_selectedDate.year}";
    }
  }

  // --- 3. FUNGSI MEMUNCULKAN KALENDER YANG LEBIH PINTAR ---
  Future<void> _pilihTanggal() async {
    // Logika pintar: Jika rentang 'Tahunan', kalender langsung buka mode pilihan Tahun.
    DatePickerMode mode = _selectedRentang == 'Tahunan' ? DatePickerMode.year : DatePickerMode.day;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDatePickerMode: mode, // Set mode otomatis
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryBrown, 
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  // --- 4. FUNGSI MEMUNCULKAN PILIHAN KATEGORI (BOTTOM SHEET) ---
  void _pilihKategori() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              const Text('Pilih Kategori', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 10),
              ..._kategoriList.map((kat) {
                bool isSelected = _selectedKategori == kat;
                return ListTile(
                  title: Text(kat, style: TextStyle(color: isSelected ? primaryBrown : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
                  trailing: isSelected ? Icon(Icons.check_circle, color: primaryBrown) : null,
                  onTap: () {
                    setState(() => _selectedKategori = kat);
                    Navigator.pop(context); // Tutup bottom sheet setelah milih
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  // --- FUNGSI UNDUH 
  void _prosesUnduh() async {
    setState(() => _isDownloading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) throw Exception("User ID tidak ditemukan");

      // Siapkan format tanggal untuk dikirim ke backend
      String tglLengkap = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

      // 1. Tembak API Node.js
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/transaksi/export'), // Sesuaikan IP jika pakai device fisik
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'pengguna_id': userId,
          'rentang': _selectedRentang,
          'tahun': _selectedDate.year,
          'bulan': _selectedDate.month,
          'tanggal_lengkap': tglLengkap,
          'kategori': _selectedKategori,
          'format': _selectedFormat,
        }),
      );

      if (response.statusCode == 200) {
        // 2. Ambil direktori penyimpanan dokumen di HP
        final dir = await getApplicationDocumentsDirectory();
        
        // Tentukan ekstensi file
        String ext = _selectedFormat == 'Excel' ? 'xlsx' : (_selectedFormat == 'CSV' ? 'csv' : 'pdf');
        String fileName = 'DubuNote_${_selectedRentang}_${_selectedKategori.replaceAll(' ', '')}.$ext';
        String filePath = '${dir.path}/$fileName';

        // 3. Simpan file biner dari backend ke memori HP
        File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('File berhasil diunduh! Membuka dokumen...'), backgroundColor: Colors.green));
        }

        // 4. Buka file secara otomatis!
        await OpenFilex.open(filePath);

      } else {
        final errorData = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorData['pesan'] ?? 'Gagal mengunduh'), backgroundColor: Colors.red));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  // FUNGSI BAGIKAN (SHARE KE WHATSAPP/DLL) 
  void _prosesBagikan() async {
    setState(() => _isSharing = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) throw Exception("User ID tidak ditemukan");

      String tglLengkap = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

      // Tembak API
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/transaksi/export'), 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'pengguna_id': userId,
          'rentang': _selectedRentang,
          'tahun': _selectedDate.year,
          'bulan': _selectedDate.month,
          'tanggal_lengkap': tglLengkap,
          'kategori': _selectedKategori,
          'format': _selectedFormat,
        }),
      );

      if (response.statusCode == 200) {
        // Gunakan getTemporaryDirectory agar tidak nyampah di memori HP (Otomatis terhapus sistem nanti)
        final dir = await getTemporaryDirectory();
        
        String ext = _selectedFormat == 'Excel' ? 'xlsx' : (_selectedFormat == 'CSV' ? 'csv' : 'pdf');
        String fileName = 'DubuNote_${_selectedRentang}_${_selectedKategori.replaceAll(' ', '')}.$ext';
        String filePath = '${dir.path}/$fileName';

        File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        // TRIGGER NATIVE SHARE BAWAAN ANDROID/IOS
        await Share.shareXFiles(
          [XFile(filePath)], 
          text: 'Berikut adalah Laporan $_selectedRentang DubuNote saya.', // Pesan teks bawaan
        );

      } else {
        final errorData = jsonDecode(response.body);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorData['pesan'] ?? 'Gagal membagikan'), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  // BAGIAN UI (TIDAK ADA DESAIN YANG DIUBAH, HANYA DITAMBAH ONTAP)
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return Scaffold(
          backgroundColor: bgBeige,
          appBar: _buildAppBar(),
          body: FadeTransition(
            opacity: _fadeAnimation,
            // --- FITUR PULL-TO-REFRESH ---
            child: RefreshIndicator(
              onRefresh: _refreshState, // Memanggil fungsi reset
              color: primaryBrown,
              backgroundColor: isDarkMode ? const Color(0xFF292524) : Colors.white, // ubah mode gelap
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(), // Wajib agar bisa ditarik
                padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 const SizedBox(height: 10),
                Text('Persiapkan Laporan Anda', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : const Color(0xFF1E1E1E), letterSpacing: -0.5)), // ubah mode gelap
                const SizedBox(height: 8),
                Text('Pilih rentang waktu, kategori, dan format file\nyang sesuai dengan kebutuhan pencatatan\nfinansial Anda.', style: TextStyle(color: textGray, fontSize: 13, height: 1.5)),
                const SizedBox(height: 30),

                _buildRentangWaktuSection(),
                const SizedBox(height: 20),
                _buildKategoriSection(),
                const SizedBox(height: 25),

                Text('Format Dokumen', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black87)), // ubah mode gelap
                const SizedBox(height: 15),
                _buildFormatCard('PDF Laporan', 'Optimal untuk cetak', Icons.picture_as_pdf_outlined, 'PDF'),
                const SizedBox(height: 15),
                _buildFormatCard('Excel (.xlsx)', 'Untuk analisis detail', Icons.table_view_outlined, 'Excel'),
                const SizedBox(height: 15),
                _buildFormatCard('Data (.csv)', 'Mentahan data raw', Icons.data_object, 'CSV'),
                const SizedBox(height: 35),

                // --- TOMBOL UNDUH DENGAN LOADING ---
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isDownloading ? null : _prosesUnduh,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBrown,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 0,
                    ),
                    child: _isDownloading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.download_rounded, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text('Unduh Laporan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                  ),
                ),
                const SizedBox(height: 15),
                // TOMBOL BAGIKAN 
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSharing ? null : _prosesBagikan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode ? const Color(0xFF3E3025) : const Color(0xFFF3DDC9), // ubah mode gelap
                    foregroundColor: primaryBrown, 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: _isSharing
                    ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: primaryBrown, strokeWidth: 2))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.share_outlined, color: primaryBrown, size: 20),
                          const SizedBox(width: 8),
                          Text('Bagikan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryBrown)),
                        ],
                      ),
                ),
              ),
                const SizedBox(height: 100), 
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
            // KODE UNTUK PINDAH KE HALAMAN PROFIL
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

  Widget _buildRentangWaktuSection() {
    final isDark = isDarkModeNotifier.value; // ubah mode gelap
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(25)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rentang Waktu', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)), // ubah mode gelap
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPillButton('Harian'),
              _buildPillButton('Bulanan'),
              _buildPillButton('Tahunan'),
            ],
          ),
          const SizedBox(height: 20),
          
          // --- KOLOM TANGGAL INTERAKTIF (DIUBAH KE INKWELL BISA DIKLIK FULL) ---
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _pilihTanggal, // Panggil kalender saat diklik
              borderRadius: BorderRadius.circular(15),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF292524) : Colors.white, // ubah mode gelap
                  borderRadius: BorderRadius.circular(15), 
                  border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200) // ubah mode gelap
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_getDisplayDate(), style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13, fontWeight: FontWeight.w600)), // ubah mode gelap
                    Icon(Icons.calendar_today_outlined, color: textGray, size: 18),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPillButton(String text) {
    bool isSelected = _selectedRentang == text;
    final isDark = isDarkModeNotifier.value; // ubah mode gelap
    return GestureDetector(
      onTap: () => setState(() => _selectedRentang = text),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? primaryBrown : (isDark ? const Color(0xFF292524) : Colors.white), // ubah mode gelap
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected ? (isDark ? [] : [BoxShadow(color: primaryBrown.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))]) : [], // ubah mode gelap
        ),
        child: Text(text, style: TextStyle(color: isSelected ? (isDark ? const Color(0xFF1C1917) : Colors.white) : (isDark ? Colors.white70 : Colors.black87), fontWeight: isSelected ? FontWeight.bold : FontWeight.w600, fontSize: 12)), // ubah mode gelap
      ),
    );
  }

  Widget _buildKategoriSection() {
    final isDark = isDarkModeNotifier.value; // ubah mode gelap
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(25)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Kategori', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)), // ubah mode gelap
          const SizedBox(height: 15),
          // --- KOLOM KATEGORI INTERAKTIF ---
          GestureDetector(
            onTap: _pilihKategori, // Panggil menu kategori saat diklik
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF292524) : Colors.white, // ubah mode gelap
                borderRadius: BorderRadius.circular(15), 
                border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200) // ubah mode gelap
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_selectedKategori, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13, fontWeight: FontWeight.w600)), // ubah mode gelap
                  Icon(Icons.keyboard_arrow_down_rounded, color: textGray, size: 22),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFormatCard(String title, String subtitle, IconData icon, String formatType) {
    bool isSelected = _selectedFormat == formatType;
    final isDark = isDarkModeNotifier.value; // ubah mode gelap
    return GestureDetector(
      onTap: () => setState(() => _selectedFormat = formatType),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF292524) : Colors.white, // ubah mode gelap
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: isSelected ? primaryBrown : Colors.transparent, width: 1.5),
          boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, spreadRadius: 2)], // ubah mode gelap
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: isSelected ? const Color(0xFFF3DDC9) : cardBg, shape: BoxShape.circle),
                    child: Icon(icon, color: primaryBrown, size: 24),
                  ),
                  const SizedBox(height: 12),
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black87)), // ubah mode gelap
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: textGray, fontSize: 11)),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(color: primaryBrown, shape: BoxShape.circle),
                  child: const Icon(Icons.check, color: Colors.white, size: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}