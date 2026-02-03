import 'package:flutter/material.dart';
import 'scanner_ordonnance_page.dart';

class VirtualTryOnPage extends StatefulWidget {
  const VirtualTryOnPage({super.key});

  @override
  State<VirtualTryOnPage> createState() => _VirtualTryOnPageState();
}

class _VirtualTryOnPageState extends State<VirtualTryOnPage> {
  // Navigation states
  int _selectedColorIndex = 0;
  int _selectedStyleIndex = 1; // Classique selected by default

  final List<Color> _colors = [
    const Color(0xFF4A4AFF), // Blue
    const Color(0xFFA56338), // Brown
    const Color(0xFF9EAAB6), // Grey/Blueish
    const Color(0xFF9E1F4F), // Maroon
  ];

  final List<String> _styles = ['Aviateur', 'Classique', 'Rond'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Camera Background (Placeholder)
          Image.asset('assets/face_placeholder.png', fit: BoxFit.cover),

          // 2. Header
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Back Button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha((0.5 * 255).round()),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),

                      const Spacer(),

                      // Title Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha((0.5 * 255).round()),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Essai Virtuel AI',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Help Icon
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha((0.5 * 255).round()),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.help_outline,
                            color: Colors.white,
                          ),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 3. AR Overlay (Glasses Guide - Simplified visual representation)
          // Simplified Visual Guide (The blue lines in the screenshot)
          Center(
            child: CustomPaint(
              size: const Size(300, 150),
              painter: GlassesGuidePainter(),
            ),
          ),

          // Focus Brackets
          Center(
            child: SizedBox(
              width: 350,
              height: 250,
              child: CustomPaint(painter: CornerBracketsPainter()),
            ),
          ),

          // 4. Controls & Bottom Panel
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Style Selector & Color Selector Row
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      // Colors (Vertical-ish but presented in Row for this layout)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(
                            (0.2 * 255).round(),
                          ), // Glassmorphismish
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: List.generate(_colors.length, (index) {
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedColorIndex = index),
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                width: 24,
                                height: 48, // Tall pill shape
                                decoration: BoxDecoration(
                                  color: _colors[index],
                                  borderRadius: BorderRadius.circular(12),
                                  border: _selectedColorIndex == index
                                      ? Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        )
                                      : null,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Styles
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha((0.2 * 255).round()),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(_styles.length, (index) {
                              final isSelected = _selectedStyleIndex == index;
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedStyleIndex = index),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF4A90E2)
                                        : Colors
                                              .transparent, // Blue for selected
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _styles[index],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Product Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(
                      (0.3 * 255).round(),
                    ), // Glass effect
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withAlpha((0.2 * 255).round()),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Thumbnail
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE0C2), // Light peach bg
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.check_box_outline_blank,
                          color: Colors.white,
                        ), // Placeholder for frame thumbnail
                      ),
                      const SizedBox(width: 16),
                      // Info
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "L'Artiste - Bleu Minuit",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "Monture acétate haute qualité",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Price
                      const Text(
                        "129€",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Bottom Buttons
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Row(
                    children: [
                      // Camera Button
                      Expanded(
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha((0.15 * 255).round()),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 28,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Prendre une photo",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Scan Button
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ScannerOrdonnancePage(),
                              ),
                            );
                          },
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4A90E2), // Bright Blue
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.qr_code_scanner,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Scanner Ordonnance",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Moon/Theme Toggle (Bottom Right Corner Overlay)
                // Actually the design implementation places it slightly differently but for now let's skip or place absolutely.
              ],
            ),
          ),

          // Theme Toggle Floating
          Positioned(
            bottom: 24,
            right: 24,
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.nightlight_round, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}

// Painters for the AR Guide

class GlassesGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3F3F95)
          .withAlpha((0.8 * 255).round()) // Dark blueish purple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final path = Path();

    // Draw infinity shape / glasses shape simplified
    // Left Lens
    path.addOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.3, size.height / 2),
        width: size.width * 0.35,
        height: size.height * 0.6,
      ),
    );

    // Right Lens
    path.addOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.7, size.height / 2),
        width: size.width * 0.35,
        height: size.height * 0.6,
      ),
    );

    // Bridge (Simplified)
    path.moveTo(size.width * 0.47, size.height / 2);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.4,
      size.width * 0.53,
      size.height / 2,
    );

    canvas.drawPath(path, paint);

    // Fill slightly
    final fillPaint = Paint()
      ..color = Colors.white.withAlpha((0.1 * 255).round())
      ..style = PaintingStyle.fill;

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
