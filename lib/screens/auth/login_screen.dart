import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../widgets/page_transitions.dart';
import 'register_screen.dart';
import '../main_layout.dart'; // Import ini di atas login_screen.dart


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isObscure = true;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _masukAkun() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text,
          'kata_sandi': _passwordController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // 1. Simpan memori DULU (sebelum ngecek layar)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_id', data['pengguna']['id']);

        // 2. BARU cek apakah layar masih aktif (mounted)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['pesan']),
              backgroundColor: Colors.green,
            ),
          );

          // Langsung pindah halaman tanpa ada jeda proses async lagi di sini
          Navigator.pushReplacement(context, createRoute(const MainLayout()));
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
    const Color bgBeige = Color(0xFFF5F1E9);
    const Color primaryBrown = Color(0xFF7A5B4C);

    return Scaffold(
      backgroundColor: bgBeige,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: primaryBrown,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'DubuNote',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: primaryBrown,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              const Text(
                'Selamat Datang\nKembali',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2D2D),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Masuk untuk melanjutkan pengelolaan keuanganmu.',
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
              const SizedBox(height: 40),

              const Text(
                'Email',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'nama@email.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kata Sandi',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Lupa sandi?',
                      style: TextStyle(color: primaryBrown),
                    ),
                  ),
                ],
              ),
              TextField(
                controller: _passwordController,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _isObscure = !_isObscure),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 35),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _masukAkun,
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
                              'Masuk',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(Icons.arrow_forward, color: Colors.white),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 30),

              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pushReplacement(
                    context,
                    createRoute(const RegisterScreen()),
                  ),
                  child: RichText(
                    text: const TextSpan(
                      text: 'Belum punya akun? ',
                      style: TextStyle(color: Colors.black54),
                      children: [
                        TextSpan(
                          text: 'Daftar di sini',
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
