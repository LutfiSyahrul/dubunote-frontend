import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';


import 'help_center_screen.dart';
import 'about_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme_manager.dart'; // ubah mode gelap

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ubah mode gelap - warna dasar menggunakan theme manager global
  Color get bgBeige => ThemeColors.getBgBeige(isDarkModeNotifier.value);
  Color get primaryBrown => ThemeColors.getPrimaryBrown(isDarkModeNotifier.value);
  
  // --- VARIABEL DINAMIS ---
  String _nama = "Memuat...";
  String _email = "Memuat...";

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // --- FUNGSI MENARIK DATA PROFIL DARI NODE.JS ---
  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId != null) {
        final response = await http.get(Uri.parse('http://10.0.2.2:3000/api/pengguna/$userId'));
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() {
            _nama = data['nama'] ?? "Pengguna DubuNote";
            _email = data['email'] ?? "user@dudububu.com";
          });
        } else {
          setState(() { 
            _nama = "Pengguna"; 
            _email = "Gagal memuat email"; 
          });
        }
      } else {
        // PENGAMAN: Kalau userId terhapus/kosong, jangan stuck di Memuat
        setState(() { 
          _nama = "Sesi Habis"; 
          _email = "Silakan login ulang"; 
        });
      }
    } catch (e) {
      setState(() { 
        _nama = "Mode Offline"; 
        _email = "Periksa koneksi internet"; 
      });
    }
  }

  // --- FUNGSI LOGOUT ---
  void _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkModeNotifier.value ? const Color(0xFF292524) : Colors.white, // ubah mode gelap
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Keluar Akun', style: TextStyle(fontWeight: FontWeight.bold, color: isDarkModeNotifier.value ? Colors.white : Colors.black87)), // ubah mode gelap
        content: Text('Apakah Anda yakin ingin keluar dari DubuNote?', style: TextStyle(color: isDarkModeNotifier.value ? Colors.white70 : Colors.black87)), // ubah mode gelap
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: primaryBrown)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              // keluar akun - hapus sesi/preferensi pengguna dari memori lokal
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear(); 
              
              if (mounted) {
                // keluar akun - arahkan pengguna kembali ke halaman login dan hapus riwayat tumpukan halaman
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
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
          "Profil Saya",
          style: TextStyle(color: primaryBrown, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        // ==========================================
        // FITUR PULL-TO-REFRESH DITAMBAHKAN DI SINI
        // ==========================================
        child: RefreshIndicator(
          color: primaryBrown,
          backgroundColor: Colors.white,
          onRefresh: _loadProfile,
          child: SingleChildScrollView(
            // Wajib ditambah physics ini agar layar bisa ditarik meski kontennya sedikit
            physics: const AlwaysScrollableScrollPhysics(), 
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: isDarkMode ? const Color(0xFF3E3A36) : const Color(0xFFF3DDC9), width: 3), // ubah mode gelap
                              boxShadow: isDarkMode ? [] : [ // ubah mode gelap
                                BoxShadow(color: Colors.black.withValues(alpha:0.04), blurRadius: 12, offset: const Offset(0, 6)),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(55),
                              child: Image.asset(
                                'assets/images/user_profil.jpg', 
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: isDarkMode ? const Color(0xFF3E3A36) : const Color(0xFFF3DDC9), // ubah mode gelap
                                    child: Icon(Icons.person, color: primaryBrown, size: 50),
                                  );
                                },
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(color: primaryBrown, shape: BoxShape.circle),
                              child: const Icon(Icons.edit, color: Colors.white, size: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _nama,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A), letterSpacing: -0.5), // ubah mode gelap
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _email,
                        style: TextStyle(fontSize: 14, color: isDarkMode ? Colors.white70 : Colors.black54), // ubah mode gelap
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                _buildMenuSectionTitle("INFORMASI AKUN"),
                const SizedBox(height: 8),
                _buildMenuCard([
                  _buildMenuTile(
                      icon: Icons.person_outline, 
                      title: "Detail Personal", 
                      onTap: () async {
                      final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                      );
                      if (result == true) {
                          _loadProfile(); 
                          }
                      }
                  ),
                  _buildDivider(),
                  _buildMenuTile(
                      icon: Icons.lock_open_outlined, 
                      title: "Keamanan & Kata Sandi", 
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                        );
                      },
                  ),
                ]),

                const SizedBox(height: 24),

                _buildMenuSectionTitle("PREFERENSI"),
                const SizedBox(height: 8),
                _buildMenuCard([
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      children: [
                        Icon(Icons.dark_mode_outlined, color: primaryBrown, size: 22),
                        const SizedBox(width: 16),
                        Expanded(child: Text("Tampilan (Mode Gelap)", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A)))), // ubah mode gelap
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: isDarkMode,
                            activeColor: primaryBrown,
                            onChanged: (value) { // ubah mode gelap
                              saveGlobalTheme(value);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),

                const SizedBox(height: 24),

                _buildMenuSectionTitle("LAINNYA"),
                const SizedBox(height: 8),
                _buildMenuCard([
                  _buildMenuTile(
                    icon: Icons.help_outline, 
                    title: "Pusat Bantuan", 
                    onTap: () {
                      Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HelpCenterScreen()),
                      );
                    },
                  ),
                  _buildDivider(),
                 _buildMenuTile(
                    icon: Icons.info_outline, 
                    title: "Tentang DubuNote", 
                    onTap: () {
                      Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AboutScreen()),
                      );
                    },
                  ),
                ]),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode ? const Color(0xFF3D1F1F) : const Color(0xFFFFF0F0), // ubah mode gelap
                      foregroundColor: Colors.red.shade400, // ubah mode gelap
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout_rounded, size: 22),
                        SizedBox(width: 8),
                        Text("Keluar Akun", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 80), // Tambahan ruang kosong di bawah agar nyaman ditarik
              ],
            ),
          ),
        ),
      ),
        );
      },
    );
  }

  Widget _buildMenuSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: primaryBrown.withValues(alpha:0.6),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDarkModeNotifier.value ? const Color(0xFF292524) : Colors.white, // ubah mode gelap
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: isDarkModeNotifier.value ? [] : [ // ubah mode gelap
          BoxShadow(color: Colors.black.withValues(alpha:0.015), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuTile({required IconData icon, required String title, String? trailingText, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            Icon(icon, color: primaryBrown, size: 22),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: isDarkModeNotifier.value ? Colors.white : const Color(0xFF1A1A1A)))), // ubah mode gelap
            if (trailingText != null) Text(trailingText, style: TextStyle(fontSize: 13, color: isDarkModeNotifier.value ? Colors.white54 : Colors.black.withValues(alpha:0.4), fontWeight: FontWeight.w500)), // ubah mode gelap
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: isDarkModeNotifier.value ? Colors.white30 : Colors.black.withValues(alpha:0.25), size: 18), // ubah mode gelap
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: isDarkModeNotifier.value ? const Color(0xFF3E3B39) : const Color(0xFFF0F0F0), height: 1, thickness: 1, indent: 16, endIndent: 16); // ubah mode gelap
  }
}