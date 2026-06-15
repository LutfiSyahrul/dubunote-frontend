import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../widgets/page_transitions.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isObscure = true;
  bool _isLoading = false;

  // Controller untuk menangkap teks yang diketik user
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // ====================================================================
  // LOGIKA BACKEND (TIDAK DIUBAH SAMA SEKALI, SUDAH TERKONEKSI)
  // ====================================================================
  Future<void> _daftarAkun() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/auth/daftar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nama': _namaController.text,
          'email': _emailController.text,
          'kata_sandi': _passwordController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['pesan']),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacement(context, createRoute(const LoginScreen()));
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
            content: Text(
              'Gagal terhubung ke server! Pastikan Node.js menyala.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ====================================================================
  // TAMPILAN UI (100% DISESUAIKAN DENGAN DESAIN FIGMA TERBARU)
  // ====================================================================
  @override
  Widget build(BuildContext context) {
    const Color bgBeige = Color(0xFFFDFBF8); // Latar belakang krem sangat muda
    const Color primaryBrown = Color(0xFF7A5B4C); // Cokelat utama
    const Color inputBgColor = Color(
      0xFFF3F1EC,
    ); // Abu-abu krem untuk kotak input
    const Color textGray = Color(0xFF6B7280); // Abu-abu teks
    const Color iconColor = Color(0xFFC4B5A5); // Cokelat pudar untuk icon form

    return Scaffold(
      backgroundColor: bgBeige,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),

              // --- BRAND DUBUNOTE (Hanya teks sesuai desain) ---
              const Text(
                'DubuNote',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: primaryBrown,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 35),

              // --- HEADER TITLE ---
              const Text(
                'Buat Akun Baru',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Mulai langkah cerdas mengelola keuangan\nhari ini.',
                style: TextStyle(color: textGray, fontSize: 15, height: 1.5),
              ),
              const SizedBox(height: 35),

              // --- FORM NAMA LENGKAP ---
              _buildInputLabel('Nama Lengkap', textGray),
              _buildTextField(
                hint: 'Masukkan nama lengkap Anda',
                icon: Icons.person_outline,
                controller: _namaController,
                inputBgColor: inputBgColor,
                iconColor: iconColor,
              ),
              const SizedBox(height: 20),

              // --- FORM EMAIL ---
              _buildInputLabel('Email', textGray),
              _buildTextField(
                hint: 'nama@email.com',
                icon: Icons.email_outlined,
                controller: _emailController,
                inputBgColor: inputBgColor,
                iconColor: iconColor,
              ),
              const SizedBox(height: 20),

              // --- FORM PASSWORD ---
              _buildInputLabel('Password', textGray),
              _buildTextField(
                hint: 'Buat password yang kuat',
                icon: Icons.lock_outline,
                isPass: true,
                obscure: _isObscure,
                controller: _passwordController,
                inputBgColor: inputBgColor,
                iconColor: iconColor,
                onToggle: () => setState(() => _isObscure = !_isObscure),
              ),
              const SizedBox(height: 35),

              // --- TOMBOL DAFTAR ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _daftarAkun,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBrown,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Daftar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 18,
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 30),

              // --- PEMBATAS SOCIAL LOGIN ---
              const Center(
                child: Text(
                  'Daftar instan dengan',
                  style: TextStyle(color: textGray, fontSize: 13),
                ),
              ),
              const SizedBox(height: 20),

              // --- SOCIAL LOGIN (Disusun Atas-Bawah Sesuai Desain Baru) ---
              _buildFullWidthSocialBtn(
                'Google',
                Icons.g_mobiledata,
              ), // Ganti Icons.g_mobiledata dengan image asset jika kamu punya icon asli Google
              const SizedBox(height: 15),
              _buildFullWidthSocialBtn('Apple', Icons.apple),

              const SizedBox(height: 35),

              // --- NAVIGASI KE LOGIN ---
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pushReplacement(
                    context,
                    createRoute(const LoginScreen()),
                  ),
                  child: RichText(
                    text: const TextSpan(
                      text: 'Sudah punya akun? ',
                      style: TextStyle(color: textGray, fontSize: 14),
                      children: [
                        TextSpan(
                          text: 'Masuk',
                          style: TextStyle(
                            color: primaryBrown,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 35),

              // --- SYARAT & KETENTUAN ---
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      text: 'Dengan mendaftar, Anda menyetujui ',
                      style: TextStyle(
                        color: textGray,
                        fontSize: 11,
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(
                          text: 'Syarat &\nKetentuan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: primaryBrown,
                          ),
                        ),
                        TextSpan(text: ' serta '),
                        TextSpan(
                          text: 'Kebijakan Privasi',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: primaryBrown,
                          ),
                        ),
                        TextSpan(text: ' kami.'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET PEMBANTU ---

  Widget _buildInputLabel(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: color,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    bool isPass = false,
    bool obscure = false,
    VoidCallback? onToggle,
    required TextEditingController controller,
    required Color inputBgColor,
    required Color iconColor,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPass ? obscure : false,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
        prefixIcon: Icon(icon, color: iconColor, size: 22),
        suffixIcon: isPass
            ? IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: iconColor,
                  size: 20,
                ),
                onPressed: onToggle,
              )
            : null,
        filled: true,
        fillColor: inputBgColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildFullWidthSocialBtn(String label, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30), // Pill shape
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: Colors.black87),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
