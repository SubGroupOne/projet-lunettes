import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InsuranceSimulationScreen extends StatefulWidget {
  const InsuranceSimulationScreen({Key? key}) : super(key: key);

  @override
  State<InsuranceSimulationScreen> createState() => _InsuranceSimulationScreenState();
}

class _InsuranceSimulationScreenState extends State<InsuranceSimulationScreen> {
  final _amountController = TextEditingController(text: "195");
  String? _selectedInsurance;
  Map<String, dynamic>? _result;
  bool _isLoading = false;

  final List<String> _insurances = [
    'Harmonie Mutuelle',
    'MGEN Excellence',
    'AXA Santé Premium',
    'Alan Green',
    'Malakoff Humanis'
  ];

  void _simulate() async {
    setState(() => _isLoading = true);
    // Simulation d'un appel API pour le design avec un delay réaliste
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        double total = double.tryParse(_amountController.text) ?? 195;
        double covered = total * 0.72; // Simulation d'un taux de couverture
        _result = {
          'totalPrice': total,
          'amountCovered': covered,
          'finalPrice': total - covered,
          'rate': '72%',
        };
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text("Simulation Assurance", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 32),
            _buildInputSection(),
            const SizedBox(height: 40),
            if (_isLoading) 
              _buildLoadingState()
            else if (_result != null)
              _buildModernResultCard()
            else
              _buildStepInstructions(),
            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomSheet: _buildStickyAction(),
    );
  }

  Widget _buildInfoCard() {
    return FadeInDown(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF6366F1).withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.1)),
        ),
        child: Row(
          children: [
            const Icon(Icons.verified_user_rounded, color: Color(0xFF6366F1), size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Tiers-Payant Digital", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("Calculez instantanément votre prise en charge par votre mutuelle.", 
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600], height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Column(
      children: [
        _buildTextField("Prix de la monture estimé (€)", _amountController, Icons.euro_symbol_rounded),
        const SizedBox(height: 20),
        _buildDropdownField("Votre organisme de santé", _insurances),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        children: [
          const CircularProgressIndicator(color: Color(0xFF6366F1)),
          const SizedBox(height: 16),
          Text("Calcul du taux de couverture...", style: GoogleFonts.inter(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildModernResultCard() {
    return FadeInUp(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.1), blurRadius: 30, offset: const Offset(0, 15)),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBriefItem("Total Brut", "${_result!['totalPrice']}€"),
                _buildBriefItem("Taux", "${_result!['rate']}"),
              ],
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Divider(color: Colors.white12)),
            _buildResultDetail("Remboursement Mutuelle", "- ${_result!['amountCovered'].toStringAsFixed(2)}€", const Color(0xFF10B981)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("RESTE À CHARGE", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white60, letterSpacing: 1)),
                  Text("${_result!['finalPrice'].toStringAsFixed(2)}€", 
                    style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBriefItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.white60, fontWeight: FontWeight.bold)),
        Text(value, style: GoogleFonts.outfit(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildResultDetail(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 14, color: Colors.white70)),
        Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(icon, color: const Color(0xFF0F172A), size: 20),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.black12)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: _selectedInsurance,
          onChanged: (v) => setState(() => _selectedInsurance = v),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.inter()))).toList(),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.black12)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2)),
          ),
          hint: Text("Choisir mon organisme", style: GoogleFonts.inter(fontSize: 14, color: Colors.grey)),
        ),
      ],
    );
  }

  Widget _buildStepInstructions() {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.black12),
          const SizedBox(height: 12),
          Text("Entrez les montants ci-dessus pour simuler.", 
            style: GoogleFonts.inter(color: Colors.grey[400], fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildStickyAction() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 64,
        child: ElevatedButton(
          onPressed: _simulate,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F172A),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: Text("CALCULER MA PRISE EN CHARGE", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1)),
        ),
      ),
    );
  }
}
