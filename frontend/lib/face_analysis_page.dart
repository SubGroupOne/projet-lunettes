import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'screens/virtual_try_on_screen.dart'; // ← ton écran existant

// Imports conditionnels pour la webcam Web
import 'web_detection_helper.dart'
    if (dart.library.io) 'web_detection_stub.dart';

class FaceAnalysisPage extends StatefulWidget {
  final String accessToken;
  const FaceAnalysisPage({super.key, required this.accessToken});

  @override
  State<FaceAnalysisPage> createState() => _FaceAnalysisPageState();
}

class _FaceAnalysisPageState extends State<FaceAnalysisPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ── Config ──────────────────────────────
  static const String _apiBase = 'http://localhost:5001';
  static const _primary = Color(0xFF6366F1);
  static const _dark = Color(0xFF0F172A);
  static const _bg = Color(0xFFF8FAFC);

  // ── Catalogue lunettes ───────────────────
  List<Map<String, dynamic>> _catalog = [];

  // ── Tab 1 : Analyse ─────────────────────
  bool _isAnalyzing = false;
  Map<String, dynamic>? _analysisResult;

  // ── Tab 2 : Essai photo ──────────────────
  XFile? _pickedImage;
  bool _isTryingOn = false;
  String? _tryOnResult;
  String _selectedStyle = 'aviator';
  String _selectedImage = 'img1.jpg';
  String _selectedGlassesId = '1';

  // ── Tab 3 : Live (Web seulement) ─────────
  bool _liveActive = false;
  String? _liveFrame;
  Timer? _liveTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCatalog();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _stopLive();
    super.dispose();
  }

  // ════════════════════════════════════════
  // CATALOGUE
  // ════════════════════════════════════════

  Future<void> _loadCatalog() async {
    try {
      final res = await http.get(
        Uri.parse('$_apiBase/glasses'),
        headers: {'Authorization': 'Bearer ${widget.accessToken}'},
      );
      final data = json.decode(res.body);
      if (data['success'] == true) {
        setState(() => _catalog = List<Map<String, dynamic>>.from(data['catalog']));
        return;
      }
    } catch (_) {}
    // Fallback local (mêmes données que VirtualTryOnScreen)
    setState(() => _catalog = [
      {"id": "1", "name": "Aviator Gold",  "style": "aviator",   "brand": "Ray-Ban"},
      {"id": "2", "name": "Wayfarer Lite", "style": "wayfarer",  "brand": "Oakley"},
      {"id": "3", "name": "Clubmaster V1", "style": "cateye",    "brand": "Ray-Ban"},
      {"id": "4", "name": "Sport Pro",     "style": "rectangle", "brand": "Nike"},
    ]);
  }

  // ════════════════════════════════════════
  // APPELS API
  // ════════════════════════════════════════

  Future<String?> _toBase64(XFile file) async {
    final bytes = await file.readAsBytes();
    return 'data:image/jpeg;base64,${base64Encode(bytes)}';
  }

  Future<void> _analyzeImage(XFile file) async {
    setState(() { _isAnalyzing = true; _analysisResult = null; });
    try {
      final b64 = await _toBase64(file);
      final res = await http.post(
        Uri.parse('$_apiBase/analyze'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'image': b64}),
      );
      setState(() => _analysisResult = json.decode(res.body));
    } catch (e) {
      setState(() => _analysisResult = {"success": false, "error": "Erreur réseau : $e"});
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  Future<void> _applyTryOn() async {
    if (_pickedImage == null) return;
    setState(() { _isTryingOn = true; _tryOnResult = null; });
    try {
      final b64 = await _toBase64(_pickedImage!);
      final res = await http.post(
        Uri.parse('$_apiBase/try-on'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'image': b64, 'glasses_image': _selectedImage, 'glasses_id': _selectedGlassesId}),
      );
      final data = json.decode(res.body);
      if (data['success'] == true) {
        setState(() => _tryOnResult = data['result_image']);
      } else {
        _showSnack(data['error'] ?? 'Erreur');
      }
    } catch (e) {
      _showSnack('Erreur réseau : $e');
    } finally {
      setState(() => _isTryingOn = false);
    }
  }

  // ════════════════════════════════════════
  // WEBCAM LIVE (Web uniquement)
  // ════════════════════════════════════════

  Future<void> _startLive() async {
    if (!kIsWeb) {
      _showSnack('La webcam live est disponible sur Flutter Web uniquement.');
      return;
    }
    setState(() => _liveActive = true);
    await WebDetectionHelper.init();

    _liveTimer = Timer.periodic(const Duration(milliseconds: 350), (_) async {
      final videos = WebDetectionHelper.findVideos();
      if (videos.isEmpty) return;
      final result = await WebDetectionHelper.detect(videos.first);
      if (result != null && mounted) {
        // On envoie la frame à notre API Python
        final res = await http.post(
          Uri.parse('$_apiBase/try-on-live'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'frame': result, 'glasses_image': _selectedImage}),
        );
        final data = json.decode(res.body);
        if (data['success'] == true && mounted) {
          setState(() => _liveFrame = data['result_frame']);
        }
      }
    });
  }

  void _stopLive() {
    _liveTimer?.cancel();
    setState(() { _liveActive = false; _liveFrame = null; });
  }

  // ════════════════════════════════════════
  // PICK IMAGE
  // ════════════════════════════════════════

  Future<void> _pickImage({bool fromCamera = true}) async {
    final file = await ImagePicker().pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;
    setState(() { _pickedImage = file; _tryOnResult = null; _analysisResult = null; });
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _dark,
        title: Text('Analyse & Essai IA',
            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: _primary,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(icon: Icon(Icons.face_retouching_natural_rounded), text: 'Analyse'),
            Tab(icon: Icon(Icons.photo_camera_rounded), text: 'Essai Photo'),
            Tab(icon: Icon(Icons.videocam_rounded), text: 'Essai Live'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAnalysisTab(),
          _buildTryOnPhotoTab(),
          _buildTryOnLiveTab(),
        ],
      ),
    );
  }

  // ────────────────────────────────────────
  // TAB 1 — ANALYSE FORME VISAGE
  // ────────────────────────────────────────

  Widget _buildAnalysisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        _sectionHeader(Icons.face_retouching_natural_rounded, 'Analyse de votre visage',
            'Détectez votre forme et recevez des recommandations personnalisées'),
        const SizedBox(height: 24),
        Row(children: [
          Expanded(child: _pickBtn('Caméra', Icons.camera_alt_rounded, () async {
            await _pickImage(fromCamera: true);
            if (_pickedImage != null) await _analyzeImage(_pickedImage!);
          })),
          const SizedBox(width: 12),
          Expanded(child: _pickBtn('Galerie', Icons.photo_library_rounded, () async {
            await _pickImage(fromCamera: false);
            if (_pickedImage != null) await _analyzeImage(_pickedImage!);
          })),
        ]),
        const SizedBox(height: 24),
        if (_isAnalyzing) _loadingCard('Analyse en cours...'),
        if (_analysisResult != null) _buildAnalysisResult(_analysisResult!),
      ]),
    );
  }

  Widget _buildAnalysisResult(Map<String, dynamic> result) {
    if (result['success'] != true) return _errorCard(result['error'] ?? 'Erreur');

    final reco = result['recommendation'] as Map<String, dynamic>;
    final shape = result['face_shape'] as String;
    final frames = List<String>.from(reco['frames'] ?? []);
    final avoid = List<String>.from(reco['avoid'] ?? []);
    final previewB64 = result['preview_image'] as String?;

    return FadeIn(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Preview photo analysée
        if (previewB64 != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.memory(base64Decode(previewB64.split(',')[1]),
                width: double.infinity, height: 220, fit: BoxFit.cover),
          ),
        const SizedBox(height: 20),

        // Forme détectée
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(children: [
            Text(reco['emoji'] ?? '😊', style: const TextStyle(fontSize: 44)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Forme détectée', style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
              Text(shape.toUpperCase(), style: GoogleFonts.outfit(
                  color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(reco['description'] ?? '', style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.8), fontSize: 12)),
            ])),
          ]),
        ),
        const SizedBox(height: 16),

        // Recommandations
        _infoCard('✅ Montures recommandées', Colors.green.shade50, Colors.green.shade200,
          Wrap(spacing: 8, runSpacing: 8,
            children: frames.map((f) => Chip(
              label: Text(f, style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600, color: Colors.green.shade800)),
              backgroundColor: Colors.green.shade100, side: BorderSide.none,
            )).toList(),
          ),
        ),
        const SizedBox(height: 12),
        _infoCard('❌ À éviter', Colors.red.shade50, Colors.red.shade200,
          Text(avoid.join(', '), style: GoogleFonts.inter(color: Colors.red.shade700)),
        ),
        const SizedBox(height: 20),

        // CTA → Essai virtuel
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _tabController.animateTo(1),
            icon: const Icon(Icons.photo_camera_rounded),
            label: Text('Essayer des lunettes →',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _dark, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),

        // CTA → VirtualTryOnScreen (ton écran existant)
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const VirtualTryOnScreen())),
            icon: const Icon(Icons.videocam_rounded),
            label: Text('Essai AR complet →',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ]),
    );
  }

  // ────────────────────────────────────────
  // TAB 2 — ESSAI PHOTO STATIQUE
  // ────────────────────────────────────────

  Widget _buildTryOnPhotoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHeader(Icons.photo_camera_rounded, 'Essai virtuel photo',
            'Chargez une photo et essayez différentes montures'),
        const SizedBox(height: 24),

        // Zone photo
        GestureDetector(
          onTap: _showPickOptions,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _primary.withOpacity(0.3), width: 2),
            ),
            child: _pickedImage == null
                ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.add_a_photo_rounded, size: 48, color: _primary),
                    const SizedBox(height: 12),
                    Text('Appuyez pour choisir une photo',
                        style: GoogleFonts.outfit(color: _primary, fontWeight: FontWeight.bold)),
                  ])
                : ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: kIsWeb
                        ? Image.network(_pickedImage!.path,
                            width: double.infinity, fit: BoxFit.cover)
                        : Image.file(File(_pickedImage!.path),
                            width: double.infinity, fit: BoxFit.cover),
                  ),
          ),
        ),
        const SizedBox(height: 20),

        // Sélecteur de lunettes
        if (_catalog.isNotEmpty) ...[
          Text('Choisir les lunettes',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: _dark)),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _catalog.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final g = _catalog[i];
                final selected = _selectedGlassesId == g['id'];
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedGlassesId = g['id'];
                    _selectedStyle = g['style'] ?? 'aviator';
                    _selectedImage = g['mainImage'] ?? 'img1.jpg';
                    _tryOnResult = null;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? _primary : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: selected ? _primary : Colors.black12,
                          width: selected ? 2 : 1),
                      boxShadow: selected
                          ? [BoxShadow(color: _primary.withOpacity(0.3), blurRadius: 12)]
                          : [],
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.remove_red_eye_rounded,
                          color: selected ? Colors.white : Colors.black45),
                      const SizedBox(height: 4),
                      Text(g['name'] ?? '',
                          style: GoogleFonts.inter(
                              fontSize: 11, fontWeight: FontWeight.w600,
                              color: selected ? Colors.white : _dark)),
                    ]),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Bouton essayer
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: (_pickedImage == null || _isTryingOn) ? null : _applyTryOn,
            icon: _isTryingOn
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.auto_fix_high_rounded),
            label: Text(_isTryingOn ? 'Application...' : 'Essayer ces lunettes',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Résultat
        if (_tryOnResult != null) ...[
          Text('Résultat', style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold, fontSize: 18, color: _dark)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.memory(base64Decode(_tryOnResult!.split(',')[1]),
                width: double.infinity, fit: BoxFit.contain),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const VirtualTryOnScreen())),
              icon: const Icon(Icons.videocam_rounded),
              label: Text('Essayer en AR complet',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ]),
    );
  }

  // ────────────────────────────────────────
  // TAB 3 — ESSAI LIVE WEBCAM
  // ────────────────────────────────────────

  Widget _buildTryOnLiveTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        _sectionHeader(Icons.videocam_rounded, 'Essai virtuel en direct',
            'Activez la webcam pour essayer les lunettes en temps réel'),
        const SizedBox(height: 24),

        // Zone vidéo traitée
        Container(
          height: 280,
          decoration: BoxDecoration(
              color: Colors.black, borderRadius: BorderRadius.circular(24)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: _liveFrame != null
                ? Image.memory(base64Decode(_liveFrame!.split(',')[1]),
                    width: double.infinity, fit: BoxFit.cover)
                : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.videocam_off_rounded,
                        size: 56, color: Colors.white.withOpacity(0.3)),
                    const SizedBox(height: 12),
                    Text(_liveActive ? 'Initialisation...' : 'Webcam inactive',
                        style: GoogleFonts.inter(color: Colors.white54)),
                  ]),
          ),
        ),
        const SizedBox(height: 20),

        // Sélecteur lunettes live
        if (_catalog.isNotEmpty) ...[
          Text('Lunettes à essayer', style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold, fontSize: 16, color: _dark)),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _catalog.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final g = _catalog[i];
                final selected = _selectedGlassesId == g['id'];
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedGlassesId = g['id'];
                    _selectedStyle = g['style'] ?? 'aviator';
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? _dark : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: selected ? _dark : Colors.black12),
                    ),
                    child: Text(g['name'] ?? '',
                        style: GoogleFonts.inter(
                            fontSize: 12, fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : _dark)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Start/Stop webcam
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _liveActive ? _stopLive : _startLive,
            icon: Icon(_liveActive ? Icons.stop_rounded : Icons.play_arrow_rounded),
            label: Text(_liveActive ? 'Arrêter la webcam' : 'Démarrer la webcam',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _liveActive ? Colors.red.shade600 : _dark,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // CTA vers VirtualTryOnScreen (ton écran AR existant)
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const VirtualTryOnScreen())),
            icon: const Icon(Icons.auto_awesome_rounded),
            label: Text('Ouvrir l\'essai AR complet',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),

        if (!kIsWeb) ...[
          const SizedBox(height: 16),
          _infoCard('📱 Sur mobile', Colors.orange.shade50, Colors.orange.shade200,
            Text(
              'La webcam live fonctionne sur Flutter Web.\nSur mobile, utilisez "Essai Photo" ou l\'essai AR complet.',
              style: GoogleFonts.inter(color: Colors.orange.shade800, fontSize: 13),
            ),
          ),
        ],
      ]),
    );
  }

  // ════════════════════════════════════════
  // WIDGETS RÉUTILISABLES
  // ════════════════════════════════════════

  Widget _sectionHeader(IconData icon, String title, String subtitle) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: _primary.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
        child: Icon(icon, color: _primary, size: 28),
      ),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold, fontSize: 16, color: _dark)),
        Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600])),
      ])),
    ]);
  }

  Widget _pickBtn(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _primary.withOpacity(0.2)),
        ),
        child: Column(children: [
          Icon(icon, color: _primary, size: 32),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: _dark)),
        ]),
      ),
    );
  }

  Widget _loadingCard(String msg) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        const CircularProgressIndicator(color: _primary, strokeWidth: 3),
        const SizedBox(width: 16),
        Text(msg, style: GoogleFonts.inter(color: _dark)),
      ]),
    );
  }

  Widget _errorCard(String msg) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.red.shade50, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.shade200)),
      child: Row(children: [
        const Icon(Icons.error_outline_rounded, color: Colors.red),
        const SizedBox(width: 12),
        Expanded(child: Text(msg, style: GoogleFonts.inter(color: Colors.red.shade700))),
      ]),
    );
  }

  Widget _infoCard(String title, Color bg, Color border, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold, fontSize: 14, color: _dark)),
        const SizedBox(height: 8),
        child,
      ]),
    );
  }

  void _showPickOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Choisir une photo',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.camera_alt_rounded, color: _primary),
            title: Text('Prendre une photo', style: GoogleFonts.inter()),
            onTap: () { Navigator.pop(context); _pickImage(fromCamera: true); },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_rounded, color: _primary),
            title: Text('Choisir depuis la galerie', style: GoogleFonts.inter()),
            onTap: () { Navigator.pop(context); _pickImage(fromCamera: false); },
          ),
        ]),
      ),
    );
  }
}