import 'package:flutter/material.dart';
import '../auth/login_screen.dart'; // Nanti kita buat file ini
import '../../widgets/page_transitions.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // 1. Controller untuk mengatur geser halaman
  final PageController _controller = PageController();

  // 2. Variabel untuk mencatat posisi halaman saat ini
  int _currentIndex = 0;

  // 3. Data Konten Onboarding (Bisa kamu tambah/ubah teksnya di sini)
  final List<Map<String, String>> _onboardingData = [
    {
      "image": "assets/images/onboarding1.png",
      "title": "Catat Tanpa Ribet",
      "subtitle":
          "Pantau setiap rupiah yang keluar dengan antarmuka yang bersih dan mudah digunakan kapan saja.",
    },
    {
      "image": "assets/images/onboarding2.png",
      "title": "Scan Nota Instan",
      "subtitle":
          "Males input manual? Cukup foto nota belanjamu, dan DubuNote akan otomatis mencatatnya untukmu dengan akurat.",
    },
    {
      "image": "assets/images/onboarding3.png",
      "title": "Refleksi Keuangan",
      "subtitle":
          "Dapatkan wawasan mendalam tentang kebiasaan belanjamu dengan grafik dan laporan yang mudah dipahami, sehingga kamu bisa mengelola keuangan dengan lebih bijak.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Definisi Warna dari Figma
    const Color bgBeige = Color(0xFFF5F1E9);
    const Color primaryBrown = Color(0xFF7A5B4C);

    return Scaffold(
      backgroundColor: bgBeige,
      body: SafeArea(
        child: Column(
          children: [
            // AREA GESER (PAGEVIEW) 
            Expanded(
              flex: 4,
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Gambar dengan sudut tumpul (Rounded)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: Image.asset(
                            _onboardingData[index]["image"]!,
                            height: 350,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Judul
                        Text(
                          _onboardingData[index]["title"]!,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D2D2D),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        // Subtitle
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            _onboardingData[index]["subtitle"]!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // --- AREA BAWAH (DOTS & TOMBOL) ---
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 1. Titik Indikator Interaktif (Dots)
                  Row(
                    children: List.generate(
                      _onboardingData.length,
                      (index) => buildDot(index, context),
                    ),
                  ),

                  // 2. Tombol Lanjut yang Berfungsi
                  ElevatedButton(
                    onPressed: () {
                      if (_currentIndex == _onboardingData.length - 1) {
                        // Jika sudah di slide terakhir (Mulai), pindah ke Login pakai transisi halus 120 FPS
                        Navigator.pushReplacement(
                          context,
                          createRoute(
                            const LoginScreen(),
                          ), // <--- Ini kode barunya
                        );
                      } else {
                        // Jika belum terakhir (Lanjut), geser ke slide berikutnya
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBrown,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      children: [
                        Text(
                          _currentIndex == _onboardingData.length - 1
                              ? "Mulai"
                              : "Lanjut",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk membuat Titik Indikator yang bisa memanjang (Interactive Dots)
  Widget buildDot(int index, BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 8,
      width: _currentIndex == index ? 24 : 8, // Memanjang jika aktif
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: _currentIndex == index
            ? const Color(0xFF7A5B4C) // Warna aktif (Cokelat)
            : const Color(0xFFD9D9D9), // Warna tidak aktif (Abu-abu)
      ),
    );
  }
}
