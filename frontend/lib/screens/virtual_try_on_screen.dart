import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:eyeglasses_shop/web_helper.dart'
    if (dart.library.io) 'package:eyeglasses_shop/web_helper_stub.dart'
    as webHelper;

class VirtualTryOnScreen extends StatefulWidget {
  final String? initialTryOnAsset;
  const VirtualTryOnScreen({super.key, this.initialTryOnAsset});

  @override
  State<VirtualTryOnScreen> createState() => _VirtualTryOnScreenState();
}

class _VirtualTryOnScreenState extends State<VirtualTryOnScreen>
    with SingleTickerProviderStateMixin {
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
    {'name': 'Black Classic', 'image': 'assets/glasses/3D/black_eyeglasses.glb'},
    {'name': 'Eyeglasses',    'image': 'assets/glasses/3D/eyeglasses.glb'},
    {'name': 'Modele A01',    'image': 'assets/glasses/3D/eyeglasses_a01.glb'},
    {'name': 'Black V5',      'image': 'assets/glasses/3D/eyeglasses_black_v5.glb'},
    {'name': 'Specs',         'image': 'assets/glasses/3D/eyeglasses_specs.glb'},
    {'name': 'Eyewear',       'image': 'assets/glasses/3D/eyewear_specs.glb'},
    {'name': 'Glasses',       'image': 'assets/glasses/3D/glasses.glb'},
    {'name': 'Ray-Ban',       'image': 'assets/glasses/3D/ray_ban_glasses.glb'},
    {'name': 'Rounded',       'image': 'assets/glasses/3D/rounded_rectangle_eyeglasses.glb'},
    {'name': 'Wayfarer',      'image': 'assets/glasses/3D/wayfarer_sunglasses_-_eyeglasses_rims.glb'},
    {'name': 'Wayfarer V2',   'image': 'assets/glasses/3D/wayfarer_sunglasses_eyeglasses_rims.glb'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialTryOnAsset != null) {
      final index = _glasses.indexWhere((g) => g['image'] == widget.initialTryOnAsset);
      if (index != -1) {
        _selectedGlassesIndex = index;
      } else {
        _glasses.insert(0, {'name': 'Sélection', 'image': widget.initialTryOnAsset!});
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

    // Sur Web → utiliser la page HTML 3D
    if (kIsWeb) {
      if (mounted) setState(() => _cameraError = true);
      _startScanningSimulation();
      return;
    }

    // Sur Mobile (Android/iOS) → caméra native
    try {
      final permission = await Permission.camera.request();
      if (!permission.isGranted) {
        if (mounted) setState(() => _cameraError = true);
        _startScanningSimulation();
        return;
      }

      final cameras = await availableCameras().timeout(const Duration(seconds: 5));
      if (cameras.isEmpty) {
        if (mounted) setState(() => _cameraError = true);
        _startScanningSimulation();
        return;
      }

      _controller = CameraController(
        cameras[0],
        ResolutionPreset.high,
        enableAudio: false,
      );
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
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isScanningComplete = true;
          _scanController.stop();
        });
      }
    });
  }

  void _open3DExperience() {
    if (kIsWeb) {
      webHelper.openUrl('virtual_tryon_3d.html');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Fonctionnalité disponible sur la version Web',
            style: GoogleFonts.outfit(),
          ),
          backgroundColor: const Color(0xFF6366F1),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
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
          // Camera Preview
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
            _buildNoCameraBackground()
          else
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.cyanAccent),
                  SizedBox(height: 24),
                  Text("Recherche de la caméra...",
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),

          // HUD Overlay
          _buildHUDOverlay(),

          // Bottom Panel
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
                      icon: const Icon(Icons.close_rounded,
                          color: Colors.white, size: 24),
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

  Widget _buildNoCameraBackground() {
    return Container(
      color: const Color(0xFF0F172A),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.view_in_ar_rounded,
                  color: Color(0xFF6366F1), size: 48),
            ),
            const SizedBox(height: 24),
            Text(
              "Essai AR 3D",
              style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                kIsWeb
                    ? "Cliquez sur le bouton ci-dessous pour activer la caméra et essayer les lunettes en 3D."
                    : "Ouvrez l'application sur un navigateur Web pour l'essai 3D.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    color: Colors.white54, fontSize: 13, height: 1.5),
              ),
            ),
            if (kIsWeb) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _open3DExperience,
                icon: const Icon(Icons.view_in_ar_rounded),
                label: Text("Lancer l'Essai 3D",
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHUDOverlay() {
    return Stack(
      children: [
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Stack(
              children: [
                _buildHUDCorner(top: 0, left: 0),
                _buildHUDCorner(top: 0, right: 0),
                _buildHUDCorner(bottom: 0, left: 0, isBottom: true),
                _buildHUDCorner(bottom: 0, right: 0, isBottom: true),
              ],
            ),
          ),
        ),
        Center(
          child: Container(
            width: 320,
            height: 450,
            decoration: BoxDecoration(
              border: Border.all(
                  color: Colors.cyanAccent.withValues(alpha: 0.2), width: 1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                ...List.generate(6, (index) => _buildTrackingPoint(index)),
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
                GestureDetector(
                  onScaleStart: (details) => _baseScale = _scale,
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
                          child: const Icon(
                            Icons.remove_red_eye_rounded,
                            color: Colors.cyanAccent,
                            size: 80,
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
        Positioned(
          left: 30,
          bottom: 250,
          child: _buildHUDSideLabel(
              "X-AXIS: 1.42\nY-AXIS: -0.85\nZOOM: 2.1x",
              Icons.bar_chart_rounded),
        ),
        Positioned(
          right: 30,
          bottom: 250,
          child: _buildHUDSideLabel(
            _isScanningComplete
                ? "FACE-SYNC: 100%\nSTATUS: READY\nAR-CORE: AKTIV"
                : "FACE-SYNC: ANALYZING\nLUMEN: 420\nAR-CORE: AKTIV",
            Icons.insights_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildHUDCorner({
    double? top,
    double? bottom,
    double? left,
    double? right,
    bool isBottom = false,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          border: Border(
            top: top != null
                ? const BorderSide(color: Colors.cyanAccent, width: 2)
                : BorderSide.none,
            bottom: bottom != null
                ? const BorderSide(color: Colors.cyanAccent, width: 2)
                : BorderSide.none,
            left: left != null
                ? const BorderSide(color: Colors.cyanAccent, width: 2)
                : BorderSide.none,
            right: right != null
                ? const BorderSide(color: Colors.cyanAccent, width: 2)
                : BorderSide.none,
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
          decoration: const BoxDecoration(
              color: Colors.cyanAccent, shape: BoxShape.circle),
        ),
      ),
    );
  }

  Widget _buildHUDSideLabel(String text, IconData icon) {
    return FadeInLeft(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon,
              color: Colors.cyanAccent.withValues(alpha: 0.5), size: 16),
          const SizedBox(height: 8),
          Text(
            text,
            style: GoogleFonts.robotoMono(
                color: Colors.cyanAccent.withValues(alpha: 0.7),
                fontSize: 10,
                height: 1.5),
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
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(40)),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _glasses[_selectedGlassesIndex]['name']!.toUpperCase(),
                  style: GoogleFonts.outfit(
                      color: Colors.cyanAccent,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Glissez pour déplacer • Pincez pour zoomer",
                  style: TextStyle(color: Colors.white38, fontSize: 10),
                ),
                const SizedBox(height: 24),

                // Sélecteur de lunettes
                SizedBox(
                  height: 50,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: _glasses.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) {
                      final selected = i == _selectedGlassesIndex;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedGlassesIndex = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected
                                ? Colors.cyanAccent.withValues(alpha: 0.2)
                                : Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: selected
                                  ? Colors.cyanAccent
                                  : Colors.white24,
                            ),
                          ),
                          child: Text(
                            _glasses[i]['name']!,
                            style: GoogleFonts.outfit(
                              color: selected
                                  ? Colors.cyanAccent
                                  : Colors.white60,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Boutons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      // Bouton ESSAI 3D (Web seulement)
                      if (kIsWeb) ...[
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: _open3DExperience,
                              icon: const Icon(Icons.view_in_ar_rounded,
                                  size: 20),
                              label: Text(
                                "ESSAI 3D",
                                style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6366F1),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],

                      // Bouton CAPTURER
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18)),
                            ),
                            child: Text(
                              "CAPTURER LE RENDU",
                              style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1),
                            ),
                          ),
                        ),
                      ),
                    ],
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