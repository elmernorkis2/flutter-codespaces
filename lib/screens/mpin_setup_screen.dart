import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import '../secure_storage_service.dart'; // adjust path if needed

class MPINSetupScreen extends StatefulWidget {
  MPINSetupScreen({super.key});

  @override
  State<MPINSetupScreen> createState() => _MPINSetupScreenState();
}

class _MPINSetupScreenState extends State<MPINSetupScreen> {
  final TextEditingController mpinController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  void saveMPIN() async {
    final mpin = mpinController.text;
    final confirm = confirmController.text;

    if (mpin.length != 4 || confirm.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('MPIN must be 4 digits')),
      );
      return;
    }

    if (mpin != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('MPINs do not match')),
      );
      return;
    }

    await SecureStorageService.saveMPIN(mpin);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DashboardScreen(
          initialBalance: 1000.00,
          initialTransactions: [],
        ),
      ),
    );
  }

  @override
  void dispose() {
    mpinController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Your MPIN')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text('Enter 4-digit MPIN', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            TextField(
              controller: mpinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '••••',
              ),
            ),
            const SizedBox(height: 20),
            const Text('Confirm MPIN', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            TextField(
              controller: confirmController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '••••',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveMPIN,
              child: const Text('Save MPIN'),
            ),
          ],
        ),
      ),
    );
  }
}
