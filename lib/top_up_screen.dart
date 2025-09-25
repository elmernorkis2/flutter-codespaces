import 'package:flutter/material.dart';

class TopUpScreen extends StatefulWidget {
  final double currentBalance;
  final Function(double, Map<String, String>) onTransactionComplete;

  const TopUpScreen({
    super.key,
    required this.currentBalance,
    required this.onTransactionComplete,
  });

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  final TextEditingController amountController = TextEditingController();

  void _topUp() {
    final amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount')),
      );
      return;
    }

    final newBalance = widget.currentBalance + amount;
    final transaction = {
      'type': 'Top-Up',
      'amount': '+₱${amount.toStringAsFixed(2)}',
      'timestamp': DateTime.now().toIso8601String(),
    };

    widget.onTransactionComplete(newBalance, transaction);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Top-Up Balance')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Amount to Top-Up',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _topUp,
              child: const Text('Top-Up'),
            ),
          ],
        ),
      ),
    );
  }
}
