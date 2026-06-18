import 'package:flutter/material.dart';
import '../../theme_manager.dart'; // ubah mode gelap

class SuccessScreen extends StatefulWidget {
  final int transactionId;

  // Menerima ID transaksi dari database untuk ditampilkan
  const SuccessScreen({super.key, required this.transactionId});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  // ubah mode gelap - warna dasar dinamis berdasarkan theme manager
  Color get bgBeige => ThemeColors.getBgBeige(isDarkModeNotifier.value); // ubah mode gelap
  Color get primaryBrown => ThemeColors.getPrimaryBrown(isDarkModeNotifier.value); // ubah mode gelap
  Color get cardBeige => isDarkModeNotifier.value ? const Color(0xFF1C1917) : const Color(0xFFF3F1EC); // ubah mode gelap
  Color get textGray => ThemeColors.getSubTextColor(isDarkModeNotifier.value); // ubah mode gelap
  Color get successGreen => const Color(0xFF81C784); // Hijau pastel sesuai desain

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    // Animasi memantul yang memanjakan mata
    _animation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward(); 
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return Scaffold(
          backgroundColor: bgBeige,
          body: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
                  decoration: BoxDecoration(
                    color: ThemeColors.getCardBg(isDarkMode), // ubah mode gelap
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode ? Colors.transparent : Colors.black.withValues(alpha: 0.05), // ubah mode gelap
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // --- ANIMASI CENTANG MUNCUL ---
                      ScaleTransition(
                        scale: _animation,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: successGreen,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: successGreen.withValues(alpha: 0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              )
                            ],
                          ),
                          child: const Icon(Icons.check_rounded, color: Colors.white, size: 45),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // --- TEKS HEADER ---
                      Text(
                        'Pengeluaran Berhasil\nDisimpan',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22, 
                          fontWeight: FontWeight.bold, 
                          color: isDarkMode ? Colors.white : const Color(0xFF1E1E1E), // ubah mode gelap
                          height: 1.3, 
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'Keuangan Anda kini lebih\nterorganisir.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: textGray, fontSize: 14, height: 1.5),
                      ),
                      const SizedBox(height: 40),

                      // --- KARTU ID & STATUS DINAMIS ---
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        decoration: BoxDecoration(
                          color: cardBeige,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'KONFIRMASI ID', 
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.white70 : Colors.black45, // ubah mode gelap
                                    fontSize: 10, 
                                    fontWeight: FontWeight.bold, 
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                // ID Dinamis dari Database
                                Text(
                                  '#DDBB-${widget.transactionId}', 
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.white : Colors.black87, // ubah mode gelap
                                    fontSize: 16, 
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'STATUS', 
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.white70 : Colors.black45, // ubah mode gelap
                                    fontSize: 10, 
                                    fontWeight: FontWeight.bold, 
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? const Color(0xFF292524) : Colors.white, // ubah mode gelap
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(width: 6, height: 6, decoration: BoxDecoration(color: primaryBrown, shape: BoxShape.circle)),
                                      const SizedBox(width: 5),
                                      Text('Verified', style: TextStyle(color: primaryBrown, fontSize: 12, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // --- TOMBOL LIHAT REKAPAN ---
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Navigasi ke halaman Refleksi. Sementara kita arahkan ke Dashboard (Index 0)
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBrown,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            elevation: 0,
                          ),
                          child: Text(
                            'Lihat Rekapan', 
                            style: TextStyle(
                              color: isDarkMode ? const Color(0xFF1C1917) : Colors.white, // ubah mode gelap
                              fontSize: 16, 
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // --- TOMBOL TAMBAH LAGI ---
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context), // Kembali ke Halaman Form Tambah
                          style: TextButton.styleFrom(
                            backgroundColor: cardBeige,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: Text('Tambah Lagi', style: TextStyle(color: primaryBrown, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // --- FOOTER ---
                      Text(
                        'DubuNote  •  FIN.ATELIER', 
                        style: TextStyle(
                          color: isDarkMode ? Colors.white24 : Colors.black38, // ubah mode gelap
                          fontSize: 10, 
                          fontWeight: FontWeight.bold, 
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}