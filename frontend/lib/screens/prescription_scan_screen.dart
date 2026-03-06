import 'dart:convert';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class PrescriptionScanScreen extends StatefulWidget {
  const PrescriptionScanScreen({super.key});

  @override
  State<PrescriptionScanScreen> createState() => _PrescriptionScanScreenState();
}

class _PrescriptionScanScreenState extends State<PrescriptionScanScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isScanning = false;
  bool _scanComplete = false;
  bool _hasError = false;
  String _errorMessage = '';
  late AnimationController _pulseController;

  // Résultats extraits
  String _rawText = '';
  String _odSph = '-';
  String _odCyl = '-';
  String _odAxe = '-';
  String _ogSph = '-';
  String _ogCyl = '-';
  String _ogAxe = '-';
  String _ecartPupillaire = '-';

  final ImagePicker _imagePicker = ImagePicker();

  // ⚠️ Remplace par l'IP de ton PC si accès depuis téléphone
  static const String _apiUrl = 'http://192.168.100.19:5001/scan-ordonnance';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    if (!kIsWeb) _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      _controller = CameraController(cameras[0], ResolutionPreset.high);
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

  // ─── Capturer et envoyer au backend Python ──────────────
  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      String? base64Image;

      if (!kIsWeb && _isCameraInitialized && _controller != null) {
        // Prendre une photo avec la caméra
        final XFile photo = await _controller!.takePicture();
        final bytes = await photo.readAsBytes();
        base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      } else {
        // Sur Web ou si caméra non dispo → galerie
        final XFile? picked = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 90,
        );
        if (picked == null) {
          setState(() => _isScanning = false);
          return;
        }
        final bytes = await picked.readAsBytes();
        base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      }

      // Envoyer au backend Python
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'image': base64Image}),
      ).timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        setState(() {
          _rawText          = data['raw_text']         ?? '';
          _odSph            = data['od_sph']           ?? '-';
          _odCyl            = data['od_cyl']           ?? '-';
          _odAxe            = data['od_axe']           ?? '-';
          _ogSph            = data['og_sph']           ?? '-';
          _ogCyl            = data['og_cyl']           ?? '-';
          _ogAxe            = data['og_axe']           ?? '-';
          _ecartPupillaire  = data['ecart_pupillaire'] ?? '-';
          _isScanning       = false;
          _scanComplete     = true;
        });
      } else {
        setState(() {
          _isScanning   = false;
          _hasError     = true;
          _errorMessage = data['error'] ?? 'Erreur inconnue';
        });
      }
    } catch (e) {
      setState(() {
        _isScanning   = false;
        _hasError     = true;
        _errorMessage = 'Impossible de contacter le serveur.\nVérifiez que Python (face_api.py) est lancé.';
      });
    }
  }

  // ─── Import depuis la galerie ───────────────────────────
  Future<void> _importerDepuisGalerie() async {
    final XFile? picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (picked == null) return;

    setState(() {
      _isScanning   = true;
      _hasError     = false;
      _errorMessage = '';
    });

    try {
      final bytes = await picked.readAsBytes();
      final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'image': base64Image}),
      ).timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        setState(() {
          _rawText          = data['raw_text']         ?? '';
          _odSph            = data['od_sph']           ?? '-';
          _odCyl            = data['od_cyl']           ?? '-';
          _odAxe            = data['od_axe']           ?? '-';
          _ogSph            = data['og_sph']           ?? '-';
          _ogCyl            = data['og_cyl']           ?? '-';
          _ogAxe            = data['og_axe']           ?? '-';
          _ecartPupillaire  = data['ecart_pupillaire'] ?? '-';
          _isScanning       = false;
          _scanComplete     = true;
        });
      } else {
        setState(() {
          _isScanning   = false;
          _hasError     = true;
          _errorMessage = data['error'] ?? 'Erreur inconnue';
        });
      }
    } catch (e) {
      setState(() {
        _isScanning   = false;
        _hasError     = true;
        _errorMessage = 'Impossible de contacter le serveur.\nVérifiez que Python (face_api.py) est lancé.';
      });
    }
  }

  void _reset() {
    setState(() {
      _scanComplete     = false;
      _hasError         = false;
      _errorMessage     = '';
      _rawText          = '';
      _odSph = _odCyl = _odAxe = '-';
      _ogSph = _ogCyl = _ogAxe = '-';
      _ecartPupillaire  = '-';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fond caméra
          if (_isCameraInitialized && !kIsWeb)
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

          // Chargement
          if (_isScanning)
            Container(
              color: Colors.black.withValues(alpha: 0.8),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Color(0xFF6366F1)),
                    const SizedBox(height: 24),
                    Text("Extraction OCR en cours...",
                        style: GoogleFonts.outfit(
                            color: Colors.white, fontSize: 16, letterSpacing: 1)),
                    const SizedBox(height: 8),
                    Text("Tesseract analyse l'image",
                        style: GoogleFonts.robotoMono(
                            color: Colors.white38, fontSize: 12)),
                  ],
                ),
              ),
            ),

          // HUD scan
          if (!_scanComplete && !_isScanning && !_hasError) _buildScanHUD(),

          // Résultats
          if (_scanComplete) _buildResultsModal(),

          // Erreur
          if (_hasError && !_isScanning) _buildErrorMessage(),

          // Bouton retour
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
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 20),
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
        // Overlay sombre avec découpe
        ColorFiltered(
          colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.7), BlendMode.srcOut),
          child: Stack(
            children: [
              Container(decoration: const BoxDecoration(color: Colors.black)),
              Center(
                child: Container(
                  width: 320, height: 450,
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(24)),
                ),
              ),
            ],
          ),
        ),

        // Cadre scan
        Center(
          child: Container(
            width: 320, height: 450,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white30),
                borderRadius: BorderRadius.circular(24)),
            child: _buildHUDBorder(),
          ),
        ),

        // Boutons en bas
        Positioned(
          bottom: 60, left: 24, right: 24,
          child: Column(
            children: [
              FadeInUp(
                child: Text("SCAN D'ORDONNANCE",
                    style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1)),
              ),
              const SizedBox(height: 12),
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  kIsWeb
                      ? "Importez une photo de l'ordonnance."
                      : "Placez l'ordonnance dans le cadre\npuis appuyez sur Scanner.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: Colors.white60, fontSize: 13),
                ),
              ),
              const SizedBox(height: 28),

              // Bouton Scanner (caché sur Web)
              if (!kIsWeb)
                ZoomIn(
                  child: SizedBox(
                    width: double.infinity, height: 60,
                    child: ElevatedButton.icon(
                      onPressed: _startScan,
                      icon: const Icon(Icons.document_scanner_rounded),
                      label: Text("SCANNER L'ORDONNANCE",
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold, letterSpacing: 1)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                ),

              if (!kIsWeb) const SizedBox(height: 12),

              // Bouton galerie
              ZoomIn(
                delay: const Duration(milliseconds: 100),
                child: SizedBox(
                  width: double.infinity, height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _importerDepuisGalerie,
                    icon: const Icon(Icons.photo_library_rounded, size: 18),
                    label: Text("IMPORTER UNE PHOTO",
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600, letterSpacing: 1)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white30),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
          top:    top  ? const BorderSide(color: Color(0xFF6366F1), width: 4) : BorderSide.none,
          bottom: !top ? const BorderSide(color: Color(0xFF6366F1), width: 4) : BorderSide.none,
          left:   left ? const BorderSide(color: Color(0xFF6366F1), width: 4) : BorderSide.none,
          right:  !left? const BorderSide(color: Color(0xFF6366F1), width: 4) : BorderSide.none,
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
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white10),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.1),
                            shape: BoxShape.circle),
                        child: const Icon(Icons.check_rounded,
                            color: Color(0xFF10B981), size: 32),
                      ),
                      const SizedBox(height: 16),
                      Text("Ordonnance Extraite",
                          style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text("Vérifiez et corrigez si nécessaire",
                          style: GoogleFonts.inter(
                              color: Colors.white38, fontSize: 12)),
                      const SizedBox(height: 24),

                      _buildResultItem("Œil Droit (OD)",
                          "Sph: $_odSph  |  Cyl: $_odCyl  |  Axe: $_odAxe",
                          Icons.visibility_outlined),
                      const SizedBox(height: 12),
                      _buildResultItem("Œil Gauche (OG)",
                          "Sph: $_ogSph  |  Cyl: $_ogCyl  |  Axe: $_ogAxe",
                          Icons.visibility_outlined),
                      const SizedBox(height: 12),
                      _buildResultItem("Écart Pupillaire",
                          _ecartPupillaire, Icons.straighten_rounded),

                      // Texte brut
                      if (_rawText.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Texte brut OCR",
                                  style: GoogleFonts.inter(
                                      color: Colors.white38,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text(
                                _rawText.length > 400
                                    ? '${_rawText.substring(0, 400)}...'
                                    : _rawText,
                                style: GoogleFonts.robotoMono(
                                    color: Colors.white54, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity, height: 48,
                        child: OutlinedButton.icon(
                          onPressed: _reset,
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: Text("SCANNER À NOUVEAU",
                              style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w600, letterSpacing: 1)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white60,
                            side: const BorderSide(color: Colors.white24),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity, height: 56,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF0F172A),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                          child: Text("VALIDER ET CONTINUER",
                              style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text("Échec de l'extraction",
                style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_errorMessage,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.refresh_rounded),
              label: Text("Réessayer",
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10)),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.inter(
                        color: Colors.white60,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(value,
                    style: GoogleFonts.robotoMono(
                        color: Colors.white, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}