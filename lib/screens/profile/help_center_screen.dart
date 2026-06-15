import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

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
          "Pusat Bantuan",
          style: TextStyle(color: primaryBrown, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // Header Ikon
          Center(
            child: Icon(Icons.support_agent_rounded, size: 80, color: primaryBrown.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              "Ada yang bisa kami bantu?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
            ),
          ),
          const SizedBox(height: 32),

          // FAQ Section
          const Text(
            "Pertanyaan yang Sering Diajukan (FAQ)",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          
          _buildFaqItem(
            question: "Bagaimana cara mencatat pengeluaran?",
            answer: "Anda dapat menekan tombol '+' (Tambah) di menu navigasi, atau menggunakan fitur Scan Struk (OCR) untuk mencatat otomatis dari foto struk belanja Anda.",
            primaryColor: primaryBrown,
          ),
          const SizedBox(height: 12),
          _buildFaqItem(
            question: "Apakah data keuangan saya aman?",
            answer: "Tentu saja! Kata sandi Anda dilindungi dengan enkripsi keamanan tingkat tinggi (Bcrypt) di server kami, sehingga privasi Anda terjamin.",
            primaryColor: primaryBrown,
          ),
          const SizedBox(height: 12),
          _buildFaqItem(
            question: "Bagaimana cara mengekspor laporan bulanan?",
            answer: "Buka menu 'Export' di bagian bawah layar. Pilih rentang tanggal yang Anda inginkan, lalu tekan tombol export untuk mengunduhnya ke perangkat Anda.",
            primaryColor: primaryBrown,
          ),

          const SizedBox(height: 48),

          // Card Hubungi Kami
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primaryBrown.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: primaryBrown.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                const Text(
                  "Masih butuh bantuan lain?",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Tim support DubuNote siap membantu kendala teknis Anda.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Ini nanti bisa disambung ke url_launcher untuk buka WhatsApp / Email
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Membuka aplikasi Email...'), backgroundColor: Colors.green)
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBrown,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.email_outlined, size: 20),
                    label: const Text("Hubungi via Email", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // WIDGET KUSTOM UNTUK MENU LIPAT FAQ
  Widget _buildFaqItem({required String question, required String answer, required Color primaryColor}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect( // ClipRRect agar saat dilipat, radius tidak kotak
        borderRadius: BorderRadius.circular(16),
        child: ExpansionTile(
          title: Text(
            question,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
          ),
          iconColor: primaryColor,
          collapsedIconColor: Colors.black38,
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              answer,
              style: const TextStyle(fontSize: 13, color: Colors.black54, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}