class Transaction {
  final String type;
  final double amount;
  final String provider;
  final DateTime timestamp;

  Transaction({
    required this.type,
    required this.amount,
    required this.provider,
    required this.timestamp,
  });
}
