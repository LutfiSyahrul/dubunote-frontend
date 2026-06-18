import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'success_screen.dart';
import '../../theme_manager.dart'; // ubah mode gelap

class TambahPengeluaranScreen extends StatefulWidget {
  final DateTime selectedDate;

  // Menerima data tanggal yang dipilih dari halaman sebelumnya
  const TambahPengeluaranScreen({super.key, required this.selectedDate});

  @override
  State<TambahPengeluaranScreen> createState() =>
      _TambahPengeluaranScreenState();
}

class _TambahPengeluaranScreenState extends State<TambahPengeluaranScreen> {
  // ubah mode gelap - warna dasar dinamis berdasarkan theme manager
  Color get bgBeige => ThemeColors.getBgBeige(isDarkModeNotifier.value); // ubah mode gelap
  Color get primaryBrown => ThemeColors.getPrimaryBrown(isDarkModeNotifier.value); // ubah mode gelap
  Color get textGray => ThemeColors.getSubTextColor(isDarkModeNotifier.value); // ubah mode gelap
  Color get cardBg => isDarkModeNotifier.value ? const Color(0xFF292524) : const Color(0xFFF5EFE9); // ubah mode gelap

  final TextEditingController _nominalController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();

  int _selectedCategoryId = 1; // Default ke Makan & Minuman
  bool _isLoading = false;

  // Simulasi ID Kategori (Pastikan urutan ID ini cocok dengan tabel 'kategori' di database kamu)
  final List<Map<String, dynamic>> _kategoriList = [
    {'id': 1, 'nama': 'Makan &\nMinuman', 'icon': Icons.restaurant},
    {'id': 2, 'nama': 'Transport', 'icon': Icons.directions_bus},
    {'id': 3, 'nama': 'Belanja', 'icon': Icons.shopping_bag_outlined},
    {'id': 4, 'nama': 'Lainnya', 'icon': Icons.more_horiz},
  ];

  final List<String> _namaBulan = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ];
  final List<String> _namaHari = [
    "Senin",
    "Selasa",
    "Rabu",
    "Kamis",
    "Jumat",
    "Sabtu",
    "Minggu",
  ];

  String _getFormattedDate() {
    String hari = _namaHari[widget.selectedDate.weekday - 1];
    String bulan = _namaBulan[widget.selectedDate.month - 1];
    return "$hari, ${widget.selectedDate.day} $bulan ${widget.selectedDate.year}";
  }

  // --- FUNGSI SIMPAN KE DATABASE ---
  Future<void> _simpanKeDatabase() async {
    String nominalText = _nominalController.text.replaceAll(
      '.',
      '',
    ); // Bersihkan titik jika ada
    if (nominalText.isEmpty || nominalText == '0') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nominal tidak boleh kosong!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      // Format tanggal untuk MySQL (YYYY-MM-DD)
      String tglDb =
          "${widget.selectedDate.year}-${widget.selectedDate.month.toString().padLeft(2, '0')}-${widget.selectedDate.day.toString().padLeft(2, '0')}";

      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/transaksi/tambah'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'pengguna_id': userId,
          'kategori_id': _selectedCategoryId,
          'jumlah': int.parse(nominalText),
          'keterangan': _catatanController.text.isEmpty
              ? 'Pengeluaran'
              : _catatanController.text,
          'tanggal_transaksi': tglDb,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        if (mounted) {
          // Tangkap ID Transaksi dari response JSON backend
          int newTransactionId = data['id_transaksi'] ?? 0;

          // Hapus form ini dan ganti dengan Success Screen, lempar ID-nya
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SuccessScreen(transactionId: newTransactionId),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['pesan']), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal terhubung ke server!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return Scaffold(
          backgroundColor: bgBeige,
          appBar: AppBar(
            backgroundColor: bgBeige,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: primaryBrown),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Tambahkan Pengeluaran',
              style: TextStyle(
                color: primaryBrown,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: false,
            titleSpacing: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // --- HEADER NOMINAL ---
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getFormattedDate(),
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54, // ubah mode gelap
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'TOTAL NOMINAL',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black45, // ubah mode gelap
                      fontSize: 10,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // --- INPUT NOMINAL BESAR ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Rp',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryBrown,
                      ),
                    ),
                    const SizedBox(width: 10),
                    IntrinsicWidth(
                      child: TextField(
                        controller: _nominalController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          fontSize: 55,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87, // ubah mode gelap
                        ),
                        // >>> TAMBAHKAN ONCHANGED INI <<<
                        onChanged: (value) {
                          String cleanText = value.replaceAll('.', '');
                          int? val = int.tryParse(cleanText);
                          if (val != null) {
                            String formatted = val.toString().replaceAllMapped(
                              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                              (Match m) => '${m[1]}.',
                            );
                            _nominalController.value = TextEditingValue(
                              text: formatted,
                              selection: TextSelection.collapsed(
                                offset: formatted.length,
                              ),
                            );
                          }
                        },
                        // ==============================
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: TextStyle(color: isDarkMode ? Colors.white24 : Colors.black26), // ubah mode gelap
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // --- PILIH KATEGORI ---
                Text(
                  'Kategori',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87, // ubah mode gelap
                  ),
                ),
                const SizedBox(height: 15),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _kategoriList.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemBuilder: (context, index) {
                    final cat = _kategoriList[index];
                    bool isSelected = _selectedCategoryId == cat['id'];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategoryId = cat['id']),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDarkMode ? const Color(0xFF3E302A) : const Color(0xFFF3DDC9)) // ubah mode gelap
                              : (isDarkMode ? const Color(0xFF292524) : Colors.white), // ubah mode gelap
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: isDarkMode ? Colors.transparent : Colors.black.withValues(alpha: 0.02), // ubah mode gelap
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              cat['icon'],
                              color: isSelected ? primaryBrown : (isDarkMode ? Colors.white70 : Colors.black54), // ubah mode gelap
                              size: 22,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              cat['nama'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected ? primaryBrown : (isDarkMode ? Colors.white70 : Colors.black54), // ubah mode gelap
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 35),

                // --- CATATAN ---
                Text(
                  'Catatan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87, // ubah mode gelap
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _catatanController,
                  maxLines: 3,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87, // ubah mode gelap
                  ),
                  decoration: InputDecoration(
                    hintText: 'Tambahkan catatan opsional di\nsini...',
                    hintStyle: TextStyle(color: isDarkMode ? Colors.white24 : Colors.black26, fontSize: 14), // ubah mode gelap
                    filled: true,
                    fillColor: isDarkMode ? const Color(0xFF292524) : const Color(0xFFF6F6F6), // ubah mode gelap
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // --- SAVING TIP ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: primaryBrown,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SAVING TIP',
                        style: TextStyle(
                          color: isDarkMode ? const Color(0xFF1C1917).withValues(alpha: 0.7) : Colors.white70, // ubah mode gelap
                          fontSize: 9,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getSavingTip(),
                        style: TextStyle(
                          color: isDarkMode ? const Color(0xFF1C1917) : Colors.white, // ubah mode gelap
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 120), // Spasi untuk tombol sticky di bawah
              ],
            ),
          ),

          // --- TOMBOL SIMPAN (STICKY DI BAWAH) ---
          bottomSheet: Container(
            color: bgBeige,
            padding: const EdgeInsets.only(
              left: 25,
              right: 25,
              bottom: 30,
              top: 10,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _simpanKeDatabase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBrown,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: isDarkMode ? const Color(0xFF1C1917) : Colors.white) // ubah mode gelap
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: isDarkMode ? const Color(0xFF1C1917) : Colors.white, // ubah mode gelap
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Simpan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? const Color(0xFF1C1917) : Colors.white, // ubah mode gelap
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
  // Fungsi Tips Dinamis berdasarkan Kategori
  String _getSavingTip() {
    switch (_selectedCategoryId) {
      case 1:
        return 'Makan di rumah menghemat rata-rata\ndan bisa lebih bergizi'; // Makan & Minum
      case 2:
        return 'Berbagi tumpangan (ride-sharing)\nbisa memotong ongkos hingga 50%.'; // Transport
      case 3:
        return 'Terapkan aturan tunggu 24 jam\nsebelum checkout keranjangmu.'; // Belanja
      default:
        return 'Menyisihkan 10% dari uangmu di\nawal bulan adalah kunci kebebasan.'; // Lainnya
    }
  }
}
