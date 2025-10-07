import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HostHotelForm extends StatefulWidget {
  const HostHotelForm({super.key});

  @override
  State<HostHotelForm> createState() => _HostHotelFormState();
}

class _HostHotelFormState extends State<HostHotelForm> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  double latitude = 13.7563; // Default Bangkok
  double longitude = 100.5018;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Host Your Hotel')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Hotel Name'),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Price per Night'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            Text('Pin Your Property Location'),
            SizedBox(
              height: 300,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(latitude, longitude),
                  initialZoom: 14,
                  onTap: (tapPosition, point) {
                    setState(() {
                      latitude = point.latitude;
                      longitude = point.longitude;
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.phcash.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(latitude, longitude),
                        child: const Icon(Icons.location_pin,
                            color: Colors.red, size: 40),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Save to Firestore
                print('Hotel: ${nameController.text}');
                print('Price: ${priceController.text}');
                print('LatLng: $latitude, $longitude');
              },
              child: const Text('Publish Listing'),
            ),
          ],
        ),
      ),
    );
  }
}
