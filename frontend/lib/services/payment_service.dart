class PaymentService {
  Future<Map<String, dynamic>> processMockPayment({
    required double amount,
    required String currency,
    required String methodId,
  }) async {
    // Simuler un délai de transaction
    await Future.delayed(const Duration(seconds: 2));

    // Simuler un succès à 95%
    bool success = true; // Pour les tests, on met true par défaut

    if (success) {
      return {
        'success': true,
        'transactionId': 'TXN-${DateTime.now().millisecondsSinceEpoch}',
        'message': 'Paiement effectué avec succès',
      };
    } else {
      return {
        'success': false,
        'error': 'Solde insuffisant ou carte rejetée',
      };
    }
  }
}
