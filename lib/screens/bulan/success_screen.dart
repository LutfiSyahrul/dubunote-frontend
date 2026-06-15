import 'package:flutter/material.dart';

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

  final Color bgBeige = const Color(0xFFF5F5F5); // Latar abu sangat muda
  final Color primaryBrown = const Color(0xFF7A5B4C);
  final Color cardBeige = const Color(0xFFF3F1EC);
  final Color textGray = const Color(0xFF8B8B8B);
  final Color successGreen = const Color(0xFF81C784); // Hijau pastel sesuai desain

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
    return Scaffold(
      backgroundColor: bgBeige,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
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
                  const Text(
                    'Pengeluaran Berhasil\nDisimpan',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E), height: 1.3, letterSpacing: -0.5),
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
                            const Text('KONFIRMASI ID', style: TextStyle(color: Colors.black45, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                            const SizedBox(height: 5),
                            // ID Dinamis dari Database
                            Text('#DDBB-${widget.transactionId}', style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('STATUS', style: TextStyle(color: Colors.black45, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                            const SizedBox(height: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
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
                      child: const Text('Lihat Rekapan', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
                  const Text('DubuNote  •  FIN.ATELIER', style: TextStyle(color: Colors.black38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}