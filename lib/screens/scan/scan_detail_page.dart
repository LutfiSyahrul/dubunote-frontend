import 'dart:io';
import 'dart:convert'; 
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; 
import 'package:shared_preferences/shared_preferences.dart';

class ScanDetailPage extends StatefulWidget {
  final Map<String, dynamic>? scannedData; // Menerima data JSON dari layar Scan
  final String? localImagePath; // Path gambar yang difoto untuk ditampilkan di thumbnail

  const ScanDetailPage({super.key, this.scannedData, this.localImagePath});

  @override
  State<ScanDetailPage> createState() => _ScanDetailPageState();
}

class _ScanDetailPageState extends State<ScanDetailPage> {
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _storeController = TextEditingController();
  final TextEditingController _noteController = TextEditingController(text: "Scan Otomatis");
  String _selectedCategory = "Makanan";

  @override
  void initState() {
    super.initState();
    // Tarik data dari Node.js dan isikan otomatis ke dalam form!
    if (widget.scannedData != null) {
      final dataTerurai = widget.scannedData!['data_terurai'];
      _priceController.text = dataTerurai['total_harga'].toString();
      _storeController.text = dataTerurai['toko'] ?? "";
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _storeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text("DubuNote", style: TextStyle(color: Color(0xFF6F4627), fontWeight: FontWeight.bold, fontSize: 22)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Tinjau Detail", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
              const SizedBox(height: 8),
              Text("Periksa kembali detail struk yang telah Anda pindai sebelum menyimpannya.", style: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.48), height: 1.4)),
              const SizedBox(height: 24),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24.0),
                    child: widget.localImagePath != null
                        ? Image.file(File(widget.localImagePath!), width: 80, height: 80, fit: BoxFit.cover)
                        : Container(width: 80, height: 80, color: Colors.black12, child: const Icon(Icons.image, color: Colors.black38)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(color: const Color(0xFFF4DBC9).withOpacity(0.4), borderRadius: BorderRadius.circular(20)),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("STATUS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF6F4627).withOpacity(0.6), letterSpacing: 0.5)),
                            const SizedBox(height: 2),
                            const Text("Scan Berhasil", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF6F4627))),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.check_circle_outline, size: 14, color: Color(0xFF6F4627)),
                                const SizedBox(width: 4),
                                Text("AI mengekstrak data.", style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.5))),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 28),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(24.0),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("TOTAL HARGA", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black.withOpacity(0.4), letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text("RP ", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF6F4627))),
                        Expanded(
                          child: TextField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A), letterSpacing: -0.5),
                            decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Text("NAMA TOKO", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black.withOpacity(0.4), letterSpacing: 0.5)),
              const SizedBox(height: 8),
              TextField(
                controller: _storeController,
                decoration: InputDecoration(
                  filled: true, fillColor: const Color(0xFFF0F0F0).withOpacity(0.6),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),

              const SizedBox(height: 20),
              Text("KETERANGAN", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black.withOpacity(0.4), letterSpacing: 0.5)),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  filled: true, fillColor: const Color(0xFFF0F0F0).withOpacity(0.6),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),

              const SizedBox(height: 24),
              Text("KATEGORI", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black.withOpacity(0.4), letterSpacing: 0.5)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10, runSpacing: 10,
                children: [
                  _buildCategoryChip("Makanan", Icons.restaurant),
                  _buildCategoryChip("Transportasi", Icons.directions_car_filled_outlined),
                  _buildCategoryChip("Belanja", Icons.local_mall_outlined),
                  _buildCategoryChip("Lainnya", Icons.more_horiz),
                ],
              ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity, height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6F4627), foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)), elevation: 0,
                  ),

                  // simpat data dari node js ke db mysql melalui api node js
                  onPressed: () async {
                  // 1. Tampilkan loading
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFF6F4627))),
  );

  try {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');

    if (userId == null) {
      Navigator.pop(context); // Tutup loading
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sesi habis, silakan login ulang.')));
      return;
    }

    // 2. Mapping Kategori Teks menjadi ID Kategori (Sesuaikan dengan ID di Database MySQL kamu)
    int kategoriId = 4; // Default "Lainnya"
    if (_selectedCategory == "Makanan") kategoriId = 1;
    else if (_selectedCategory == "Transportasi") kategoriId = 2;
    else if (_selectedCategory == "Belanja") kategoriId = 3;

    // 3. Gabungkan nama toko dan keterangan (kalau ada)
    String keteranganLengkap = _storeController.text.trim();
    if (_noteController.text.isNotEmpty) {
      keteranganLengkap += " - ${_noteController.text.trim()}";
    }

    // 4. Buat Tanggal Hari Ini (Format: YYYY-MM-DD)
    final sekarang = DateTime.now();
    final tanggalTransaksi = "${sekarang.year}-${sekarang.month.toString().padLeft(2, '0')}-${sekarang.day.toString().padLeft(2, '0')}";

    // 5. Kirim HTTP POST ke Node.js
    final response = await http.post(
      Uri.parse('http://10.0.2.2:3000/api/transaksi/tambah'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'pengguna_id': userId,
        'kategori_id': kategoriId,
        'jumlah': int.tryParse(_priceController.text) ?? 0,
        'keterangan': keteranganLengkap.isEmpty ? 'Scan Nota Otomatis' : keteranganLengkap,
        'tanggal_transaksi': tanggalTransaksi
      }),
    );

    if (!mounted) return;
    Navigator.pop(context); // Tutup loading

    if (response.statusCode == 201) {
      // BERHASIL SIMPAN!
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi berhasil disimpan!'), backgroundColor: Colors.green)
      );
      // Kembali ke beranda dan refresh datanya
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } else {
      final jsonResponse = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(jsonResponse['pesan'] ?? 'Gagal menyimpan')));
    }
  } catch (e) {
    if (mounted) {
      Navigator.pop(context); // Tutup loading
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Terjadi kesalahan koneksi')));
    }
  }
},

                  child: const Text("Kirim", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String title, IconData icon) {
    final bool isSelected = _selectedCategory == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(color: isSelected ? const Color(0xFF6F4627) : const Color(0xFFEFEFEF), borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.black54),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black54)),
          ],
        ),
      ),
    );
  }
}