import 'package:flutter/material.dart';
import 'pilih_tanggal_screen.dart';
import '../profile/profile_screen.dart'; 

class BulanScreen extends StatefulWidget {
  const BulanScreen({super.key});

  @override
  State<BulanScreen> createState() => _BulanScreenState();
}

class _BulanScreenState extends State<BulanScreen> {
  // Warna sesuai desain Figma kamu
  final Color bgBeige = const Color(0xFFFDFBF8);
  final Color primaryBrown = const Color(0xFF7A5B4C);
  final Color selectedTileBg = const Color(
    0xFF3D3D3D,
  ); // Warna gelap untuk bulan terpilih
  final Color unselectedTileBg = Colors.white;
  final Color textGray = const Color(0xFF8B8B8B);

  // State Real-time
  late int _selectedYear;
  late int _selectedMonth; // 1 = Jan, 12 = Dec

  final List<String> _bulanNames = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ];

  @override
  void initState() {
    super.initState();
    // Inisialisasi berdasarkan waktu saat ini
    DateTime now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgBeige,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Pilih Bulan',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1E1E),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Renungkan perjalanan Anda melalui berbagai\nmusim.',
              style: TextStyle(color: textGray, fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 40),

            // --- TAHUN PICKER ---
            _buildYearPicker(),
            const SizedBox(height: 30),

            // --- GRID BULAN ---
            _buildMonthGrid(),
            const SizedBox(height: 40),
            
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: bgBeige,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'DubuNote',
        style: TextStyle(
          color: primaryBrown,
          fontWeight: FontWeight.bold,
          fontSize: 22,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.account_circle, color: primaryBrown, size: 30),
          onPressed: () {
            // KODE UNTUK PINDAH KE HALAMAN PROFIL 
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
        ),
        const SizedBox(width: 10),
      ],
      automaticallyImplyLeading: false,
    );
  }

  Widget _buildYearPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () => setState(() => _selectedYear--),
          icon: Icon(
            Icons.chevron_left,
            color: primaryBrown.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(width: 20),
        Text(
          '$_selectedYear',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 20),
        IconButton(
          onPressed: () => setState(() => _selectedYear++),
          icon: Icon(
            Icons.chevron_right,
            color: primaryBrown.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 12,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio:
            1.1, // Agar tile terlihat proporsional (agak kotak membulat)
      ),
      itemBuilder: (context, index) {
        int monthIndex = index + 1;
        bool isSelected = _selectedMonth == monthIndex;

        return GestureDetector(
          onTap: () {
            // Update UI bulan yang terpilih
            setState(() => _selectedMonth = monthIndex);

            // Pindah halaman dengan transisi ke PilihTanggalScreen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PilihTanggalScreen(
                  initialYear: _selectedYear,
                  initialMonth: _selectedMonth,
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? selectedTileBg : unselectedTileBg,
              borderRadius: BorderRadius.circular(
                35,
              ), // Pill-shape rounded sesuai figma
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 5,
                      ),
                    ],
            ),
            child: Center(
              child: Text(
                _bulanNames[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
