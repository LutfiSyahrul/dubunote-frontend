import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color bgBeige = Color(0xFFFDFBF8);
    const Color primaryBrown = Color(0xFF7A5B4C);

    return Scaffold(
      backgroundColor: bgBeige,
      appBar: AppBar(
        backgroundColor: bgBeige,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryBrown),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Tentang DubuNote",
          style: TextStyle(color: primaryBrown, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Logo Animasi Visual / Icon Aplikasi
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 64,
                  color: primaryBrown,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                "DubuNote",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
              ),
            ),
            const Center(
              child: Text(
                "Versi 1.0.0 (Build Berbasis Cloud)",
                style: TextStyle(fontSize: 13, color: Colors.black38, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 32),

            // Deskripsi Aplikasi Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.015), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: const Text(
                "DubuNote adalah aplikasi pencatatan keuangan modern yang dirancang khusus untuk mempermudah manajemen arus kas harian Anda. Dilengkapi dengan fitur analisis trend pengeluaran berkala, refleksi tabungan bersama, serta sistem pintar pemindaian struk digital (OCR). Seluruh data disinkronisasikan secara real-time dan aman.",
                textAlign: TextAlign.justify,
                style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.6),
              ),
            ),
            const SizedBox(height: 24),

            // Spesifikasi Detail Sistem (Informasi Tambahan)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.015), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  _buildInfoTile("Hak Cipta", "© 2026 Dudububu Studio"),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black54)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(color: Color(0xFFF5F5F5), height: 1, thickness: 1, indent: 20, endIndent: 20);
  }
}