import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:permission_handler/permission_handler.dart';

class VirtualTryOnScreen extends StatefulWidget {
  final String? initialTryOnAsset;
  const VirtualTryOnScreen({super.key, this.initialTryOnAsset});

  @override
  State<VirtualTryOnScreen> createState() => _VirtualTryOnScreenState();
}

class _VirtualTryOnScreenState extends State<VirtualTryOnScreen> with SingleTickerProviderStateMixin {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  late AnimationController _scanController;
  int _selectedGlassesIndex = 0;
  Offset _offset = Offset.zero;
  double _scale = 1.0;
  double _baseScale = 1.0;
  bool _cameraError = false;
  bool _isScanningComplete = false;

  final List<Map<String, String>> _glasses = [
    {'name': 'Aviator', 'image': 'assets/glasses/image.jpeg'},
    {'name': 'Wayfarer', 'image': 'assets/glasses/image2.jpg'},
    {'name': 'Clubmaster', 'image': 'assets/glasses/image4.jpg'},
    {'name': 'Nike Sport', 'image': 'assets/glasses/image5.jpg'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialTryOnAsset != null) {
      final index = _glasses.indexWhere((g) => g['image'] == widget.initialTryOnAsset);
      if (index != -1) {
        _selectedGlassesIndex = index;
      } else {
        _glasses.insert(0, {
          'name': 'Sélection',
          'image': widget.initialTryOnAsset!,
        });
        _selectedGlassesIndex = 0;
      }
    }
    
    _scanController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    if (mounted) {
      setState(() {
        _cameraError = false;
        _isCameraInitialized = false;
        _isScanningComplete = false;
        _scanController.repeat();
      });
    }

    // Demander la permission explicitement
    var status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) setState(() => _cameraError = true);
      _startScanningSimulation();
      return;
    }

    try {
      final cameras = await availableCameras().timeout(const Duration(seconds: 5));
      if (cameras.isEmpty) {
        if (mounted) setState(() => _cameraError = true);
        _startScanningSimulation();
        return;
      }

      _controller = CameraController(cameras[0], ResolutionPreset.high, enableAudio: false);
      await _controller!.initialize().timeout(const Duration(seconds: 10));
      
      if (!mounted) return;
      setState(() => _isCameraInitialized = true);
      _startScanningSimulation();
    } catch (e) {
      debugPrint("Camera error: $e");
      if (mounted) setState(() => _cameraError = true);
      _startScanningSimulation();
    }
  }

  void _startScanningSimulation() {
    // Simuler la fin du scan après 3 secondes, peu importe l'état de la caméra
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isScanningComplete = true;
          _scanController.stop();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Preview (Background)
          if (_isCameraInitialized)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.previewSize!.height,
                height: _controller!.value.previewSize!.width,
                child: CameraPreview(_controller!),
              ),
            )
          else if (_cameraError)
            Container(
              color: const Color(0xFF0F172A),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.videocam_off_rounded, color: Colors.white54, size: 64),
                    const SizedBox(height: 24),
                    Text(
                      "Caméra non détectée",
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        "Vous pouvez tout de même essayer les lunettes sur ce fond sombre.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white38),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _initializeCamera,
                      child: const Text("Réessayer"),
                    ),
                  ],
                ),
              ),
            )
          else
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.cyanAccent),
                  SizedBox(height: 24),
                  Text("Recherche de la caméra...", style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),

          // High-Tech HUD Layer
          _buildHUDOverlay(),

          // Glassmorphism Bottom Panel
          _buildModernBottomControls(),

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
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
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

  Widget _buildHUDOverlay() {
    return Stack(
      children: [
        // Corner Brackets
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Stack(
              children: [
                _buildHUDCorner(top: 0, left: 0),
                _buildHUDCorner(top: 0, right: 0, isRotated: true),
                _buildHUDCorner(bottom: 0, left: 0, isBottom: true),
                _buildHUDCorner(bottom: 0, right: 0, isBottom: true, isRotated: true),
              ],
            ),
          ),
        ),

        // Scanning Line & Face Map Points
        Center(
          child: Container(
            width: 320,
            height: 450,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.2), width: 1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Digital Face Map Simulation
                ...List.generate(6, (index) => _buildTrackingPoint(index)),

                // Laser Scan Line
                if (!_isScanningComplete)
                  AnimatedBuilder(
                    animation: _scanController,
                    builder: (context, child) {
                      double top = _scanController.value * 450;
                      return Positioned(
                        top: top,
                        child: Container(
                          width: 300,
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.cyanAccent.withValues(alpha: 0.8),
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyanAccent.withValues(alpha: 0.3),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                // Virtual Glasses Overlay
                GestureDetector(
                  onScaleStart: (details) {
                    _baseScale = _scale;
                  },
                  onScaleUpdate: (details) {
                    setState(() {
                      _scale = _baseScale * details.scale;
                      _offset += details.focalPointDelta;
                    });
                  },
                  child: Transform.translate(
                    offset: _offset,
                    child: Transform.scale(
                      scale: _scale,
                      child: Visibility(
                        visible: _isScanningComplete,
                        child: FadeIn(
                          duration: const Duration(milliseconds: 800),
                          child: Image.asset(
                            _glasses[_selectedGlassesIndex]['image']!,
                            width: 260,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Technical Data Sidebars
        Positioned(
          left: 30,
          bottom: 250,
          child: _buildHUDSideLabel("X-AXIS: 1.42\nY-AXIS: -0.85\nZOOM: 2.1x", Icons.bar_chart_rounded),
        ),
        Positioned(
          right: 30,
          bottom: 250,
          child: _buildHUDSideLabel(
            _isScanningComplete 
              ? "FACE-SYNC: 100%\nSTATUS: READY\nAR-CORE: AKTIV" 
              : "FACE-SYNC: ANALYZING\nLUMEN: 420\nAR-CORE: AKTIV", 
            Icons.insights_rounded
          ),
        ),
      ],
    );
  }

  Widget _buildHUDCorner({double? top, double? bottom, double? left, double? right, bool isBottom = false, bool isRotated = false}) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          border: Border(
            top: top != null ? const BorderSide(color: Colors.cyanAccent, width: 2) : BorderSide.none,
            bottom: bottom != null ? const BorderSide(color: Colors.cyanAccent, width: 2) : BorderSide.none,
            left: left != null ? const BorderSide(color: Colors.cyanAccent, width: 2) : BorderSide.none,
            right: right != null ? const BorderSide(color: Colors.cyanAccent, width: 2) : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildTrackingPoint(int index) {
    return Positioned(
      top: 100 + (index * 50).toDouble(),
      left: index % 2 == 0 ? 80 : 220,
      child: Pulse(
        infinite: true,
        child: Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(color: Colors.cyanAccent, shape: BoxShape.circle),
        ),
      ),
    );
  }

  Widget _buildHUDSideLabel(String text, IconData icon) {
    return FadeInLeft(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.cyanAccent.withValues(alpha: 0.5), size: 16),
          const SizedBox(height: 8),
          Text(
            text,
            style: GoogleFonts.robotoMono(color: Colors.cyanAccent.withValues(alpha: 0.7), fontSize: 10, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildModernBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Model Info
                Text(
                  _glasses[_selectedGlassesIndex]['name']!.toUpperCase(),
                  style: GoogleFonts.outfit(color: Colors.cyanAccent, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Glissez pour déplacer • Pincez pour zoomer",
                  style: TextStyle(color: Colors.white38, fontSize: 10),
                ),
                const SizedBox(height: 32),
                // Main CTA
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text(
                        "CAPTURER LE RENDU",
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
