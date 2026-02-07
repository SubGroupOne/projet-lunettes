import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:permission_handler/permission_handler.dart';
import 'scanner_ordonnance_page.dart';

class VirtualTryOnPage extends StatefulWidget {
  const VirtualTryOnPage({super.key});

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
  FaceDetector? _faceDetector;
  bool _isBusy = false;
  List<Face> _faces = [];
  bool _isCameraReady = false;
  bool _isFrontCamera = true; // Track camera direction
  Offset? _mockGlassesOffset; // For manual positioning on PC/Web

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeDetector();
  }

  void _initializeDetector() {
    final options = FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
      performanceMode: FaceDetectorMode.fast,
    );
    _faceDetector = FaceDetector(options: options);
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

        _cameraController!.startImageStream(_processCameraImage);

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
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());

    final cameras = await availableCameras();
    final camera = cameras.firstWhere(
      (c) => c.lensDirection == (_isFrontCamera ? CameraLensDirection.front : CameraLensDirection.back),
      orElse: () => cameras.first,
    );
    final imageRotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation) ??
        InputImageRotation.rotation0deg;

    final inputImageFormat =
        InputImageFormatValue.fromRawValue(image.format.raw) ??
        InputImageFormat.yuv420;

    final metadata = InputImageMetadata(
      size: imageSize,
      rotation: imageRotation,
      format: inputImageFormat,
      bytesPerRow: image.planes[0].bytesPerRow,
    );

    final inputImage = InputImage.fromBytes(bytes: bytes, metadata: metadata);

    if (!kIsWeb) {
      try {
        final faces = await _faceDetector?.processImage(inputImage);
        if (mounted) {
          setState(() {
            _faces = faces ?? [];
          });
        }
      } catch (e) {
        debugPrint('Face detection error: $e');
      }
    }
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
                    return MouseRegion(
                      onHover: (event) {
                        if (_faces.isEmpty) {
                          setState(() {
                            _mockGlassesOffset = event.localPosition;
                          });
                        }
                      },
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          if (_faces.isEmpty) {
                            setState(() {
                              _mockGlassesOffset = details.localPosition;
                            });
                          }
                        },
                        child: Stack(
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
                              else ...[
                                _buildMockGlassesOverlay(constraints.biggest),
                                 _buildDemoModeLabel(!kIsWeb && (defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.linux || defaultTargetPlatform == TargetPlatform.macOS)),
                              ],
    
                            // Corner Brackets (Focus Markers)
                            CustomPaint(
                              painter: CornerBracketsPainter(),
                            ),
    
                            // AR Guide / Silhouette (When no faces detected)
                            if (_faces.isEmpty)
                              Center(
                                child: Opacity(
                                  opacity: 0.3,
                                  child: CustomPaint(
                                    size: const Size(200, 300),
                                    painter: FaceGuidePainter(),
                                  ),
                                ),
                              ),
                            
                            // Interaction Hint
                            if (_faces.isEmpty && _selectedFrameIndex != -1)
                              Positioned(
                                bottom: 12,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Text(
                                    "Glissez pour ajuster les lunettes",
                                    style: TextStyle(
                                      color: Colors.white.withAlpha((0.6 * 255).round()),
                                      fontSize: 10,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ),
    
                            if (_faces.isEmpty && !kIsWeb && _selectedFrameIndex == -1)
                              Center(
                                child: CustomPaint(
                                  size: const Size(260, 130),
                                  painter: GlassesGuidePainter(),
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

  Widget _buildGlassesOverlay(Face face, Size viewportSize) {
    if (_cameraController == null || _selectedFrameIndex == -1) return const SizedBox.shrink();

    // Camera image size (typically landscape, so we swap for orientation)
    final double imgWidth = _cameraController!.value.previewSize!.height;
    final double imgHeight = _cameraController!.value.previewSize!.width;

    final double scaleX = viewportSize.width / imgWidth;
    final double scaleY = viewportSize.height / imgHeight;

    final leftEye = face.landmarks[FaceLandmarkType.leftEye];
    final rightEye = face.landmarks[FaceLandmarkType.rightEye];

    double centerX, centerY, width, rotation;

    if (leftEye != null && rightEye != null) {
      // Use landmarks for precise alignment
      final leftPoint = Offset(leftEye.position.x * scaleX, leftEye.position.y * scaleY);
      final rightPoint = Offset(rightEye.position.x * scaleX, rightEye.position.y * scaleY);
      
      centerX = (leftPoint.dx + rightPoint.dx) / 2;
      centerY = (leftPoint.dy + rightPoint.dy) / 2;
      
      // Width based on eye distance * multiplier
      width = (rightPoint.dx - leftPoint.dx).abs() * 2.2 * _glassesSizeScale;
      rotation = (face.headEulerAngleZ ?? 0) * (3.14159 / 180);
    } else {
      // Fallback to bounding box
      final rect = face.boundingBox;
      centerX = rect.center.dx * scaleX;
      centerY = rect.top * scaleY + (rect.height * 0.25 * scaleY);
      width = rect.width * scaleX * _glassesSizeScale;
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
  }

  Widget _buildMockGlassesOverlay(Size viewportSize) {
    final double width = 180.0 * _glassesSizeScale;
    final double height = width * 0.45;
    
    // Use the tracked offset or default to center
    final double centerX = (_mockGlassesOffset?.dx ?? (viewportSize.width / 2));
    final double centerY = (_mockGlassesOffset?.dy ?? (viewportSize.height * 0.35));

    // Dynamic tilt based on position relative to center
    final double relativeX = (centerX - viewportSize.width / 2) / (viewportSize.width / 2);
    final double rotationY = relativeX * 0.4; // Subtle 3D-like turn

    return Positioned(
      left: centerX - (width / 2),
      top: centerY - (height / 2), 
      width: width,
      height: height,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001) // Perspective
          ..rotateY(rotationY),
        child: Image.asset(
          _getAssetForSelection(),
          fit: BoxFit.contain,
          opacity: const AlwaysStoppedAnimation(0.95),
        ),
      ),
    );
  }

  // Position the Demo Mode label separately to avoid squashing
  Widget _buildDemoModeLabel(bool isDesktop) {
    return Positioned(
      top: 12,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha((0.5 * 255).round()),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: Text(
            isDesktop ? "Mode Démo (Bureau)" : "Mode Démo Web",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
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
