import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ubah mode gelap - notifier global untuk memantau status dark mode secara realtime
final ValueNotifier<bool> isDarkModeNotifier = ValueNotifier<bool>(false);

// ubah mode gelap - skema warna global sesuai strategi "Dark Espresso"
class ThemeColors {
  // Background Aplikasi: Abu-abu kecokelatan sangat gelap (#1C1917) atau Beige Terang
  static Color getBgBeige(bool isDark) => isDark ? const Color(0xFF1C1917) : const Color(0xFFFDFBF8);
  
  // Warna Cokelat Utama: Pastel (#B89381) atau Cokelat Gelap (#7A5B4C)
  static Color getPrimaryBrown(bool isDark) => isDark ? const Color(0xFFB89381) : const Color(0xFF7A5B4C);
  
  // Background Card: Abu-abu kecokelatan lebih terang (#292524) atau Putih
  static Color getCardBg(bool isDark) => isDark ? const Color(0xFF292524) : Colors.white;
  
  // Warna Teks Utama
  static Color getTextColor(bool isDark) => isDark ? Colors.white : const Color(0xFF1A1A1A);
  
  // Warna Teks Keterangan / Subtitle
  static Color getSubTextColor(bool isDark) => isDark ? Colors.white70 : Colors.black54;
  
  // Warna Garis Pembatas
  static Color getDividerColor(bool isDark) => isDark ? const Color(0xFF3E3B39) : const Color(0xFFF0F0F0);
}

// ubah mode gelap - inisialisasi status tema dari SharedPreferences saat aplikasi dibuka
Future<void> initGlobalTheme() async {
  final prefs = await SharedPreferences.getInstance();
  isDarkModeNotifier.value = prefs.getBool('is_dark_mode') ?? false;
}

// ubah mode gelap - simpan status tema ke SharedPreferences dan picu pembaruan UI global
Future<void> saveGlobalTheme(bool value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('is_dark_mode', value);
  isDarkModeNotifier.value = value;
}
