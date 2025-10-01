import 'package:flutter/material.dart';
import 'hotels_screen.dart'; // ✅ Make sure this exists

class TravelBookingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Travel & Booking'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Hotels'),
              Tab(text: 'Flights'), // You can add more tabs later
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            HotelsScreen(), // ✅ This shows your Airbnb-style layout
            Center(child: Text('Flights tab coming soon')), // Placeholder
          ],
        ),
      ),
    );
  }
}
