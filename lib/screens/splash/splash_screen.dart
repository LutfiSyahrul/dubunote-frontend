import 'dart:async';
import 'package:flutter/material.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// Ditambahkan 'with SingleTickerProviderStateMixin' untuk mengaktifkan fungsi animasi widget
class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  double _opacity = 0.0;
  late AnimationController _animationController;
  late Animation<double> _loadingAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Inisialisasi Kontroler Animasi selama 3.5 detik (selaras dengan perpindahan halaman)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    // 2. Membuat Nilai Loading berjalan mulus dari 0.0 (kosong) sampai 1.0 (penuh)
    _loadingAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        )..addListener(() {
          setState(
            () {},
          ); // Memaksa widget menggambar ulang setiap kali loading bar maju
        });

    // 3. Mulai jalankan animasi loading bar
    _animationController.forward();

    // 4. Efek Fade-in untuk Logo & Judul
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
        });
      }
    });

    // 5. Pindah otomatis ke Onboarding setelah 4 detik dengan transisi 120 FPS Smooth
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const OnboardingScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              var curve = CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOutCubic,
              );

              // Efek memudar (Fade) dikombinasikan dengan kurva super smooth
              return FadeTransition(opacity: curve, child: child);
            },
            // Durasi transisi perpindahan halaman (500 milidetik / setengah detik)
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController
        .dispose(); // Wajib dihapus dari memori agar laptop tidak berat
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundBrown = Color(0xFF7A5B4C);
    const Color primaryWhite = Colors.white;
    const Color lightBrownText = Color(0xFFC7AF9F);

    return Scaffold(
      backgroundColor: backgroundBrown,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const Spacer(flex: 2),

              // --- LOGO & JUDUL DUBUNOTE ---
              AnimatedOpacity(
                duration: const Duration(milliseconds: 1500),
                opacity: _opacity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        color: Color(0x1FFFFFFF),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(25),
                      child: Image.asset(
                        'assets/images/Icon-splash.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'DubuNote',
                      style: TextStyle(
                        color: primaryWhite,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Catat Keuanganmu dengan Mudah',
                      style: TextStyle(
                        color: primaryWhite,
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // --- BAGIAN PROGRESS BAR YANG INTERAKTIF & BERGERAK ---
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // 1. Loading Bar Utama
                  Container(
                    width: 200,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(
                        0x33FFFFFF,
                      ), // Background bar transparan
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: _loadingAnimation
                            .value, 
                        child: Container(
                          decoration: BoxDecoration(
                            color: primaryWhite, 
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // 2. Teks "SINCRONIZING DATA"
                  const Text(
                    'SINCRONIZING DATA',
                    style: TextStyle(
                      color: lightBrownText,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
