import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final Color bgBeige = const Color(0xFFFDFBF8);
  final Color primaryBrown = const Color(0xFF7A5B4C);

  // Status awal tombol (Default)
  bool _dailyReminder = true;
  bool _monthlyReport = true;
  bool _appUpdates = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Menarik status tombol dari memori HP
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dailyReminder = prefs.getBool('notif_daily') ?? true;
      _monthlyReport = prefs.getBool('notif_monthly') ?? true;
      _appUpdates = prefs.getBool('notif_updates') ?? false;
    });
  }

  // Menyimpan status tombol setiap kali di-klik
  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
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
          "Notifikasi",
          style: TextStyle(color: primaryBrown, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          const Text(
            "Sesuaikan preferensi notifikasi agar DubuNote dapat membantu mencatat keuanganmu dengan lebih baik.",
            style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
          ),
          const SizedBox(height: 32),
          
          _buildSwitchTile(
            title: "Pengingat Catat Harian",
            subtitle: "Ingatkan saya mencatat pengeluaran setiap jam 20:00",
            value: _dailyReminder,
            onChanged: (val) {
              setState(() => _dailyReminder = val);
              _saveSetting('notif_daily', val);
            },
          ),
          const SizedBox(height: 16),
          
          _buildSwitchTile(
            title: "Laporan Bulanan",
            subtitle: "Terima ringkasan arus kas setiap awal bulan",
            value: _monthlyReport,
            onChanged: (val) {
              setState(() => _monthlyReport = val);
              _saveSetting('notif_monthly', val);
            },
          ),
          const SizedBox(height: 16),
          
          _buildSwitchTile(
            title: "Promo & Pembaruan",
            subtitle: "Informasi fitur baru dan tips keuangan",
            value: _appUpdates,
            onChanged: (val) {
              setState(() => _appUpdates = val);
              _saveSetting('notif_updates', val);
            },
          ),
        ],
      ),
    );
  }

  // WIDGET KUSTOM UNTUK KOTAK SWITCH
  Widget _buildSwitchTile({required String title, required String subtitle, required bool value, required ValueChanged<bool> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Transform.scale(
            scale: 0.9,
            child: Switch(
              value: value,
              activeColor: primaryBrown,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}