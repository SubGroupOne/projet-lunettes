import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'mobile_detection_helper.dart' if (dart.library.html) 'mobile_detection_stub.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'dart:async';
import 'web_detection_stub.dart' if (dart.library.html) 'web_detection_helper.dart';
import 'scanner_ordonnance_page.dart';

class VirtualTryOnPage extends StatefulWidget {
  final String? initialFrameAsset;
  const VirtualTryOnPage({super.key, this.initialFrameAsset});

  @override
  State<VirtualTryOnPage> createState() => _VirtualTryOnPageState();
}

class _VirtualTryOnPageState extends State<VirtualTryOnPage> {
  // Navigation and Filtering
  int _selectedFrameIndex = -1;
  String _selectedCategory = "Tout";
  double _glassesSizeScale = 1.25; 

  final List<String> _allFrames = [
    'assets/blue_sunglasses.png',
    'assets/orange_sunglasses.png',
    'assets/tortoise_glasses.png',
    'assets/pink_gold_glasses.png',
    'assets/glasses.png',
  ];


  // Camera & Face Detection
  CameraController? _cameraController;
  dynamic _faceDetector;
  bool _isBusy = false;
  List<dynamic> _faces = [];
  List<dynamic>? _webFaceLandmarks;
  bool _isCameraReady = false;
  bool _isFrontCamera = true; // Track camera direction

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeDetector();
    _handleInitialSelection();
    if (kIsWeb) {
      _initWebLandmarker();
    }
  }

  Future<void> _initWebLandmarker() async {
    try {
      final success = await WebDetectionHelper.init();
      if (success) {
        _startWebDetection();
      }
    } catch (e) {
      debugPrint("Web Landmarker init error: $e");
    }
  }

  void _startWebDetection() {
    debugPrint("Web detection started loop");
    Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      if (!mounted || !kIsWeb || _isBusy) return;
      
      final videos = WebDetectionHelper.findVideos();
      if (videos.isEmpty) {
        // debugPrint("No video elements found for detection");
        return;
      }

      final video = videos.first;
      
      _isBusy = true;
      try {
        final result = await WebDetectionHelper.detect(video);
        if (result != null) {
          final data = jsonDecode(result);
          _processWebResults(data);
        }
      } catch (e) {
        debugPrint("Web Detection error: $e");
      }
      _isBusy = false;
    });
  }

  void _processWebResults(dynamic data) {
    if (data == null || data['faceLandmarks'] == null || (data['faceLandmarks'] as List).isEmpty) {
      if (_faces.isNotEmpty || _webFaceLandmarks != null) {
        setState(() {
          _faces = [];
          _webFaceLandmarks = null;
        });
      }
      return;
    }

    final landmarks = data['faceLandmarks'][0] as List;

    if (mounted) {
      setState(() {
        _webFaceLandmarks = landmarks;
      });
    }
  }

  List<dynamic>? _webFaceLandmarks;

  void _handleInitialSelection() {
    if (widget.initialFrameAsset != null) {
      // Find the index of the passed asset
      final index = _allFrames.indexOf(widget.initialFrameAsset!);
      if (index != -1) {
        setState(() {
          _selectedFrameIndex = index;
        });
      } else {
        // If not found in the list, add it to the list 
        // Note: This assumes the passed asset is a valid transparent PNG
        setState(() {
          _allFrames.insert(0, widget.initialFrameAsset!);
          _selectedFrameIndex = 0;
        });
      }
    }
  }

  void _initializeDetector() async {
    if (kIsWeb) return;
    _faceDetector = await MobileDetectionHelper.createDetector();
  }

  Future<void> _initializeCamera() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      final cameras = await availableCameras();
      final targetDirection = _isFrontCamera 
          ? CameraLensDirection.front 
          : CameraLensDirection.back;

      final selectedCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == targetDirection,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: kIsWeb ? ImageFormatGroup.jpeg : (defaultTargetPlatform == TargetPlatform.android ? ImageFormatGroup.yuv420 : ImageFormatGroup.bgra8888),
      );

      try {
        await _cameraController!.initialize();
        if (!mounted) return;

        if (!kIsWeb) {
          _cameraController!.startImageStream(_processCameraImage);
        }

        setState(() {
          _isCameraReady = true;
        });
      } catch (e) {
        debugPrint('Camera initialization error: $e');
      }
    }
  }

  void _processCameraImage(CameraImage image) {
    if (_isBusy) return;
    _isBusy = true;

    _processImage(image).then((_) {
      _isBusy = false;
    });
  }

  Future<void> _processImage(CameraImage image) async {
    if (kIsWeb || _faceDetector == null || _isBusy) return;

    final cameras = await availableCameras();
    final camera = cameras.firstWhere(
      (c) => c.lensDirection == (_isFrontCamera ? CameraLensDirection.front : CameraLensDirection.back),
      orElse: () => cameras.first,
    );

    _isBusy = true;
    try {
      final faces = await MobileDetectionHelper.processImage(_faceDetector, image, camera);
      if (mounted) {
        setState(() {
          _faces = faces;
        });
      }
    } catch (e) {
      debugPrint('Face detection error: $e');
    }
    _isBusy = false;
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101820), // Dark background from mockup
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  const SizedBox(width: 48), // Spacer for centering
                  const Expanded(
                    child: Text(
                      'Essais Virtuel',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _toggleCamera,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.flip_camera_ios_outlined,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Camera Viewport (Bounded Area)
            Expanded(
              child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                  ),
                clipBehavior: Clip.antiAlias,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        // Camera Feed
                        _isCameraReady && _cameraController != null
                            ? Center(
                                child: CameraPreview(_cameraController!),
                              )
                            : const Center(
                                child: CircularProgressIndicator(color: Colors.white24),
                              ),

                        // Glasses Overlay (Scoped to this stack)
                        if (_isCameraReady && _selectedFrameIndex != -1)
                          if (_faces.isNotEmpty)
                            ..._faces.map((face) => _buildGlassesOverlay(face, constraints.biggest))
                          else if (kIsWeb && _webFaceLandmarks != null)
                            _buildWebGlassesOverlay(constraints.biggest),
    
                            // Corner Brackets (Focus Markers)
                            CustomPaint(
                              painter: CornerBracketsPainter(),
                            ),
    
                            // AR Guide / Silhouette (When no faces detected)
                            if (_faces.isEmpty && _webFaceLandmarks == null)
                              Center(
                                child: Opacity(
                                  opacity: 0.3,
                                  child: CustomPaint(
                                    size: const Size(200, 300),
                                    painter: FaceGuidePainter(),
                                  ),
                                ),
                              ),
                            
                        // Interaction Hint - Logic removed as we want automatic detection

                        if (_faces.isEmpty && !kIsWeb && _selectedFrameIndex == -1)
                          Center(
                            child: CustomPaint(
                              size: const Size(260, 130),
                              painter: GlassesGuidePainter(),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),

            // 3. Size Slider (Integrated into Bottom Panel)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.zoom_in, color: Colors.white54, size: 18),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFF4A90E2),
                        inactiveTrackColor: Colors.white12,
                        thumbColor: Colors.white,
                        trackHeight: 2,
                      ),
                      child: Slider(
                        value: _glassesSizeScale,
                        min: 0.8,
                        max: 2.5,
                        onChanged: (value) => setState(() => _glassesSizeScale = value),
                      ),
                    ),
                  ),
                  const Text("Taille", style: TextStyle(color: Colors.white54, fontSize: 10)),
                ],
              ),
            ),

            // 4. Controls & Selection Area
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF1A1F26), // Darker bottom panel
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Category Filter
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: ["Tout", "Soleil", "Optique", "Luxe"].map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCategory = cat),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF4A90E2) : Colors.white.withAlpha(20),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              cat,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white70,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Frame Gallery
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _allFrames.length,
                      itemBuilder: (context, index) {
                        final isSelected = _selectedFrameIndex == index;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedFrameIndex = index),
                          child: Container(
                            width: 100,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF4A90E2) : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Image.asset(_allFrames[index], fit: BoxFit.contain),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Add to Cart Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton(
                      onPressed: _selectedFrameIndex == -1 ? null : () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A90E2),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Ajouter au panier",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleCamera() async {
    if (_cameraController == null) return;
    
    setState(() {
      _isCameraReady = false;
      _isFrontCamera = !_isFrontCamera;
    });

    await _cameraController!.dispose();
    await _initializeCamera();
  }

  String _getAssetForSelection() {
    if (_selectedFrameIndex == -1) return ''; 
    return _allFrames[_selectedFrameIndex];
  }

  bool _shouldApplyTint() {
    return false; 
  }

  // Helper to check if we have a valid selection
  bool get _hasSelection => _selectedFrameIndex != -1;

  Widget _buildGlassesOverlay(dynamic face, Size viewportSize) {
    if (_cameraController == null || _selectedFrameIndex == -1) return const SizedBox.shrink();

    try {
      final boundingBox = MobileDetectionHelper.getBoundingBox(face);
      final landmarks = MobileDetectionHelper.getLandmarks(face);

      final leftEye = landmarks['leftEye'];
      final rightEye = landmarks['rightEye'];
      final noseBridge = landmarks['noseBase'];

      // Camera image size (typically landscape, so we swap for orientation)
      final double imgWidth = _cameraController!.value.previewSize!.height;
      final double imgHeight = _cameraController!.value.previewSize!.width;

      final double scaleX = viewportSize.width / imgWidth;
      final double scaleY = viewportSize.height / imgHeight;

      double centerX, centerY, width, rotation;

      if (leftEye != null && rightEye != null) {
        // Use landmarks for precise alignment
        centerX = (leftEye.dx * scaleX + rightEye.dx * scaleX) / 2;
        centerY = (leftEye.dy * scaleY + rightEye.dy * scaleY) / 2;
        
        // Width based on eye distance * multiplier
        width = (rightEye.dx * scaleX - leftEye.dx * scaleX).abs() * 2.2 * _glassesSizeScale;
        rotation = (face.headEulerAngleZ ?? 0) * (3.14159 / 180);
      } else {
        // Fallback to bounding box
        centerX = boundingBox.center.dx * scaleX;
        centerY = boundingBox.top * scaleY + (boundingBox.height * 0.25 * scaleY);
        width = boundingBox.width * scaleX * _glassesSizeScale;
        rotation = (face.headEulerAngleZ ?? 0) * (3.14159 / 180);
      }

      final height = width * 0.45;

      // Simulate 3D rotation using Yaw (Y) and Pitch (X)
      final yaw = (face.headEulerAngleY ?? 0); // Side to side
      final pitch = (face.headEulerAngleX ?? 0); // Up and down

      // Yaw affect horizontal scale (foreshortening)
      double yawScale = (1.0 - (yaw.abs() / 100)).clamp(0.7, 1.0);
      
      // Pitch affects vertical offset (perspective)
      double pitchOffset = (pitch / 10) * (height / 4);

      return Positioned(
        left: centerX - (width * yawScale / 2),
        top: centerY - (height / 2) + pitchOffset,
        width: width * yawScale,
        height: height,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..rotateZ(rotation)
            ..rotateY(yaw * (3.14159 / 180) * 0.5) // Subtle 3D-like turn
            ..rotateX(pitch * (3.14159 / 180) * 0.2), // Subtle tilt
          child: Image.asset(
            _getAssetForSelection(),
            fit: BoxFit.contain,
            opacity: const AlwaysStoppedAnimation(0.95),
          ),
        ),
      );
    } catch (e) {
      debugPrint("Overlay error: $e");
      return const SizedBox.shrink();
    }
  }

  Widget _buildWebGlassesOverlay(Size viewportSize) {
    if (_webFaceLandmarks == null || _selectedFrameIndex == -1) return const SizedBox.shrink();

    final landmarks = _webFaceLandmarks!;
    
    // Normalized coordinates from MediaPipe
    // Left eye (index 133 inner, 33 outer)
    // Right eye (index 362 inner, 263 outer)
    
    final lInner = landmarks[133];
    final lOuter = landmarks[33];
    final rInner = landmarks[362];
    final rOuter = landmarks[263];
    final bridge = landmarks[168]; // Bridge between eyes

    final double lx = ((lInner['x'] + lOuter['x']) / 2) * viewportSize.width;
    final double ly = ((lInner['y'] + lOuter['y']) / 2) * viewportSize.height;
    final double rx = ((rInner['x'] + rOuter['x']) / 2) * viewportSize.width;
    final double ry = ((rInner['y'] + rOuter['y']) / 2) * viewportSize.height;
    
    final double centerX = (lx + rx) / 2;
    final double centerY = (ly + ry) / 2;
    
    final double eyeDist = (rx - lx).abs();
    final double width = eyeDist * 2.2 * _glassesSizeScale;
    final double height = width * 0.45;
    
    // Rotation Z (Roll)
    final double rotationZ = (ry - ly) / (rx - lx + 0.001);

    // Estimation of Yaw (Y) and Pitch (X) from landmarks (simplified)
    // Yaw: ratio of distance from bridge to each eye inner corner
    final double distL = (lx - bridge['x'] * viewportSize.width).abs();
    final double distR = (rx - bridge['x'] * viewportSize.width).abs();
    final double yaw = (distR - distL) / (distR + distL + 0.001) * 1.5;

    return Positioned(
      left: centerX - (width / 2),
      top: centerY - (height / 2),
      width: width,
      height: height,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..rotateZ(rotationZ)
          ..rotateY(yaw.clamp(-0.8, 0.8)),
        child: Image.asset(
          _getAssetForSelection(),
          fit: BoxFit.contain,
          opacity: const AlwaysStoppedAnimation(0.95),
        ),
      ),
    );
  }

}

// Painters remain same for fallback
class GlassesGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3F3F95).withAlpha((0.8 * 255).round())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    final path = Path();
    path.addOval(Rect.fromCenter(center: Offset(size.width * 0.3, size.height / 2), width: size.width * 0.35, height: size.height * 0.6));
    path.addOval(Rect.fromCenter(center: Offset(size.width * 0.7, size.height / 2), width: size.width * 0.35, height: size.height * 0.6));
    path.moveTo(size.width * 0.47, size.height / 2);
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.4, size.width * 0.53, size.height / 2);
    canvas.drawPath(path, paint);
    final fillPaint = Paint()..color = Colors.white.withAlpha((0.1 * 255).round())..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CornerBracketsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4A90E2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    double len = 20.0;

    // Top Left
    canvas.drawLine(const Offset(0, 0), Offset(len, 0), paint);
    canvas.drawLine(const Offset(0, 0), Offset(0, len), paint);

    // Top Right
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - len, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, len), paint);

    // Bottom Left
    canvas.drawLine(Offset(0, size.height), Offset(len, size.height), paint);
    canvas.drawLine(
      Offset(0, size.height),
      Offset(0, size.height - len),
      paint,
    );

    // Bottom Right
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width - len, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width, size.height - len),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FaceGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    
    // Oval for head
    path.addOval(Rect.fromLTWH(size.width * 0.1, size.height * 0.05, size.width * 0.8, size.height * 0.8));
    
    // Guide for eyes
    path.moveTo(size.width * 0.25, size.height * 0.4);
    path.lineTo(size.width * 0.4, size.height * 0.4);
    
    path.moveTo(size.width * 0.6, size.height * 0.4);
    path.lineTo(size.width * 0.75, size.height * 0.4);
    
    // Guide for nose bridge
    path.moveTo(size.width * 0.45, size.height * 0.4);
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.35, size.width * 0.55, size.height * 0.4);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
