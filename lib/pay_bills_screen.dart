import 'package:flutter/material.dart';

class PayBillsScreen extends StatefulWidget {
  final double currentBalance;
  final Function(double, Map<String, String>) onTransactionComplete;

  const PayBillsScreen({
    super.key,
    required this.currentBalance,
    required this.onTransactionComplete,
  });

  @override
  State<PayBillsScreen> createState() => _PayBillsScreenState();
}

class _PayBillsScreenState extends State<PayBillsScreen> {
  final TextEditingController amountController = TextEditingController();
  String? selectedBiller;

  final List<String> billers = [
    'Meralco',
    'Maynilad',
    'Globe Telecom',
    'Smart Communications',
    'PLDT Home',
    'Manila Water',
    'PhilHealth',
    'SSS',
    'Pag-IBIG Fund',
    'GSIS',
    'BDO',
    'BPI',
    'Metrobank',
    'Landbank',
    'UnionBank',
    'RCBC',
    'Security Bank',
    'PNB',
    'EastWest Bank',
    'Tonik',
  ];

  void _payBill() {
    final transaction = PaymentService.createBillPaymentTransaction(
      selectedBiller: selectedBiller,
      amountText: amountController.text,
      currentBalance: widget.currentBalance,
    );

    if (transaction == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid input or insufficient balance')),
      );
      return;
    }

    final newBalance =
        widget.currentBalance - double.parse(amountController.text);
    widget.onTransactionComplete(newBalance, transaction);
    Navigator.pop(context);

    widget.onTransactionComplete(newBalance, transaction);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pay Bills')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: selectedBiller,
              items: billers
                  .map((biller) => DropdownMenuItem(
                        value: biller,
                        child: Text(biller),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => selectedBiller = value),
              decoration: const InputDecoration(
                labelText: 'Select Biller',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Amount to Pay',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _payBill,
              child: const Text('Pay'),
            ),
          ],
        ),
      ),
    );
  }
}
