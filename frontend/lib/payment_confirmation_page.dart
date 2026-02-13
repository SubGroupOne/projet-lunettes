import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'services/cart.dart';
import 'services/payment_service.dart';
import 'order_tracking_page.dart';

enum PaymentMethod { card, mobileMoney, cod }

class PaymentConfirmationPage extends StatefulWidget {
  final double totalAmount;
  final String accessToken;

  const PaymentConfirmationPage({
    super.key,
    required this.totalAmount,
    required this.accessToken,
  });

  @override
  State<PaymentConfirmationPage> createState() => _PaymentConfirmationPageState();
}

class _PaymentConfirmationPageState extends State<PaymentConfirmationPage> {
  PaymentMethod _paymentMethod = PaymentMethod.card;
  bool _isLoading = false;
  
  // Controllers
  final _addressController = TextEditingController();
  final _insuranceController = TextEditingController();
  final _policyController = TextEditingController();
  
  // Card details
  final _cardNumberController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCvvController = TextEditingController();
  
  // Mobile Money
  final _phoneController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // Validation Assurance
  bool _isInsuranceValid = false;
  double _coverageRate = 0.0;
  String? _insuranceMessage;
  bool _checkingInsurance = false;

  Future<void> _checkInsurance() async {
    final insuranceId = _insuranceController.text;
    if (insuranceId.isEmpty) return;

    setState(() {
      _checkingInsurance = true;
      _insuranceMessage = null;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));
      if (insuranceId.startsWith('MUT') || insuranceId.length > 3) {
        setState(() {
          _isInsuranceValid = true;
          _coverageRate = 0.70;
          _insuranceMessage = "Assurance valide: Couverture 70%";
        });
      } else {
        setState(() {
          _isInsuranceValid = false;
          _coverageRate = 0.0;
          _insuranceMessage = "Assurance non reconnue";
        });
      }
    } catch (e) {
      setState(() => _insuranceMessage = "Erreur vérification: $e");
    } finally {
      setState(() => _checkingInsurance = false);
    }
  }

  Future<void> _processOrder() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs obligatoires')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cart = Provider.of<Cart>(context, listen: false);
      final items = cart.items;

      if (_paymentMethod != PaymentMethod.cod) {
        final paymentSuccess = await PaymentService().processMockPayment(
          amount: widget.totalAmount * (1 - _coverageRate),
          currency: 'XOF',
          methodId: _paymentMethod.toString(),
        );

        if (!paymentSuccess['success']) {
          throw Exception('Paiement refusé');
        }
      }

      final orderData = {
        'frameId': items.isNotEmpty ? items.first.id : null,
        'frameName': items.isNotEmpty ? items.first.title : null,
        'prescriptionData': {},
        'insuranceData': {
          'company': _insuranceController.text,
          'policy': _policyController.text,
          'coverage': _coverageRate,
        },
        'shippingAddress': _addressController.text,
        'paymentMethod': _paymentMethod.toString(),
        'totalPrice': widget.totalAmount,
      };

      final response = await http.post(
        Uri.parse('http://localhost:3000/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.accessToken}',
        },
        body: json.encode(orderData),
      );

      if (response.statusCode == 201) {
        cart.clear();
        _showSuccessDialog();
      } else {
        throw Exception('Erreur serveur (${response.statusCode})');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Commande Validée ! 🎉', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: const Text('Votre commande a été enregistrée. Vous pouvez suivre son état dans votre profil.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OrderTrackingPage(accessToken: widget.accessToken)),
              );
            },
            child: const Text('Suivre ma commande'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final finalAmount = widget.totalAmount * (1 - _coverageRate);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Confirmation', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF0F172A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCard(finalAmount),
              const SizedBox(height: 32),
              
              Text('ADRESSE DE LIVRAISON', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A), letterSpacing: 1.5)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  hintText: 'Ex: Rue 12.04, Porte 123, Ouagadougou',
                  prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'L\'adresse est obligatoire pour la livraison' : null,
              ),
              const SizedBox(height: 32),

              Text('ASSURANCE (FACULTATIF)', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A), letterSpacing: 1.5)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _insuranceController,
                      decoration: InputDecoration(
                        hintText: 'Nom Mutuelle',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _checkingInsurance ? null : _checkInsurance,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16)),
                    child: _checkingInsurance ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Vérifier'),
                  ),
                ],
              ),
              if (_insuranceMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 4),
                  child: Text(_insuranceMessage!, style: GoogleFonts.inter(fontSize: 11, color: _isInsuranceValid ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                ),
              const SizedBox(height: 32),

              Text('MODE DE PAIEMENT', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A), letterSpacing: 1.5)),
              const SizedBox(height: 12),
              _buildPaymentSelector(),
              
              const SizedBox(height: 24),
              _buildConditionalFields(),

              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _processOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('CONFIRMER LE PAIEMENT', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(double finalAmount) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Commande', style: GoogleFonts.inter(color: Colors.white60, fontSize: 13)),
              Text('${widget.totalAmount.toStringAsFixed(0)} F', style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          if (_isInsuranceValid) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Couverture Assurance', style: GoogleFonts.inter(color: Colors.greenAccent, fontSize: 13)),
                Text('-${(widget.totalAmount * _coverageRate).toStringAsFixed(0)} F', style: GoogleFonts.outfit(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Colors.white10)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('NET À PAYER', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Text('${finalAmount.toStringAsFixed(0)} F', style: GoogleFonts.outfit(color: const Color(0xFF6366F1), fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSelector() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          _buildPaymentTile(PaymentMethod.card, 'Carte Bancaire', Icons.credit_card_rounded),
          const Divider(height: 1, indent: 64),
          _buildPaymentTile(PaymentMethod.mobileMoney, 'Mobile Money', Icons.phone_android_rounded),
          const Divider(height: 1, indent: 64),
          _buildPaymentTile(PaymentMethod.cod, 'Paiement à la livraison', Icons.local_shipping_outlined),
        ],
      ),
    );
  }

  Widget _buildPaymentTile(PaymentMethod method, String title, IconData icon) {
    bool isSelected = _paymentMethod == method;
    return InkWell(
      onTap: () => setState(() => _paymentMethod = method),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: isSelected ? const Color(0xFF6366F1).withValues(alpha: 0.1) : const Color(0xFFF1F5F9), shape: BoxShape.circle), child: Icon(icon, color: isSelected ? const Color(0xFF6366F1) : Colors.grey, size: 20)),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: GoogleFonts.inter(fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, fontSize: 14))),
            if (isSelected) const Icon(Icons.check_circle_rounded, color: Color(0xFF6366F1), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionalFields() {
    if (_paymentMethod == PaymentMethod.cod) return const SizedBox.shrink();

    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.2))),
        child: Column(
          children: [
            if (_paymentMethod == PaymentMethod.card) ...[
              _buildInputLabel('Numéro de carte'),
              _buildSquareField(_cardNumberController, '0000 0000 0000 0000', Icons.credit_card, true),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildInputLabel('Expiration'), _buildSquareField(_cardExpiryController, 'MM/YY', Icons.calendar_today, false)])),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildInputLabel('CVV'), _buildSquareField(_cardCvvController, '123', Icons.lock_outline, false)])),
                ],
              ),
            ],
            if (_paymentMethod == PaymentMethod.mobileMoney) ...[
              _buildInputLabel('Numéro de téléphone'),
              _buildSquareField(_phoneController, '+226 XX XX XX XX', Icons.phone_android, true),
              const SizedBox(height: 8),
              Text('Un message de confirmation sera envoyé à ce numéro.', style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[600])));
  }

  Widget _buildSquareField(TextEditingController controller, String hint, IconData icon, bool required) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.grey[400]),
        prefixIcon: Icon(icon, size: 18),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      validator: (v) => (required && (v == null || v.isEmpty)) ? 'Requis' : null,
    );
  }
}
