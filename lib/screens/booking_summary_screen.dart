import 'package:flutter/material.dart';
import 'payment_screen.dart'; // 👈 Add this import

class BookingSummaryScreen extends StatelessWidget {
  final Map<String, dynamic> hotel;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int guestCount;

  const BookingSummaryScreen({
    super.key,
    required this.hotel,
    required this.checkInDate,
    required this.checkOutDate,
    required this.guestCount,
  });

  @override
  Widget build(BuildContext context) {
    final nights = checkOutDate.difference(checkInDate).inDays;
    final pricePerNight =
        int.tryParse(hotel['price'].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final totalPrice = pricePerNight * nights;

    return Scaffold(
      appBar: AppBar(title: const Text('Booking Summary')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(hotel['name'],
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('${hotel['location']} • ${hotel['town']}'),
            const SizedBox(height: 12),
            Text('Check-in: ${checkInDate.toLocal().toString().split(' ')[0]}'),
            Text(
                'Check-out: ${checkOutDate.toLocal().toString().split(' ')[0]}'),
            Text('Guests: $guestCount'),
            const SizedBox(height: 12),
            Text('Total Price: ₱$totalPrice',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentScreen(totalPrice: totalPrice),
                  ),
                );
              },
              child: const Text('Proceed to Payment'),
            ),
          ],
        ),
      ),
    );
  }
}
