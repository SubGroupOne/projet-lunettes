import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'services/cart.dart';
import 'services/payment_service.dart';
import 'profile_page.dart';  // Pour redirection
import 'order_tracking_page.dart';

enum PaymentMethod { card, mobileMoney, cod }

class PaymentConfirmationPage extends StatefulWidget {
  final double totalAmount;
  final String accessToken;

  const PaymentConfirmationPage({
    Key? key,
    required this.totalAmount,
    required this.accessToken,
  }) : super(key: key);

  @override
  State<PaymentConfirmationPage> createState() => _PaymentConfirmationPageState();
}

class _PaymentConfirmationPageState extends State<PaymentConfirmationPage> {
  PaymentMethod _paymentMethod = PaymentMethod.card;
  bool _isLoading = false;
  final _addressController = TextEditingController();
  final _insuranceController = TextEditingController();
  final _policyController = TextEditingController();
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
      // Appel API simulé ou réel vers backend
      // TODO: Remplacer par vrai endpoint GET /insurances/:id ou validation
      // Ici on simule une réponse backend pour la démo instantanée
      await Future.delayed(const Duration(seconds: 1));
      
      // Logique simple pour démo: si commence par "MUT", valide
      if (insuranceId.startsWith('MUT') || insuranceId.length > 3) {
        setState(() {
          _isInsuranceValid = true;
          _coverageRate = 0.70; // 70%
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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final cart = Provider.of<Cart>(context, listen: false);
      final items = cart.items;

      // 1. Simuler paiement si Carte ou Mobile
      if (_paymentMethod != PaymentMethod.cod) {
        final paymentSuccess = await PaymentService().processMockPayment(
          amount: widget.totalAmount * (1 - _coverageRate),
          currency: 'EUR',
          methodId: _paymentMethod.toString(),
        );

        if (!paymentSuccess['success']) {
          throw Exception('Paiement refusé');
        }
      }

      // 2. Créer commande Backend
      final orderData = {
        'frameId': items.first.id,
        'prescriptionData': {}, // TODO: Passer infos OCR
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
        cart.clear(); // Vider panier
        
        // Succès
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Commande Confirmée 🎉'),
            content: const Text('Votre commande a été validée avec succès !'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Close payment page
                  // Rediriger vers suivi commande
                   Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderTrackingPage(
                        accessToken: widget.accessToken,
                      ),
                    ),
                  );
                },
                child: const Text('Suivre ma commande'),
              ),
            ],
          ),
        );
      } else {
        throw Exception('Erreur backend: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final finalAmount = widget.totalAmount * (1 - _coverageRate);

    return Scaffold(
      appBar: AppBar(title: const Text('Paiement')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Récap
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Commande'),
                          Text('${widget.totalAmount.toStringAsFixed(2)} €', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      if (_isInsuranceValid) ...[
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Couverture Assurance', style: TextStyle(color: Colors.green)),
                            Text('-${(widget.totalAmount * _coverageRate).toStringAsFixed(2)} €', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Reste à payer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('${finalAmount.toStringAsFixed(2)} €', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Adresse
              const Text('Livraison', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Adresse complète',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 20),

              // Assurance
              const Text('Assurance Santé (Optionnel)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _insuranceController,
                      decoration: const InputDecoration(
                        labelText: 'Nom Compagnie / Mutuelle',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.health_and_safety),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _checkingInsurance ? null : _checkInsurance,
                    child: _checkingInsurance ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Vérifier'),
                  ),
                ],
              ),
              if (_insuranceMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    _insuranceMessage!,
                    style: TextStyle(
                      color: _isInsuranceValid ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              if (_isInsuranceValid)
                TextFormField(
                  controller: _policyController,
                  decoration: const InputDecoration(
                    labelText: 'Numéro de Police / Adhérent',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.isEmpty ? 'Requis pour validation' : null,
                ),
              const SizedBox(height: 20),

              // Paiement
              const Text('Mode de Paiement', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Column(
                children: PaymentMethod.values.map((method) {
                  return RadioListTile<PaymentMethod>(
                    title: Text(method == PaymentMethod.card ? 'Carte Bancaire' : method == PaymentMethod.mobileMoney ? 'Mobile Money' : 'Paiement à la livraison'),
                    value: method,
                    groupValue: _paymentMethod,
                    onChanged: (PaymentMethod? value) {
                      setState(() {
                        _paymentMethod = value!;
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 30),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _processOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'PAYER ${finalAmount.toStringAsFixed(2)} €',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
