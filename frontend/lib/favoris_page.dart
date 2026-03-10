import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FavorisPage extends StatelessWidget {
  final String accessToken;
  const FavorisPage({super.key, required this.accessToken});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Mes Favoris', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF0F172A),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: const Color(0xFFEF4444).withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.favorite_rounded, size: 64, color: Color(0xFFEF4444)),
              ),
              const SizedBox(height: 24),
              Text('Mes Favoris', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text('Ajoutez des favoris depuis le catalogue.', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600])),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                child: Row(children: [const Icon(Icons.info_outline, color: Colors.grey), const SizedBox(width: 12), Text('Aucun favori pour le moment.', style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]))]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
