import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:camera/camera.dart';

class PrescriptionScanScreen extends StatefulWidget {
  const PrescriptionScanScreen({Key? key}) : super(key: key);

  @override
  State<PrescriptionScanScreen> createState() => _PrescriptionScanScreenState();
}

class _PrescriptionScanScreenState extends State<PrescriptionScanScreen> with SingleTickerProviderStateMixin {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isScanning = false;
  bool _scanComplete = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    _controller = CameraController(cameras[0], ResolutionPreset.high);
    try {
      await _controller!.initialize();
      if (!mounted) return;
      setState(() => _isCameraInitialized = true);
    } catch (e) {
      debugPrint("Camera error: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startScan() async {
    setState(() => _isScanning = true);
    await Future.delayed(const Duration(seconds: 4));
    if (mounted) {
      setState(() {
        _isScanning = false;
        _scanComplete = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background: Camera Preview
          if (_isCameraInitialized)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.previewSize!.height,
                height: _controller!.value.previewSize!.width,
                child: CameraPreview(_controller!),
              ),
            )
          else
            Container(color: const Color(0xFF0F172A)),

          // Scan HUD Overlay
          if (!_scanComplete) _buildScanHUD(),

          // Glass Results Modal
          if (_scanComplete) _buildResultsModal(),

          // Exit Button
          Positioned(
            top: 60,
            left: 24,
            child: FadeInDown(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanHUD() {
    return Stack(
      children: [
        // Darkened overlay with cutout
        ColorFiltered(
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.7), BlendMode.srcOut),
          child: Stack(
            children: [
              Container(decoration: const BoxDecoration(color: Colors.black)),
              Center(
                child: Container(
                  width: 320, height: 450,
                  decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(24)),
                ),
              ),
            ],
          ),
        ),

        // Scanning UI Elements
        Center(
          child: Container(
            width: 320, height: 450,
            decoration: BoxDecoration(border: Border.all(color: Colors.white30), borderRadius: BorderRadius.circular(24)),
            child: Stack(
              children: [
                if (_isScanning)
                  _buildLaserScanLine(),
                
                // Corner Indicators
                _buildHUDBorder(),
              ],
            ),
          ),
        ),

        // GUIDELINES & CTA
        Positioned(
          bottom: 60, left: 24, right: 24,
          child: Column(
            children: [
              FadeInUp(
                child: Text(
                  _isScanning ? "OPTIMISATION DU FLUX IA..." : "ANALYSE DE L'ORDONNANCE",
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ),
              const SizedBox(height: 12),
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  "Placez le document au centre du cadre\npour une lecture haute fidélité.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: Colors.white60, fontSize: 13),
                ),
              ),
              const SizedBox(height: 40),
              if (!_isScanning)
                ZoomIn(
                  child: SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: _startScan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      child: Text("DÉMARRER L'EXTRACTION", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLaserScanLine() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 2),
      builder: (context, value, child) {
        return Positioned(
          top: value * 450,
          left: 0, right: 0,
          child: Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.transparent, Color(0xFF6366F1), Colors.transparent]),
              boxShadow: [BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.5), blurRadius: 20, spreadRadius: 2)],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHUDBorder() {
    return Stack(
      children: [
        Positioned(top: 0, left: 0, child: _corner(top: true, left: true)),
        Positioned(top: 0, right: 0, child: _corner(top: true, left: false)),
        Positioned(bottom: 0, left: 0, child: _corner(top: false, left: true)),
        Positioned(bottom: 0, right: 0, child: _corner(top: false, left: false)),
      ],
    );
  }

  Widget _corner({required bool top, required bool left}) {
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        border: Border(
          top: top ? const BorderSide(color: Color(0xFF6366F1), width: 4) : BorderSide.none,
          bottom: !top ? const BorderSide(color: Color(0xFF6366F1), width: 4) : BorderSide.none,
          left: left ? const BorderSide(color: Color(0xFF6366F1), width: 4) : BorderSide.none,
          right: !left ? const BorderSide(color: Color(0xFF6366F1), width: 4) : BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildResultsModal() {
    return Center(
      child: FadeInUp(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.check_rounded, color: Color(0xFF10B981), size: 32),
                    ),
                    const SizedBox(height: 24),
                    Text("Données Extraites", style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 32),
                    _buildResultItem("Œil Droit (OD)", "Sph: -2.50 | Cyl: +0.50 | Axe: 90°", Icons.visibility_outlined),
                    const SizedBox(height: 16),
                    _buildResultItem("Œil Gauche (OG)", "Sph: -2.25 | Cyl: +0.25 | Axe: 85°", Icons.visibility_outlined),
                    const SizedBox(height: 16),
                    _buildResultItem("Écart Pupillaire", "64 mm", Icons.straighten_rounded),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0F172A),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: Text("VALIDER ET CONTINUER", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultItem(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(value, style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
