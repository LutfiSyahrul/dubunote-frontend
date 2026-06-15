import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final Color bgBeige = const Color(0xFFFDFBF8);
  final Color primaryBrown = const Color(0xFF7A5B4C);
  
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  
  bool _isLoadingData = true;
  bool _isSaving = false;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // --- MENGAMBIL DATA DARI NODE.JS ---
  Future<void> _fetchUserData() async {
    setState(() => _isLoadingData = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getInt('user_id');

      if (_userId != null) {
        final response = await http.get(Uri.parse('http://10.0.2.2:3000/api/pengguna/$_userId'));
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() {
            _namaController.text = data['nama'] ?? "";
            _emailController.text = data['email'] ?? "";
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memuat koneksi: $e'), backgroundColor: Colors.red));
      }
    } finally {
      setState(() => _isLoadingData = false);
    }
  }

  // --- MENYIMPAN PERUBAHAN KE NODE.JS ---
  Future<void> _simpanPerubahan() async {
    // Validasi form kosong
    if (_namaController.text.trim().isEmpty || _emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama dan Email tidak boleh kosong!'), backgroundColor: Colors.orange));
      return;
    }

    setState(() => _isSaving = true);
    
    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:3000/api/pengguna/$_userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nama': _namaController.text.trim(),
          'email': _emailController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil berhasil diperbarui!'), backgroundColor: Colors.green));
          // Kembali ke halaman sebelumnya dan kirim sinyal 'true' agar halaman Profil ikut refresh
          Navigator.pop(context, true); 
        }
      } else {
        throw Exception("Gagal menyimpan data");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e'), backgroundColor: Colors.red));
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          "Detail Personal",
          style: TextStyle(color: primaryBrown, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      // --- REFRESH INDICATOR UNTUK PULL-TO-REFRESH ---
      body: RefreshIndicator(
        color: primaryBrown,
        backgroundColor: Colors.white,
        onRefresh: _fetchUserData,
        child: _isLoadingData
            ? Center(child: CircularProgressIndicator(color: primaryBrown))
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(), // Wajib agar RefreshIndicator bisa ditarik walau konten sedikit
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // FOTO PROFIL (Hanya Visual)
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFF3DDC9),
                              image: const DecorationImage(
                                image: AssetImage('assets/images/user_profil.jpg'), // Pastikan gambarnya ada
                                fit: BoxFit.cover,
                              ),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5)),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: primaryBrown,
                                shape: BoxShape.circle,
                                border: Border.all(color: bgBeige, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // FORM NAMA
                    Text("Nama Lengkap", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryBrown.withValues(alpha: 0.7))),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _namaController,
                      icon: Icons.person_outline,
                      hint: "Masukkan nama lengkap Anda",
                    ),
                    const SizedBox(height: 24),

                    // FORM EMAIL
                    Text("Alamat Email", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryBrown.withValues(alpha: 0.7))),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _emailController,
                      icon: Icons.email_outlined,
                      hint: "Masukkan alamat email Anda",
                      inputType: TextInputType.emailAddress,
                    ),
                    
                    const SizedBox(height: 48),

                    // TOMBOL SIMPAN
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _simpanPerubahan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBrown,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: _isSaving
                            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                            : const Text("Simpan Perubahan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                      ),
                    ),
                    // Ruang ekstra di bawah agar RefreshIndicator lebih nyaman ditarik
                    const SizedBox(height: 100), 
                  ],
                ),
              ),
      ),
    );
  }

  // WIDGET KUSTOM UNTUK INPUT TEXT
  Widget _buildTextField({required TextEditingController controller, required IconData icon, required String hint, TextInputType inputType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF1A1A1A)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.black.withValues(alpha: 0.3)),
        prefixIcon: Icon(icon, color: primaryBrown.withValues(alpha: 0.7), size: 22),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.05), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryBrown, width: 1.5),
        ),
      ),
    );
  }
}