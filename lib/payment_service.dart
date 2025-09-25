// lib/services/payment_service.dart

class PaymentService {
  /// Validates bill payment input and returns a transaction map if valid.
  static Map<String, String>? createBillPaymentTransaction({
    required String? selectedBiller,
    required String amountText,
    required double currentBalance,
  }) {
    final amount = double.tryParse(amountText);
    if (selectedBiller == null || amount == null || amount <= 0 || amount > currentBalance) {
      return null;
    }

    return {
      'type': 'Pay Bills - $selectedBiller',
      'amount': '-₱${amount.toStringAsFixed(2)}',
      'date': DateTime.now().toIso8601String(), // You can format this later
    };
  }
}
