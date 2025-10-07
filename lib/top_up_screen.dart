import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TopUpScreen extends StatefulWidget {
  final double currentBalance;
  final Function(double, Map<String, String>) onTransactionComplete;

  const TopUpScreen({
    required this.currentBalance,
    required this.onTransactionComplete,
    Key? key,
  }) : super(key: key);

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  String selectedProvider = 'GCash';
  String selectedAmount = '100';

  final List<String> providers = [
    'AUB',
    'Bank of Commerce',
    'BDO',
    'BPI',
    'China Bank',
    'Coins.ph',
    'EastWest Bank',
    'GCash',
    'GrabPay',
    'Landbank',
    'Metrobank',
    'Maya',
    'PNB',
    'PSBank',
    'PayPal',
    'RCBC',
    'Robinsons Bank',
    'Security Bank',
    'ShopeePay',
    'UCPB',
    'UnionBank',
  ];

  final List<String> amounts = [
    '50',
    '100',
    '200',
    '500',
    '1000',
    '2000',
  ];

  @override
  void initState() {
    super.initState();
    providers.sort();
  }

  Future<void> _confirmTopUp() async {
    final amount = double.tryParse(selectedAmount);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a valid amount')),
      );
      return;
    }

    final newBalance = widget.currentBalance + amount;

    final transaction = {
      'type': 'Top-Up via $selectedProvider',
      'amount': '₱${amount.toStringAsFixed(2)}',
      'timestamp': DateTime.now().toIso8601String(),
    };

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('walletBalance', newBalance);

    List<String> history = prefs.getStringList('transactionHistory') ?? [];
    history.insert(0, jsonEncode(transaction));
    await prefs.setStringList('transactionHistory', history);

    widget.onTransactionComplete(newBalance, transaction);

    Navigator.pop(context, transaction); // ✅ Return transaction to parent
  }

  Widget buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
    double width = 180,
    String prefix = '',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13)),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue, width: 1.5),
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          constraints: BoxConstraints(maxWidth: width),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down, size: 20),
            style: const TextStyle(fontSize: 13, color: Colors.black),
            dropdownColor: Colors.white,
            menuMaxHeight: 500,
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    '$prefix$item',
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Top-Up Balance')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildDropdown(
              label: 'Select Provider',
              value: selectedProvider,
              items: providers,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedProvider = value;
                  });
                }
              },
              width: 200,
            ),
            const SizedBox(height: 16),
            buildDropdown(
              label: 'Amount to Top-Up',
              value: selectedAmount,
              items: amounts,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedAmount = value;
                  });
                }
              },
              width: 120,
              prefix: '₱',
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _confirmTopUp,
              child: const Text('Top-Up', style: TextStyle(fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }
}
