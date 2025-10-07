import 'package:flutter/material.dart';

class PaymentScreen extends StatelessWidget {
  final int totalPrice;

  const PaymentScreen({super.key, required this.totalPrice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Total: ₱$totalPrice', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(labelText: 'Card Number'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Cardholder Name'),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Expiry Date'),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'CVV'),
              obscureText: true,
              keyboardType: TextInputType.number,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment successful!')),
                );
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('Pay Now'),
            ),
          ],
        ),
      ),
    );
  }
}
