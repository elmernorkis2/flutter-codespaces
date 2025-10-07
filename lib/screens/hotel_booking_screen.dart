import 'package:flutter/material.dart';
import 'booking_summary_screen.dart'; // 👈 Make sure this file exists in your screens folder

class HotelBookingScreen extends StatefulWidget {
  final Map<String, dynamic> hotel;

  const HotelBookingScreen({super.key, required this.hotel});

  @override
  State<HotelBookingScreen> createState() => _HotelBookingScreenState();
}

class _HotelBookingScreenState extends State<HotelBookingScreen> {
  DateTime? checkInDate;
  DateTime? checkOutDate;
  int guestCount = 1;

  Future<void> selectDate({required bool isCheckIn}) async {
    final initialDate = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: initialDate,
      lastDate: initialDate.add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          checkInDate = picked;
          if (checkOutDate != null && checkOutDate!.isBefore(picked)) {
            checkOutDate = null;
          }
        } else {
          checkOutDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hotel = widget.hotel;

    return Scaffold(
      appBar: AppBar(title: const Text('Booking')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🧳 Booking Screen Active',
                style: const TextStyle(fontSize: 18, color: Colors.green)),
            const SizedBox(height: 12),
            Text(hotel['name'],
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('${hotel['location']} • ${hotel['town']}'),
            Text(hotel['tag'], style: const TextStyle(color: Colors.blueGrey)),
            const SizedBox(height: 8),
            Text('Price: ${hotel['price']}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            const Text('🗓️ Select your stay dates:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => selectDate(isCheckIn: true),
                  label: Text(checkInDate == null
                      ? 'Select Check-in Date'
                      : 'Check-in: ${checkInDate!.toLocal().toString().split(' ')[0]}'),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: checkInDate == null
                      ? null
                      : () => selectDate(isCheckIn: false),
                  label: Text(checkOutDate == null
                      ? 'Select Check-out Date'
                      : 'Check-out: ${checkOutDate!.toLocal().toString().split(' ')[0]}'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('👥 Number of Guests:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButton<int>(
              value: guestCount,
              items: List.generate(5, (index) {
                final count = index + 1;
                return DropdownMenuItem<int>(
                  value: count,
                  child: Text('$count guest${count > 1 ? 's' : ''}'),
                );
              }),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    guestCount = value;
                  });
                }
              },
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: checkInDate != null && checkOutDate != null
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingSummaryScreen(
                            hotel: hotel,
                            checkInDate: checkInDate!,
                            checkOutDate: checkOutDate!,
                            guestCount: guestCount,
                          ),
                        ),
                      );
                    }
                  : null,
              child: const Text('Confirm Booking'),
            ),
          ],
        ),
      ),
    );
  }
}
