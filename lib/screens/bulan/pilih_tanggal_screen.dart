import 'package:flutter/material.dart';
import 'tambah_pengeluaran_screen.dart';

class PilihTanggalScreen extends StatefulWidget {
  final int initialYear;
  final int initialMonth;

  // Menerima data tahun dan bulan dari halaman sebelumnya
  const PilihTanggalScreen({
    super.key,
    required this.initialYear,
    required this.initialMonth,
  });

  @override
  State<PilihTanggalScreen> createState() => _PilihTanggalScreenState();
}

class _PilihTanggalScreenState extends State<PilihTanggalScreen> {
  final Color bgBeige = const Color(0xFFFDFBF8);
  final Color primaryBrown = const Color(0xFF7A5B4C);
  final Color textGray = const Color(0xFF8B8B8B);
  final Color selectedCardBg = const Color(
    0xFFF5EFE9,
  ); // Krem muda untuk kartu bawah

  late int _currentYear;
  late int _currentMonth;
  int? _selectedDay;

  final List<String> _namaBulan = [
    "Januari",
    "Februari",
    "Maret",
    "April",
    "Mei",
    "Juni",
    "Juli",
    "Agustus",
    "September",
    "Oktober",
    "November",
    "Desember",
  ];

  final List<String> _namaHari = [
    "Senin",
    "Selasa",
    "Rabu",
    "Kamis",
    "Jumat",
    "Sabtu",
    "Minggu",
  ];

  @override
  void initState() {
    super.initState();
    _currentYear = widget.initialYear;
    _currentMonth = widget.initialMonth;
  }

  // Fungsi mengubah bulan via panah < >
  void _ubahBulan(int increment) {
    setState(() {
      _currentMonth += increment;
      if (_currentMonth > 12) {
        _currentMonth = 1;
        _currentYear++;
      } else if (_currentMonth < 1) {
        _currentMonth = 12;
        _currentYear--;
      }
      _selectedDay = null; // Reset pilihan hari jika pindah bulan
    });
  }

  // Fungsi merakit teks tanggal
  String _getFormattedDate() {
    if (_selectedDay == null) return "Pilih tanggal di atas";

    DateTime date = DateTime(_currentYear, _currentMonth, _selectedDay!);
    String hari = _namaHari[date.weekday - 1];
    String bulan = _namaBulan[_currentMonth - 1];

    return "$hari, $_selectedDay $bulan $_currentYear";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgBeige,
      // AppBar simpel tanpa Navbar
      appBar: AppBar(
        backgroundColor: bgBeige,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryBrown),
          onPressed: () => Navigator.pop(context), // Tombol kembali
        ),
        title: Text(
          'Pilih Tanggal',
          style: TextStyle(
            color: primaryBrown,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text(
              'Pilih Tanggal',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1E1E),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kapan transaksi ini dilakukan? Pilih satu hari untuk\nmelanjutkan.',
              style: TextStyle(color: textGray, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 30),

            // --- KARTU KALENDER INTERAKTIF ---
            _buildCalendarCard(),
            const SizedBox(height: 30),

            // --- KARTU TANGGAL TERPILIH ---
            _buildSelectedDateCard(),
            const SizedBox(height: 30),

            // --- TOMBOL LANJUTKAN ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _selectedDay == null
                    ? null // Tombol mati kalau belum pilih tanggal
                    : () {
                        // Menggabungkan tahun, bulan, hari menjadi objek DateTime
                        DateTime dateToPass = DateTime(
                          _currentYear,
                          _currentMonth,
                          _selectedDay!,
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TambahPengeluaranScreen(
                              selectedDate: dateToPass,
                            ),
                          ),
                        );
                        debugPrint(
                          "Tanggal untuk DB: $_currentYear-$_currentMonth-$_selectedDay",
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBrown,
                  disabledBackgroundColor: primaryBrown.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Lanjutkan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_namaBulan[_currentMonth - 1]} $_currentYear',
                style: TextStyle(
                  color: primaryBrown,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _ubahBulan(-1),
                    icon: Icon(
                      Icons.chevron_left,
                      color: primaryBrown,
                      size: 22,
                    ),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(width: 15),
                  IconButton(
                    onPressed: () => _ubahBulan(1),
                    icon: Icon(
                      Icons.chevron_right,
                      color: primaryBrown,
                      size: 22,
                    ),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Table(children: _generateDynamicCalendar()),
        ],
      ),
    );
  }

  List<TableRow> _generateDynamicCalendar() {
    List<TableRow> rows = [];
    int daysInMonth = DateTime(_currentYear, _currentMonth + 1, 0).day;
    int firstWeekday = DateTime(_currentYear, _currentMonth, 1).weekday;
    int daysInPrevMonth = DateTime(_currentYear, _currentMonth, 0).day;

    rows.add(
      TableRow(
        children: ['SU', 'MO', 'TU', 'WE', 'TH', 'FR', 'SA']
            .map(
              (day) => Center(
                child: Text(
                  day,
                  style: const TextStyle(
                    color: Color(0xFFD6C8BC),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );

    List<String> currentRowDays = [];
    List<bool> currentRowFaded = [];

    int paddingDays = firstWeekday == 7 ? 0 : firstWeekday;

    // Hari dari bulan sebelumnya
    for (int i = paddingDays; i > 0; i--) {
      currentRowDays.add((daysInPrevMonth - i + 1).toString());
      currentRowFaded.add(true);
    }

    // Hari bulan ini
    for (int i = 1; i <= daysInMonth; i++) {
      currentRowDays.add(i.toString());
      currentRowFaded.add(false);

      if (currentRowDays.length == 7) {
        rows.add(
          const TableRow(
            children: [
              SizedBox(height: 15),
              SizedBox(),
              SizedBox(),
              SizedBox(),
              SizedBox(),
              SizedBox(),
              SizedBox(),
            ],
          ),
        );
        rows.add(_buildDynamicCalendarRow(currentRowDays, currentRowFaded));
        currentRowDays = [];
        currentRowFaded = [];
      }
    }

    // Hari bulan depannya
    if (currentRowDays.isNotEmpty) {
      int nextMonthDay = 1;
      while (currentRowDays.length < 7) {
        currentRowDays.add(nextMonthDay.toString());
        currentRowFaded.add(true);
        nextMonthDay++;
      }
      rows.add(
        const TableRow(
          children: [
            SizedBox(height: 15),
            SizedBox(),
            SizedBox(),
            SizedBox(),
            SizedBox(),
            SizedBox(),
            SizedBox(),
          ],
        ),
      );
      rows.add(_buildDynamicCalendarRow(currentRowDays, currentRowFaded));
    }

    return rows;
  }

  TableRow _buildDynamicCalendarRow(List<String> days, List<bool> isFadedList) {
    return TableRow(
      children: List.generate(days.length, (index) {
        String day = days[index];
        bool isFaded = isFadedList[index];
        bool isSelected =
            (_selectedDay != null &&
            day == _selectedDay.toString() &&
            !isFaded);

        return GestureDetector(
          onTap: isFaded
              ? null
              : () => setState(() => _selectedDay = int.parse(day)),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: isSelected
                  ? BoxDecoration(
                      color: primaryBrown,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryBrown.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    )
                  : const BoxDecoration(
                      shape: BoxShape.circle,
                    ), // Tetap beri shape agar animasi tap enak
              child: Text(
                day,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (isFaded ? Colors.black26 : Colors.black87),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSelectedDateCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: selectedCardBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryBrown,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_today_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TANGGAL TERPILIH',
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 10,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getFormattedDate(),
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
