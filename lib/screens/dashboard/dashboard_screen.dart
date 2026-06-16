import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../riwayat/expense_history_page.dart';
import '../bulan/bulan_screen.dart';
import '../profile/profile_screen.dart';
import '../../theme_manager.dart'; // ubah mode gelap

class DashboardScreen extends StatefulWidget {
  final Function(int)? onTabChanged; // 1.variabel callback ini
  const DashboardScreen({super.key, this.onTabChanged}); 

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // ubah mode gelap - warna dasar menggunakan theme manager global
  Color get bgBeige => ThemeColors.getBgBeige(isDarkModeNotifier.value);
  Color get primaryBrown => ThemeColors.getPrimaryBrown(isDarkModeNotifier.value);
  Color get textDark => ThemeColors.getTextColor(isDarkModeNotifier.value);
  Color get textGray => ThemeColors.getSubTextColor(isDarkModeNotifier.value);

  // --- VARIABEL DINAMIS ---
  bool _isLoading = true;
  String _bulanTahun = "Memuat...";
  int _totalPengeluaran = 0;
  List<dynamic> _aktivitasTerkini = [];
  
  // Variabel baru untuk Grafik
  List<double> _grafikPengeluaran = [];
  String _labelAwalBulan = "OCT 1";
  String _labelAkhirBulan = "OCT 31";

  @override
  void initState() {
    super.initState();
    _initDataDinamis();
  }

  // --- FUNGSI MENGAMBIL DATA DARI BACKEND ---
  Future<void> _initDataDinamis() async {
    _setBulanTahunOtomatis();
    await _tarikDataDariNode();
  }

  void _setBulanTahunOtomatis() {
    List<String> namaBulan = ["Januari", "Februari", "Maret", "April", "Mei", "Juni", "Juli", "Agustus", "September", "Oktober", "November", "Desember"];
    List<String> namaBulanSingkat = ["Jan", "Feb", "Mar", "Apr", "Mei", "Jun", "Jul", "Agt", "Sep", "Okt", "Nov", "Des"];
    
    DateTime now = DateTime.now();
    int daysInMonth = DateTime(now.year, now.month + 1, 0).day; // Mencari jumlah hari bulan ini
    
    setState(() {
      _bulanTahun = "${namaBulan[now.month - 1]} ${now.year}";
      _labelAwalBulan = "${namaBulanSingkat[now.month - 1].toUpperCase()} 1";
      _labelAkhirBulan = "${namaBulanSingkat[now.month - 1].toUpperCase()} $daysInMonth";
      _grafikPengeluaran = List.filled(daysInMonth, 0.0); // Menyiapkan wadah batang grafik sebanyak jumlah hari
    });
  }

  Future<void> _tarikDataDariNode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId != null) {
        // 1. Tarik Summary & Grafik
        DateTime now = DateTime.now(); // Ambil waktu HP sekarang
        final resSummary = await http.get(Uri.parse('http://10.0.2.2:3000/api/transaksi/summary/$userId?bulan=${now.month}&tahun=${now.year}'));

        if (resSummary.statusCode == 200) {

          final dataSummary = jsonDecode(resSummary.body);
          _totalPengeluaran = double.tryParse(dataSummary['total_pengeluaran'].toString())?.toInt() ?? 0;

          // Memasukkan data transaksi harian ke dalam wadah grafik
          if (dataSummary['grafik_harian'] != null) {
            List<dynamic> grafikData = dataSummary['grafik_harian'];
            for (var item in grafikData) {
               int tgl = int.tryParse(item['tanggal'].toString()) ?? 1;
               double total = double.tryParse(item['total'].toString()) ?? 0.0;
               if (tgl >= 1 && tgl <= _grafikPengeluaran.length) {
                  _grafikPengeluaran[tgl - 1] = total;
               }
            }
          }
        }

        // 2. Tarik Aktivitas Terkini
        final resAktivitas = await http.get(Uri.parse('http://10.0.2.2:3000/api/transaksi/terkini/$userId'));
        if (resAktivitas.statusCode == 200) {
          _aktivitasTerkini = jsonDecode(resAktivitas.body);
        }
      }
    } catch (e) {
      debugPrint("Gagal narik data: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Fungsi mengubah angka 1200000 jadi 1.200.000
  String _formatRupiah(int angka) {
    return angka.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  // TAMPILAN UI (TIDAK ADA DESAIN YANG BERUBAH)
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
              // PULL-TO-REFRESH 
              : RefreshIndicator(
                  onRefresh: _initDataDinamis, // Memanggil ulang fungsi pengambilan data
                  color: primaryBrown,
                  backgroundColor: isDarkMode ? const Color(0xFF292524) : Colors.white, // ubah mode gelap
                  child: SingleChildScrollView(
                    // physics ini WAJIB agar layar tetap bisa ditarik ke bawah walau transaksinya masih kosong
                    physics: const AlwaysScrollableScrollPhysics(), 
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCalendarCard(),
                        const SizedBox(height: 20),
                        _buildSummaryCard(),
                        const SizedBox(height: 25),
                        _buildActivityHeader(),
                        const SizedBox(height: 15),

                        // LOOPING AKTIVITAS TERKINI DARI DATABASE
                        if (_aktivitasTerkini.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                "Belum ada transaksi bulan ini",
                                style: TextStyle(color: isDarkMode ? Colors.white38 : Colors.black38), // ubah mode gelap
                              ),
                            ),
                          )
                        else
                          ..._aktivitasTerkini.map((item) {
                            int jumlahUang = double.tryParse(item['jumlah'].toString())?.toInt() ?? 0;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 15),
                              child: _buildActivityItem(
                                title: item['keterangan'] ?? 'Transaksi',
                                subtitle:
                                    '${item['nama_kategori'] ?? 'Lainnya'} • ${item['tanggal_transaksi'].toString().substring(0, 10)}',
                                amount: '-Rp ${_formatRupiah(jumlahUang)}',
                                status: 'SUCCESS', 
                                iconData: Icons.receipt_long, 
                                iconBgColor: isDarkMode ? const Color(0xFF3E3A36) : const Color(0xFFF3DDC9), // ubah mode gelap
                                iconColor: primaryBrown,
                              ),
                            );
                          }),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
          // BAGIAN FLOATING ACTION BUTTON 
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // Jika fungsi pemindah tab ada, perintahkan pindah ke indeks 1 (Tab Bulan)
              if (widget.onTabChanged != null) {
                widget.onTabChanged!(1); 
              }
            },
            backgroundColor: primaryBrown,
            elevation: 4,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: Colors.white, size: 30),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      }
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: bgBeige,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'DubuNote',
        style: TextStyle(
          color: primaryBrown,
          fontWeight: FontWeight.bold,
          fontSize: 22,
          letterSpacing: -0.5,
        ),
      ),
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

  Widget _buildActivityHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Aktivitas Terkini', style: TextStyle(color: primaryBrown, fontSize: 18, fontWeight: FontWeight.bold)),
      
        GestureDetector(
          onTap: () {
            // Pindah halaman, dan JIKA BALIK LAGI, langsung refresh data Beranda!
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ExpenseHistoryPage()),
            ).then((_) => _initDataDinamis()); 
          },
          child: Text(
            'Lihat semua', 
            style: TextStyle(color: primaryBrown.withValues(alpha: 0.7), fontSize: 13, fontWeight: FontWeight.w600)
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarCard() {
    final isDark = isDarkModeNotifier.value; // ubah mode gelap
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF292524) : Colors.white, // ubah mode gelap
        borderRadius: BorderRadius.circular(25),
        boxShadow: isDark ? [] : [ // ubah mode gelap
          BoxShadow(
            color: Colors.black.withValues(alpha:0.03),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Pastikan teks rata kiri
        children: [
          // >>> PANAH KIRI KANAN SUDAH DIHAPUS, TERSISA TEKS BULAN SAJA <<<
          Text(
            _bulanTahun,
            style: TextStyle(
              color: primaryBrown,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 20),
          // Memanggil fungsi pembuat kalender dinamis
          Table(children: _generateDynamicCalendar()),
        ],
      ),
    );
  }

  // LOGIKA KALENDER REAL-TIME (SUNDAY START) ---
  List<TableRow> _generateDynamicCalendar() {
    List<TableRow> rows = [];
    DateTime now = DateTime.now();
    int currentDay = now.day;
    int daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    int firstWeekday = DateTime(now.year, now.month, 1).weekday; // 1 = Senin, 7 = Minggu
    int daysInPrevMonth = DateTime(now.year, now.month, 0).day;

    // 1. Masukkan Header Hari Dimulai dari MIN (Minggu)
    rows.add(
      TableRow(
        children: ['MIN', 'SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB'].map((day) => Center(
          child: Text(day, style: const TextStyle(color: Color(0xFFC4B5A5), fontSize: 10, fontWeight: FontWeight.bold))
        )).toList(),
      )
    );

    List<String> currentRowDays = [];
    List<bool> currentRowFaded = [];

    // Hitung sisa hari dari bulan lalu berdasarkan urutan Minggu - Sabtu
    int paddingDays = firstWeekday == 7 ? 0 : firstWeekday;

    // 2. Isi tanggal sisa dari bulan sebelumnya (Faded)
    for (int i = paddingDays; i > 0; i--) {
      currentRowDays.add((daysInPrevMonth - i + 1).toString());
      currentRowFaded.add(true);
    }

    // 3. Isi tanggal bulan ini
    for (int i = 1; i <= daysInMonth; i++) {
      currentRowDays.add(i.toString());
      currentRowFaded.add(false);

      // Jika baris sudah penuh 7 hari (sampai hari Sabtu), masukkan ke tabel
      if (currentRowDays.length == 7) {
        rows.add(const TableRow(children: [SizedBox(height: 15), SizedBox(), SizedBox(), SizedBox(), SizedBox(), SizedBox(), SizedBox()]));
        rows.add(_buildDynamicCalendarRow(currentRowDays, currentRowFaded, currentDay.toString()));
        currentRowDays = [];
        currentRowFaded = [];
      }
    }

    // 4. Isi tanggal awal bulan berikutnya jika baris terakhir belum penuh
    if (currentRowDays.isNotEmpty) {
      int nextMonthDay = 1;
      while (currentRowDays.length < 7) {
        currentRowDays.add(nextMonthDay.toString());
        currentRowFaded.add(true);
        nextMonthDay++;
      }
      rows.add(const TableRow(children: [SizedBox(height: 15), SizedBox(), SizedBox(), SizedBox(), SizedBox(), SizedBox(), SizedBox()]));
      rows.add(_buildDynamicCalendarRow(currentRowDays, currentRowFaded, currentDay.toString()));
    }

    return rows;
  }

  // --- PEMBUAT BARIS KALENDER ---
  TableRow _buildDynamicCalendarRow(
    List<String> days,
    List<bool> isFadedList,
    String activeDay,
  ) {
    return TableRow(
      children: List.generate(days.length, (index) {
        String day = days[index];
        bool isFaded = isFadedList[index];
        // Tanggal hanya aktif/dibundel JIKA angkanya cocok dengan hari ini DAN dia bukan tanggal pudar dari bulan lain
        bool isActive = (day == activeDay) && !isFaded;

        return Center(
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: isActive
                ? BoxDecoration(color: primaryBrown, shape: BoxShape.circle)
                : null,
            child: Text(
              day,
              style: TextStyle(
                color: isActive
                    ? Colors.white
                    : (isFaded ? (isDarkModeNotifier.value ? Colors.white24 : Colors.black26) : (isDarkModeNotifier.value ? Colors.white70 : Colors.black87)), // ubah mode gelap
                fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: primaryBrown, borderRadius: BorderRadius.circular(30)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('TOTAL PENGELUARAN BULAN INI', style: TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w600)),
          const SizedBox(height: 5),
          RichText(
            text: TextSpan(
              children: [
                const TextSpan(text: 'Rp ', style: TextStyle(color: Colors.white70, fontSize: 16)),
                TextSpan(
                  text: _formatRupiah(_totalPengeluaran),
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          
          // --- GRAFIK DINAMIS CERDAS ---
          LayoutBuilder(
            builder: (context, constraints) {
              // 1. Logika Proporsi Otomatis (Cari nilai tertinggi bulan ini)
              double maxPengeluaran = 0.0; 
              for (double val in _grafikPengeluaran) {
                if (val > maxPengeluaran) maxPengeluaran = val;
              }
              
              double maxBarHeight = 50.0; // Batas tinggi maksimal atap grafik

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                
                // .asMap().entries.map digunakan agar kita tahu indeks (tanggal) ke-berapa tiang ini
                children: _grafikPengeluaran.asMap().entries.map((entry) {
                  int index = entry.key;
                  double val = entry.value;
                  
                  // 2. Hitung proporsi tinggi
                  double height = 0;
                  if (maxPengeluaran > 0) {
                    height = (val / maxPengeluaran) * maxBarHeight;
                  }
                  
                  // 3. Logika Estetika (Fallback): Jika 0, beri tinggi minimal 3px
                  if (height < 3) height = 3; 
                  
                  // 4. Logika Highlight: Cek apakah tiang ini adalah "Tanggal Hari Ini"
                  bool isToday = (index + 1) == DateTime.now().day;
                  
                  return _buildBar(height, isToday);
                }).toList(),
              );
            }
          ),
          const SizedBox(height: 10),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_labelAwalBulan, style: const TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold)),
              const Text('SPENDING TREND', style: TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
              Text(_labelAkhirBulan, style: const TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double height, bool isToday) {
    return Container(
      width: 6, // Ukuran ideal agar 31 hari muat di layar
      height: height,
      decoration: BoxDecoration(
        // JIKA HARI INI: Putih tebal & menyala. JIKA HARI LAIN: Agak redup (Transparan)
        color: isToday ? Colors.white : Colors.white.withValues(alpha: 0.25),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(5), 
          topRight: Radius.circular(5)
        ),
      ),
    );
  }

  Widget _buildActivityItem({
    required String title,
    required String subtitle,
    required String amount,
    required String status,
    required IconData iconData,
    required Color iconBgColor,
    required Color iconColor,
  }) {
    final isDark = isDarkModeNotifier.value; // ubah mode gelap
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF292524) : Colors.white, // ubah mode gelap
        borderRadius: BorderRadius.circular(15),
        boxShadow: isDark ? [] : [ // ubah mode gelap
          BoxShadow(
            color: Colors.black.withValues(alpha:0.02),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: iconColor, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87, // ubah mode gelap
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: textGray, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black87, // ubah mode gelap
                ),
              ),
              const SizedBox(height: 4),
              Text(
                status,
                style: TextStyle(
                  color: primaryBrown,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
