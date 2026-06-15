import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final Color bgBeige = const Color(0xFFFDFBF8);
  final Color primaryBrown = const Color(0xFF7A5B4C);

  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isObscureOld = true;
  bool _isObscureNew = true;
  bool _isObscureConfirm = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _ubahKataSandi() async {
    final oldPass = _oldPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    // 1. Validasi Input Kosong
    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Semua kolom harus diisi!'), backgroundColor: Colors.orange));
      return;
    }

    // 2. Validasi Konfirmasi Password
    if (newPass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Konfirmasi kata sandi baru tidak cocok!'), backgroundColor: Colors.red));
      return;
    }

    // 3. Validasi Panjang Password (Opsional)
    if (newPass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kata sandi baru minimal 6 karakter!'), backgroundColor: Colors.orange));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      final response = await http.put(
        Uri.parse('http://10.0.2.2:3000/api/pengguna/password/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'password_lama': oldPass,
          'password_baru': newPass,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kata sandi berhasil diubah!'), backgroundColor: Colors.green));
          Navigator.pop(context); // Kembali ke profil jika sukses
        }
      } else {
        // Menangkap pesan error dari Node.js (misal: "Kata sandi lama salah!")
        final errorData = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorData['message'] ?? 'Gagal mengubah kata sandi'), backgroundColor: Colors.red));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Terjadi kesalahan koneksi: $e'), backgroundColor: Colors.red));
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
          "Keamanan & Kata Sandi",
          style: TextStyle(color: primaryBrown, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Buat kata sandi yang kuat untuk menjaga keamanan data keuangan Anda.",
              style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
            ),
            const SizedBox(height: 32),

            // KATA SANDI LAMA
            Text("Kata Sandi Lama", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryBrown.withOpacity(0.7))),
            const SizedBox(height: 8),
            _buildPasswordField(
              controller: _oldPasswordController,
              hint: "Masukkan kata sandi lama",
              isObscure: _isObscureOld,
              onVisibilityToggle: () => setState(() => _isObscureOld = !_isObscureOld),
            ),
            const SizedBox(height: 24),

            // KATA SANDI BARU
            Text("Kata Sandi Baru", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryBrown.withOpacity(0.7))),
            const SizedBox(height: 8),
            _buildPasswordField(
              controller: _newPasswordController,
              hint: "Masukkan kata sandi baru",
              isObscure: _isObscureNew,
              onVisibilityToggle: () => setState(() => _isObscureNew = !_isObscureNew),
            ),
            const SizedBox(height: 24),

            // KONFIRMASI KATA SANDI BARU
            Text("Konfirmasi Kata Sandi Baru", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryBrown.withOpacity(0.7))),
            const SizedBox(height: 8),
            _buildPasswordField(
              controller: _confirmPasswordController,
              hint: "Ketik ulang kata sandi baru",
              isObscure: _isObscureConfirm,
              onVisibilityToggle: () => setState(() => _isObscureConfirm = !_isObscureConfirm),
            ),

            const SizedBox(height: 48),

            // TOMBOL SIMPAN
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _ubahKataSandi,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBrown,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : const Text("Perbarui Kata Sandi", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET KUSTOM UNTUK INPUT PASSWORD
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool isObscure,
    required VoidCallback onVisibilityToggle,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF1A1A1A)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
        prefixIcon: Icon(Icons.lock_outline, color: primaryBrown.withOpacity(0.7), size: 22),
        suffixIcon: IconButton(
          icon: Icon(isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.black38, size: 20),
          onPressed: onVisibilityToggle,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.05), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryBrown, width: 1.5),
        ),
      ),
    );
  }
}