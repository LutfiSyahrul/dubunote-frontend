import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart'; // PACKAGE KAMERA BARU
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'scan_detail_page.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> with SingleTickerProviderStateMixin {
  // Variabel Kamera
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;

  // Variabel Animasi & Galeri
  late AnimationController _animationController;
  late Animation<double> _scanAnimation;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // 1. Siapkan Animasi Radar
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _scanAnimation = Tween<double>(begin: 0.05, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    // 2. Nyalakan Mesin Kamera Live
    _initCamera();
  }

  // --- FUNGSI MENGHIDUPKAN KAMERA ---
  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        // Pilih kamera belakang (biasanya index 0)
        _cameraController = CameraController(_cameras![0], ResolutionPreset.high, enableAudio: false);
        await _cameraController!.initialize();
        
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint("Gagal inisialisasi kamera: $e");
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cameraController?.dispose(); // Wajib matikan kamera saat keluar halaman
    super.dispose();
  }

  // --- FUNGSI MENGATUR FLASH (LAMPU SENTER) ---
  void _toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    
    try {
      if (_isFlashOn) {
        await _cameraController!.setFlashMode(FlashMode.off);
      } else {
        await _cameraController!.setFlashMode(FlashMode.torch);
      }
      setState(() => _isFlashOn = !_isFlashOn);
    } catch (e) {
      debugPrint("Gagal atur flash: $e");
    }
  }

  // FUNGSI UTAMA: JEPRET & UPLOAD KE NODE.JS
  Future<void> _captureAndUpload({bool fromGallery = false}) async {
    if (!fromGallery && (!_isCameraInitialized || _cameraController == null)) return;

    try {
      XFile? image;

      if (fromGallery) {
        // Ambil dari Galeri
        image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      } else {
        // Jepret langsung dari Live Camera
        image = await _cameraController!.takePicture();
      }

      if (image == null) return; // Batal milih/jepret foto

      if (!mounted) return;

      // Munculkan dialog loading transparan
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFF6F4627))),
      );

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sesi habis, silakan login ulang.')));
        return;
      }

      // Kirim ke Node.js
      var request = http.MultipartRequest('POST', Uri.parse('http://10.0.2.2:3000/api/ocr/scan'));
      request.fields['pengguna_id'] = userId.toString();
      request.files.add(await http.MultipartFile.fromPath('foto_nota', image!.path));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseData);

      if (!mounted) return;
      Navigator.pop(context); // Tutup loading

      if (response.statusCode == 200) {
        // Matikan flash jika menyala sebelum pindah halaman
        if (_isFlashOn) _toggleFlash();
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ScanDetailPage(scannedData: jsonResponse, localImagePath: image!.path),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(jsonResponse['pesan'] ?? 'Gagal Scan')));
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1C1C),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_isFlashOn) _toggleFlash(); // Matikan flash jika user back
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    ),
                  ),
                  const Text("Scan Nota", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), shape: BoxShape.circle),
                    child: const Icon(Icons.help_outline, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Center(
                      child: AspectRatio(
                        aspectRatio: 3 / 4,
                        child: Stack(
                          children: [
                            // === KAMERA LIVE VIEW ===
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: _isCameraInitialized 
                                  ? CameraPreview(_cameraController!) 
                                  : Container(
                                      color: Colors.white10,
                                      child: const Center(child: CircularProgressIndicator(color: Color(0xFFF4DBC9))),
                                    ),
                              ),
                            ),
                            
                            // UI Viewfinder & Animasi Radar
                            Positioned.fill(child: CustomPaint(painter: ViewfinderCornerPainter(cornerColor: const Color(0xFFF4DBC9)))),
                            AnimatedBuilder(
                              animation: _scanAnimation,
                              builder: (context, child) {
                                return Positioned(
                                  top: constraints.maxHeight * _scanAnimation.value,
                                  left: 10,
                                  right: 10,
                                  child: Container(
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF4DBC9),
                                      boxShadow: [BoxShadow(color: const Color(0xFFF4DBC9).withOpacity(0.5), blurRadius: 10, spreadRadius: 2)],
                                    ),
                                  ),
                                );
                              },
                            ),
                            Positioned(
                              bottom: 20, left: 0, right: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(20)),
                                  child: const Text("PASTIKAN TERLIHAT JELAS", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24.0, 32.0, 24.0, 32.0),
              decoration: const BoxDecoration(
                color: Color(0xFFFFFDFB),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(36), topRight: Radius.circular(36)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: _isFlashOn ? Icons.flash_on : Icons.flash_off_outlined,
                    label: "FLASH",
                    onTap: _toggleFlash, // NYALAKAN/MATIKAN FLASH SUNGGUHAN
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _captureAndUpload(fromGallery: false), // JEPRET DARI LIVE CAMERA
                      borderRadius: BorderRadius.circular(50),
                      splashColor: const Color(0xFF6F4627).withOpacity(0.3),
                      child: Container(
                        width: 84, height: 84, padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF6F4627), width: 4)),
                        child: Container(
                          decoration: const BoxDecoration(color: Color(0xFF6F4627), shape: BoxShape.circle),
                          child: const Icon(Icons.document_scanner, color: Colors.white, size: 32),
                        ),
                      ),
                    ),
                  ),
                  _buildActionButton(
                    icon: Icons.image_outlined,
                    label: "GALLERY",
                    onTap: () => _captureAndUpload(fromGallery: true), // AMBIL DARI GALERI
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                width: 52, height: 52,
                decoration: const BoxDecoration(color: Color(0xFFF4F3F1), shape: BoxShape.circle),
                child: Icon(icon, color: const Color(0xFF1A1C1C), size: 22),
              ),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 0.5)),
            ],
          ),
        ),
      ),
    );
  }
}

class ViewfinderCornerPainter extends CustomPainter {
  final Color cornerColor;
  ViewfinderCornerPainter({required this.cornerColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = cornerColor..strokeWidth = 4..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    const double length = 30; 
    canvas.drawLine(const Offset(0, 0), const Offset(length, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, length), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - length, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, length), paint);
    canvas.drawLine(Offset(0, size.height), Offset(length, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - length), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - length, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - length), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}