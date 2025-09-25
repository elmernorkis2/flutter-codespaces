import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoLiveScreen extends StatelessWidget {
  const GoLiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Go Live')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Ready to go live?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance.collection('live_users').add({
                  'name': 'StreamerOne', // Replace with actual user name
                  'thumbnailUrl':
                      'https://via.placeholder.com/150', // Replace with real image
                  'viewers': 0,
                });

                Navigator.pop(context); // Return to main screen
              },
              child: const Text('Start Streaming'),
            ),
          ],
        ),
      ),
    );
  }
}
