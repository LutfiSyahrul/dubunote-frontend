import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ExpenseHistoryPage extends StatefulWidget {
  const ExpenseHistoryPage({super.key});

  @override
  State<ExpenseHistoryPage> createState() => _ExpenseHistoryPageState();
}

class _ExpenseHistoryPageState extends State<ExpenseHistoryPage> {
  final Color bgBeige = const Color(0xFFFDFBF8);
  final Color primaryBrown = const Color(0xFF7A5B4C);
  
  final TextEditingController _searchController = TextEditingController();
  String _selectedChip = "Semua";
  DateTime _currentDate = DateTime.now();
  
  bool _isLoading = true;
  int _totalBulanIni = 0;
  List<dynamic> _riwayatData = [];
  Map<String, List<dynamic>> _groupedData = {};

  @override
  void initState() {
    super.initState();
    _tarikDataRiwayat(); // Panggil data pertama kali dibuka
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- FUNGSI TARIK DATA DARI NODE.JS ---
  Future<void> _tarikDataRiwayat() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId != null) {
        final response = await http.post(
          Uri.parse('http://10.0.2.2:3000/api/transaksi/riwayat'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'pengguna_id': userId,
            'bulan': _currentDate.month,
            'tahun': _currentDate.year,
            'kategori': _selectedChip,
            'search': _searchController.text,
          }),
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          setState(() {
            _riwayatData = responseData['data'];
            
            // Hitung otomatis 
            _totalBulanIni = _riwayatData.fold<int>(0, (sum, item) => sum + (double.tryParse(item['jumlah'].toString())?.toInt() ?? 0));
            
            _kelompokkanData();
          });
        }
      }
    } catch (e) {
      debugPrint("Gagal menarik data riwayat: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Fungsi untuk mengelompokkan transaksi berdasarkan tanggal
  void _kelompokkanData() {
    _groupedData.clear();
    List<String> namaBulan = ["Jan", "Feb", "Mar", "Apr", "Mei", "Jun", "Jul", "Agt", "Sep", "Okt", "Nov", "Des"];
    
    for (var item in _riwayatData) {
      DateTime tgl = DateTime.parse(item['tanggal_transaksi']).toLocal();
      DateTime now = DateTime.now();
      
      String key;
      if (tgl.year == now.year && tgl.month == now.month && tgl.day == now.day) {
        key = "Hari ini, ${namaBulan[tgl.month - 1]} ${tgl.day}";
      } else if (tgl.year == now.year && tgl.month == now.month && tgl.day == now.day - 1) {
        key = "Kemarin, ${namaBulan[tgl.month - 1]} ${tgl.day}";
      } else {
        key = "${tgl.day} ${namaBulan[tgl.month - 1]} ${tgl.year}";
      }

      if (!_groupedData.containsKey(key)) {
        _groupedData[key] = [];
      }
      _groupedData[key]!.add(item);
    }
  }

  String _formatRupiah(int angka) {
    return angka.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  IconData _getKategoriIcon(String kategori) {
    switch (kategori) {
      case 'Makanan & Minuman': return Icons.restaurant;
      case 'Transport': return Icons.directions_car_filled_outlined;
      case 'Belanja': return Icons.local_mall_outlined;
      default: return Icons.receipt_long_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> listBulan = ["Januari", "Februari", "Maret", "April", "Mei", "Juni", "Juli", "Agustus", "September", "Oktober", "November", "Desember"];
    
    return Scaffold(
      backgroundColor: bgBeige,
      appBar: AppBar(
        backgroundColor: bgBeige,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryBrown),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Riwayat Pengeluaran", style: TextStyle(color: primaryBrown, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER TETAP DI ATAS ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
              child: Column(
                children: [
                  // SELEKTOR BULAN 
                  Center(
                    child: PopupMenuButton<int>(
                      initialValue: _currentDate.month,
                      onSelected: (int bulanDipilih) {
                        setState(() {
                          // Ubah bulan sesuai yang dipilih tanpa merubah tahun
                          _currentDate = DateTime(_currentDate.year, bulanDipilih, 1);
                        });
                        // Langsung filter ulang data ke backend
                        _tarikDataRiwayat();
                      },
                      itemBuilder: (BuildContext context) {
                        return List.generate(12, (index) {
                          return PopupMenuItem<int>(
                            value: index + 1,
                            child: Text(listBulan[index]),
                          );
                        });
                      },
                      // Tampilan tombolnya tetap konsisten dengan desain lama
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "${listBulan[_currentDate.month - 1]} ${_currentDate.year}",
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            const SizedBox(width: 5),
                            Icon(Icons.keyboard_arrow_down, color: primaryBrown, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // B. KARTU TOTAL PENGELUARAN BULAN INI (VERSI BERSIH MINIMALIS)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 15,
                      spreadRadius: 1,
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "TOTAL PENGELUARAN BULAN INI",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Rp ${_formatRupiah(_totalBulanIni)}",
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E), letterSpacing: -0.5),
                    ),
                  ],
                ),
              ),
                  const SizedBox(height: 20),
                  
                 //  KOLOM PENCARIAN (LIVE SEARCH)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      borderRadius: BorderRadius.circular(20), 
                      border: Border.all(color: Colors.grey.shade200)
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      
                      // Filter otomatis setiap ngetik
                      onChanged: (value) {
                        _tarikDataRiwayat(); 
                      },
                      onSubmitted: (value) => _tarikDataRiwayat(), // tarik data dari riwayat saat submit (enter)
                      
                      decoration: InputDecoration(
                        hintText: "Cari transaksi...",
                        hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.7), fontSize: 14),
                        prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 22),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip("Semua"), const SizedBox(width: 8),
                        _buildFilterChip("Makanan & Minuman"), const SizedBox(width: 8),
                        _buildFilterChip("Transport"), const SizedBox(width: 8),
                        _buildFilterChip("Belanja"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // --- LIST VIEW UNTUK DATA DINAMIS ---
            Expanded(
              child: _isLoading 
                ? Center(child: CircularProgressIndicator(color: primaryBrown))
                : _riwayatData.isEmpty
                  ? const Center(child: Text("Tidak ada transaksi.", style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
                      itemCount: _groupedData.keys.length,
                      itemBuilder: (context, index) {
                        String tanggalKey = _groupedData.keys.elementAt(index);
                        List<dynamic> transaksiHariIni = _groupedData[tanggalKey]!;
                        
                        // Hitung total harian menggunakan fold (mulai dari 0)
                        int totalHarian = transaksiHariIni.fold<int>(0, (sum, item) => sum + (double.tryParse(item['jumlah'].toString())?.toInt() ?? 0));

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(tanggalKey, "Rp ${_formatRupiah(totalHarian)}"),
                            const SizedBox(height: 15),
                            ...transaksiHariIni.map((trx) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: _buildHistoryCard(
                                  icon: _getKategoriIcon(trx['nama_kategori'] ?? 'Lainnya'),
                                  title: trx['keterangan'] ?? 'Transaksi',
                                  time: trx['tanggal_transaksi'].toString().substring(11, 16), // Ambil jam saja
                                  amount: "-Rp ${_formatRupiah(double.tryParse(trx['jumlah'].toString())?.toInt() ?? 0)}",
                                ),
                              );
                            }),
                            const SizedBox(height: 20),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET PEMBANTU ---
  Widget _buildSectionHeader(String dateText, String dayTotal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(dateText, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
        Text(dayTotal, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
      ],
    );
  }

  Widget _buildFilterChip(String title) {
    final bool isSelected = _selectedChip == title;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedChip = title);
        _tarikDataRiwayat(); // Langsung reload data saat kategori diklik
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? primaryBrown : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade300),
        ),
        child: Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black54)),
      ),
    );
  }

  Widget _buildHistoryCard({required IconData icon, required String title, required String time, required String amount}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20.0), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, spreadRadius: 1)],
      ),
      child: Row(
        children: [
          Container(width: 46, height: 46, decoration: const BoxDecoration(color: Color(0xFFF3DDC9), shape: BoxShape.circle), child: Icon(icon, color: primaryBrown, size: 22)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 4),
                Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Text(amount, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }
}