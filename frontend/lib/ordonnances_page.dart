import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/prescription_scan_screen.dart';

class OrdonnancesPage extends StatelessWidget {
  final String accessToken;
  const OrdonnancesPage({super.key, required this.accessToken});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Mes Ordonnances', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
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
                decoration: BoxDecoration(color: const Color(0xFF6366F1).withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.assignment_rounded, size: 64, color: Color(0xFF6366F1)),
              ),
              const SizedBox(height: 24),
              Text('Mes Ordonnances', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text('Scannez votre ordonnance pour la sauvegarder.', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600])),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrescriptionScanScreen())),
                  icon: const Icon(Icons.document_scanner_rounded),
                  label: Text('Scanner une ordonnance', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
