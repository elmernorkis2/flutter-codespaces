import 'package:flutter/material.dart';
import 'hotel_booking_screen.dart';
import 'hotel_map_view.dart';

class HotelDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> hotel;

  const HotelDetailsScreen({super.key, required this.hotel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(hotel['name'])),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1️⃣ Hotel Image
          Image.network(
            hotel['image'],
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),

          // 2️⃣ Hotel Info Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2.1 Location
                Text(hotel['location'],
                    style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),

                // 2.2 Rating
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text('${hotel['rating']}'),
                  ],
                ),
                const SizedBox(height: 12),

                // 2.3 Price
                Text(
                  hotel['price'],
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // 3️⃣ Book Now Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HotelBookingScreen(hotel: hotel),
                      ),
                    );
                  },
                  child: const Text('Book Now'),
                ),

                const SizedBox(height: 12),

                // 4️⃣ View on Map Button
                ElevatedButton.icon(
                  icon: const Icon(Icons.map),
                  label: const Text('View on Map'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HotelMapView(
                          hotelName: hotel['name'],
                          latitude: hotel['latitude'],
                          longitude: hotel['longitude'],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
