class PaymentService {
  Future<Map<String, dynamic>> processMockPayment({
    required double amount,
    required String currency,
    required String methodId,
  }) async {
    // Simuler un délai de transaction
    await Future.delayed(const Duration(seconds: 2));

    // Simuler un succès à 95%
    bool success = DateTime.now().millisecond % 100 < 95;

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
